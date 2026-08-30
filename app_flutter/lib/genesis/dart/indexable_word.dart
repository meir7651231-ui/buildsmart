// ⚛️ אטום-Dart (דרגת-חוזה) · indexableWord
// מוצא: buildsmart/app_flutter/lib/data/lipskey_catalog.dart:493-495 (חצב-AST · חוק-4 — התנהגות זהה, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס-import (אומת ע"י פותר-המזהים).
// מהות: האם מילה ארוכה-דיה כדי להיכנס למפתח-החיפוש.

bool indexableWord(String w, {required int kIndexMinWordLen}) => w.length >= kIndexMinWordLen;
