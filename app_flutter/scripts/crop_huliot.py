"""Adaptive crop for Huliot SmartLock catalog pages.

The catalog draws a thin green horizontal line at the TOP of every product
band (page 5 protocol). The bands within a page are NOT equal height — band
heights grow with diagram complexity, and some pages also carry an extra
green line under a page-level header (e.g. "אביזרים משלימים"). Equal-spaced
bands therefore drift, capturing the diagram of one product on top of the
photo of the next.

This script:
  1. Detects every green horizontal line on the page (≥15% of width, ≥g130).
  2. Drops the page-header line(s) (excess over expected SECTIONS count).
  3. Treats each remaining green line as a band-top; band-bottom is the next
     line (or the page footer for the last band).
  4. Crops a photo box from the upper half of the band (right under the
     header gap) — small enough to never spill into the diagram below.
  5. Crops a spec box from the lower half, BUT skips it when the box is
     mostly white (this band has no dimension diagram — e.g. the cutter
     on page 11). spec crops are paired with photo crops by tag (a/b/c/d).
"""
from PIL import Image, ImageStat
import os

PAGES = 'assets/huliot_smartlock/pages'
OUT = 'assets/huliot_smartlock/products'
os.makedirs(OUT, exist_ok=True)

# Per page: ordered list of section tags (top→bottom). Photo column = left.
# tag letters a,b,c,d map to _huliotImageFor routing.
SECTIONS = {
    11: ['a', 'b', 'c'],
    12: ['a', 'b', 'c', 'd'],
    13: ['a', 'b', 'c'],
    14: ['a', 'b'],
    15: ['a', 'b', 'c'],
    16: ['a', 'b'],
    17: ['a', 'b'],
    18: ['a', 'b'],
    19: ['a', 'b', 'c'],
    20: ['a', 'b', 'c'],
    21: ['a', 'b', 'c'],
    22: ['a', 'b'],
    23: ['a', 'b'],
    24: ['a', 'c', 'd'],
    25: ['a', 'c'],
    28: ['a', 'b', 'c', 'd'],
    29: ['a', 'b', 'c', 'd'],
    30: ['a', 'b', 'c', 'd'],
    31: ['a', 'b', 'c'],
    32: ['a', 'b', 'c'],
    33: ['a', 'b'],
    34: ['a', 'b'],
    35: ['a', 'b'],
    36: ['a', 'b'],
    37: ['a', 'b'],
    38: ['a', 'b'],
    39: ['a', 'b', 'c', 'd'],
    40: ['a', 'b', 'c'],
    41: ['a', 'b', 'c'],
    42: ['a', 'b', 'c', 'd'],
    43: ['a', 'b', 'c'],
}

# Page 27 (AQUA SLIM) has a UNIQUE layout — 2 product renders (330+700)
# on the right side and a thin strip drawing at the bottom; the band scheme
# doesn't fit. Hand-tuned crops apply directly.
CROPS_27 = {
    'a': (470, 195, 825, 315),   # Aqua Slim 330 render
    'b': (420, 440, 825, 540),   # Aqua Slim 700 render
    'c': (150, 870, 670, 920),   # פס ניקוז ללא סט (strip-only)
}

# Photo column (left side of band) + tuning constants
X0, X1 = 12, 238
PHOTO_TOP_GAP = 22         # px gap below the green header line
PHOTO_BOTTOM_FRAC = 0.43   # photo ends at 43% of band (avoids diagram lip)
SPEC_TOP_FRAC = 0.45       # spec diagram starts at 45% of band
SPEC_BOTTOM_FRAC = 0.97    # spec diagram ends at 97% of band
MAX_PHOTO_H = 165          # cap so tiny bands don't crop a giant rectangle


def find_green_lines(im, min_width_frac=0.15):
    """Find every row where a horizontal green line spans ≥min_width_frac.
    Returns (y, max_run_width) pairs, GROUPED across consecutive y rows."""
    W, H = im.size
    px = im.load()
    raw = []
    for y in range(50, H - 50):
        max_run = run = 0
        for x in range(W):
            r, g, b = px[x, y]
            if g > 130 and g > r + 30 and g > b + 20:
                run += 1
                if run > max_run:
                    max_run = run
            else:
                run = 0
        if max_run > W * min_width_frac:
            raw.append((y, max_run))
    grouped = []
    if not raw:
        return grouped
    start = last = raw[0][0]
    best = raw[0][1]
    for y, run in raw[1:]:
        if y == last + 1:
            last = y
            if run > best:
                best = run
        else:
            grouped.append(((start + last) // 2, best))
            start = y
            last = y
            best = run
    grouped.append(((start + last) // 2, best))
    return grouped


def band_tops_for(im, expected_n):
    """Return [y, y, ...] of length expected_n — one band-top per section."""
    lines = find_green_lines(im)
    if len(lines) == expected_n:
        return [y for y, _ in sorted(lines, key=lambda t: t[0])]
    if len(lines) > expected_n:
        # Drop page-header line(s); keep the bottom-most N (those are the bands).
        lines_by_y = sorted(lines, key=lambda t: t[0])
        drop = len(lines_by_y) - expected_n
        return [y for y, _ in lines_by_y[drop:]]
    # Underdetection — pad with equal spacing as a soft fallback.
    H = im.height
    last_y = max(y for y, _ in lines) if lines else 135
    extra = (H - 100 - last_y) // (expected_n - len(lines) + 1)
    out = sorted(y for y, _ in lines)
    while len(out) < expected_n:
        out.append(out[-1] + extra)
    return out


def is_mostly_white(crop, min_ink_pixels=120):
    """True if the crop has fewer than `min_ink_pixels` dark pixels.

    Diagram crops are 99% white with thin dark lines + dimension labels — the
    mean brightness stays ~250 even when ink IS present, so we count dark
    pixels directly. 120 covers a basic L/DN/W tick-mark drawing comfortably."""
    px = crop.load()
    W, H = crop.size
    dark = 0
    for y in range(0, H, 2):
        for x in range(0, W, 2):
            r, g, b = px[x, y]
            if r < 200 and g < 200 and b < 200:
                dark += 1
                if dark >= min_ink_pixels:
                    return False
    return True


def crop_page(pg, tags):
    src = f'{PAGES}/page_{pg:02d}.jpg'
    im = Image.open(src).convert('RGB')
    H = im.height
    tops = band_tops_for(im, len(tags))
    # band_bottom of band i is start of band i+1; the last band ends ~H-50
    bottoms = tops[1:] + [H - 50]
    photo_count = spec_count = 0
    for tag, top, bot in zip(tags, tops, bottoms):
        band_h = bot - top
        # Photo box
        ph_top = top + PHOTO_TOP_GAP
        ph_bot = top + min(int(band_h * PHOTO_BOTTOM_FRAC), MAX_PHOTO_H + PHOTO_TOP_GAP)
        # safety: never spill past band bottom
        ph_bot = min(ph_bot, bot - 5)
        photo = im.crop((X0, ph_top, X1, ph_bot))
        photo.save(f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)
        photo_count += 1
        # Spec box (skip if blank)
        sp_top = top + int(band_h * SPEC_TOP_FRAC)
        sp_bot = top + int(band_h * SPEC_BOTTOM_FRAC)
        if sp_bot - sp_top < 40:
            continue
        spec = im.crop((X0, sp_top, X1, sp_bot))
        # Decide: keep spec only if it has ink (diagram pixels), drop if blank.
        if not is_mostly_white(spec):
            spec.save(f'{OUT}/spec_sml_p{pg:02d}_{tag}.jpg', quality=85)
            spec_count += 1
    return photo_count, spec_count


if __name__ == '__main__':
    # Clean any old crops first so we don't keep stale ones from earlier runs.
    for f in os.listdir(OUT):
        if (f.startswith('sml_p') or f.startswith('spec_sml_p')) and f.endswith('.jpg'):
            # Page 27 hand-tuned crops are managed separately below.
            if f.startswith('sml_p27_'):
                continue
            os.remove(os.path.join(OUT, f))

    total_p = total_s = 0
    for pg, tags in SECTIONS.items():
        p, s = crop_page(pg, tags)
        total_p += p
        total_s += s

    # Page 27 — hand-tuned crops (overrides any auto SECTIONS entry).
    im27 = Image.open(f'{PAGES}/page_27.jpg')
    for tag, box in CROPS_27.items():
        im27.crop(box).save(f'{OUT}/sml_p27_{tag}.jpg', quality=85)
    total_p += len(CROPS_27)

    print(f'cropped {total_p} photos + {total_s} spec diagrams')
