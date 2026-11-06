# Contributing · תרומה לפרויקט

Thanks for helping. This page says how work gets into the repo. · תודה שאתם עוזרים. כאן מוסבר איך עבודה נכנסת לריפו.

## Before you start · לפני שמתחילים

- **New features go to `app_flutter/` only.** `app/` (Preact) is live and takes bug fixes only (`CLAUDE.md`).
  פיצ'ר חדש — רק ב-`app_flutter/`. ב-`app/` מתקנים באגים בלבד.
- **Feature freeze until the store launch.** Fixes, tests and docs are welcome; new features wait. See [`ROADMAP.md`](ROADMAP.md).
  הקפאת פיצ'רים עד ההשקה. תיקונים, בדיקות ותיעוד — כן.
- **Hebrew UI text is copied verbatim** from the legacy prototype (`index.html`), never invented (rule R6, `app_flutter/README.md`).
  טקסט בממשק מועתק מילה במילה מאב-הטיפוס — לא ממציאים.
- Security problems: **don't open an issue** — see [`SECURITY.md`](SECURITY.md).

## Workflow · זרימת עבודה

1. Branch from `main` (`claude/<topic>` or `<you>/<topic>`). Never push to `main`.
2. Make the change. Keep it to one topic.
3. Run the checks below and paste the results into the PR.
4. Open a pull request against `main` — the template asks for the checks and the "CI on main" line.
5. A maintainer merges. Contributors don't merge their own PRs.

## Checks to run · בדיקות להרצה

```bash
bash scripts/gen_version.sh                          # needed before any Flutter build/test
cd app_flutter
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings  # must report 0 errors
flutter test --concurrency=4                          # full suite (6,034 tests on 2026-11-06)
flutter build web --release
```

Changed catalog data (`app_flutter/lib/data/**`) or `scripts/catalog_qa.py`? Also run:

```bash
python3 scripts/catalog_qa.py audit       # 0 blocking errors
python3 scripts/catalog_qa.py selftest    # the planted-error rules fire
python3 scripts/test_catalog_qa.py        # unit tests
```

Changed the Preact app (`app/`)? Also run `cd app && npm ci && npm run build`.

Changed `firestore.rules`? Run the rules tests in [`rules_test/`](rules_test/) (see its README).

## What CI checks · מה ה-CI בודק

| Workflow | When | Checks |
|---|---|---|
| `Protocol Enforcement` | PRs to `main` | `flutter analyze` + `flutter test` |
| `catalog-qa` | changes to catalog data | `selftest` + `audit` |
| `Deploy to GitHub Pages` | push to `main` | builds `app/` and the Flutter web preview |

## Writing style · סגנון כתיבה

- Commit messages: one line that says what changed, in Hebrew or English; details in the body.
- Docs: short sentences, facts you checked against the code, no invented numbers.
- Every claim about a number (tests, products, sizes) says which command produced it.
