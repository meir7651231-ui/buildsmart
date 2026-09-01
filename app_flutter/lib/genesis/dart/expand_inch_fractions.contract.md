# חוזה · expandInchFractions

> אטום-Dart · נחצב אוטומטית ע"י חצב-AST (חוק-4 — verbatim מהמקור).

## מקור
buildsmart/app_flutter/lib/data/lipskey_catalog.dart:265-275

## התנהגות
Normalise unicode inch fractions so the size engine recognises them
(צעד 22): 1¼ → 1.25 · 1½ → 1.5 · 2½ → 2.5 · ¾ → 0.75 ...

## אימות
בדיקת-Golden (`expand_inch_fractions_test.dart`): אפיון דטרמיניסטי על סל-קלטים — הוקלט מהרצת הקוד-החלוץ. הרצה: `dart run --enable-asserts new/dart/expand_inch_fractions_test.dart`.
