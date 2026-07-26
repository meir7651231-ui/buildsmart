// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · מנוע-ההתראות ("דורש-טיפול") — PURE Dart, אפס Flutter.
//
// הדפוס מ-Maor `home/homeData.ts` (attentionItems/digestLines) — **הדפוס עובר,
// הקוד לא**: fan-in ממקורות-רבים → פריטים מדורגים (crit לפני warn) + deep-link
// + תקציר-בוקר. המקורות פה הם של **בנייה** (הזמנות-תקועות · אישורי-עובדים ·
// חופשות · בקשות-חשבון) — לא של עמותה; לוח-עברי נוטרל (אין ימי-הולדת בבנייה).
//
// טהור לגמרי: מקבל DTO-קלט שספק חיצוני חילץ מהמנועים החיים — אין קריאת-provider
// ואין DateTime.now() כאן (ה-ageDays מחושב בשכבת-הספק). כל תווית דרך termOf.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/org_config.dart' show OrgConfig, termOf;

/// חומרת-פריט — crit קודם ל-warn במיון הסופי.
enum AttentionSev { crit, warn }

/// פריט "דורש-טיפול" יחיד. [navTab] = טאב-המנהל שאליו מוביל לחיצה (0..3).
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

/// שורת-תקציר-בוקר. [urgent] מסמן את שורת-הראש הקריטית.
class DigestLine {
  const DigestLine({
    required this.key,
    required this.text,
    required this.navTab,
    this.urgent = false,
  });

  final String key;
  final String text;
  final int navTab;
  final bool urgent;
}

/// הזמנה-פתוחה עם ותק (הספק מחשב ageDays מ-createdAt מול now).
class AgingOrder {
  const AgingOrder(this.id, this.ageDays);
  final String id;
  final int ageDays;
}

/// קלט-המנוע — מה שהספק חילץ מהמנועים החיים. immutable כולו.
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

/// ותק שממנו הזמנה-פתוחה נחשבת "דורשת-טיפול" (warn), ומעליו — crit.
const int kAttnOrderWarnDays = 3;
const int kAttnOrderCritDays = 7;

/// גיבוב-אישורים שממנו התור נחשב קריטי (עומס מצטבר = דחוף). מתחתיו — warn.
const int kAttnApprovalsCritCount = 8;

/// הפריטים המדורגים. crit לפני warn ב**חלוקה-יציבה** (Dart `List.sort` אינו
/// יציב — לכן מפצלים ולא ממיינים: הסדר-הפנימי של כל קבוצה נשמר).
List<AttentionItem> attentionItems(AttentionInput inp, {required OrgConfig cfg}) {
  final out = <AttentionItem>[];

  // הזמנות-פתוחות ותיקות — ותק יורד; עד 3 פרטניות ואז פריט-צבירה אחד.
  final aging = [...inp.agingOrders]..sort((a, b) => b.ageDays - a.ageDays);
  final tagOrder = termOf(cfg, 'attn.tag.order', 'הזמנה');
  for (final o in aging.take(3)) {
    out.add(AttentionItem(
      key: 'order:${o.id}',
      tag: tagOrder,
      title: 'הזמנה ${o.id} ממתינה ${o.ageDays} ימים',
      sev: o.ageDays >= kAttnOrderCritDays ? AttentionSev.crit : AttentionSev.warn,
      navTab: 1,
    ));
  }
  if (aging.length > 3) {
    out.add(AttentionItem(
      key: 'order:more',
      tag: tagOrder,
      title: '+${aging.length - 3} הזמנות נוספות ממתינות',
      sev: AttentionSev.warn,
      navTab: 1,
    ));
  }

  // אישורי-עובדים ממתינים (משימות במצב "review") — פריט-צבירה, טאב ניהול.
  if (inp.pendingApprovals > 0) {
    out.add(AttentionItem(
      key: 'approvals',
      tag: termOf(cfg, 'attn.tag.approval', 'אישור'),
      title: inp.pendingApprovals == 1
          ? 'משימה אחת ממתינה לאישור'
          : '${inp.pendingApprovals} משימות ממתינות לאישור',
      sev: inp.pendingApprovals >= kAttnApprovalsCritCount
          ? AttentionSev.crit
          : AttentionSev.warn,
      navTab: 3,
    ));
  }

  // בקשות-חופשה ממתינות.
  if (inp.pendingVacations > 0) {
    out.add(AttentionItem(
      key: 'vacations',
      tag: termOf(cfg, 'attn.tag.vacation', 'חופשה'),
      title: inp.pendingVacations == 1
          ? 'בקשת חופשה אחת ממתינה'
          : '${inp.pendingVacations} בקשות חופשה ממתינות',
      sev: AttentionSev.warn,
      navTab: 3,
    ));
  }

  // בקשות-חשבון/תפקיד ממתינות (שרת בלבד — 0 בדמו, ואז אין פריט).
  if (inp.pendingAccountReqs > 0) {
    out.add(AttentionItem(
      key: 'accountReqs',
      tag: termOf(cfg, 'attn.tag.account', 'חשבון'),
      title: inp.pendingAccountReqs == 1
          ? 'בקשת חשבון אחת ממתינה'
          : '${inp.pendingAccountReqs} בקשות חשבון ממתינות',
      sev: AttentionSev.warn,
      navTab: 3,
    ));
  }

  // crit-לפני-warn, סדר-פנימי נשמר (חלוקה, לא מיון).
  return [
    ...out.where((a) => a.sev == AttentionSev.crit),
    ...out.where((a) => a.sev == AttentionSev.warn),
  ];
}

/// תקציר-בוקר קומפקטי: שורת-ראש קריטית (אם יש), שורה-לכל-מקור, אחרת "שקט".
List<DigestLine> digestLines(AttentionInput inp, {required OrgConfig cfg}) {
  final items = attentionItems(inp, cfg: cfg);
  final out = <DigestLine>[];

  final crit = items.where((a) => a.sev == AttentionSev.crit).toList();
  if (crit.isNotEmpty) {
    out.add(DigestLine(
      key: 'urgent',
      urgent: true,
      text: crit.length == 1
          ? '⚠ פריט קריטי אחד דורש טיפול'
          : '⚠ ${crit.length} פריטים קריטיים דורשים טיפול',
      navTab: crit.first.navTab,
    ));
  }
  if (inp.pendingApprovals > 0) {
    out.add(DigestLine(
      key: 'approvals',
      text: '${inp.pendingApprovals} משימות ממתינות לאישור',
      navTab: 3,
    ));
  }
  if (inp.pendingVacations > 0) {
    out.add(DigestLine(
      key: 'vacations',
      text: '${inp.pendingVacations} בקשות חופשה ממתינות',
      navTab: 3,
    ));
  }
  if (out.isEmpty) {
    out.add(const DigestLine(
      key: 'quiet',
      text: 'הכל מעודכן — אין משימות דחופות הבוקר',
      navTab: 0,
    ));
  }
  return out;
}
