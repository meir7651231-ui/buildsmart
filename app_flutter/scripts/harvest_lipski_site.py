#!/usr/bin/env python3
"""Harvest every product on lipski.co.il (official manufacturer site, ~186 products):
for each product page, pull its SKU, name, and main image URL. Output a JSON map for
matching against our catalog. Uses curl (Cloudflare blocks urllib's UA). Read-only.
Usage: python scripts/harvest_lipski_site.py
"""
import subprocess, re, json, sys, io, html

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
UA = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'


def curl(url):
    try:
        return subprocess.run(['curl', '-s', '-A', UA, url], capture_output=True,
                              timeout=30).stdout.decode('utf-8', 'replace')
    except Exception:
        return ''


def main():
    sm = curl('https://lipski.co.il/product-sitemap.xml')
    urls = re.findall(r'<loc>([^<]+)</loc>', sm)
    print(f"product URLs: {len(urls)}")
    out = []
    for i, u in enumerate(urls):
        page = curl(u)
        if not page:
            continue
        # SKU: try schema json, .sku span, retailer_item_id
        sku = None
        for pat in [r'"sku"\s*:\s*"([^"]+)"',
                    r'class="sku"[^>]*>([^<]+)<',
                    r'product:retailer_item_id"\s+content="([^"]+)"']:
            m = re.search(pat, page)
            if m and m.group(1).strip() not in ('', 'N/A'):
                sku = m.group(1).strip(); break
        img = None
        m = re.search(r'property="og:image"\s+content="([^"]+)"', page)
        if m:
            img = m.group(1)
        nm = None
        m = re.search(r'property="og:title"\s+content="([^"]+)"', page)
        if m:
            nm = html.unescape(m.group(1)).split(' -')[0].strip()
        out.append({'url': u, 'sku': sku, 'name': nm, 'image': img})
        if (i + 1) % 20 == 0:
            print(f"  ...{i+1}/{len(urls)}")
    with open('knowledge/_lipski_site.json', 'w', encoding='utf-8') as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    withboth = [x for x in out if x['sku'] and x['image']]
    print(f"harvested {len(out)} · with sku+image: {len(withboth)}")


if __name__ == '__main__':
    main()
