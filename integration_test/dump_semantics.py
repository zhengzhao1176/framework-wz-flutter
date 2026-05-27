#!/usr/bin/env python3
"""Dump Flutter web semantics tree for inspection."""
import os
import sys
import time

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By

BASE_URL = os.environ.get("BASE_URL", "http://localhost:8765")
DRIVER_PATH = os.path.expanduser("~/.local/bin/chromedriver147")

opts = Options()
opts.add_argument("--window-size=1280,800")
opts.add_argument("--force-renderer-accessibility")
driver = webdriver.Chrome(service=Service(DRIVER_PATH), options=opts)
try:
    driver.set_window_size(1280, 800)
    driver.get(BASE_URL)
    time.sleep(3)
    # Enable semantics
    p = driver.execute_script("return document.querySelector('flt-semantics-placeholder')")
    if p:
        driver.execute_script("arguments[0].click()", p)
        time.sleep(1.5)

    html = driver.execute_script(
        "return document.querySelector('flt-semantics-host')?.outerHTML || 'NONE'"
    )
    with open("/tmp/semantics.html", "w") as f:
        f.write(html)
    print(f"length={len(html)}")
    # First 4000 chars to console
    print(html[:4000])
finally:
    driver.quit()
