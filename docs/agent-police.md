# agent-police ב-buildsmart — מה הותקן ולמה

> הותקן 2026-11-07 באישור מאיר, בענף `claude/install-agent-police`, עם
> `npx --yes github:agentpolice/police install`. הסרה: `node .agent-police/bin/agent-police.mjs uninstall`.

## מה נכנס
| קובץ | תפקיד |
|---|---|
| `.agent-police/` | השופט עצמו. סוכנים לא אמורים לקרוא אותו, וה-hook חוסם קריאה שלו. |
| `harness.json` | הגדרת השער, כולל פקודת `verify` (פירוט בהמשך). |
| `.claude/settings.json` | נוספו hooks: `PreToolUse` (`*`), `UserPromptSubmit`, `PostToolUse` (AskUserQuestion), `Stop` (timeout 900s). ה-hooks הקיימים של הריפו (`session-start.sh`, `pre-tool.sh`) נשארו בלי שינוי. |
| `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/agent-police.mdc` | הנחיות "Verification gate" לסוכנים. |
| `.cursor/hooks.json`, `.codex/hooks.json`, `.github/hooks/agent-police.json` | אותו שער ב-Cursor, ב-Codex וב-Copilot. |
| `.gitignore` | נוסף `.harness/` (מצב מקומי, לא נכנס ל-commit). נוספה גם חריגה לתיקיית השופט: כללי השורש מתעלמים מ-`*.mjs` ומ-`package.json`, ובלי החריגה קוד השופט לא היה נכנס ל-git, וכל ה-hooks ב-clone אחר היו מפנים לקובץ שלא קיים. |

## מה **לא** נכנס, ובכוונה
- **`.githooks/pre-commit` ו-`.githooks/pre-push` הוחזרו למצב המקורי.** ההתקנה הוסיפה בראש כל אחד מהם בלוק
  `agent-police check`, אבל לפי ההוראה לא נוגעים ב-git hooks של הריפו (פרוטוקול-100-השערים). לכן אין
  כרגע אכיפה של השוטר דרך git hooks. האכיפה היא רק ב-hooks של הסוכנים (Claude/Cursor/Codex/Copilot).
  החלטה עתידית של מאיר: אם רוצים אכיפה גם ב-commit/push, מחזירים את 4 השורות.

## `verify` — subset מהיר, לא כל 6,034 הבדיקות
ההתקנה הגדירה `python3 -m unittest discover && npm --prefix rules_test test --silent`. הפקודה הזו לא תקינה:
`unittest` מוצא 0 בדיקות ויוצא עם קוד 5, כך שהשער היה נכשל תמיד, והוא גם לא בודק את קוד ה-Flutter בכלל.

חבילת ה-Flutter המלאה (6,034 בדיקות) רצה כ-16 דקות ב-CI. זה יותר מה-timeout של ה-Stop hook (900s),
ולכן ה-hook היה נחתך. לכן הוגדר:

```
bash scripts/gen_version.sh && cd app_flutter && flutter test --reporter=compact \
  test/knowledge_protocol_test.dart test/legal_screen_test.dart test/widget_test.dart
```

אלה 17 בדיקות: חוזה הידע/פרוטוקול, יושר טקסט-המשפט, ועליית ה-shell וה-dials. הן רצות בכ-35 שניות מקומית.
**החבילה המלאה ממשיכה לרוץ ב-CI** (`protocol-enforce.yml`, Gate 2) על כל PR ל-main.
`rules_test/` (חוקי Firestore) דורש Firebase emulator ולכן לא נכלל. השופט מציין את זה ב-"Not checked".

`flutter` חייב להיות ב-PATH. בסביבת הענן הוא נמצא ב-`/home/user/flutter/bin`, כמו ב-CLAUDE.md.

## אזהרות-סודות שההתקנה הציגה (קבצים שכבר היו בריפו לפני ההתקנה)
`bs-test-debug.keystore` הוא מפתח-בדיקה שנכנס לריפו בכוונה ואינו מפתח Play. מפתחות ה-Firebase
(`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) הם ציבוריים מעצם התכנון,
ומוגנים ב-App Check ובחוקים. נשאר לבדוק את `edge-proxy/worker.js`, `push_state_test.dart`
ו-`firebase-messaging-sw.js`. לא שיניתי אותם, כי זה מחוץ להיקף ההתקנה.
