// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart Studio · Pillar 1 · Step 12 — the element registry.
//
// [ElementDescriptor] is the contract for ONE editable element. It carries the SIX
// governance fields (R1-A1) — editableProps · allowedActions · allowedValues ·
// kImmutable · kRoleFloor · kind — plus identity (id/screen/area/labelHe). The
// inspector lists descriptors; `validateSafe` (P4) gates every write against them.
//
// [findDescriptor] is FAIL-CLOSED: an id NOT in the registry ⇒ null ⇒ the inspector
// won't edit it and a publish validator rejects it (no vacuous green — R1-A1/R2-#15).
// `kElementRegistry` is `const` (zero runtime cost); [elementRegistryProvider] chains
// [domainElementsProvider] so Pillar-2's no-code domain builder can append rows.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bumped whenever the registry's SHAPE changes — lets Pillar-3 analytics annotate
/// funnels across builds without a full diff.
const int kElementRegistryVersion = 1;

/// The axes an element exposes for editing (mirrors the CfgNode axes).
enum EditAxis { text, emoji, hidden, order, style, action }

/// The broad kind of an element — drives which inspector panel + wrapper apply.
enum ElementKind { text, container, list, action, theme }

/// The contract for one editable element.
///
/// ⚠️ FROZEN (step 12.5 · seam-freeze before step 30) — Pillars 2/4/5 ground their
/// `validateSafe` on the six governance fields below. Changing/removing a field
/// needs a schema migration + an update to `descriptor_contract_test`; do NOT edit
/// the shape casually.
@immutable
class ElementDescriptor {
  const ElementDescriptor({
    required this.id,
    required this.screen,
    required this.area,
    required this.labelHe,
    required this.kind,
    this.editableProps = const {},
    this.allowedActions = const [],
    this.allowedValues = const {},
    this.kImmutable = false,
    this.kRoleFloor = 'contractor',
    this.wired = false,
  });

  // identity
  final String id;
  final String screen;
  final String area;
  final String labelHe;

  // the 6 governance fields (R1-A1)
  final ElementKind kind;
  final Set<EditAxis> editableProps;
  final List<String> allowedActions;
  final Map<String, List<String>> allowedValues;

  /// Critical — can never be hidden / action-rerouted (enforced in merge + publish).
  final bool kImmutable;

  /// The minimum canonical roleKey that may see/edit this element.
  final String kRoleFloor;

  /// Flipped true once a widget actually adopts this id (step 14 / Phase E); lets the
  /// inspector show "not yet wired" without a warn-scan.
  final bool wired;
}

/// The built-in elements. SEED set (pilot targets, `wired: false`); step 14 wraps the
/// widgets + flips them wired, and adopts the rest screen-by-screen.
const List<ElementDescriptor> kElementRegistry = [
  ElementDescriptor(
    id: 'cart.cta',
    screen: 'cart',
    area: 'checkout',
    labelHe: 'כפתור הזמנה (עגלה)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.emoji, EditAxis.style},
  ),
  // Step-14 pilot — the 5 cockpit KPI labels (manager_dashboard _MetricGrid), wired.
  ElementDescriptor(
    id: 'manager.cockpit.kpi.openOrders',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — הזמנות פתוחות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.products',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — מוצרים בקטלוג',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.accessories',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — אביזרים נלווים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.available',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — זמינים כעת',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.cockpit.kpi.stores',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'KPI — חנויות פעילות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // ── Phase-E content adoption (step 29) — high-value screen literals wrapped as
  // CfgText, the literal kept as the fallback (OFF ⇒ verbatim). Append-only.
  ElementDescriptor(
    id: 'manager.cockpit.copilot.title',
    screen: 'manager',
    area: 'cockpit',
    labelHe: 'כותרת קו-פיילוט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // catalog product-detail section headers (s29-b8).
  ElementDescriptor(
    id: 'catalog.detail.requiredStandards',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: תקינות נדרשת',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.detail.connectionNeeds',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: מה הקו צריך לחיבור',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.detail.acceptanceCheck',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: בדיקת קבלה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.detail.israeliStandard',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: תקן ישראלי רלוונטי',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.detail.commonMistakes',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: טעויות נפוצות וטיפים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // catalog misc labels (s29-b9).
  ElementDescriptor(
    id: 'catalog.detail.brandGuide',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: מתי לבחור איזה מותג',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.detail.recentlyViewed',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: נצפו לאחרונה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.card.productBadge',
    screen: 'catalog',
    area: 'card',
    labelHe: 'תג: מוצר',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.templates.label',
    screen: 'catalog',
    area: 'templates',
    labelHe: 'תווית: תבניות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.search.clearAll',
    screen: 'catalog',
    area: 'search',
    labelHe: 'כפתור: נקה הכל',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // catalog action buttons + data header (s29-b10).
  ElementDescriptor(
    id: 'catalog.detail.dataHeader',
    screen: 'catalog',
    area: 'detail',
    labelHe: 'כותרת: נתוני קטלוג',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.action.buildBom',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: בנה לי קו (BOM)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.action.addToProject',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: הוסף לפרויקט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.action.saveVersion',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: שמור גרסה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // catalog product-chip actions (s29-b11) — completes catalog static-text adoption.
  ElementDescriptor(
    id: 'catalog.action.proposal',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: הצעה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.action.draft',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: נסח',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'catalog.action.howToBridge',
    screen: 'catalog',
    area: 'action',
    labelHe: 'כפתור: איך לגשר?',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // ── Critical/protected set (step 26) — navigation + auth the owner may RENAME but
  // never hide or re-route. `kImmutable:true` is the canonical critical flag (R1-A1);
  // declared here (wired:false) so the merge defence + publish validator protect them
  // even before a widget adopts them (defence-in-depth — §8.1).
  ElementDescriptor(
    id: 'auth.login.cta',
    screen: 'welcome',
    area: 'auth',
    labelHe: 'כניסה (מסך פתיחה)',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'auth.logout',
    screen: 'app',
    area: 'auth',
    labelHe: 'התנתקות',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'nav.bottombar',
    screen: 'app',
    area: 'nav',
    labelHe: 'סרגל ניווט תחתון',
    kind: ElementKind.container,
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'manager.entry',
    screen: 'app',
    area: 'nav',
    labelHe: 'כניסת מנהל',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  ElementDescriptor(
    id: 'studio.exit',
    screen: 'studio',
    area: 'chrome',
    labelHe: 'יציאה מהסטודיו',
    kind: ElementKind.action,
    editableProps: {EditAxis.text},
    kImmutable: true,
  ),
  // ── Coverage round 1 — home_shell + store_dashboard adoptions (wired) ──
  ElementDescriptor(
    id: 'home.topbar.brand',
    screen: 'home',
    area: 'topbar',
    labelHe: 'לוגו/כותרת האפליקציה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'home.helpmode.banner',
    screen: 'home',
    area: 'helpmode',
    labelHe: 'באנר מצב היכרות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'home.newchat.title',
    screen: 'home',
    area: 'newchat',
    labelHe: 'כותרת "שיחה חדשה"',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'home.newchat.subtitle',
    screen: 'home',
    area: 'newchat',
    labelHe: 'כתובית בורר איש קשר',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'home.profilecard.editCta',
    screen: 'home',
    area: 'profile',
    labelHe: 'כפתור "ערוך פרופיל"',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.action.exit',
    screen: 'store',
    area: 'nav',
    labelHe: 'כפתור יציאה (חנות)',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.home.greeting',
    screen: 'store',
    area: 'home',
    labelHe: 'ברכת פתיחה (חנות)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.section.orders',
    screen: 'store',
    area: 'orders',
    labelHe: 'כותרת הזמנות (חנות)',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.action.newProduct',
    screen: 'store',
    area: 'stock',
    labelHe: 'כפתור הוסף-מוצר (מלאי)',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.addProduct.title',
    screen: 'store',
    area: 'addProduct',
    labelHe: 'כותרת גיליון מוצר',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.addProduct.category',
    screen: 'store',
    area: 'addProduct',
    labelHe: 'תווית קטגוריה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.action.addProduct',
    screen: 'store',
    area: 'addProduct',
    labelHe: 'כפתור שליחת מוצר',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.settings.title',
    screen: 'store',
    area: 'settings',
    labelHe: 'כותרת הגדרות ספק',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.settings.businessProfile',
    screen: 'store',
    area: 'settings',
    labelHe: 'כותרת פרופיל עסקי',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.settings.logo',
    screen: 'store',
    area: 'settings',
    labelHe: 'כותרת לוגו',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'store.action.captureLogo',
    screen: 'store',
    area: 'settings',
    labelHe: 'כפתור צלם/העלה לוגו',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  // ── Coverage round 2 — worker/courier/manager screen adoptions (wired) ──
  ElementDescriptor(
    id: 'worker.section.title',
    screen: 'worker',
    area: 'section',
    labelHe: 'כותרת עובד',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.exit',
    screen: 'worker',
    area: 'action',
    labelHe: 'יציאה',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.section.journal',
    screen: 'worker',
    area: 'section',
    labelHe: 'היומן שלי',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.fullMonth',
    screen: 'worker',
    area: 'action',
    labelHe: 'חודש מלא',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.checkEquipment',
    screen: 'worker',
    area: 'action',
    labelHe: 'בדוק ציוד',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.employerStock',
    screen: 'worker',
    area: 'action',
    labelHe: 'מלאי הקבלן',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.addTask',
    screen: 'worker',
    area: 'action',
    labelHe: 'הוסף משימה',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.gantt',
    screen: 'worker',
    area: 'action',
    labelHe: 'גאנט משימות',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.defects',
    screen: 'worker',
    area: 'action',
    labelHe: 'ליקויים',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.section.proposeTitle',
    screen: 'worker',
    area: 'section',
    labelHe: 'כותרת הצעת משימה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.propose.subtitle',
    screen: 'worker',
    area: 'propose',
    labelHe: 'תת-כותרת הצעה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.action.submit',
    screen: 'worker',
    area: 'action',
    labelHe: 'שלח לאישור',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.title',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כותרת דוחות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.weekly_title',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כותרת סיכום שבועי',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.time_title',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כותרת זמן למשימה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.area_title',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כותרת אזור עבודה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.time_empty',
    screen: 'worker',
    area: 'reports',
    labelHe: 'מצב-ריק זמנים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.area_note',
    screen: 'worker',
    area: 'reports',
    labelHe: 'הערת אזור',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.history_empty',
    screen: 'worker',
    area: 'reports',
    labelHe: 'מצב-ריק היסטוריה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.rejections_empty',
    screen: 'worker',
    area: 'reports',
    labelHe: 'מצב-ריק דחיות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.send_daily_button',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כפתור שליחת דוח יומי',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.ai_button',
    screen: 'worker',
    area: 'reports',
    labelHe: 'כפתור ניסוח דוח AI',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'worker.reports.send_note',
    screen: 'worker',
    area: 'reports',
    labelHe: 'הערת שליחת דוח',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.dash.appbar_title',
    screen: 'courier',
    area: 'dash',
    labelHe: 'כותרת סרגל השליח',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.dash.exit',
    screen: 'courier',
    area: 'dash',
    labelHe: 'כפתור יציאה',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.gate.vehicle_title',
    screen: 'courier',
    area: 'gate',
    labelHe: 'כותרת שער בחירת רכב',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.gate.vehicle_sub',
    screen: 'courier',
    area: 'gate',
    labelHe: 'תת-כותרת שער הרכב',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.dash.subtitle',
    screen: 'courier',
    area: 'dash',
    labelHe: 'תת-כותרת הבית',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.dash.vehicle_title',
    screen: 'courier',
    area: 'dash',
    labelHe: 'כותרת בורר הרכב',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.vehicle.preferred',
    screen: 'courier',
    area: 'vehicle',
    labelHe: 'תג רכב מועדף',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.notifs.title',
    screen: 'courier',
    area: 'notifs',
    labelHe: 'כותרת גיליון התראות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.notifs.empty',
    screen: 'courier',
    area: 'notifs',
    labelHe: 'מצב ריק בהתראות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.notifs.mark_all',
    screen: 'courier',
    area: 'notifs',
    labelHe: 'סמן הכל כנקרא',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.notifs.clear_all',
    screen: 'courier',
    area: 'notifs',
    labelHe: 'נקה הכל',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.title',
    screen: 'courier',
    area: 'settings',
    labelHe: 'כותרת הגדרות שליח',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.push',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג התראות Push',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.shipment_updates',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג עדכוני משלוחים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.new_chats',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג הודעות צ׳אט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.quiet_driving',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג שקט בנהיגה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.sound',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג צליל',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.vibration',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג רטט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.language',
    screen: 'courier',
    area: 'settings',
    labelHe: 'תווית בורר שפה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.text_size',
    screen: 'courier',
    area: 'settings',
    labelHe: 'תווית גודל טקסט',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.high_contrast',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג ניגודיות גבוהה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.settings.reduced_motion',
    screen: 'courier',
    area: 'settings',
    labelHe: 'מתג הנפשות מופחתות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.info.terms',
    screen: 'courier',
    area: 'info',
    labelHe: 'ניווט לתנאי שימוש',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.info.privacy',
    screen: 'courier',
    area: 'info',
    labelHe: 'ניווט למדיניות פרטיות',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.profile.title',
    screen: 'courier',
    area: 'profile',
    labelHe: 'כותרת מסך הפרופיל',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.profile.settings_title',
    screen: 'courier',
    area: 'profile',
    labelHe: 'פתיחת הגדרות שליח',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.profile.role_switch_title',
    screen: 'courier',
    area: 'profile',
    labelHe: 'החלפת תפקיד',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.profile.logout_title',
    screen: 'courier',
    area: 'profile',
    labelHe: 'יציאה מהחשבון',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.personal.attendance_title',
    screen: 'courier',
    area: 'personal',
    labelHe: 'נוכחות',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.personal.forms_title',
    screen: 'courier',
    area: 'personal',
    labelHe: 'טפסים',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.personal.certs_title',
    screen: 'courier',
    area: 'personal',
    labelHe: 'תעודות נהג',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.personal.payslips_title',
    screen: 'courier',
    area: 'personal',
    labelHe: 'תלושי שכר',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'courier.profile.save_action',
    screen: 'courier',
    area: 'profile',
    labelHe: 'שמירת פרופיל',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.dash.title',
    screen: 'manager',
    area: 'dash',
    labelHe: 'כותרת מרכז השליטה',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.dash.subtitle',
    screen: 'manager',
    area: 'dash',
    labelHe: 'תת-כותרת פרסונת המנהל',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.dash.exit',
    screen: 'manager',
    area: 'dash',
    labelHe: 'כפתור יציאה',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.dash.pipeline.title',
    screen: 'manager',
    area: 'dash',
    labelHe: 'כותרת צינור ההזמנות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.orders.advance',
    screen: 'manager',
    area: 'orders',
    labelHe: 'כפתור קידום שלב',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.orders.empty',
    screen: 'manager',
    area: 'orders',
    labelHe: 'מצב ריק — אין הזמנות',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.customers.empty',
    screen: 'manager',
    area: 'customers',
    labelHe: 'מצב ריק — אין קבלנים',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.manage.intro',
    screen: 'manager',
    area: 'manage',
    labelHe: 'באנר פתיח לטאב ניהול',
    kind: ElementKind.text,
    editableProps: {EditAxis.text, EditAxis.style, EditAxis.hidden},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.manage.roles.open',
    screen: 'manager',
    area: 'manage',
    labelHe: 'כפתור פתיחת שיוך תפקידים',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
  ElementDescriptor(
    id: 'manager.manage.regression.open',
    screen: 'manager',
    area: 'manage',
    labelHe: 'כפתור פתיחת בדיקות רגרסיה',
    kind: ElementKind.action,
    editableProps: {EditAxis.text, EditAxis.style},
    wired: true,
  ),
];

/// Pillar-2 (the no-code domain builder) overrides this to append domain elements.
/// Empty until then, so the registry is exactly [kElementRegistry].
final domainElementsProvider =
    Provider<List<ElementDescriptor>>((_) => const []);

/// SEAM 4 — FROZEN (step 30): Pillar-2 appends domain rows via
/// [domainElementsProvider]; the 6-field [ElementDescriptor] froze at step 12.5.
/// Pinned by `test/studio/seam_contract_test.dart`.
/// The full registry = built-ins ⊕ domain elements.
final elementRegistryProvider = Provider<List<ElementDescriptor>>(
  (ref) => [...kElementRegistry, ...ref.watch(domainElementsProvider)],
);

/// The critical/immutable set — every registered id flagged `kImmutable` (R1-A1).
/// SINGLE source for both the merge defence (resolve drops a hide/reroute on these)
/// and the publish validator, so the two can never drift (gate-118 · step 26).
final criticalIdsProvider = Provider<Set<String>>(
  (ref) => ref
      .watch(elementRegistryProvider)
      .where((d) => d.kImmutable)
      .map((d) => d.id)
      .toSet(),
);

/// FAIL-CLOSED lookup: returns null for an id not in [all] (the inspector then
/// refuses to edit it and the publish validator rejects it).
ElementDescriptor? findDescriptor(Iterable<ElementDescriptor> all, String id) {
  for (final d in all) {
    if (d.id == id) return d;
  }
  return null;
}

/// The descriptor for `id` across the live (built-in ⊕ domain) registry, or null.
final descriptorProvider = Provider.family<ElementDescriptor?, String>(
  (ref, id) => findDescriptor(ref.watch(elementRegistryProvider), id),
);
