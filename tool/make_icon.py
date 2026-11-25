#!/usr/bin/env python3
"""App icon: three stacked gold ingots on deep charcoal.

Writes the launcher icons (legacy + adaptive foreground), the splash mark and the
512 px Play Store icon. Needs playwright (Chromium). Run from the repo root.
"""
import os

from playwright.sync_api import sync_playwright

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RES = os.path.join(ROOT, 'android', 'app', 'src', 'main', 'res')

DEFS = '''<defs>
 <radialGradient id="bg" cx=".5" cy=".35" r=".8">
  <stop offset="0" stop-color="#1B6656"/><stop offset="1" stop-color="#0A2F28"/>
 </radialGradient>
 <linearGradient id="band" x1="0" y1="0" x2="1" y2="0">
  <stop offset="0" stop-color="#F3DA8E"/><stop offset=".5" stop-color="#D4AE52"/><stop offset="1" stop-color="#A9822C"/>
 </linearGradient>
 <linearGradient id="side" x1="0" y1="0" x2="0" y2="1">
  <stop offset="0" stop-color="#26241F"/><stop offset="1" stop-color="#0E0D0B"/>
 </linearGradient>
</defs>'''


def mark(cy=256, s=1.0):
    """Ka'bah in two-point view with the gold band, inside a dashed Tawaf ring."""
    def P(x, y):
        return f'{256 + x * s:.1f},{cy + y * s:.1f}'
    ring = (f'<path d="M{256 - 178 * s:.1f},{cy + 70 * s:.1f} A{178 * s:.1f},{62 * s:.1f} 0 0 1 {256 + 178 * s:.1f},{cy + 70 * s:.1f}" '
            f'fill="none" stroke="#E9D9A8" stroke-opacity=".55" stroke-width="{7 * s:.1f}" stroke-dasharray="{26 * s:.1f} {16 * s:.1f}"/>')
    left = f'<path d="M{P(-112,-60)} L{P(0,-24)} L{P(0,110)} L{P(-112,74)} Z" fill="url(#side)"/>'
    right = f'<path d="M{P(0,-24)} L{P(112,-60)} L{P(112,74)} L{P(0,110)} Z" fill="#1A1916"/>'
    top = f'<path d="M{P(-112,-60)} L{P(0,-96)} L{P(112,-60)} L{P(0,-24)} Z" fill="#33302A"/>'
    band_l = f'<path d="M{P(-112,-34)} L{P(0,2)} L{P(0,24)} L{P(-112,-12)} Z" fill="url(#band)"/>'
    band_r = f'<path d="M{P(0,2)} L{P(112,-34)} L{P(112,-12)} L{P(0,24)} Z" fill="url(#band)" opacity=".85"/>'
    door = f'<path d="M{P(28,40)} L{P(62,29)} L{P(62,84)} L{P(28,95)} Z" fill="url(#band)" opacity=".9"/>'
    # front half of the ring passes in front of the cube
    front = (f'<path d="M{256 - 178 * s:.1f},{cy + 70 * s:.1f} A{178 * s:.1f},{62 * s:.1f} 0 0 0 {256 + 178 * s:.1f},{cy + 70 * s:.1f}" '
             f'fill="none" stroke="#E9D9A8" stroke-width="{7 * s:.1f}" stroke-dasharray="{26 * s:.1f} {16 * s:.1f}"/>')
    return ring + left + right + top + band_l + band_r + door + front


def full(rounded=True):
    r = 112 if rounded else 0
    return DEFS + f'<rect width="512" height="512" rx="{r}" fill="url(#bg)"/>' + mark(250, 1.15)


def foreground():
    # adaptive icon: 108dp canvas, masked to ~66dp in the middle
    return DEFS + mark(250, .82)


def render(page, svg, size, path, transparent=True):
    page.set_viewport_size({'width': size, 'height': size})
    page.set_content(f'<html><body style="margin:0;background:transparent"><svg xmlns="http://www.w3.org/2000/svg" '
                     f'width="{size}" height="{size}" viewBox="0 0 512 512">{svg}</svg></body></html>')
    os.makedirs(os.path.dirname(path), exist_ok=True)
    page.screenshot(path=path, omit_background=transparent)


with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    for name, px in {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}.items():
        render(page, full(), px, f'{RES}/mipmap-{name}/ic_launcher.png')
    for name, px in {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}.items():
        render(page, foreground(), px, f'{RES}/mipmap-{name}/ic_launcher_foreground.png')
    render(page, full(rounded=False), 512, os.path.join(ROOT, 'store', 'listing', 'icon-512.png'), transparent=False)
    render(page, full(), 1024, os.path.join(ROOT, 'store', 'icon-preview.png'))
    browser.close()
os.makedirs(f'{RES}/mipmap-anydpi-v26', exist_ok=True)
open(f'{RES}/mipmap-anydpi-v26/ic_launcher.xml', 'w').write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')
print('ok')
