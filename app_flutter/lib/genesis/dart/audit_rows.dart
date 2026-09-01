// ⚛️ אטום-Dart (דרגת-חוזה) · auditRows — סריקת-איכות של שורות-קטלוג: מזהה
//    שמות-כפולים (מק"ט שונה) ומק"טים-כמעט-זהים (הבדל רישיות/רווח בלבד).
// מוצא: buildsmart/app_flutter/lib/logic/data_quality.dart:56-90 (auditRows; חוק-4 —
//        התנהגות זהה-ביט למקור, לא-משופרת). המקור חולל אוטומטית מהאתר-החי (app_flutter)
//        ואינו בעץ-ה-git ⇒ טיפוסי-השכן שוחזרו מהשימוש המדויק בטיוטה (דיבר-9, מופחת-נאמן).
//
// אחים שהוטבעו/סוקטו:
//  • השכן normName(s) (נרמול-שם/מק"ט; נקרא 2× בגוף) ⇒ **שקע-פרמטר** named-required
//    (חוק-1/חוק-3: קריאה-לשכן ⇒ פרמטר-שקע, מתועד בחוזה). אינו יובא — מוזרק.
//  • טיפוסי-השכן QualityRow / QualityWarning / QualityReport (קטנים, האטום מקבל/מחזיר
//    אותם) ⇒ **הוטבעו inline** כמחלקות-נתונים אימוטביליות (חוק/דיבר: טיפוס-שכן קטן
//    ⇒ הטבעה). השדות והבנאים-הנקובים verbatim מהשימוש בטיוטה (r.line/r.name/r.key ·
//    QualityWarning(line/kind/message) · QualityReport(warnings/scanned)).
//
// תפקיד: לכל שורה מנרמל שם ומק"ט דרך השקע; שם-נורמל שכבר-נראה (לא-ריק) ⇒ אזהרת
//        'dup-name' (מפנה לשורה-הראשונה); מק"ט-נורמל שכבר-נראה (לא-ריק) ⇒ אזהרת
//        'near-key'. נורמל-ריק ⇒ מדולג. המפה נרשמת רק בהופעה-הראשונה ⇒ כל האזהרות
//        מפנות ל-first-occurrence (לא לקודמת). scanned = מספר-השורות-שנסרקו.
// קלט:  rows (List<QualityRow>) · השקע normName(String)⇒String. פלט: QualityReport.

/// שורת-קלט לסריקה. `line` = מספר-הפריט המוצג; `name`/`key` = שם ומק"ט גולמיים.
class QualityRow {
  final int line;
  final String name;
  final String key;
  const QualityRow({required this.line, required this.name, required this.key});
}

/// אזהרת-איכות. `kind` ∈ {'dup-name','near-key'}; `line` = השורה המפירה; `message` עברית.
class QualityWarning {
  final int line;
  final String kind;
  final String message;
  const QualityWarning({
    required this.line,
    required this.kind,
    required this.message,
  });
}

/// דוח-סריקה: רשימת-אזהרות + מספר-השורות שנסרקו.
class QualityReport {
  final List<QualityWarning> warnings;
  final int scanned;
  const QualityReport({required this.warnings, required this.scanned});
}

/// Audits catalog rows for duplicate names (different SKU) and near-duplicate SKUs
/// (differ only by case/whitespace). Both `name` and `key` are normalised through the
/// injected `normName` socket; the first occurrence of each normalised value is recorded,
/// every later match yields a warning pointing back at that first line. Empty-after-norm
/// values are skipped. Verbatim behaviour of data_quality.dart:56-90 with the sibling
/// `normName` injected (Law 1/3) and the neighbour types inlined.
QualityReport auditRows(
  List<QualityRow> rows, {required String Function(String) term, 
  required String Function(String) normName,
}) {
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
          message: '${term('pryt')}${r.line}${term('shm-zhh-lpryt')}$first${term('mkt-shvnh')}${r.name}"',
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
          message: '${term('pryt')}${r.line}${term('mkt-shvnh-rk-bryshyvtrvvch-mpryt')}$first',
        ));
      } else {
        firstByKey[nk] = r.line;
      }
    }
  }
  return QualityReport(warnings: warnings, scanned: rows.length);
}
