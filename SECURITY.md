# Security · אבטחה

## Reporting a vulnerability

Please **don't open a public issue** for a security problem.

Report it privately through GitHub: the repo's **Security** tab → **Report a vulnerability**.
If that button isn't shown, open an issue that only asks the maintainer to get in touch — with no details of the problem — and the details will be taken privately.

Helpful to include: what is affected (app, Cloud Functions, Firestore rules, edge proxy), steps to reproduce, and what an attacker could do.

## What's in scope

- `app_flutter/` — the mobile and web app
- `app/` — the live web version (Preact)
- `functions/` — Firebase Cloud Functions
- `firestore.rules` — database security rules (tested in `rules_test/`)
- `edge-proxy/` — the Cloudflare Worker

## Secrets

CI credentials (Firebase service account, Android signing key) are read from GitHub Actions secrets, not from files in the repo.
The Firebase config in `app_flutter/lib/firebase_options.dart` is client configuration that ships inside every app build; access is enforced by `firestore.rules` and the Cloud Functions, not by hiding it.
If you find a real secret committed to the repo, report it as above.

---

## דיווח על בעיית אבטחה

בבקשה **לא לפתוח issue ציבורי** על בעיית אבטחה.

דווחו בפרטיות דרך GitHub: לשונית **Security** בריפו ← **Report a vulnerability**.
אם הכפתור לא מופיע, פתחו issue שרק מבקש מהמתחזק ליצור קשר — בלי פרטי הבעיה — והפרטים יועברו בפרטיות.

כדאי לצרף: מה מושפע (האפליקציה, Cloud Functions, חוקי Firestore, מתווך-הקצה), צעדים לשחזור, ומה תוקף יכול לעשות.

## סודות

פרטי הגישה של ה-CI (חשבון השירות של Firebase, מפתח החתימה של Android) נקראים מ-GitHub Actions secrets, לא מקבצים בריפו.
הגדרות Firebase ב-`app_flutter/lib/firebase_options.dart` הן הגדרות-לקוח שנכללות בכל build של האפליקציה; ההרשאות נאכפות ב-`firestore.rules` וב-Cloud Functions.
מצאתם סוד אמיתי שנכנס לריפו? דווחו כמו למעלה.
