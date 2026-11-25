import sys, base64, os
from playwright.sync_api import sync_playwright
root, title, sub, chips, bg, fg, accent, out = sys.argv[1:9]
icon = base64.b64encode(open(f'{root}/store/listing/icon-512.png','rb').read()).decode()
b64 = lambda f: 'data:font/ttf;base64,' + base64.b64encode(open(f'{root}/assets/fonts/{f}','rb').read()).decode()
chips_html = ''.join(f'<span>{c}</span>' for c in chips.split('|'))
html = f'''<html dir="rtl"><head><style>
@font-face{{font-family:C;src:url({b64('Cairo_800ExtraBold.ttf')});font-weight:800}}
@font-face{{font-family:C;src:url({b64('Cairo_600SemiBold.ttf')});font-weight:600}}
body{{margin:0;width:1024px;height:500px;background:{bg};font-family:C;color:{fg};display:flex;align-items:center;overflow:hidden}}
.t{{flex:1;padding:0 70px 0 30px}}
h1{{font-size:76px;font-weight:800;margin:0;line-height:1.15}}
p{{font-size:30px;font-weight:600;margin:14px 0 26px;opacity:.85}}
.c span{{display:inline-block;border:2px solid {accent};color:{accent};border-radius:30px;padding:4px 18px;margin:0 0 10px 10px;font-size:22px;font-weight:600}}
img{{width:330px;height:330px;border-radius:70px;margin-left:80px;box-shadow:0 20px 60px rgba(0,0,0,.35)}}
</style></head><body><div class="t"><h1>{title}</h1><p>{sub}</p><div class="c">{chips_html}</div></div>
<img src="data:image/png;base64,{icon}"></body></html>'''
with sync_playwright() as p:
    b = p.chromium.launch(); pg = b.new_page(viewport={'width':1024,'height':500})
    pg.set_content(html); pg.wait_for_timeout(300); pg.screenshot(path=out); b.close()
