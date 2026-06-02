from PIL import Image
import os

PAGES = 'assets/huliot_smartlock/pages'
OUT = 'assets/huliot_smartlock/products'
os.makedirs(OUT, exist_ok=True)

# Per page: ordered list of section tags (top→bottom). Photo column = left.
# Section count drives even vertical division of the content area.
# tag letters a,b,c,d map to _huliotImageFor routing.
## Page 27 (AQUA SLIM) has a UNIQUE layout — 2 product renders (330 + 700) on
## the right side and a thin strip drawing at the bottom; the standard band
## scheme (PHOTO_H from top of equal bands) doesn't fit. Hand-tuned crops below
## (CROPS_27) are applied AFTER the loop, overriding any generic SECTIONS entry.
CROPS_27 = {
  'a': (470, 195, 825, 315),   # Aqua Slim 330 render
  'b': (420, 440, 825, 540),   # Aqua Slim 700 render
  'c': (150, 870, 670, 920),   # פס ניקוז ללא סט (strip-only)
}

SECTIONS = {
  11: ['a','b','c'],            # pipe / cutter / joker
  12: ['a','b','c','d'],        # elbow oneside 15/30/45/90
  13: ['a','b','c'],            # elbow 45 / 90 / reducing 90
  14: ['a','b'],               # reducing-to-siphon / reducing socket
  15: ['a','b','c'],            # telescopic / tel oneside / tel-reducing oneside
  16: ['a','b'],               # tee 45 / tee reducing 45
  17: ['a','b'],               # tee 90 / tee reducing 90
  18: ['a','b'],               # double coupling / reducer
  19: ['a','b','c'],            # gutter 70-40 / 130 / 230
  20: ['a','b','c'],            # drop gutter 50 / 100 / 110
  21: ['a','b','c'],            # drain closed 80-50 / 140-50 / 245-50
  22: ['a','b'],               # drain open 140 / 245
  23: ['a','b'],               # kettle drain closed / open
  24: ['a','c','d'],            # joker seal (a) · joker nut (c) · plug (d) — 24_b
                                #   "אטם מעביר" is table-only (no photo); routing
                                #   reuses 24_a (shared seal). P5 removed unused crop.
  25: ['a','c'],                # SmartLock nut (a) · iron nut (c) — 25_b "מצרה
                                #   צד אחד חלק חיבור ברזל ופלסטיק" is table-only;
                                #   routing reuses 18_b (reducer). P5 removed crop.
  28: ['a','b','c','d'],        # raise square / Top Floor / cylindrical / temp round
  29: ['a','b','c','d'],        # round raised / fixed round / sq ext / sq int
  30: ['a','b','c','d'],        # grid raised / nickel / round / square
  31: ['a','b','c'],            # basin siphon / +measure / +AC
  32: ['a','b','c'],            # no-siphon / kitchen 2" / kitchen+dishwasher
  33: ['a','b'],               # double 2 inlets / double+side
  34: ['a','b'],               # american 1¼ / american 2"
  35: ['a','b'],               # american+dishwasher / double american
  36: ['a','b'],               # double+dishwasher / H washing
  37: ['a','b'],               # 1¼ washing / 1½ overflow
  38: ['a','b'],               # 1½ J / bathtub 2002
  39: ['a','b','c','d'],        # short basin / long basin / rosette / american inlet
  40: ['a','b','c'],            # siphon kit / slip pipe / inlet extension
  41: ['a','b','c'],            # long inlet / inlet+AC / american adapter
  42: ['a','b','c','d'],        # dishwasher set / funnel / vent / abik
  43: ['a','b','c'],            # plugs / plug set / wrench
}

Y0, Y1 = 140, 1200      # content area (below page top, above footer)
X0, X1 = 12, 238        # left photo column (P2: 250→238 trims table unit-icons)
# P1: the product render sits at the TOP of each section band at a roughly
# CONSTANT height regardless of band count (the L/DN dimension diagram + value
# table sit BELOW it). So crop a fixed photo height from each band top — this
# yields a clean product photo (front), not photo+diagram. Tall items (drains,
# cylinders) need a touch more; PHOTO_H=170 fits them without grabbing the
# diagram on dense 4-section pages (band≈265 → 95px diagram margin left out).
PHOTO_H = 170

for pg, tags in SECTIONS.items():
    src = f'{PAGES}/page_{pg:02d}.jpg'
    im = Image.open(src)
    n = len(tags)
    band = (Y1 - Y0) / n
    for idx, tag in enumerate(tags):
        by0 = Y0 + idx * band
        # photo height never exceeds the band itself (small bands stay in-band)
        by1 = by0 + min(PHOTO_H, band * 0.92)
        crop = im.crop((X0, int(by0), X1, int(by1)))
        crop.save(f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)

# Page 27 — apply hand-tuned crops (overrides any generic SECTIONS entry).
im27 = Image.open(f'{PAGES}/page_27.jpg')
for tag, box in CROPS_27.items():
    im27.crop(box).save(f'{OUT}/sml_p27_{tag}.jpg', quality=85)

print('cropped', sum(len(v) for v in SECTIONS.values()) + len(CROPS_27), 'images')
