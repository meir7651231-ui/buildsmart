# הנחיה: סגירת האתר להשקה (web/PWA) — בקבוצות

> **אושר ע"י הבעלים** (29/7: "נתחיל לסגור את האתר, בקבוצות, תשלח נחיל").
> **ביצוע:** `claude/whats-happening-LyY9G` · הצי · רב-פעמי · **עצור-לדיווח בין קבוצות.**
> **מטרה:** ה-web/PWA (buildsmart-il.com) **מוכן-להשקה-פומבית השבוע.**
> **מאומת:** אין `app_flutter/web/` מותאם → האתר על **אייקון+manifest ברירת-המחדל של Flutter (כחול)**. זה הפער המרכזי.

---

## 🥇 קבוצה 1 — מותג + PWA (הכי-דחוף · הופך אותו לאפליקציה-אמיתית)
- **אייקון-מותג** (במקום הכחול-של-Flutter): צור/עדכן `app_flutter/web/` + `web/icons/` עם אייקוני-מותג **כתומים** — `Icon-192`/`Icon-512`/`Icon-maskable-192/512` · `favicon.png` · `apple-touch-icon`.
- **`manifest.json`:** `name="בנייה חכמה"` · `short_name` · `theme_color` כתום · `background_color` · `display:"standalone"` · icons מלאים.
- **`index.html`:** `<title>` · `<meta description>` · `lang="he"` `dir="rtl"` · `apple-mobile-web-app-capable` + `-title` + `-status-bar`.
- **splash** ממותג + באנר **"הוסף למסך הבית"** (install-prompt).
- *(אם משתמשים ב-`flutter_launcher_icons`/`flutter_native_splash` — הוסף ל-pubspec והרץ; אחרת ידני ב-`web/`.)*

## קבוצה 2 — קונפיג-השקה על ה-web-החי
- ודא שהדיפלוי-החי (`web-deploy.yml`/`firebase-hosting.yml`) רץ עם: **backend-אמיתי · קטלוג-מהשרת · סטודיו owner-gated · org-config כפי-שהוחלט.** **ה-web-החי = חוויית-ההשקה בפועל.** הדפס את הדגלים ב-run-summary לאימות.

## קבוצה 3 — ליטוש-פומבי (זנבות Phase-B)
- כל **"בבנייה"/placeholder** שגלוי ל**משתמש-פומבי/לא-בעלים** על ה-web → **מוסתר** (זנבות B7 · עלים-מתים). **אפס-דאטה-מזויפת** למשתמש-אמת (אישור סריקת-fake-data).

## קבוצה 4 — SEO/שיתוף + דומיין
- **meta:** `title` · `description` · **OG-tags** (`og:title/description/image`) — כדי שכשמשתפים את הלינק זה נראה טוב · favicon.
- **דומיין:** בניהחכמה.ישראל + redirect + SSL (בעלים+הצי · DM2/DM3).

---

## 🛡️ בטיחות
כל קבוצה: **byte-verified · `central-verify` ירוק · לא-שובר-קיים · עצור-לדיווח.** האתר-החי לא-נשבר בין קבוצות.

## DoD
buildsmart-il.com = **PWA ממותג ניתן-להתקנה** (אייקון כתום, לא-Flutter · manifest אמיתי · install-prompt) · **קונפיג-השקה חי** · **אפס-placeholder-פומבי** · **meta-שיתוף**. **מוכן להשקה-פומבית.**
