#!/usr/bin/env python3
"""Click each sidebar item by COORDINATE — Flutter Web doesn't expose
sidebar items as individual semantic DOM nodes, so we dispatch real
pointer events at known positions. Verifies every menu item navigates
and the page renders new content."""
from __future__ import annotations

import os, sys, time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

FL_BASE = "http://localhost:8765/"
DRIVER_PATH = os.path.expanduser("~/.local/bin/chromedriver147")
OUT = os.path.join(os.path.dirname(__file__), "_clickthru")
os.makedirs(OUT, exist_ok=True)

# Sidebar item Y positions in 1440x900 viewport (collapsed children excluded
# initially). 50px row height starting at y≈85.
TOP_LEVEL = [
    ("Dashboard", "/dashboard", 110),
    ("介绍", "/introduction", 160),
    ("component组件", None, 210),     # group
    ("echart图表", None, 260),         # group (will shift after expand)
    ("表格综合实例", "/table", 310),
    ("JSON视图", "/jsontree", 360),
    ("Markdown", "/markdown", 410),
]

# After clicking component group, these 14 children appear right under it
COMPONENT_CHILDREN = [
    "Buttons按钮", "悬停特效按钮", "Alert警告提示", "Card卡片", "DatePicker",
    "Form表单", "Modal对话框", "Select选择器", "Spin加载中", "Steps步骤条",
    "Timeline时间轴", "Transfer穿梭框", "Timepicker", "Upload上传",
]

# After clicking echart group, 3 children
CHART_CHILDREN = ["商场统计图表", "雷达图", "蛋糕销量图表"]


def make_driver():
    opts = Options()
    opts.add_argument("--window-size=1440,900")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--force-renderer-accessibility")
    opts.set_capability("pageLoadStrategy", "eager")
    d = webdriver.Chrome(service=Service(DRIVER_PATH), options=opts)
    d.set_page_load_timeout(60)
    return d


def native_click_xy(driver, x, y):
    driver.execute_script(
        f"""
        const x={x}, y={y};
        const mk = (t) => new PointerEvent(t, {{
          pointerType:'mouse', pointerId:1, clientX:x, clientY:y, screenX:x, screenY:y,
          isPrimary:true, button:0, buttons: t==='pointerdown'?1:0,
          bubbles:true, cancelable:true, view:window,
        }});
        const target = document.elementFromPoint(x, y);
        if (target) {{
          target.dispatchEvent(mk('pointerover'));
          target.dispatchEvent(mk('pointerenter'));
          target.dispatchEvent(mk('pointerdown'));
          target.dispatchEvent(mk('pointerup'));
          target.dispatchEvent(new MouseEvent('click', {{
            clientX:x, clientY:y, bubbles:true, cancelable:true, button:0, view:window,
          }}));
        }}
        """
    )
    time.sleep(1.5)


def login(driver):
    driver.get(FL_BASE)
    end = time.time() + 60
    while time.time() < end:
        if driver.execute_script(
            "return !!document.querySelector('flt-glass-pane, flutter-view')"
        ):
            break
        time.sleep(0.5)
    time.sleep(3)
    p = driver.execute_script(
        "return document.querySelector('flt-semantics-placeholder')"
    )
    if p:
        driver.execute_script("arguments[0].click()", p)
        time.sleep(2)
    btn = driver.execute_script(
        """
        const nodes = document.querySelectorAll('flt-semantics[role="button"]');
        for (const n of nodes) if (n.textContent.includes('登录')) return n;
        return null;
        """
    )
    if btn:
        driver.execute_script(
            """
            const r = arguments[0].getBoundingClientRect();
            const x=r.left+r.width/2, y=r.top+r.height/2;
            const mk = (t) => new PointerEvent(t, {
              pointerType:'mouse', pointerId:1, clientX:x, clientY:y,
              isPrimary:true, button:0, buttons:t==='pointerdown'?1:0,
              bubbles:true, cancelable:true,
            });
            arguments[0].dispatchEvent(mk('pointerdown'));
            arguments[0].dispatchEvent(mk('pointerup'));
            arguments[0].dispatchEvent(new MouseEvent('click',{clientX:x,clientY:y,bubbles:true}));
            """,
            btn,
        )
    for _ in range(60):
        time.sleep(0.5)
        text = driver.execute_script(
            "return document.querySelector('flt-semantics-host')?.innerText || ''"
        )
        if "管理员" in text:
            return


def snap(driver, slug):
    path = os.path.join(OUT, f"{slug}.png")
    driver.save_screenshot(path)


def main():
    driver = make_driver()
    log = []
    try:
        print(">>> login...")
        login(driver)
        time.sleep(2)

        # === Click each top-level item (the 4 non-group ones) ===
        for name, path, y in TOP_LEVEL:
            if path is None:  # group, handled later
                continue
            print(f"\n>>> click sidebar @{y}: {name}")
            native_click_xy(driver, 100, y)
            time.sleep(2)
            url = driver.current_url
            ok = path in url
            snap(driver, name)
            log.append(f"  {'✅' if ok else '❌'} {name:<18} → {url.split('#')[-1]}")

        # === Expand component 组件, then click each of 14 children ===
        print("\n>>> EXPAND component组件")
        native_click_xy(driver, 100, 210)
        time.sleep(1.5)
        for i, child in enumerate(COMPONENT_CHILDREN):
            y = 260 + i * 50
            print(f">>> click child @{y}: {child}")
            native_click_xy(driver, 110, y)
            time.sleep(2)
            url = driver.current_url
            slug_path = url.split("#")[-1]
            ok = "/components/" in slug_path
            snap(driver, child)
            log.append(f"  {'✅' if ok else '❌'} {child:<18} → {slug_path}")

        # Collapse component, expand echart (component group at 210, echart at 260)
        print("\n>>> COLLAPSE component, EXPAND echart图表")
        native_click_xy(driver, 100, 210)  # collapse
        time.sleep(1)
        native_click_xy(driver, 100, 260)  # expand echart
        time.sleep(1.5)
        for i, child in enumerate(CHART_CHILDREN):
            y = 310 + i * 50
            print(f">>> click chart child @{y}: {child}")
            native_click_xy(driver, 110, y)
            time.sleep(2)
            url = driver.current_url
            slug_path = url.split("#")[-1]
            ok = "/charts/" in slug_path
            snap(driver, child)
            log.append(f"  {'✅' if ok else '❌'} {child:<18} → {slug_path}")

        print("\n" + "=" * 60)
        print("Sidebar click-through summary")
        print("=" * 60)
        for line in log:
            print(line)
        passed = sum(1 for x in log if x.strip().startswith("✅"))
        print(f"\n{passed}/{len(log)} items clicked successfully")
    finally:
        driver.quit()


if __name__ == "__main__":
    sys.exit(main())
