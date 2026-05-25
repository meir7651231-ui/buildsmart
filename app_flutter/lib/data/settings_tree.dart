// Settings tree — @legacy index.html:6806 (renderSettings — 10 groups).
// Verbatim port of SETTINGS_ROWS + SETTINGS_SUB from
// app/src/components/menu/submenu-settings.tsx.
//
// Level 2: renderSettings() @6817-6875
// Level 3: SETTINGS_LABELS @6750-6757, openSecurityHub @21752-21762,
//          openServiceHub @22081-22090
// Level 4: secRBAC @21812-21813, secSession @21922, secEncryption
//          @21952-21957, secPrivacy @22018-22023, svcQtyCalc
//          @22289-22293, svcOnboarding @22374-22381

class SettingsNode {
  const SettingsNode({
    required this.label,
    this.children = const [],
  });

  final String label;
  final List<SettingsNode> children;

  bool get hasChildren => children.isNotEmpty;
}

class SettingsGroup {
  const SettingsGroup({
    required this.id,
    required this.label,
    required this.emoji,
    this.children = const [],
    this.isAction = false,
  });

  final String id;
  final String label;
  final String emoji;
  final List<SettingsNode> children;
  final bool isAction; // `reset` is an action — no sub-rows.
}

/// The 10 group rows shown at the root of "הגדרות מתקדמות".
/// Emoji chosen to evoke the Preact SVG meaning; the labels themselves
/// are verbatim from SETTINGS_ROWS.
const List<SettingsGroup> kSettingsGroups = [
  SettingsGroup(
    id: 'account',
    label: 'חשבון',
    emoji: '👤',
    children: [
      SettingsNode(label: 'שם הקבלן'),
      SettingsNode(label: 'טלפון'),
      SettingsNode(label: 'סוג עוסק'),
      SettingsNode(label: 'תחום מקצועי'),
    ],
  ),
  SettingsGroup(
    id: 'notifications',
    label: 'התראות',
    emoji: '🔔',
    children: [
      SettingsNode(label: 'עדכוני משלוחים'),
      SettingsNode(label: 'מבצעים והטבות'),
      SettingsNode(label: 'התראות תקציב'),
      SettingsNode(label: 'עדכוני הזמנות'),
    ],
  ),
  SettingsGroup(
    id: 'display',
    label: 'תצוגה',
    emoji: '🖥️',
    children: [
      SettingsNode(
        label: 'ערכת נושא',
        children: [SettingsNode(label: 'בהיר'), SettingsNode(label: 'כהה')],
      ),
      SettingsNode(
        label: 'גודל טקסט',
        children: [
          SettingsNode(label: 'קטן'),
          SettingsNode(label: 'בינוני'),
          SettingsNode(label: 'גדול'),
        ],
      ),
      SettingsNode(label: 'הפחתת אנימציות'),
    ],
  ),
  SettingsGroup(
    id: 'accessibility',
    label: 'נגישות',
    emoji: '♿',
    children: [
      SettingsNode(label: 'מצב ניגודיות גבוהה (לשמש)'),
    ],
  ),
  SettingsGroup(
    id: 'security',
    label: 'אבטחה והרשאות',
    emoji: '🛡️',
    children: [
      SettingsNode(
        label: 'מרכז האבטחה',
        children: [
          SettingsNode(label: 'אימות דו-שלבי'),
          SettingsNode(
            label: 'הרשאות גישה',
            children: [
              SettingsNode(label: 'קבלן'),
              SettingsNode(label: 'מנהל מערכת'),
              SettingsNode(label: 'ספק / חנות'),
              SettingsNode(label: 'שליח'),
              SettingsNode(label: 'עובד'),
            ],
          ),
          SettingsNode(label: 'כניסה ביומטרית'),
          SettingsNode(label: 'יומן ביקורת'),
          SettingsNode(label: 'הרשאת מיקום'),
          SettingsNode(
            label: 'נעילת הפעלה',
            children: [
              SettingsNode(label: '5 דק׳'),
              SettingsNode(label: '15 דק׳'),
              SettingsNode(label: '30 דק׳'),
              SettingsNode(label: '60 דק׳'),
            ],
          ),
          SettingsNode(
            label: 'הצפנת נתונים',
            children: [
              SettingsNode(label: 'תקשורת מוצפנת (HTTPS/TLS)'),
              SettingsNode(label: 'נתונים מקומיים מוגנים'),
              SettingsNode(label: 'סיסמאות מאוחסנות כ-Hash'),
              SettingsNode(label: 'גיבוי מוצפן בענן'),
            ],
          ),
          SettingsNode(label: 'היסטוריית כניסות'),
          SettingsNode(label: 'ניהול מכשירים'),
          SettingsNode(
            label: 'בקרת פרטיות',
            children: [
              SettingsNode(label: 'שיתוף נתוני שימוש'),
              SettingsNode(label: 'שירותי מיקום'),
              SettingsNode(label: 'התאמת תוכן שיווקי'),
              SettingsNode(label: 'שליחת דוחות תקלה'),
            ],
          ),
        ],
      ),
    ],
  ),
  SettingsGroup(
    id: 'support',
    label: 'שירות ותמיכה',
    emoji: '🎧',
    children: [
      SettingsNode(
        label: 'מרכז השירות',
        children: [
          SettingsNode(label: 'מוקד תמיכה'),
          SettingsNode(label: 'צ׳אטבוט'),
          SettingsNode(label: 'דיווח על באג'),
          SettingsNode(label: 'המרת מידות'),
          SettingsNode(
            label: 'מחשבון כמויות',
            children: [
              SettingsNode(label: 'אריחים'),
              SettingsNode(label: 'צבע'),
              SettingsNode(label: 'בטון'),
            ],
          ),
          SettingsNode(label: 'סנכרון יומן'),
          SettingsNode(label: 'לוח דרושים'),
          SettingsNode(
            label: 'סיור היכרות',
            children: [
              SettingsNode(label: 'מסך הבית'),
              SettingsNode(label: 'הזמנה'),
              SettingsNode(label: 'תקציב'),
              SettingsNode(label: 'משימות ואתר'),
              SettingsNode(label: 'מועדון BuildSmart'),
              SettingsNode(label: 'מוכנים!'),
            ],
          ),
        ],
      ),
    ],
  ),
  SettingsGroup(
    id: 'delivery',
    label: 'משלוח ותשלום',
    emoji: '🚚',
    children: [
      SettingsNode(
        label: 'סוג הובלה מועדף',
        children: [
          SettingsNode(label: 'משלוח קטן'),
          SettingsNode(label: 'טנדר'),
          SettingsNode(label: 'משאית'),
        ],
      ),
      SettingsNode(label: 'ברירת מחדל — משלוח אקספרס'),
      SettingsNode(label: 'אמצעי תשלום'),
    ],
  ),
  SettingsGroup(
    id: 'region',
    label: 'אזור ושפה',
    emoji: '🌐',
    children: [
      SettingsNode(
        label: 'שפה',
        children: [
          SettingsNode(label: 'עברית'),
          SettingsNode(label: 'العربية'),
          SettingsNode(label: 'English'),
        ],
      ),
      SettingsNode(
        label: 'יחידות מידה',
        children: [
          SettingsNode(label: 'מטרי (מ׳, ק״ג)'),
          SettingsNode(label: 'אימפריאלי'),
        ],
      ),
      SettingsNode(
        label: 'מטבע',
        children: [
          SettingsNode(label: '₪ שקל'),
          SettingsNode(label: r'$ דולר'),
        ],
      ),
    ],
  ),
  SettingsGroup(
    id: 'about',
    label: 'מידע',
    emoji: 'ℹ️',
    children: [
      SettingsNode(label: 'גרסה'),
      SettingsNode(label: 'תנאי שימוש'),
      SettingsNode(label: 'מדיניות פרטיות'),
      SettingsNode(label: 'יצירת קשר'),
    ],
  ),
  SettingsGroup(
    id: 'reset',
    label: 'איפוס לברירת מחדל',
    emoji: '🔄',
    isAction: true,
  ),
];

/// Walks the group's tree along `path` labels; mirrors walkSettings()
/// in app/src/components/menu/submenu-settings.tsx.
({List<SettingsNode> anchors, List<SettingsNode> current}) walkSettings(
  String groupId,
  List<String> path,
) {
  final group = kSettingsGroups.firstWhere(
    (g) => g.id == groupId,
    orElse: () => const SettingsGroup(id: '', label: '', emoji: ''),
  );
  final anchors = <SettingsNode>[];
  var current = group.children;
  for (final label in path) {
    final i = current.indexWhere((n) => n.label == label);
    if (i < 0) break;
    final node = current[i];
    if (!node.hasChildren) break;
    anchors.add(node);
    current = node.children;
  }
  return (anchors: anchors, current: current);
}
