// ⚛️ אטום-Dart (דרגת-חוזה) · dataUrlMime
// מוצא: buildsmart/app_flutter/lib/services/task_photo.dart:297-306 (חצב-בינה · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// פרטי-במקור: `_dataUrlMime` — הוצא לחוזה כ-top-level ציבורי.
//
// קלט:  dataUrl — מחרוזת `data:<mime>;base64,…`.
// פלט:  ה-MIME (למשל `image/jpeg`), או null אם הקידומת פגומה.

/// ה-MIME של [dataUrl] מסוג `data:...;...`, או null בקידומת פגומה. טהור.
String? dataUrlMime(String dataUrl) {
  if (!dataUrl.startsWith('data:')) return null;
  final semi = dataUrl.indexOf(';');
  final comma = dataUrl.indexOf(',');
  if (semi <= 5 || comma <= semi) return null;
  return dataUrl.substring(5, semi);
}
