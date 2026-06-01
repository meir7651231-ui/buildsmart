from PIL import Image
import os

PAGES = 'assets/huliot_smartlock/pages'
OUT = 'assets/huliot_smartlock/products'
os.makedirs(OUT, exist_ok=True)

# Per page: ordered list of section tags (top→bottom). Photo column = left.
# Section count drives even vertical division of the content area.
# tag letters a,b,c,d map to _huliotImageFor routing.
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
  24: ['a','b','c','d'],        # joker seal / transfer seal / joker nut / plug
  25: ['a','b','c'],            # SmartLock nut / reducer iron / iron nut
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
X0, X1 = 12, 250        # left photo column (excludes table)
TOP_FRAC = 0.72         # photo sits in top ~72% of each band

for pg, tags in SECTIONS.items():
    src = f'{PAGES}/page_{pg:02d}.jpg'
    im = Image.open(src)
    n = len(tags)
    band = (Y1 - Y0) / n
    for idx, tag in enumerate(tags):
        by0 = Y0 + idx*band
        by1 = by0 + band*TOP_FRAC
        crop = im.crop((X0, int(by0), X1, int(by1)))
        crop.save(f'{OUT}/sml_p{pg:02d}_{tag}.jpg', quality=85)
print('cropped', sum(len(v) for v in SECTIONS.values()), 'images')
