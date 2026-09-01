// ⚛️ אטום-Dart (דרגת-חוזה) · digestLines
// תפקיד: בניית שורות "תקציר-הבוקר" — פריט-דחוף (אם יש קריטיים), ממתינים-לאישור,
//        בקשות-חופשה, ואם ריק ⇒ שורת "הכל מעודכן". משמע מנוע-תשומת-הלב.
// מוצא: buildsmart/app_flutter/lib/logic/attention_engine.dart:155-193 (‏digestLines; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שסוקטו: `attentionItems(inp, cfg:)` הומר לשקע `attentionItems` (חוק-3; ה-inp/cfg נצרכים
//        רק שם ⇒ נבלעים בשקע-סגור). אחים-שהוטבעו: `DigestLine`(key/urgent/text/navTab) ⇒ record
//        inline; שדות-`AttentionInput` הנקראים-ישירות (pendingApprovals/pendingVacations) ⇒ פרמטרים;
//        ה-enum `AttentionSev.crit` צומצם לשדה-bool `crit` ברשומת-הפריט (רק הבחנת "קריטי" נצרכת).
//        ברירת-המחדל `urgent=false` (שורות לא-דחופות במקור השמיטו את הפרמטר) הוסקה ומוגדרת מפורשות.
//
// קלט:  pendingApprovals — מספר-ממתינים-לאישור (int).
//       pendingVacations — מספר-בקשות-חופשה (int).
//       attentionItems   — שקע: פריטי-תשומת-הלב `({bool crit, int navTab})` (כבר-סגור על inp/cfg).
// פלט:  List<DigestLine> (record) בסדר: [urgent?] [approvals?] [vacations?] | [quiet].

/// Morning-digest lines: an urgent roll-up (when any item is critical), pending
/// approvals, pending vacations; if none ⇒ an "all clear" line. `attentionItems`
/// injected, `AttentionSev.crit`→`crit`. Verbatim behaviour of attention_engine.dart:155-193.
List<({String key, bool urgent, String text, int navTab})> digestLines({required String Function(String) term, 
  required int pendingApprovals,
  required int pendingVacations,
  required List<({bool crit, int navTab})> Function() attentionItems,
}) {
  final items = attentionItems();
  final out = <({String key, bool urgent, String text, int navTab})>[];

  final crit = items.where((a) => a.crit).toList();
  if (crit.isNotEmpty) {
    out.add((
      key: 'urgent',
      urgent: true,
      text: crit.length == 1
          ? term('pryt-kryty-achd-dvrsh-typvl')
          : '⚠ ${crit.length}${term('xi_prytym-krytyym-dvrshym-typvl')}',
      navTab: crit.first.navTab,
    ));
  }
  if (pendingApprovals > 0) {
    out.add((
      key: 'approvals',
      urgent: false,
      text: '$pendingApprovals${term('xi_mshymvt-mmtynvt-layshvr')}',
      navTab: 3,
    ));
  }
  if (pendingVacations > 0) {
    out.add((
      key: 'vacations',
      urgent: false,
      text: '$pendingVacations${term('xi_bkshvt-chvpshh-mmtynvt')}',
      navTab: 3,
    ));
  }
  if (out.isEmpty) {
    out.add((
      key: 'quiet',
      urgent: false,
      text: term('hkl-mavdkn-ayn-mshymvt-dchvpvt-hbvkr'),
      navTab: 0,
    ));
  }
  return out;
}
