# Image CDN — הקמת Cloudflare R2 (תשתית-תמונות סקיילבילית)

> **למה R2:** object-storage עם **egress (תעבורה) חינם** — הגשת-תמונות = הרבה תעבורה, וב-R2 לא משלמים
> עליה (בניגוד ל-S3/GCS/Firebase). free-tier: 10GB אחסון. S3-תקני, CDN מהיר, סקייל ל-100k+ תמונות.
>
> **עיקרון:** האפליקציה כבר נבנית **host-agnostic** — צריכה רק `kImageBaseUrl` (כתובת-בסיס HTTPS).
> עד שתגדיר אותה — האפליקציה משתמשת בתמונות-הארוזות (fallback). הגדרת ה-URL = ה-"flip" לרשת.

מקרא: ⬜ פעולה שלך (כשתרצה) · 🔧 בנצי מכין/מבצע.

---

## שלב A — ⬜ הקמת ה-bucket (חד-פעמי, ~10 דק', free-tier)
1. חשבון ב-**Cloudflare** (חינם) → לוח-הבקרה → **R2**.
2. **Create bucket** → שם: `buildsmart-images` (או כרצונך).
3. **Public access:** הפעל `r2.dev` public URL (לקריאה ציבורית) — או חבר דומיין משלך ל-CDN.
   → תקבל **base-URL**, למשל `https://pub-xxxx.r2.dev` (זה מה שתיתן לי).
4. **CORS** (אם ה-Web ייגש גם): אפשר `GET` מהמקורות של האפליקציה (origin של ה-PWA).
5. *(אופציונלי לכתיבה אוטומטית)* צור **API token** (R2 → Manage API Tokens) — נחוץ רק לסקריפט-העלאה (שלב C).

## שלב B — 🔧 חיבור באפליקציה (בנצי, רגע אחד)
- אגדיר `kImageBaseUrl = 'https://pub-xxxx.r2.dev'` (מה-שלב A) ב-config.
- ה-resolver (`resolveProductImage`) כבר ינתב כל תמונת-מוצר/עמוד אל `"$base/<relative-path>"`,
  עם cache מקומי (`cached_network_image`) + fallback לתמונה-הארוזה אם הרשת נכשלת.

## שלב C — 🔧 העלאת התמונות הקיימות (בנצי מכין סקריפט)
- מבנה היעד ב-R2 = **מראה של `assets/`** (אותם נתיבים יחסיים), כך שה-resolver מוצא הכול.
- אכין סקריפט (`rclone`/AWS-CLI S3-compatible) שמסנכרן את `app_flutter/assets/lipskey` + `assets/polyroll`
  אל ה-bucket. (כל קטלוג חדש בעתיד — אותו `sync`, וזהו.)
- מומלץ: להעלות **גם גרסה דחוסה (WebP)** — חוסך תעבורה ומקום; ה-resolver יבקש את ה-WebP.

## שלב D — מה נשאר ארוז באפליקציה (קטן)
אייקונים, glyphs של קטגוריות, placeholders — נשארים ב-`assets/` (קלים). **רק צילומי-המוצר ועמודי-הקטלוג
(המסה, ~98MB) עוברים ל-R2.** כך גודל-האפליקציה קטן וקבוע ללא תלות בגודל-הקטלוג.

---

## עלות (הערכה)
free-tier R2: 10GB אחסון + egress חינם. גם 100k תמונות דחוסות (~30KB) ≈ 3GB — **בתוך ה-free-tier או קרוב,
בעלות זניחה**. ההגשה (bandwidth) — חינם.

## מה זה משנה ב-data-safety (פאזה H)
התמונות נטענות מ-CDN (היה offline-מלא). עדיין **0 PII** — בקשת-GET לתמונה ציבורית בלבד.
לעדכן את `data-safety.md`: "product images fetched from CDN (no personal data)". (בנצי יעדכן עם ה-flip.)

*(נכתב ע״י בנצי/משיק. בלוקר יחיד: base-URL מ-שלב A. כל השאר מוכן/host-agnostic.)*
