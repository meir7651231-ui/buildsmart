// 🔌 מנוע-קטלוג-3D · פאזה B (שלב 33) — ניכוי-חיתוך Z: אורך-הצינור לחיתוך-בשטח
// בין שני אביזרים. טהור · מגודר (`features/fittings/`). היסוד לכתב-כמויות (פאזה C).
//
// המודל (INTEGRATION-SPEC §5.3): הצינור מגיע ל**תחתית-השקע**, ולכן
//   אורך-חיתוך = מרחק בין-מרכזים − Z₁ − Z₂
// כאשר Z (הניכוי פר-קצה) = (מרכז→פתח-השקע) − F = מרכז→תחתית-השקע. פר-משפחה:
//   · ברך:  Z = z            (z = l − F, אות-מנוע golden)
//   · מצמד: Z = A/2 − F
//   · טי:   רַץ Z = B/2       · הסתעפות Z = A − F
// משפחות א-סימטריות/קצה (מצרה/פקק/ברז/רוכב/צווארון/מתאם/מחותכת) → `null` כרגע
// (נגזרות בפרוסה נפרדת · מתועד) — לעולם לא ניכוי שגוי (M1).

import 'package:buildsmart/features/fittings/engine/fitting_dims.dart';

/// המשפחות שהניכוי מוגדר-להן חד-משמעית (אביזרי-רַץ סימטריים).
const Set<String> _kCutFamilies = {'ברך 90°', 'ברך 45°', 'מצמד', 'מסעף (טי)'};

/// ניכוי-החיתוך (מ״מ) שאביזר "אוכל" ממרחק-המרכזים בקצה נתון, או `null` כשלא-מוגדר.
/// ל-טי: [socket] = `'run'` (רַץ · ברירת-מחדל) או `'branch'` (הסתעפות).
double? cutDeductionFor(String family, int od, {String socket = 'run', int? od2}) {
  if (!_kCutFamilies.contains(family)) return null;
  final d = generate(family, od, od2: od2);
  final f = d['F'];
  if (f == null || f.isNaN) return null; // OD מחוץ-לטבלה → fallback
  switch (family) {
    case 'ברך 90°':
    case 'ברך 45°':
      return d['z']; // = l − F, כבר golden
    case 'מצמד':
      return r1(d['A']! / 2 - f);
    case 'מסעף (טי)':
      return socket == 'branch' ? r1(d['A']! - f) : r1(d['B']! / 2);
    default:
      return null;
  }
}

/// אורך-הצינור לחיתוך בין שני מרכזי-אביזר במרחק [centerToCenter], בהינתן
/// הניכויים בשני הקצוות. `אורך = מרכז↔מרכז − Z₁ − Z₂`, מעוגל ל-מ״מ-עשירון.
double pipeCutLength(double centerToCenter, double deduction1, double deduction2) =>
    r1(centerToCenter - deduction1 - deduction2);
