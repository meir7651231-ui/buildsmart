# SERVER-KICKOFF — חבילת-משימות להפעלת הצי (Backend / Firebase)

> **נקודת-כניסה אחת** להפעלת הצי על פרויקט-השרת. SSOT מפורט: `SPEC-server-connect-MICRO.md` (~48 מיקרו, S0–S9) + `SPEC-server-connect.md` (ארכיטקטורה). ענף: `claude/whats-happening-LyY9G`.

## 🎯 המטרה (משפט אחד)
לחבר את האפליקציה ל-Firebase החי דרך **drop-in** (`_local`→`_firebase`) ב-**cache-pattern** — כך ש**ה-interface (sync) וה-UI לא משתנים**, אבל הנתונים אמיתיים (Auth · Firestore · real-time · push).

## ✅ היסוד כבר מוכן (אל תקים מחדש)
- **Project:** `buildsmart-b0b78` (Spark).
- **Auth:** Phone + Email/Password מופעלים.
- **Firestore:** Standard · **me-west1 (Tel Aviv)** · Production mode (deny-by-default → דורש Rules).
- **Hosting + CI:** `firebase-hosting.yml` + `firebase.json` · secret `FIREBASE_SERVICE_ACCOUNT`.

## 🧭 סדר-העבודה (tracks)
**שלב A — חיבור SDK (חוסם הכל · סדרתי)**
- `S0.2` `flutterfire configure` → `firebase_options.dart` *(דורש Firebase CLI + גישת-פרויקט)*
- `S0.3` deps: firebase_core/auth/firestore/messaging/functions/app_check
- `S0.4` `main.dart`: `initializeApp` + Firestore persistence
- `S0.5` App Check

**שלב B — Authentication (אחרי A)** → `S1.1–S1.9`
טלפון-OTP · אימות-קוד · מייל-fallback · `authProvider` · role מ-custom-claims · `role_picker` רק לרב-תפקיד · logout · **מחיקת-חשבון (Apple דורש)** · set-role function.

**שלב C — שכבת-נתונים (אחרי A)**
- `S2` base `FirestoreCachedRepo<T>` (cache-pattern · שומר `all()` **sync**) + pilot=orders
- `S3` **×6 מקבילי** → `orders · customers · catalog(סטטי!) · site · stock · finance` — כל repo מממש את ה-interface הקיים מול Firestore
- `S4` real-time → chat threads/messages · orders snapshots

**שלב D — 🔒 אבטחה (לפני launch — קריטי)** → `S5.1–S5.8`
Security Rules per-collection (RBAC צד-שרת) + **emulator-tests** (חנות לא-קוראת-של-אחר · chat מבודד · credit חסום).

**שלב E — מקבילי אחרי A** → `S6` FCM push · `S7` R2 images · `S8` Cloud Functions · `S9` offline/sync.

## 🚦 גייט per-task (DoD)
1. `central-verify` ירוק: **analyze=0 · test pass · build · conformance**.
2. **לא להפוך interface ל-async** — cache-pattern שומר sync (drop-in).
3. **לא לגעת ב-UI** — רק data/providers.
4. **catalog (1,877) לא ב-Firestore** — bundle/R2 (אפס עלות-DB).
5. `grep-verify` מול ה-spec — **אפס המצאה**.

## 👤 דברי-console שתצטרך אתה (לאורך הדרך)
- **Blaze billing** — להעלות מכסת-SMS לפני launch (עכשיו 10/יום).
- **App Check** register (S0.5).
- **Deploy Security Rules** (אחרי S5) — או הצי דרך CI.

## 🚀 Prompt-הפעלה לצי (העתק כמו שהוא)
```
הפעל את הצי (9×9 · LAW #0) על פרויקט-השרת.
SSOT: knowledge/SERVER-KICKOFF.md + knowledge/SPEC-server-connect-MICRO.md (FOUNDATION READY · S0–S9).
ענף: claude/whats-happening-LyY9G.

התחל שלב A (S0.2→S0.5) סדרתי. אחריו פצל:
  • שלב C/S3 ל-6 fleets מקבילים: orders · customers · catalog · site · stock · finance
    — כל אחד מממש את ה-interface הקיים מול Firestore דרך cache-pattern (sync · drop-in · UI ללא-שינוי).
  • שלב E (S6/S7/S9) מקבילי לפי-צורך.
שלב B (Auth S1) אחרי A. שלב D (Security Rules S5) — לפני כל deploy פומבי, עם emulator-tests.

גייט per-task: central-verify (analyze+test+build+conformance) + grep-verify מול ה-spec.
catalog לא ב-Firestore. אל תהפוך interface ל-async. דווח checklist חי.
```

## תלויות (מבט-על)
```
A (S0) ─┬─→ B (S1 auth)
        ├─→ C (S2→S3×6→S4)
        └─→ E (S6/S7/S9)
A+B ────┴─→ D (S5 Rules — לפני launch!)
```
**אומדן:** ~48 מיקרו · 2–3 שבועות.
