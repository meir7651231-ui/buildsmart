// BS persona sub-section trees — verbatim port of
// app/src/components/bs/bs-dial.tsx (~200 leaves).
//
// Every emoji + Hebrew title is sourced from index.html (the 22K-line
// legacy prototype) with the @legacy line refs preserved from the
// original Preact comments. Do NOT invent any string here (R6/R8).

class Section {
  const Section({
    required this.id,
    required this.emoji,
    required this.title,
    this.children = const [],
  });

  final String id;
  final String emoji;
  final String title;
  final List<Section> children;

  bool get hasChildren => children.isNotEmpty;
}

/// @legacy index.html:4260-4263 (admTab buttons of screen-store).
/// s-home children: 3 shStat tiles @17128-17132
/// s-orders children: 3 soChip filters @17310-17313
/// s-stock children: 2 md-pmeta status labels @17914
/// s-portal children: 8 portal items @20762-20769
const List<Section> kStoreSections = [
  Section(
    id: 's-home',
    emoji: '🏠',
    title: 'בית',
    children: [
      Section(id: 'sh-prep',    emoji: '🔧', title: 'בהכנה'),
      Section(id: 'sh-ready',   emoji: '📦', title: 'מוכן לאיסוף'),
      Section(id: 'sh-revenue', emoji: '💰', title: 'מחזור פעיל'),
    ],
  ),
  Section(
    id: 's-orders',
    emoji: '📥',
    title: 'הזמנות',
    children: [
      Section(id: 'so-new',   emoji: '📥', title: 'לאישור'),
      Section(id: 'so-prep',  emoji: '🔧', title: 'בהכנה'),
      Section(id: 'so-ready', emoji: '📦', title: 'מוכנות'),
    ],
  ),
  Section(
    id: 's-stock',
    emoji: '📦',
    title: 'מלאי',
    children: [
      Section(id: 'ss-in',  emoji: '✅', title: 'זמין במלאי'),
      Section(id: 'ss-out', emoji: '❌', title: 'אזל'),
    ],
  ),
  Section(
    id: 's-portal',
    emoji: '🧰',
    title: 'פורטל',
    children: [
      Section(id: 'sp-ratings', emoji: '⭐',  title: 'דירוג ספקים'),
      Section(id: 'sp-sla',     emoji: '⏱️', title: 'מעקב SLA'),
      Section(id: 'sp-zones',   emoji: '🗺️', title: 'אזורי הפצה'),
      Section(id: 'sp-bulk',    emoji: '📉', title: 'הנחות כמות'),
      Section(id: 'sp-barcode', emoji: '🏷️', title: 'הפקת ברקודים'),
      Section(id: 'sp-fleet',   emoji: '🚛', title: 'ניהול צי רכב'),
      Section(id: 'sp-chat',    emoji: '💬', title: 'צ׳אט עם קבלן'),
      Section(id: 'sp-autostk', emoji: '🔄', title: 'עדכון מלאי'),
    ],
  ),
];

/// @legacy index.html:17991-18043 (renderCourierHome).
/// vehicle children: 3 HAUL_TYPES @11951-11953
/// active children: 3 ch-btn labels @18112-18114
/// portal children: 6 items in openCourierPortal @20787-20792
const List<Section> kCourierSections = [
  Section(
    id: 'vehicle',
    emoji: '🛵',
    title: 'הרכב שלי היום',
    children: [
      Section(id: 'haul-small', emoji: '🛵', title: 'משלוח קטן'),
      Section(id: 'haul-van',   emoji: '🚐', title: 'טנדר'),
      Section(id: 'haul-truck', emoji: '🚛', title: 'משאית'),
    ],
  ),
  Section(id: 'pickup', emoji: '📦', title: 'משלוחים ממתינים לאיסוף'),
  Section(
    id: 'active',
    emoji: '🚚',
    title: 'משלוחים פעילים',
    children: [
      Section(id: 'ca-pickup',    emoji: '📦', title: 'אספתי מהחנות'),
      Section(id: 'ca-transit',   emoji: '🚚', title: 'יצאתי לדרך'),
      Section(id: 'ca-delivered', emoji: '✅', title: 'נמסר ללקוח'),
    ],
  ),
  Section(
    id: 'portal',
    emoji: '🧰',
    title: 'פורטל השליח',
    children: [
      Section(id: 'cp-nav',   emoji: '🧭', title: 'ניווט למשלוח'),
      Section(id: 'cp-fleet', emoji: '🚛', title: 'צי רכב'),
      Section(id: 'cp-sla',   emoji: '⏱️', title: 'מעקב SLA'),
      Section(id: 'cp-zones', emoji: '🗺️', title: 'אזורי הפצה'),
      Section(id: 'cp-pod',   emoji: '📸', title: 'אישור מסירה'),
      Section(id: 'cp-chat',  emoji: '💬', title: 'צ׳אט עם חנות'),
    ],
  ),
];

/// @legacy index.html:8099-8102 (renderWorker task-group headers)
/// + :8048-8054 (taskStatusInfo). Each group filters to specific statuses
/// per :8096-8098.
const _stPending  = Section(id: 'st-pending',  emoji: '⏳', title: 'ממתינה');
const _stActive   = Section(id: 'st-active',   emoji: '🔨', title: 'בביצוע');
const _stReview   = Section(id: 'st-review',   emoji: '📸', title: 'ממתין לאישור');
const _stDone     = Section(id: 'st-done',     emoji: '✅', title: 'אושר ✓');
const _stRejected = Section(id: 'st-rejected', emoji: '↩️', title: 'נדחה — לתקן');

const List<Section> kWorkerSections = [
  Section(
    id: 'current',
    emoji: '🔨',
    title: 'המשימה הנוכחית שלך',
    children: [_stActive, _stRejected],
  ),
  Section(
    id: 'queue',
    emoji: '⏳',
    title: 'הבאות בתור',
    children: [_stPending],
  ),
  Section(
    id: 'submitted',
    emoji: '📋',
    title: 'שהגשת',
    children: [_stReview, _stDone],
  ),
];

/// @legacy index.html:4213-4216 (admTab buttons of screen-manager)
/// + :12160-12164 (לוח בקרה mdMetric tiles)
/// + ORDER_FLOW @16943 + ORDER_STAGE labels @12041-12048
/// + :16653-16745 (mmSection calls in renderMgrManage)
/// + :16608/:16617 (mc-pill labels + msd-tag).
const List<Section> kManagerSections = [
  Section(
    id: 'm-products',
    emoji: '📊',
    title: 'לוח בקרה',
    children: [
      Section(id: 'md-open-orders', emoji: '🚚', title: 'הזמנות פתוחות'),
      Section(id: 'md-catalog',     emoji: '📦', title: 'מוצרים בקטלוג'),
      Section(id: 'md-accessories', emoji: '🧰', title: 'אביזרים נלווים'),
      Section(id: 'md-available',   emoji: '✅', title: 'זמינים כעת'),
      Section(id: 'md-stores',      emoji: '🏪', title: 'חנויות פעילות'),
    ],
  ),
  Section(
    id: 'm-orders',
    emoji: '🚚',
    title: 'הזמנות',
    children: [
      Section(id: 'mo-new',       emoji: '📥', title: 'התקבלה'),
      Section(id: 'mo-preparing', emoji: '🔧', title: 'בהכנה'),
      Section(id: 'mo-ready',     emoji: '📦', title: 'מוכן לאיסוף'),
      Section(id: 'mo-pickup',    emoji: '🚛', title: 'נאסף'),
      Section(id: 'mo-transit',   emoji: '🚚', title: 'בדרך לאתר'),
      Section(id: 'mo-delivered', emoji: '✅', title: 'נמסר ✓'),
    ],
  ),
  Section(
    id: 'm-customers',
    emoji: '👥',
    title: 'לקוחות',
    children: [
      Section(id: 'mc-live', emoji: '🟢', title: 'פעיל'),
      Section(id: 'mc-low',  emoji: '⚠️', title: 'אשראי גבוה'),
    ],
  ),
  Section(
    id: 'm-manage',
    emoji: '🛠️',
    title: 'ניהול',
    children: [
      Section(id: 'mm-trees',      emoji: '🌳', title: 'עץ המוצרים'),
      Section(id: 'mm-brands',     emoji: '🏷️', title: 'מותגים ומחירים'),
      Section(id: 'mm-cats',       emoji: '🗂️', title: 'קטגוריות'),
      Section(id: 'mm-settings',   emoji: '⚙️', title: 'הגדרות אפליקציה'),
      Section(id: 'mm-regression', emoji: '🔬', title: 'בדיקות רגרסיה'),
    ],
  ),
];

/// Look-up table mirroring PERSONA_SECTIONS in bs-dial.tsx.
const Map<String, List<Section>> kPersonaSections = {
  'store':   kStoreSections,
  'courier': kCourierSections,
  'worker':  kWorkerSections,
  'manager': kManagerSections,
  // contractor — no sub-sections in legacy.
};

/// Walks the persona's tree along [path]; mirrors walkBsDrill().
({List<Section> anchors, List<Section> current}) walkBsDrill(
  String persona,
  List<String> path,
) {
  final anchors = <Section>[];
  var current = kPersonaSections[persona] ?? const <Section>[];
  for (final label in path) {
    final i = current.indexWhere((s) => s.title == label);
    if (i < 0) break;
    final node = current[i];
    if (!node.hasChildren) break;
    anchors.add(node);
    current = node.children;
  }
  return (anchors: anchors, current: current);
}
