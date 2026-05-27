#!/usr/bin/env python3
"""Click EVERY sidebar item in BOTH apps and screenshot each.

Output: integration_test/_compare/<NN>-<slug>__{vue,flutter}.png
Plus a side-by-side comparison HTML at integration_test/_compare/index.html.
"""
from __future__ import annotations

import os
import sys
import time

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

VUE_BASE = "http://localhost:9001/index.html#"
FL_BASE = "http://localhost:8765/#"
DRIVER_PATH = os.path.expanduser("~/.local/bin/chromedriver147")
OUT = os.path.join(os.path.dirname(__file__), "_compare")
os.makedirs(OUT, exist_ok=True)


# (slug, vue-hash, flutter-hash, description)
PAGES = [
    ("00-login", "/login", "/login", "登录页"),
    ("01-dashboard", "/dashboard", "/dashboard", "Dashboard"),
    ("02-introduction", "/introduction", "/introduction", "介绍"),

    # component 组件 (14)
    ("03-comp-buttons", "/components/buttons", "/components/buttons", "Buttons按钮"),
    ("04-comp-hoverbtn", "/components/hoverbuttons", "/components/hoverbuttons", "悬停特效按钮"),
    ("05-comp-alert", "/components/alert", "/components/alert", "Alert警告提示"),
    ("06-comp-card", "/components/card", "/components/card", "Card卡片"),
    ("07-comp-datepicker", "/components/datepicker", "/components/datepicker", "DatePicker"),
    ("08-comp-form", "/components/form", "/components/form", "Form表单"),
    ("09-comp-modal", "/components/modal", "/components/modal", "Modal对话框"),
    ("10-comp-select", "/components/select", "/components/select", "Select选择器"),
    ("11-comp-spin", "/components/spin", "/components/spin", "Spin加载中"),
    ("12-comp-steps", "/components/steps", "/components/steps", "Steps步骤条"),
    ("13-comp-timeline", "/components/timeline", "/components/timeline", "Timeline时间轴"),
    ("14-comp-transfer", "/components/transfer", "/components/transfer", "Transfer穿梭框"),
    ("15-comp-timepicker", "/components/timepicker", "/components/timepicker", "Timepicker"),
    ("16-comp-upload", "/components/upload", "/components/upload", "Upload上传"),

    # charts (3)
    ("17-charts-shop", "/charts/shopchart", "/charts/shopchart", "商场统计图表"),
    ("18-charts-radar", "/charts/radarchart", "/charts/radarchart", "雷达图"),
    ("19-charts-cake", "/charts/cakechart", "/charts/cakechart", "蛋糕销量图表"),

    ("20-table", "/table", "/table", "表格综合实例"),
    ("21-json", "/jsontree", "/jsontree", "JSON视图"),
    ("22-markdown", "/markdown", "/markdown", "Markdown"),
    ("23-404", "/no-such-page", "/no-such-page", "404 错误页"),
]


def make_driver() -> webdriver.Chrome:
    opts = Options()
    opts.add_argument("--window-size=1440,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--force-renderer-accessibility")
    opts.set_capability("pageLoadStrategy", "eager")
    driver = webdriver.Chrome(service=Service(DRIVER_PATH), options=opts)
    driver.set_page_load_timeout(60)
    return driver


def login_vue(driver: webdriver.Chrome) -> None:
    driver.get(VUE_BASE + "/login")
    time.sleep(3.0)
    driver.execute_script(
        """
        const inputs = document.querySelectorAll('input.ivu-input');
        if (inputs.length >= 2) {
          const set = (el, val) => {
            const setter = Object.getOwnPropertyDescriptor(
              window.HTMLInputElement.prototype, 'value'
            ).set;
            setter.call(el, val);
            el.dispatchEvent(new Event('input', { bubbles: true }));
          };
          set(inputs[0], 'admin@wz.com');
          set(inputs[1], '123456');
        }
        """
    )
    time.sleep(0.5)
    btns = driver.find_elements("xpath", "//button[contains(., '登录')]")
    if btns:
        btns[0].click()
    time.sleep(4.0)
    if "/login" in driver.current_url:
        driver.add_cookie({"name": "Admin-Token", "value": "admin", "path": "/"})
        driver.get(VUE_BASE + "/dashboard")
        time.sleep(3.0)


def login_flutter(driver: webdriver.Chrome) -> None:
    driver.get(FL_BASE + "/login")
    # CanvasKit cold-start takes ~20s. Wait for flutter-view to mount first.
    end = time.time() + 45
    while time.time() < end:
        if driver.execute_script(
            "return !!document.querySelector('flutter-view, flt-glass-pane')"
        ):
            break
        time.sleep(0.5)
    time.sleep(3.0)
    p = driver.execute_script(
        "return document.querySelector('flt-semantics-placeholder')"
    )
    if p:
        driver.execute_script("arguments[0].click()", p)
        time.sleep(2.0)
    # Wait for the 登录 button to actually exist in semantics
    btn = None
    end = time.time() + 20
    while time.time() < end:
        btn = driver.execute_script(
            """
            const nodes = document.querySelectorAll('flt-semantics[role="button"]');
            for (const n of nodes) {
              if (n.textContent.includes('登录')) return n;
            }
            return null;
            """
        )
        if btn is not None:
            break
        time.sleep(0.5)
    if btn:
        driver.execute_script(
            """
            const el = arguments[0];
            const r = el.getBoundingClientRect();
            const x = r.left + r.width/2, y = r.top + r.height/2;
            const mk = (t) => new PointerEvent(t, {
              pointerType:'mouse', pointerId:1, clientX:x, clientY:y,
              isPrimary:true, button:0, buttons: t==='pointerdown'?1:0,
              bubbles:true, cancelable:true,
            });
            el.dispatchEvent(mk('pointerdown'));
            el.dispatchEvent(mk('pointerup'));
            el.dispatchEvent(new MouseEvent('click', {clientX:x, clientY:y, bubbles:true}));
            """,
            btn,
        )
    for _ in range(40):
        time.sleep(0.3)
        text = driver.execute_script(
            "return document.querySelector('flt-semantics-host')?.innerText || ''"
        )
        if "管理员" in text:
            break


def wait_for_render(driver: webdriver.Chrome, label: str, timeout: float = 8.0) -> None:
    """Wait until the page has actually painted non-bg content."""
    if label == "flutter":
        # Wait for at least one frame after Flutter mounts
        end = time.time() + timeout
        while time.time() < end:
            ok = driver.execute_script(
                """
                const h = document.querySelector('flt-semantics-host');
                const t = h ? (h.innerText || '') : '';
                if (t.length > 5) return true;
                // Look for any canvas with non-trivial size
                const cs = document.querySelectorAll('canvas, picture, flutter-view');
                for (const c of cs) {
                  const r = c.getBoundingClientRect();
                  if (r.width > 200 && r.height > 200) return true;
                }
                return false;
                """
            )
            if ok:
                return
            time.sleep(0.3)
    else:  # vue
        end = time.time() + timeout
        while time.time() < end:
            ok = driver.execute_script(
                "return document.body && document.body.innerText.trim().length > 5"
            )
            if ok:
                return
            time.sleep(0.3)


def capture_side(label: str, base: str, login_fn, idx: int) -> None:
    driver = make_driver()
    try:
        print(f">>> {label}: login")
        login_fn(driver)
        for slug, v_hash, f_hash, desc in PAGES:
            path = (v_hash, f_hash)[idx]
            out = os.path.join(OUT, f"{slug}__{label}.png")
            try:
                if slug == "00-login":
                    driver.get(base + path)
                else:
                    driver.execute_script(
                        "window.location.hash = arguments[0]", path
                    )
                # Wait for content to actually paint
                wait_for_render(driver, label, timeout=10.0)
                # Extra settle time for charts / animations
                time.sleep(1.5)
                driver.save_screenshot(out)
                print(f"  {label} {slug}: ok")
            except Exception as e:
                print(f"  {label} {slug}: FAIL {e}")
    finally:
        driver.quit()


def write_compare_html() -> None:
    rows = []
    for slug, v_hash, f_hash, desc in PAGES:
        vue_img = f"{slug}__vue.png"
        flu_img = f"{slug}__flutter.png"
        rows.append(f"""
        <h2>{slug} — {desc}</h2>
        <div class='row'>
          <div class='col'>
            <h3>Vue 原版 <code>{v_hash}</code></h3>
            <img src='{vue_img}' />
          </div>
          <div class='col'>
            <h3>Flutter 端 <code>{f_hash}</code></h3>
            <img src='{flu_img}' />
          </div>
        </div>
        """)
    body = "\n".join(rows)
    html = f"""<!DOCTYPE html>
<html lang='zh'><head><meta charset='utf-8'><title>vue vs flutter side-by-side</title>
<style>
body {{font-family: -apple-system, sans-serif; margin: 0; padding: 24px; background: #fafafa;}}
.row {{display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 24px;}}
.col {{background: white; padding: 12px; border: 1px solid #ddd;}}
h2 {{border-top: 2px solid #1890ff; padding-top: 16px; margin-top: 32px;}}
h3 {{margin: 4px 0 8px;}}
img {{width: 100%; display: block; border: 1px solid #eee;}}
code {{background: #f5f5f5; padding: 2px 6px; border-radius: 3px;}}
</style></head><body>
<h1>vue-framework-wz vs Flutter port — full side-by-side</h1>
{body}
</body></html>"""
    out = os.path.join(OUT, "index.html")
    with open(out, "w") as f:
        f.write(html)
    print(f"\nComparison HTML: {out}")


def main() -> int:
    capture_side("vue", VUE_BASE, login_vue, 0)
    capture_side("flutter", FL_BASE, login_flutter, 1)
    write_compare_html()
    return 0


if __name__ == "__main__":
    sys.exit(main())
