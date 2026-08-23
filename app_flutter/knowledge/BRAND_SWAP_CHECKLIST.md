# צ'ק-ליסט החלפת-מותג — חברה חדשה מה-Clean (stage-3.2)

> **הקוד:** כל שם-החברה בקוד עובר דרך `lib/config/app_brand.dart` (`AppBrand.name/club/shareDomain`) —
> **קובץ אחד להחליף.** הצבעים: `lib/theme/tokens.dart` (`BsTokens.brand/brandDark`) — מקור-יחיד.
> הטקסטים בפריסה: שכבת-ה-Studio (`CfgText`, 869 אתרים) עוקפת הכל בזמן-ריצה.
> מה שלמטה הוא **מעטפת-הפלטפורמה** — קבצי-נכסים שמוחלפים ידנית פר-חברה (אין להם seam בקוד).

## 1 · מעטפת-ווב
- [ ] `web/index.html` — `<title>` (:21), `meta description` (:26), `apple-mobile-web-app-title` (:33)
- [ ] `web/manifest.json` — `name` / `short_name` / `description` (:2-8) + `theme_color`/`background_color`
      (חייבים להשתוות ל-`BsTokens.brand` החדש)
- [ ] `web/icons/` ×4 + `web/favicon.png` — סט-אייקונים של החברה

## 2 · אנדרואיד
- [ ] `android/app/src/main/AndroidManifest.xml` — `android:label` (:47)
- [ ] `android/app/src/main/res/mipmap-*/` ×5 dpi — אייקוני-launcher
- [ ] (release-eng) `applicationId` — `android/app/build.gradle` (:16,:22)

## 3 · iOS
- [ ] `ios/Runner/Info.plist` — `CFBundleDisplayName`/`CFBundleName` (:7-8,:15-16)
- [ ] `ios/Runner/Assets.xcassets/AppIcon.appiconset/` ×15 — אייקונים
- [ ] (release-eng) bundle-id

## 4 · שרת/פרויקט (release-engineering — לא קוד)
- [ ] פרויקט-Firebase נפרד → `lib/firebase_options.dart` חדש (flutterfire configure)
- [ ] `APP_PROFILE` — פרופיל-הבנייה של החברה (ראה `lib/state/app_profile.dart`):
      `CATALOG_BASE_URL` / `IMAGE_BASE_URL` של החברה (או ריק=ארוז)
- [ ] store-listing (`LAUNCH_PACKAGE/store-listing/` = התבנית)

## 5 · מה לא צריך להחליף (מטופל בקוד)
- ✅ כל מחרוזות-השם בקוד — `AppBrand` (פרוסת-3.2 ניתבה ~24 אתרים: כותרת-אפליקציה, onboarding,
  מועדון ×7, שיתופים ×5, PDF ×4, דוחות ×6, ערוץ-push, שם-בוט, טקסטים-משפטיים, דומיין-שיתוף)
- ✅ ה-wordmark העליון — `CfgText('home.topbar.brand')` (Studio)
- ✅ הפלטה — `BsTokens` (79 ליטרלי-אלפא ב-21 קבצים = phase-2 מתועד, לא חוסם)
- ✅ שדות-זהות משפטיים — `legal_texts.dart` מחזיק placeholders מכוונים (`[שם החברה]`)

## הערות
- ה-LLM prompts (assistant_intent/manager_copilot/edit_prompt) מזכירים את השם — לא-מוצג-למשתמש,
  יטופל בפרוסה עתידית אם יידרש.
- `package:buildsmart/...` (namespace הקוד) — בלתי-נראה-למשתמש, לא מוחלף.
