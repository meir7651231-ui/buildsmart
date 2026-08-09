# Danny & the Magic Book — code-generated 3D animation

`danny_magic_book.mp4` — 12s · 1080×1920 (9:16) · 30fps · H.264 + AAC.

סרטון תלת-ממד מסוגנן (low-poly) שנוצר כולו בקוד, ללא מודל וידאו ג׳נרטיבי:
דני מוצא ספר קסום מתחת למיטה, פותח אותו, הדפים מתעופפים מעצמם,
והמילים "BE WISE" מופיעות בזוהר זהוב.

## Pipeline

| קובץ | תפקיד |
|------|--------|
| `scene.html` | סצנת Three.js — חדר, דמות מרוגגת, ספר, חלקיקים, מצלמה. כל האנימציה היא פונקציה דטרמיניסטית טהורה של הזמן `t` (`window.renderFrame(t)` / `window.captureFrame(t)`). |
| `render.mjs` | Playwright (chromium headless) — מצלם 360 פריימים כ-PNG, במקביל על מספר עמודים. |
| `gen-audio.mjs` | פסקול פרוצדורלי — "פסנתר תיבת נגינה", טווינקלים, דפדופי דפים, whoosh. כותב `audio.wav`. |

## Rebuild

```bash
npm install three playwright-core ffmpeg-static
node render.mjs preview 0 6.5 11.5      # sample frames -> frames/preview_*.png
node render.mjs all 4                   # 360 frames on 4 workers -> frames/f####.png
node gen-audio.mjs                      # -> audio.wav
./node_modules/ffmpeg-static/ffmpeg -y -framerate 30 -i frames/f%04d.png -i audio.wav \
  -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k \
  -shortest -movflags +faststart danny_magic_book.mp4
```

הערות סביבה (Claude Code remote):

- דגל `--allow-file-access-from-files` נדרש ל-Chromium כדי לטעון ES-module מ-`file://`.
- ה-ffmpeg של Playwright תומך רק ב-WebM/VP8 — לכן `ffmpeg-static`.
- הרינדור דטרמיניסטי (PRNG עם seed) — אותם פריימים בכל worker ובכל ריצה.
