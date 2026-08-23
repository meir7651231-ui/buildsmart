// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · קרנל-איכות-נתונים — PURE Dart, אפס Flutter.
//
// מעבר-איכות **אחרי-הפרסור**, לא-חוסם: הפרסור הקיים (company_catalog_import)
// כבר בעל ולידציה-אטומית (שגיאות חוסמות commit). כאן מוסיפים ערוץ **אזהרות**
// נפרד — דברים שאינם שגיאה-קשה אך מריחים כמו זבל-נתונים ושווים עין אנושית:
//   • כפילות-שם — שתי שורות עם אותו שם-מנורמל (normName) אך מק"ט שונה (ה-dedup
//     הקיים משווה מק"ט raw בלבד ⇒ מפספס "אותו מוצר, מק"ט אחר").
//   • מק"ט-כמעט-זהה — מק"ט שנבדל מקודמו רק ברישיות/רווח (normName מתנגש).
//
// גנרי בכוונה (QualityRow דק, לא כבול לישות) — ייבוא-לקוחות/ספק עתידי יעשה
// reuse. טהור ⇒ בר-בדיקה בלי Riverpod. הצרכן (גיליון-הייבוא) מגודר
// `catalog.validation`; כבוי ⇒ אף שורה לא נבדקת ⇒ זהה-בייטים.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/text_normalize.dart' show normName;

/// מבט-מינימלי על שורת-ייבוא לצורך ביקורת-איכות — מנותק מכל ישות ספציפית.
class QualityRow {
  const QualityRow({required this.line, required this.key, required this.name});

  final int line; // מיקום-הפריט (1-מבוסס) ברשימה שנסרקת
  final String key; // הזהות ל-dedup (מק"ט)
  final String name; // שם-התצוגה ל-dedup-מנורמל
}

/// אזהרת-איכות בודדת — לא-חוסמת.
class QualityWarning {
  const QualityWarning({
    required this.line,
    required this.kind,
    required this.message,
  });

  final int line; // השורה המדוּוחת
  final String kind; // 'dup-name' · 'near-key'
  final String message; // הודעה עברית מוכנה-לתצוגה
}

/// דוח-האיכות — אוסף אזהרות + סיכום.
class QualityReport {
  const QualityReport({required this.warnings, required this.scanned});

  final List<QualityWarning> warnings;
  final int scanned; // כמה שורות נסרקו

  int get flagged => warnings.length;
  bool get clean => warnings.isEmpty;

  /// כמה אזהרות מסוג נתון.
  int countOf(String kind) => warnings.where((w) => w.kind == kind).length;
}

/// סורק שורות-ייבוא ומחזיר אזהרות-איכות לא-חוסמות. טהור, דטרמיניסטי.
/// שם/מק"ט ריקים מדולגים (הפרסור כבר טיפל בחסרים כשגיאה-קשה).
QualityReport auditRows(List<QualityRow> rows) {
  final warnings = <QualityWarning>[];
  final firstByName = <String, int>{}; // normName(name) → השורה הראשונה
  final firstByKey = <String, int>{}; // normName(key)  → השורה הראשונה
  for (final r in rows) {
    final nn = normName(r.name);
    if (nn.isNotEmpty) {
      final first = firstByName[nn];
      if (first != null) {
        warnings.add(QualityWarning(
          line: r.line,
          kind: 'dup-name',
          message: 'פריט ${r.line} — שם זהה לפריט $first (מק"ט שונה): "${r.name}"',
        ));
      } else {
        firstByName[nn] = r.line;
      }
    }
    final nk = normName(r.key);
    if (nk.isNotEmpty) {
      final first = firstByKey[nk];
      if (first != null) {
        warnings.add(QualityWarning(
          line: r.line,
          kind: 'near-key',
          message: 'פריט ${r.line} — מק"ט שונה רק ברישיות/רווח מפריט $first',
        ));
      } else {
        firstByKey[nk] = r.line;
      }
    }
  }
  return QualityReport(warnings: warnings, scanned: rows.length);
}
