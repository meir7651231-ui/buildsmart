# machtzev-gen — המחולל (gen-max) + קטלוג חלקיקי-פעולות-היסוד

הועבר לכאן כדי שיהיה נגיש מכל סשן (קישור-GitHub קבוע).

## מה יש כאן
- `gen-max.mjs` — המחולל (1,067 שורות). 20 מצבים.
- `master-particles.json` — 40,854 חלקיקי-פעולות-היסוד (7 ops), נחצבו מ-90,234 קבצים.
- `harvest-particles.mjs` — כלי-החציבה (יוצר את הקטלוג מכל ריפו/ענף).
- מסמכי-השוואה: `COMPARE-FULL.md` · `PORT-LIST.md` · `UPGRADES-ACCOUNTING.md`.
- כלי-לוואי: super-compose/monster · gen-merge/fold · max-best · *.max/*.restr/*.switch (artifacts).

## הרצה (מסשן אחר)
```bash
cd machtzev-gen
node gen-max.mjs --maxall            # מפקד: 783/5 מתוך 846
node gen-max.mjs --board-scan        # גרף-טיפוסים: 654 אטומים, 27,901 קשתות
node gen-max.mjs --board --from=OrgConfig --to=number   # מחבר שרשרת
node gen-max.mjs --deepfiles         # גלאי-באגי-נכונות
```
⚠️ `--board`/`--deepfiles` קוראים את קוד-מאור החי — צריך ריפו maor-system לצידו.

## 7 השדרוגים שלי מול המחצב — ראה PORT-LIST.md / UPGRADES-ACCOUNTING.md
