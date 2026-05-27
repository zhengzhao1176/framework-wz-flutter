#!/usr/bin/env python3
"""Dump dashboard semantics for inspection."""
import os
import time

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service

BASE_URL = "http://localhost:8765"
DRIVER_PATH = os.path.expanduser("~/.local/bin/chromedriver147")

opts = Options()
opts.add_argument("--window-size=1280,800")
opts.add_argument("--force-renderer-accessibility")
driver = webdriver.Chrome(service=Service(DRIVER_PATH), options=opts)
try:
    driver.set_window_size(1280, 800)
    driver.get(BASE_URL)
    time.sleep(3)
    p = driver.execute_script("return document.querySelector('flt-semantics-placeholder')")
    if p:
        driver.execute_script("arguments[0].click()", p)
    time.sleep(1.5)

    # Click submit to login (semantics tree should have 登 录 button by now)
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
        driver.execute_script("""
        const el = arguments[0];
        const r = el.getBoundingClientRect();
        const x = r.left + r.width/2, y = r.top + r.height/2;
        const mk = (t) => new PointerEvent(t, {pointerType:'mouse', pointerId:1, clientX:x, clientY:y, isPrimary:true, button:0, buttons: t==='pointerdown'?1:0, bubbles:true, cancelable:true});
        el.dispatchEvent(mk('pointerdown'));
        el.dispatchEvent(mk('pointerup'));
        el.dispatchEvent(new MouseEvent('click', {clientX:x, clientY:y, bubbles:true}));
        """, btn)
    time.sleep(5)
    # Dump the entire semantics
    html = driver.execute_script(
        "return document.querySelector('flt-semantics-host')?.outerHTML || ''"
    )
    with open("/tmp/dashboard_semantics.html", "w") as f:
        f.write(html)
    print(f"length={len(html)}")
    # Save the screenshot too
    driver.save_screenshot("/tmp/dashboard.png")

    # Print all nodes that look like sidebar items
    sidebar_nodes = driver.execute_script(
        """
        const all = document.querySelectorAll('flt-semantics-host *');
        const result = [];
        for (const n of all) {
          const t = (n.textContent || '').trim();
          if (['仪表盘','图表','表格','JSON 视图','权限','折线图','柱状图'].some(x => t === x || t.startsWith(x))) {
            const r = n.getBoundingClientRect();
            result.push({
              tag: n.tagName.toLowerCase(),
              text: t.slice(0, 50),
              role: n.getAttribute('role'),
              tappable: n.hasAttribute('flt-tappable'),
              x: Math.round(r.left + r.width/2),
              y: Math.round(r.top + r.height/2),
              w: Math.round(r.width),
              h: Math.round(r.height),
            });
          }
        }
        return result;
        """
    )
    for n in sidebar_nodes:
        print(n)
finally:
    driver.quit()
