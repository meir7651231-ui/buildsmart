// ⚛️ אטום-Dart (דרגת-חוזה) · attentionItems
// תפקיד: בונה רשימת פריטי-תשומת-לב (הזמנות-ותיקות / אישורים / חופשות / בקשות-חשבון),
//        עד-3 הזמנות פרטניות + פריט-צבירה, ולבסוף crit-לפני-warn (חלוקה, לא מיון).
// מוצא: buildsmart/app_flutter/lib/logic/attention_engine.dart:81-154 (חוק-4).
// אחים שהוטבעו/סוקטו (חוק-3):
//   • termOf(cfg, key, fallback) ⇒ שקע-פונקציה `termOf(key, fallback)` (מנטרל OrgConfig).
//   • kAttnOrderCritDays / kAttnApprovalsCritCount (const-מודול) ⇒ שקעים `orderCritDays`/`approvalsCritCount`.
//   • טיפוסי-שכן AttentionItem/AttentionInput/AgingOrder/AttentionSev ⇒ הוטבעו inline.
// טוהר: dart:core בלבד.

/// verbatim attention_engine.dart:81-154 (עם termOf/הספים כשקעים).
List<AttentionItem> attentionItems(
  AttentionInput inp, {required String Function(String) term, 
  required String Function(String key, String fallback) termOf,
  required int orderCritDays,
  required int approvalsCritCount,
}) {
  final out = <AttentionItem>[];

  final aging = [...inp.agingOrders]..sort((a, b) => b.ageDays - a.ageDays);
  final tagOrder = termOf('attn.tag.order', term('hzmnh'));
  for (final o in aging.take(3)) {
    out.add(AttentionItem(
      key: 'order:${o.id}',
      tag: tagOrder,
      title: '${term('xi_hzmnh')}${o.id}${term('xi_mmtynh')}${o.ageDays}${term('xi_ymym')}',
      sev: o.ageDays >= orderCritDays ? AttentionSev.crit : AttentionSev.warn,
      navTab: 1,
    ));
  }
  if (aging.length > 3) {
    out.add(AttentionItem(
      key: 'order:more',
      tag: tagOrder,
      title: '+${aging.length - 3}${term('xi_hzmnvt-nvspvt-mmtynvt')}',
      sev: AttentionSev.warn,
      navTab: 1,
    ));
  }

  if (inp.pendingApprovals > 0) {
    out.add(AttentionItem(
      key: 'approvals',
      tag: termOf('attn.tag.approval', term('ayshvr')),
      title: inp.pendingApprovals == 1
          ? term('mshymh-acht-mmtynh-layshvr')
          : '${inp.pendingApprovals}${term('xi_mshymvt-mmtynvt-layshvr')}',
      sev: inp.pendingApprovals >= approvalsCritCount
          ? AttentionSev.crit
          : AttentionSev.warn,
      navTab: 3,
    ));
  }

  if (inp.pendingVacations > 0) {
    out.add(AttentionItem(
      key: 'vacations',
      tag: termOf('attn.tag.vacation', term('chvpshh')),
      title: inp.pendingVacations == 1
          ? term('bksht-chvpshh-acht-mmtynh')
          : '${inp.pendingVacations}${term('xi_bkshvt-chvpshh-mmtynvt')}',
      sev: AttentionSev.warn,
      navTab: 3,
    ));
  }

  if (inp.pendingAccountReqs > 0) {
    out.add(AttentionItem(
      key: 'accountReqs',
      tag: termOf('attn.tag.account', term('chshbvn')),
      title: inp.pendingAccountReqs == 1
          ? term('bksht-chshbvn-acht-mmtynh')
          : '${inp.pendingAccountReqs}${term('xi_bkshvt-chshbvn-mmtynvt')}',
      sev: AttentionSev.warn,
      navTab: 3,
    ));
  }

  return [
    ...out.where((a) => a.sev == AttentionSev.crit),
    ...out.where((a) => a.sev == AttentionSev.warn),
  ];
}

// — טיפוסי-שכן מוטבעים —
enum AttentionSev { crit, warn }

class AgingOrder {
  const AgingOrder({required this.id, required this.ageDays});
  final String id;
  final int ageDays;
}

class AttentionInput {
  const AttentionInput({
    this.agingOrders = const [],
    this.pendingApprovals = 0,
    this.pendingVacations = 0,
    this.pendingAccountReqs = 0,
  });
  final List<AgingOrder> agingOrders;
  final int pendingApprovals;
  final int pendingVacations;
  final int pendingAccountReqs;
}

class AttentionItem {
  const AttentionItem({
    required this.key,
    required this.tag,
    required this.title,
    required this.sev,
    required this.navTab,
  });
  final String key;
  final String tag;
  final String title;
  final AttentionSev sev;
  final int navTab;
}
