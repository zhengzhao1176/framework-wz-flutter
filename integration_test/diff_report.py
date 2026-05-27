#!/usr/bin/env python3
"""Quantitative per-page diff between Vue and Flutter screenshots.

For each pair, compute:
  - color histogram cosine similarity
  - dominant background color match
  - mean per-pixel L1 distance on resized 200x125 images

Emit a sorted list (worst first) so we know which pages to attack next.
"""
import os, glob, json, math
from PIL import Image

OUT = "/Users/apple/Desktop/test/t13/integration_test/_compare"


def load(p, size=(200, 125)):
    img = Image.open(p).convert("RGB").resize(size)
    return img


def l1_dist(a, b):
    pa = list(a.getdata())
    pb = list(b.getdata())
    s = 0
    for (r1, g1, b1), (r2, g2, b2) in zip(pa, pb):
        s += abs(r1 - r2) + abs(g1 - g2) + abs(b1 - b2)
    return s / (len(pa) * 3 * 255)  # 0..1


def histogram_sim(a, b):
    ha = a.histogram()
    hb = b.histogram()
    # cosine sim
    dot = sum(x * y for x, y in zip(ha, hb))
    na = math.sqrt(sum(x * x for x in ha))
    nb = math.sqrt(sum(x * x for x in hb))
    return dot / (na * nb) if na and nb else 0.0


def dominant_color(img, sample=2000):
    pixels = list(img.getdata())[:sample]
    return tuple(sum(c) // len(pixels) for c in zip(*pixels))


def main():
    rows = []
    pairs = sorted(set(
        f.split("__")[0]
        for f in os.listdir(OUT)
        if f.endswith("__vue.png") and not f.startswith("_small")
    ))
    for slug in pairs:
        vp = f"{OUT}/{slug}__vue.png"
        fp = f"{OUT}/{slug}__flutter.png"
        if not os.path.exists(fp):
            continue
        va = load(vp)
        fa = load(fp)
        dist = l1_dist(va, fa)
        sim = histogram_sim(va, fa)
        rows.append({
            "slug": slug,
            "l1": round(dist, 4),
            "hist_sim": round(sim, 4),
            "vue_dom": dominant_color(va),
            "flu_dom": dominant_color(fa),
        })
    rows.sort(key=lambda r: -r["l1"])
    print(f"{'page':<28} {'L1':>8} {'hist':>8}  {'vue_dom':>15}  {'flu_dom':>15}")
    print("-" * 80)
    for r in rows:
        print(
            f"{r['slug']:<28} "
            f"{r['l1']:>8.4f} {r['hist_sim']:>8.4f}  "
            f"{str(r['vue_dom']):>15}  {str(r['flu_dom']):>15}"
        )


if __name__ == "__main__":
    main()
