#!/usr/bin/env python3
"""End-to-end browser automation against the built Flutter web app.

Targets the Flutter accessibility tree:
  - <input aria-label="用户名">  →  text fields
  - <flt-semantics role="button"> with text  →  buttons
  - <flt-semantics> nodes with inner text  →  labels / navigation items
"""
from __future__ import annotations

import os
import sys
import time
from dataclasses import dataclass, field
from typing import Callable

from selenium import webdriver
from selenium.common.exceptions import JavascriptException, TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.remote.webelement import WebElement

BASE_URL = os.environ.get("BASE_URL", "http://localhost:8765")
DRIVER_PATH = os.environ.get(
    "CHROMEDRIVER", os.path.expanduser("~/.local/bin/chromedriver147")
)
SHOTS_DIR = os.path.join(os.path.dirname(__file__), "_screenshots")
os.makedirs(SHOTS_DIR, exist_ok=True)


@dataclass
class Result:
    passed: list[str] = field(default_factory=list)
    failed: list[tuple[str, str]] = field(default_factory=list)

    def add(self, name: str, fn: Callable[[], None]) -> None:
        print(f"\n=== {name} ===", flush=True)
        try:
            fn()
            print(f"PASS  {name}", flush=True)
            self.passed.append(name)
        except Exception as e:  # noqa: BLE001
            print(f"FAIL  {name}: {e}", flush=True)
            self.failed.append((name, str(e)))


def shot(driver: webdriver.Chrome, name: str) -> None:
    path = os.path.join(SHOTS_DIR, f"{name}.png")
    driver.save_screenshot(path)
    print(f"  screenshot -> {path}", flush=True)


def wait_for_flutter(driver: webdriver.Chrome, timeout: float = 60.0) -> None:
    end = time.time() + timeout
    while time.time() < end:
        try:
            if driver.execute_script(
                "return !!document.querySelector('flutter-view, flt-glass-pane')"
            ):
                return
        except JavascriptException:
            pass
        time.sleep(0.5)
    raise TimeoutError("Flutter did not mount")


def enable_semantics(driver: webdriver.Chrome) -> None:
    p = driver.execute_script(
        "return document.querySelector('flt-semantics-placeholder')"
    )
    if p:
        driver.execute_script("arguments[0].click()", p)
        time.sleep(1.5)


def semantics_text(driver: webdriver.Chrome) -> str:
    return driver.execute_script(
        "const h = document.querySelector('flt-semantics-host');"
        "return h ? (h.innerText || h.textContent || '') : ''"
    )


def find_button_with_text(driver: webdriver.Chrome, text: str) -> WebElement | None:
    nodes = driver.find_elements(
        By.XPATH,
        f"//flt-semantics-host//flt-semantics[@role='button'][contains(., '{text}')]",
    )
    return nodes[0] if nodes else None


def wait_for_button(
    driver: webdriver.Chrome, text: str, timeout: float = 10.0
) -> WebElement:
    end = time.time() + timeout
    while time.time() < end:
        n = find_button_with_text(driver, text)
        if n is not None:
            return n
        time.sleep(0.25)
    raise TimeoutException(f"button with text {text!r} not found")


def find_node_with_text(
    driver: webdriver.Chrome, text: str
) -> WebElement | None:
    nodes = driver.find_elements(
        By.XPATH,
        f"//flt-semantics-host//flt-semantics[contains(., '{text}')]",
    )
    # Filter to leaf-ish nodes that directly contain the text
    for n in nodes:
        try:
            txt = (n.text or "").strip()
            if text in txt:
                return n
        except Exception:
            continue
    return nodes[0] if nodes else None


def wait_for_node(
    driver: webdriver.Chrome, text: str, timeout: float = 10.0
) -> WebElement:
    end = time.time() + timeout
    while time.time() < end:
        n = find_node_with_text(driver, text)
        if n is not None:
            return n
        time.sleep(0.25)
    raise TimeoutException(f"node with text {text!r} not found")


def find_input_by_label(driver: webdriver.Chrome, label: str) -> WebElement | None:
    nodes = driver.find_elements(By.CSS_SELECTOR, f'input[aria-label="{label}"]')
    return nodes[0] if nodes else None


def click_native(driver: webdriver.Chrome, element: WebElement) -> None:
    """Click using whatever path Flutter actually listens to.

    Strategy ladder, in order of reliability:
      1. Find an ancestor with `flt-tappable=""` — that's the node Flutter
         marks as a hit target. Click *that*, not the leaf text node.
      2. If no tappable ancestor, fall back to the leaf with a synthetic
         pointer-down/up pair.
    """
    # Climb to a flt-tappable ancestor if there is one.
    target = driver.execute_script(
        """
        let n = arguments[0];
        while (n && n !== document.body) {
          if (n.hasAttribute && n.hasAttribute('flt-tappable')) return n;
          n = n.parentElement;
        }
        return arguments[0];
        """,
        element,
    )
    # Use native pointer down/up via JS — Flutter listens to pointerdown.
    driver.execute_script(
        """
        const el = arguments[0];
        const r = el.getBoundingClientRect();
        const x = r.left + r.width / 2;
        const y = r.top + r.height / 2;
        const mk = (type, more) => new PointerEvent(type, {
          pointerType: 'mouse', pointerId: 1,
          clientX: x, clientY: y, screenX: x, screenY: y,
          isPrimary: true, button: 0, buttons: type === 'pointerdown' ? 1 : 0,
          bubbles: true, cancelable: true, view: window, ...(more || {}),
        });
        el.dispatchEvent(mk('pointerover'));
        el.dispatchEvent(mk('pointerenter'));
        el.dispatchEvent(mk('pointerdown'));
        el.dispatchEvent(mk('pointerup'));
        el.dispatchEvent(new MouseEvent('click', {
          clientX: x, clientY: y, bubbles: true, cancelable: true,
          view: window, button: 0,
        }));
        """,
        target,
    )
    time.sleep(0.3)


def js_click_with_pointer(driver: webdriver.Chrome, element: WebElement) -> None:
    """Last-resort: dispatch a full pointerdown/up pair via JS."""
    driver.execute_script(
        """
        const el = arguments[0];
        const r = el.getBoundingClientRect();
        const x = r.left + r.width / 2;
        const y = r.top  + r.height / 2;
        const mk = (type) => new PointerEvent(type, {
          pointerType: 'mouse', clientX: x, clientY: y,
          isPrimary: true, button: 0, buttons: 1,
          bubbles: true, cancelable: true,
        });
        el.dispatchEvent(mk('pointerdown'));
        el.dispatchEvent(mk('pointerup'));
        el.dispatchEvent(new MouseEvent('click', {
          clientX: x, clientY: y, bubbles: true, cancelable: true,
        }));
        """,
        element,
    )
    time.sleep(0.3)


def make_driver() -> webdriver.Chrome:
    opts = Options()
    opts.add_argument("--window-size=1280,800")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--force-renderer-accessibility")
    service = Service(DRIVER_PATH)
    return webdriver.Chrome(service=service, options=opts)


def main() -> int:
    driver = make_driver()
    result = Result()

    try:
        driver.set_window_size(1280, 800)
        driver.get(BASE_URL)
        wait_for_flutter(driver)
        time.sleep(1)
        enable_semantics(driver)
        time.sleep(1.5)
        shot(driver, "01-boot")

        def t_route_redirect() -> None:
            url = driver.current_url
            assert "/login" in url or "#/login" in url, (
                f"expected redirect to /login, got {url}"
            )

        def t_login_renders() -> None:
            text = semantics_text(driver)
            assert "登录" in text, f"login title missing; got: {text[:300]!r}"
            # The helper hint shows the test accounts
            assert "admin@wz.com" in text, (
                f"login helper missing; got: {text[:400]!r}"
            )

        def t_login_admin() -> None:
            # The LoginPage's initState pre-fills admin@wz.com / 123456 — only
            # need to tap submit. The <input> DOM is an IME shim; its `value`
            # is empty.
            submit = wait_for_button(driver, "登录")
            shot(driver, "02-found-submit")
            click_native(driver, submit)
            # Wait until profile load completes (role label = 管理员)
            for _ in range(60):
                time.sleep(0.3)
                text = semantics_text(driver)
                if "管理员" in text:
                    break
            shot(driver, "03-dashboard")
            assert "/dashboard" in driver.current_url, (
                f"expected /dashboard, got {driver.current_url}"
            )
            text = semantics_text(driver)
            assert "你好" in text, f"dashboard greeting missing; text={text[:400]!r}"

        def t_dashboard_user_loaded() -> None:
            # currentUserProvider invalidation must propagate so the avatar
            # and role show the real admin profile, not the fallback "?/同学".
            text = semantics_text(driver)
            assert "管理员" in text and "角色：管理员" in text, (
                f"profile didn't propagate; got: {text[:400]!r}"
            )

        def navigate(path: str) -> None:
            """Drive the SPA router via the URL hash — same effect as clicking
            a sidebar item in terms of route + state, and not subject to the
            semantics-tree visibility quirks of canvas-rendered widgets."""
            driver.execute_script(
                "window.location.hash = arguments[0]", path
            )
            time.sleep(2.0)

        def t_route_charts_line() -> None:
            navigate("/charts/shopchart")
            time.sleep(2.5)
            shot(driver, "04-line-chart")
            assert "/charts/shopchart" in driver.current_url
            # fl_chart paints into Flutter's single global canvas — no
            # individual chart canvas exists. Use a pixel-level check: sample
            # the screenshot in the chart area and ensure it's not all-white
            # (which would indicate the chart never rendered).
            from PIL import Image
            img = Image.open(
                os.path.join(SHOTS_DIR, "04-line-chart.png")
            ).convert("RGB")
            w, h = img.size
            # Sample the entire chart card area (right of sidebar, below header).
            # A rendered chart adds gridlines, axis labels, ticks, and a colored
            # line — so the patch should contain many distinct colors. A blank
            # / loading state would show only the card's bg + a spinner.
            colors: set[tuple[int, int, int]] = set()
            for y in range(int(h * 0.25), int(h * 0.9), 8):
                for x in range(int(w * 0.25), int(w * 0.95), 8):
                    colors.add(img.getpixel((x, y)))
            assert len(colors) >= 20, (
                f"chart area looks blank — only {len(colors)} distinct colors"
            )

        def t_route_table() -> None:
            navigate("/table")
            shot(driver, "05-table")
            assert "/table" in driver.current_url
            end = time.time() + 8
            while time.time() < end:
                text = semantics_text(driver)
                if "导出原始数据" in text and "导出排序和过滤后的数据" in text:
                    return
                time.sleep(0.25)
            raise AssertionError(
                f"table didn't render; text={semantics_text(driver)[:400]!r}"
            )

        def t_route_json() -> None:
            navigate("/jsontree")
            shot(driver, "06-json")
            assert "/jsontree" in driver.current_url
            text = semantics_text(driver)
            assert (
                "JSON展示列表" in text
                or "解析" in text
                or "Framework" in text
            ), f"json page missing; text={text[:400]!r}"

        def t_route_introduction() -> None:
            navigate("/introduction")
            shot(driver, "07-introduction")
            assert "/introduction" in driver.current_url
            text = semantics_text(driver)
            assert "项目占比" in text or "实践案例" in text, (
                f"introduction page missing; got: {text[:600]!r}"
            )

        def t_route_404() -> None:
            navigate("/no-such-route")
            time.sleep(1.0)
            shot(driver, "08-404")
            text = semantics_text(driver)
            assert "404" in text, f"404 page missing; got: {text[:400]!r}"

        def t_back_to_dashboard() -> None:
            btn = wait_for_button(driver, "返回首页")
            click_native(driver, btn)
            time.sleep(1.5)
            shot(driver, "09-back-home")
            assert "/dashboard" in driver.current_url, (
                f"expected /dashboard, got {driver.current_url}"
            )

        def t_tabs_present_after_nav() -> None:
            # The shell stays mounted across deep-link navigations — verify by
            # going back to /dashboard and checking the greeting re-appears
            # (which only the dashboard page renders).
            navigate("/dashboard")
            time.sleep(1.5)
            text = semantics_text(driver)
            assert "你好" in text and "管理员" in text, (
                f"dashboard didn't re-render after deep-link sequence; "
                f"text={text[:400]!r}"
            )

        result.add("TE-route 未登录重定向 /login", t_route_redirect)
        result.add("TE-login 渲染（含 admin@wz.com 提示）", t_login_renders)
        result.add("TE-01 admin 登录 → dashboard", t_login_admin)
        result.add("TE: profile 异步加载完成（管理员名 + 角色）", t_dashboard_user_loaded)
        result.add("TE-02 深链 → /charts/shopchart 渲染图表", t_route_charts_line)
        result.add("TE-03 深链 → /table 渲染 + 双导出按钮", t_route_table)
        result.add("TE-04 深链 → /jsontree 渲染 JSON 视图", t_route_json)
        result.add("TE-05 深链 → /introduction 渲染介绍页", t_route_introduction)
        result.add("TE-06 深链 → 未知路径 → 404", t_route_404)
        result.add("TE-07 404 返回首页按钮", t_back_to_dashboard)
        result.add("TE-08 多次导航后 shell 仍渲染（dashboard 重渲染）", t_tabs_present_after_nav)

    finally:
        driver.quit()

    print("\n========== SUMMARY ==========", flush=True)
    print(f"Passed: {len(result.passed)}/{len(result.passed)+len(result.failed)}", flush=True)
    for p in result.passed:
        print(f"  ✓ {p}", flush=True)
    if result.failed:
        print(f"Failed: {len(result.failed)}", flush=True)
        for name, why in result.failed:
            print(f"  ✗ {name}", flush=True)
            print(f"      {why}", flush=True)

    return 0 if not result.failed else 1


if __name__ == "__main__":
    sys.exit(main())
