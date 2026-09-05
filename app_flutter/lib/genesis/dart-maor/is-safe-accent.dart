// חוט · is-safe-accent — האם מחרוזת היא ערך-הדגשה בטוח (hex/rgb/hsl/שם-צבע). חוזה: is-safe-accent.contract.md
// המרה מ-JS (new/atoms/is-safe-accent.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4). מוצא: maor/src/lib/config.ts:866-874.
// אפס-import (dart-core בלבד). שלושת ה-RegExp מעוגנים ^…$ בדיוק כמו המקור; דגל-i ⇒ caseSensitive:false.
bool isSafeAccent(String a) {
  return RegExp(r'^#([0-9a-fA-F]{3,4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(a) ||
      RegExp(r'^(?:rgb|rgba|hsl|hsla)\([0-9.,%\s/]+\)$', caseSensitive: false).hasMatch(a) ||
      RegExp(r'^[a-zA-Z]{3,20}$').hasMatch(a);
}
