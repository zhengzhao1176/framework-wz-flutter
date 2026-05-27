#!/usr/bin/env python3
"""Screenshot equivalent routes on both apps side-by-side for visual diffing.

Vue (original) hash routes  →  http://localhost:9001/index.html#/<route>
Flutter port  hash routes   →  http://localhost:8765/#/<route>

Output: integration_test/_compare/<route-slug>__{vue,flutter}.png
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


# Pages to compare:
#   (slug, vue_hash, flutter_hash, description)
PAGES = [
    ("00-login", "/login", "/login", "登录页"),
    ("01-dashboard", "/dashboard", "/dashboard", "仪表盘"),
    ("02-introduction", "/introduction", "/dashboard", "介绍页（Flutter 未实现 → fallback dashboard）"),
    ("03-charts-shopchart", "/charts/shopchart", "/charts/line", "图表-商场统计 vs 折线图"),
    ("04-charts-radar", "/charts/radarchart", "/charts/line", "图表-雷达图 vs 折线图"),
    ("05-charts-cake", "/charts/cakechart", "/charts/pie", "图表-蛋糕销量 vs 饼图"),
    ("06-table", "/table", "/table", "表格综合"),
    ("07-jsontree", "/jsontree", "/json", "JSON 视图"),
    ("08-markdown", "/markdown", "/editor/markdown", "Markdown 编辑器"),
    ("09-comp-buttons", "/components/buttons", "/dashboard", "Buttons 按钮（Flutter 缺）"),
    ("10-comp-hoverbtn", "/components/hoverbuttons", "/dashboard", "悬停按钮（Flutter 缺）"),
    ("11-comp-alert", "/components/alert", "/dashboard", "Alert 警告（Flutter 缺）"),
    ("12-comp-card", "/components/card", "/dashboard", "Card 卡片（Flutter 缺）"),
    ("13-comp-datepicker", "/components/datepicker", "/dashboard", "DatePicker（Flutter 缺）"),
    ("14-comp-form", "/components/form", "/dashboard", "Form 表单（Flutter 缺）"),
    ("15-comp-modal", "/components/modal", "/dashboard", "Modal 对话框（Flutter 缺）"),
    ("16-comp-select", "/components/select", "/dashboard", "Select 选择器（Flutter 缺）"),
    ("17-comp-spin", "/components/spin", "/dashboard", "Spin 加载（Flutter 缺）"),
    ("18-comp-steps", "/components/steps", "/dashboard", "Steps 步骤条（Flutter 缺）"),
    ("19-comp-timeline", "/components/timeline", "/dashboard", "Timeline 时间轴（Flutter 缺）"),
    ("20-comp-transfer", "/components/transfer", "/dashboard", "Transfer 穿梭（Flutter 缺）"),
    ("21-comp-timepicker", "/components/timepicker", "/dashboard", "Timepicker（Flutter 缺）"),
    ("22-comp-upload", "/components/upload", "/dashboard", "Upload 上传（Flutter 缺）"),
    ("23-404", "/no-such-page", "/no-such-page", "404"),
]


def make_driver() -> webdriver.Chrome:
    opts = Options()
    opts.add_argument("--window-size=1440,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--force-renderer-accessibility")
    # Don't block on heavy resources (Vue app loads three.js + cdn tinymce)
    opts.set_capability("pageLoadStrategy", "eager")
    driver = webdriver.Chrome(service=Service(DRIVER_PATH), options=opts)
    driver.set_page_load_timeout(60)
    driver.set_script_timeout(30)
    return driver


def login_vue(driver: webdriver.Chrome) -> None:
    """Login by interacting with the iview login form via native input events.

    The form is built on iview Input components which use Vue's v-model.
    `el.value = x` alone won't trigger v-model; we need to also dispatch
    an `input` event so Vue's watcher picks up the change.
    """
    driver.get(VUE_BASE + "/login")
    time.sleep(3.0)
    # Set values + fire input events
    driver.execute_script(
        """
        const inputs = document.querySelectorAll('input.ivu-input');
        // First input = email (already filled), second = password
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
    time.sleep(0.6)
    # Click 登录 button via real click
    btns = driver.find_elements("xpath", "//button[contains(., '登录')]")
    if btns:
        btns[0].click()
    time.sleep(4.0)
    # Verify we left /login
    url = driver.current_url
    if "/login" in url:
        # As a fallback, set the cookie too and reload.
        driver.add_cookie({"name": "Admin-Token", "value": "admin", "path": "/"})
        driver.get(VUE_BASE + "/dashboard")
        time.sleep(3.0)


def login_flutter(driver: webdriver.Chrome) -> None:
    driver.get(FL_BASE + "/login")
    time.sleep(3)
    p = driver.execute_script(
        "return document.querySelector('flt-semantics-placeholder')"
    )
    if p:
        driver.execute_script("arguments[0].click()", p)
        time.sleep(1.5)
    # Form pre-fills admin/123456 — just find and click 登 录 button.
    btn = driver.execute_script(
        """
        const nodes = document.querySelectorAll('flt-semantics[role="button"]');
        for (const n of nodes) {
          if (n.textContent.includes('登 录')) return n;
        }
        return null;
        """
    )
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
    # Wait until 管理员 appears (profile loaded)
    for _ in range(40):
        time.sleep(0.3)
        text = driver.execute_script(
            "return document.querySelector('flt-semantics-host')?.innerText || ''"
        )
        if "管理员" in text:
            break


def run_side(label: str, base: str, login_fn, pages_hash_key: int) -> None:
    """Walk PAGES on a single browser instance — Vue or Flutter."""
    driver = make_driver()
    try:
        print(f">>> {label}: login")
        try:
            login_fn(driver)
        except Exception as e:
            print(f"  ! {label} login failed: {e}")

        for slug, v_hash, f_hash, desc in PAGES:
            path = (v_hash, f_hash)[pages_hash_key]
            out_path = os.path.join(OUT, f"{slug}__{label}.png")
            print(f"--- {label} {slug} → {path}")
            try:
                if slug == "00-login":
                    driver.get(base + path)
                else:
                    driver.execute_script(
                        "window.location.hash = arguments[0]", path
                    )
                time.sleep(2.0)
                driver.save_screenshot(out_path)
            except Exception as e:
                print(f"  ! failed: {e}")
    finally:
        driver.quit()


def main() -> int:
    print(">>> Vue side")
    run_side("vue", VUE_BASE, login_vue, 0)
    print(">>> Flutter side")
    run_side("flutter", FL_BASE, login_flutter, 1)
    print(f"\nSaved comparison screenshots to {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
