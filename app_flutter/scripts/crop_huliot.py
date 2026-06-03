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
PHOTO_SAFETY_PAD = 6       # safety margin between detected photo-bottom and crop
SPEC_TOP_PAD = 8           # gap between photo bottom and spec top
SPEC_BOTTOM_PAD = 18       # leave page footer / sku row out of the spec
MIN_PHOTO_H = 80           # bands narrower than this — keep up to MIN_PHOTO_H
MAX_PHOTO_H = 175          # cap so a tall band doesn't grab the diagram below

# Pages where the photo↔diagram gap is too small (5-8 px) for block detection
# to reliably split. We fall back to a fixed photo height + spec at a fixed
# offset, which is exact for these fitting-only pages (no AQUA SLIM/render).
# Per-page PHOTO_H, hand-tuned to the actual product silhouette on each catalog
# page. Small-fitting pages (elbows/tees) get a tight 105-130 to avoid the
# diagram "DN" tick-marks; large-drain pages (19-23) get 160-170 so the bigger
# fixtures aren't truncated. Pages not listed fall back to block detection.
# Default formula: PHOTO_H = clamp(band_h × 0.45, 90..195).
# Catches the ~290-band fittings (130px photo) AND the ~500-band siphons
# (195px capped). Per-page/per-band overrides win when the silhouette is
# unusual (drains 245/50, AQUA SLIM strip, etc.).
PHOTO_H_FRAC = 0.45
PHOTO_H_MIN, PHOTO_H_MAX = 90, 195

PER_PAGE_PHOTO_H = {}
# Per-band override (page, tag) → PHOTO_H. Used when density-scan picks up the
# diagram's "DN" label as a false-positive dense row (page 12 elbows, p14_b, etc).
PER_BAND_PHOTO_H = {
    # Page 12 — elbow oneside × 4 angles; DN label below catches density
    (12, 'a'): 110,
    (12, 'b'): 110,
    (12, 'c'): 110,
    (12, 'd'): 110,
    # Page 14 — elbow מצרה צד אחד שקע תקע (band b)
    (14, 'b'): 145,
    # Page 20 — drop gutters (re-measured from PAGE overlay — base was cut)
    (20, 'a'): 145,    # photo 160-290 incl. base; diagram starts ~305
    (20, 'b'): 165,    # photo 520-680; diagram ~695
    (20, 'c'): 160,    # photo 895-1055; D1 tick at y=1060 trimmed
    # Page 21 — drains scale with size (re-measured)
    (21, 'a'): 118,    # drain 80/50 photo 170-275; diagram ~290
    (21, 'b'): 165,    # drain 140/50 photo 460-625; tick at y=635 trimmed
    (21, 'c'): 200,    # drain 245/50 — base was cut
    # Page 22 — drains open
    (22, 'a'): 155,
    (22, 'b'): 180,
    # Page 23 — kettle drains
    (23, 'a'): 155,
    (23, 'b'): 150,
    # Page 28 — cylindrical raised has DN tick below
    (28, 'c'): 110,
    # Page 30 — nickel grid has visible DN+H ticks
    (30, 'b'): 100,
    # Page 32 — no-siphon (tall photo) + kitchen siphon
    (32, 'a'): 135,    # no-siphon — full L-shape (pipe + elbow + horizontal)
    (32, 'b'): 165,
    (32, 'c'): 160,
    # Page 34 — american 1¼ siphon
    (34, 'a'): 165,
    # Page 35 — double american siphon
    (35, 'b'): 180,    # was 195 — capturing diagram tick
    # Page 36 — H-washing (cylinder + extension); see PER_BAND_X for narrow x-crop
    (36, 'b'): 290,    # photo full: y=720→1010 (band_top 704 + 22 + 290 = 1016)
    # Page 39 — long basin connector
    (39, 'b'): 88,     # capturing L1 tick at y=683-690
    # Page 40 — siphon kit + inlet extension
    (40, 'a'): 120,    # was 165 — capturing green line below
    (40, 'c'): 105,
    # Page 42 — funnel
    (42, 'b'): 195,
}

# Per-band X1 override (page, tag) → x1. Used when a diagram element sits in
# the right portion of the photo column (e.g. p36_b: H tick + rect at x=180+).
PER_BAND_X1 = {
    # Drains pages 20-23 — right port/elbow extends past default X1=238
    (20, 'a'): 265, (20, 'b'): 265, (20, 'c'): 265,
    (21, 'a'): 275, (21, 'b'): 275, (21, 'c'): 275,
    (22, 'a'): 260, (22, 'b'): 260,
    (23, 'a'): 290, (23, 'b'): 290,
    (36, 'b'): 168,    # photo column is x=12-170; diagram H tick starts at x=180
}

# PER_BAND_BOX overrides EVERYTHING — absolute (x0, y0, x1, y1) in page pixels.
# Used when band-relative tuning isn't sufficient (photo cap above default top
# gap, etc). Wins over PER_BAND_PHOTO_H + PER_BAND_X1.
PER_BAND_BOX = {
    # p32_a — L-shaped no-siphon: cap at y=140, horizontal extension ends ~y=270
    (32, 'a'): (12, 145, 260, 273),
    # p36_b — H-washing: cap y=720, base y=1030 (narrow x to skip H tick)
    (36, 'b'): (12, 720, 170, 1035),
}

# Per-band override (page, tag) → PHOTO_H. Wins over PER_PAGE_PHOTO_H.
# Used for bands where the photo is taller than the page average — e.g.
# drains scale 80/50 → 140/50 → 245/50 within p21.
# (PER_BAND_PHOTO_H defined above — kept empty by default; v25 density
# scanning is the source of truth.)
FIXED_SPEC_GAP = 14        # gap from photo bottom to spec top (FIXED pages)


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


def row_has_ink(im, x0, x1, y, threshold=0.015):
    """True if row y contains at least `threshold` fraction of non-white pixels.

    Used to detect a content row vs an empty/whitespace row. The threshold is
    low (1.5%) because diagrams have only thin lines."""
    px = im.load()
    n = ink = 0
    for x in range(x0, x1, 3):
        r, g, b = px[x, y]
        n += 1
        if r < 235 or g < 235 or b < 235:
            ink += 1
    return (ink / n) >= threshold


def find_content_blocks(im, x0, x1, y0, y1, gap_threshold=8):
    """Return [(block_top, block_bottom), ...] — vertically separated runs of
    content rows. Two blocks are separated when ≥`gap_threshold` consecutive
    whitespace rows sit between them.

    NOTE: the previous "merge nearby blocks" hack was wrong — in catalog page
    12 the photo↔diagram gap is only ~10px, while in pages with internal
    photo white-space the inside gap is ~6-7px. So we keep gap_threshold
    moderate (8) and use bbox-trim later (`trim_block_y`) to remove the
    diagram lip that sometimes leaks into the photo block."""
    blocks = []
    in_block = False
    block_start = 0
    empty_run = 0
    for y in range(y0, y1):
        if row_has_ink(im, x0, x1, y):
            if not in_block:
                in_block = True
                block_start = y
            empty_run = 0
        else:
            if in_block:
                empty_run += 1
                if empty_run >= gap_threshold:
                    blocks.append((block_start, y - empty_run))
                    in_block = False
    if in_block:
        blocks.append((block_start, y1 - 1))
    return blocks


def trim_block_y(im, x0, x1, y_top, y_bot):
    """Tighten a content block's vertical bounds by stripping leading/trailing
    rows that have only minimal ink (<1.5%). Removes the diagram-leakage tail
    that sometimes attaches to the bottom of a photo block."""
    while y_top < y_bot and not row_has_ink(im, x0, x1, y_top, 0.015):
        y_top += 1
    while y_bot > y_top and not row_has_ink(im, x0, x1, y_bot, 0.015):
        y_bot -= 1
    return y_top, y_bot


def split_photo_and_diagram(im, x0, x1, block_top, block_bot):
    """When a single content block is BOTH photo + diagram fused, split it.

    Strategy 1: look for an internal low-ink stretch (<5% pixels) ≥4 rows.
    Strategy 2 (fallback): use the longest internal LOWEST-ink window —
    diagrams have higher AVERAGE row-ink than photos (per pixel), but the
    transition row always has the local-minimum density.

    Returns (photo_bot, diagram_top) — or (None, None) when no fused-split
    is needed (block too short to be photo+diagram)."""
    block_h = block_bot - block_top
    if block_h < 160:
        return (None, None)

    # Strategy 1: longest stretch of low-density rows
    seam_y = None
    seam_len = 0
    cur_start = None
    scan_end = min(block_top + 230, block_bot - 30)
    for y in range(block_top + 60, scan_end):
        if not row_has_ink(im, x0, x1, y, 0.04):
            if cur_start is None:
                cur_start = y
        else:
            if cur_start is not None:
                run = y - cur_start
                if run >= 4 and run > seam_len:
                    seam_len = run
                    seam_y = cur_start + run // 2
                cur_start = None
    if cur_start is not None:
        run = scan_end - cur_start
        if run >= 4 and run > seam_len:
            seam_len = run
            seam_y = cur_start + run // 2

    if seam_y is not None:
        return (seam_y - seam_len // 2 - 2, seam_y + seam_len // 2 + 2)

    # Strategy 2: pick the row with absolute-lowest ink density in the
    # candidate seam zone (rows 100-200 from block_top). The photo+diagram
    # transition always dips here even when the gap is only 1-2 white rows.
    candidates = []
    for y in range(block_top + 100, min(block_top + 200, block_bot - 50)):
        d = sum(1 for x in range(x0, x1, 3)
                if any(c < 235 for c in im.getpixel((x, y))[:3]))
        candidates.append((d, y))
    if not candidates:
        return (None, None)
    candidates.sort()  # ascending by ink density
    seam_y = candidates[0][1]
    return (seam_y - 3, seam_y + 3)


def crop_page(pg, tags):
    src = f'{PAGES}/page_{pg:02d}.jpg'
    im = Image.open(src).convert('RGB')
    H = im.height
    tops = band_tops_for(im, len(tags))
    # band_bottom of band i is start of band i+1; the last band ends ~H-50
    bottoms = tops[1:] + [H - 50]
    photo_count = spec_count = 0
    for tag, top, bot in zip(tags, tops, bottoms):
        # PER_BAND_BOX absolute override — wins over all other dicts
        if (pg, tag) in PER_BAND_BOX:
            x0a, y0a, x1a, y1a = PER_BAND_BOX[(pg, tag)]
            im.crop((x0a, y0a, x1a, y1a)).save(
                f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)
            photo_count += 1
            continue
        # Density-based: photo body has ≥25% ink (dense product silhouette),
        # diagram tick-marks have <15% (thin lines). Find last dense row.
        ph_top = top + PHOTO_TOP_GAP
        band_h = bot - top
        scan_end = min(top + int(band_h * 0.65), bot - 5)
        px = im.load()
        last_dense = ph_top
        for y in range(ph_top, scan_end):
            ink = 0
            tot = 0
            for x in range(X0, X1, 3):
                r, g, b = px[x, y]
                tot += 1
                if r < 230 or g < 230 or b < 230:
                    ink += 1
            if (ink / tot) >= 0.25:
                last_dense = y
        ph_bot = min(last_dense + 8, bot - 5)
        # PER_BAND override is reserved for hand-tuned edge cases.
        if (pg, tag) in PER_BAND_PHOTO_H:
            ph_bot = ph_top + PER_BAND_PHOTO_H[(pg, tag)]
            photo = im.crop((X0, ph_top, PER_BAND_X1.get((pg, tag), X1), ph_bot))
            photo.save(f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)
            photo_count += 1
            sp_top = ph_bot + FIXED_SPEC_GAP
            sp_bot = bot - SPEC_BOTTOM_PAD
            if sp_bot - sp_top >= 40:
                spec = im.crop((X0, sp_top, X1, sp_bot))
                if not is_mostly_white(spec):
                    spec.save(f'{OUT}/spec_sml_p{pg:02d}_{tag}.jpg', quality=85)
                    spec_count += 1
            continue
        blocks = find_content_blocks(
            im, X0, X1, top + PHOTO_TOP_GAP, bot - SPEC_BOTTOM_PAD)
        if not blocks:
            continue
        # If the first block is suspiciously tall (>160 px), try to split it —
        # might be a photo+diagram fused by a too-small internal whitespace
        # (e.g. page 12 / page 13 where the gap is ~10px).
        b_top, b_bot = blocks[0]
        if b_bot - b_top > 160 and len(blocks) == 1:
            split_photo_bot, split_diag_top = split_photo_and_diagram(
                im, X0, X1, b_top, b_bot)
            if split_photo_bot is not None:
                # rewrite the block list as if it was always 2 blocks
                blocks = [(b_top, split_photo_bot), (split_diag_top, b_bot)]
                b_top, b_bot = blocks[0]
        # Photo from block 0
        ph_top, ph_bot = trim_block_y(im, X0, X1, b_top, b_bot)
        ph_top = max(ph_top - 2, top + PHOTO_TOP_GAP)
        ph_bot = min(ph_bot + 2, bot - 5)
        if ph_bot - ph_top < MIN_PHOTO_H:
            ph_bot = min(ph_top + MIN_PHOTO_H, bot - 5)
        photo = im.crop((X0, ph_top, PER_BAND_X1.get((pg, tag), X1), ph_bot))
        photo.save(f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)
        photo_count += 1
        # Diagram from block 1
        if len(blocks) >= 2:
            d_top, d_bot = trim_block_y(im, X0, X1, blocks[1][0], blocks[1][1])
            spec = im.crop((X0, max(d_top - 2, ph_bot + SPEC_TOP_PAD),
                            X1, min(d_bot + 4, bot - SPEC_BOTTOM_PAD)))
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
