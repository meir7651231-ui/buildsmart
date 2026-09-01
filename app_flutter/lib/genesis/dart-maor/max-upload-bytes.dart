// חוט · max-upload-bytes — תקרת-בייטים לקלט-תמונה גולמי. חוזה: max-upload-bytes.contract.md
// המרה מ-JS (new/atoms/max-upload-bytes.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// ערך בלבד (חוק-5): המספר לא יודע שהוא "תקרת-העלאה". אפס-import (dart-core בלבד).
// JS: 8 * 1024 * 1024 = 8388608. int של Dart שלם ומדויק בטווח זה.
const int maxUploadBytes = 8 * 1024 * 1024; // 8MB קלט גולמי — נכווץ בכל מקרה
