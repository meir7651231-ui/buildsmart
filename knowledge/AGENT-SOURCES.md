# 📍 מקורות-האמת לכל סוכן — קוד מול ידע

> נתקענו פעמיים על גרסאות: (1) golden-מסך-1 "לא נמצא" · (2) `smart_home_screen.dart` 833 מול 955 שורות. הכלל הזה מונע את שניהם.

## שני מקורות-אמת (לא לבלבל)
- **קוד = `claude/whats-happening-LyY9G`** — הענף החי. **כל** קריאת-קוד / בנייה / golden-input משם. **לעולם לא מעותק ישן בענף אחר.**
- **ידע = `claude/nice-volta-BSbVm`** — ה-SSOT: תוכניות · הנחיות · פירוקי-מסך (golden-MD) · סכמות. **כל** מפרט / golden / הנחיה משם.

## הכלל (pre-flight — לפני כל בנייה)
1. `git fetch origin claude/whats-happening-LyY9G` **וגם** `claude/nice-volta-BSbVm` — **טרי**.
2. **קוד-קלט** (golden-input · "ראה את הקוד") → מגרסת **whats-happening בלבד**.
3. **מפרט / golden / הנחיה** → מ-**nice-volta**.
4. **בונים על whats-happening** (שם הקוד). כלי-dev ב-`tools/` — גם על whats-happening.
5. **גרסה-לא-תואמת = הבלוקר, לא באג.** אם golden "לא נמצא" → הוא ב-nice-volta. אם line-count לא-תואם → קוד מגרסה שגויה (משוך whats-happening).

## למה
- "golden לא קיים" → הוא **תמיד** ב-nice-volta (‏`knowledge/`).
- "833 מול 955" → קוד **תמיד** מ-whats-happening, לא מענף-העבודה הישן שלך.

---

## ✂️ בלוק לכל סוכן — להעתקה
━━━━━━━━━━━━━━━━━━
מקורות-אמת (חובה לפני בנייה):
- **קוד** (לקרוא/לבנות/golden-input) → מ-`claude/whats-happening-LyY9G` **בלבד** (הגרסה החיה).
- **ידע/מפרט/golden/הנחיה** → מ-`claude/nice-volta-BSbVm` (‏`knowledge/`).
Pre-flight: `git fetch origin claude/whats-happening-LyY9G claude/nice-volta-BSbVm` (טרי). בונים על whats-happening.
אם golden "לא נמצא" → הוא ב-nice-volta. אם line-count/גרסה לא-תואם → משוך whats-happening. גרסה-לא-תואמת = בלוקר, לא באג.
━━━━━━━━━━━━━━━━━━
