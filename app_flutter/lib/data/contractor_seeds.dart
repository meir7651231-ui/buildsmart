// Contractor "לוח קבלן" data seeds — verbatim from the prototype, per
// knowledge/port/proto/04-contractor-projects-tasks.md (§1/§3/§5/§9).
// T0.1 of knowledge/PLAN-contractor-completion.md (לוח-קבלן, שלב א׳).
//
// Immutable `const` seeds only. Mutable state (mute/orders/favorites…) lives in
// StateNotifiers (T0.2). All Hebrew strings + numbers are verbatim (R6/R8) — do
// NOT paraphrase. Sources are noted per block with their proto `[L####]` anchor.

// ─────────────────────────────────────────────────────────────────────────────
// §5 · SAFETY_TIPS (5) — proto [L19833]. Rotates daily: kSafetyTips[day % 5]
//     (siteSafety, §7.6). Each line is emoji + verbatim guidance.
// ─────────────────────────────────────────────────────────────────────────────
const List<String> kSafetyTips = [
  '🦺 לוודא קסדות ואפודים זוהרים לכל הנוכחים באתר.',
  '⚡ לנתק מתח לפני עבודה על מערכות חשמל.',
  '🪜 לבדוק יציבות פיגומים וסולמות לפני טיפוס.',
  '🧯 לוודא שעמדות כיבוי אש פנויות וזמינות.',
  '🕳️ לסמן ולגדר פתחים ובורות פתוחים.',
];

// ─────────────────────────────────────────────────────────────────────────────
// §3/§4 · Budget thresholds (finThresholds) — proto [L19633].
//   Level by pct = round(spent/total*100):  >=90 → 'חריגה קריטית' (cls 'x');
//   >=80 → 'התראת חריגה' (cls 'h'); else → 'תקין' (cls 'ok').
// ─────────────────────────────────────────────────────────────────────────────
class BudgetThreshold {
  final int pct;
  final String label;
  const BudgetThreshold(this.pct, this.label);
}

const List<BudgetThreshold> kBudgetThresholds = [
  BudgetThreshold(80, '80% — התראת חריגה ראשונית'),
  BudgetThreshold(90, '90% — חריגה קריטית — נדרש אישור'),
  BudgetThreshold(100, '100% — חריגה מלאה מהתקציב'),
];

/// Budget level label/class for a given pct (§4 finThresholds verbatim).
({String label, String cls}) budgetLevel(int pct) {
  if (pct >= 90) return (label: 'חריגה קריטית', cls: 'x');
  if (pct >= 80) return (label: 'התראת חריגה', cls: 'h');
  return (label: 'תקין', cls: 'ok');
}

// ─────────────────────────────────────────────────────────────────────────────
// §9b · PLAN_TYPES (4) — proto [L9658-9730]. Used by the "סרוק תוכנית" scan (T3).
//   Each item carries 3 store offers; `bestStore` (T0.3 helper) picks the lowest.
//   `tree` (when set) opens the smart product tree instead of a price block.
// ─────────────────────────────────────────────────────────────────────────────
class StoreOffer {
  final String store;
  final int price;
  const StoreOffer(this.store, this.price);
}

class ScanItem {
  final String name;
  final String meta;
  final String emoji;
  final String? tree; // smart-tree key (toilet/faucet/shower/cable/profile…)
  final List<StoreOffer> stores;
  const ScanItem({
    required this.name,
    required this.meta,
    required this.emoji,
    this.tree,
    required this.stores,
  });
}

class ScanZone {
  final String emoji;
  final String name;
  final int conf; // detection confidence %
  final List<ScanItem> items;
  const ScanZone({
    required this.emoji,
    required this.name,
    required this.conf,
    required this.items,
  });
}

class PlanType {
  final String key;
  final String label;
  final String icon;
  final String sub;
  final String summaryUnit;
  final List<String> steps; // 4 scan-progress lines (first+last shared)
  final List<ScanZone> zones;
  const PlanType({
    required this.key,
    required this.label,
    required this.icon,
    required this.sub,
    required this.summaryUnit,
    required this.steps,
    required this.zones,
  });
}

// Shared first/last scan steps (proto §9b note — identical across all types).
const String _scanFirst = 'סורק את התוכנית...';
const String _scanLast = 'משווה מחירים בחנויות...';

const List<PlanType> kPlanTypes = [
  // ── אינסטלציה (plumbing) · 4 zones ──
  PlanType(
    key: 'plumbing',
    label: 'אינסטלציה',
    icon: '🚿',
    sub: 'מים, ביוב, ניקוז',
    summaryUnit: 'נקודות אינסטלציה',
    steps: [
      _scanFirst,
      'מזהה סמלים סניטריים...',
      'מאתר נקודות מים וניקוז...',
      _scanLast,
    ],
    zones: [
      ScanZone(emoji: '🚽', name: 'נקודת אסלה — קיר צפוני', conf: 98, items: [
        ScanItem(
          name: 'אסלה תלויה — סט מושלם',
          meta: 'כולל מיכל סמוי · 6 אביזרים',
          emoji: '🚽',
          tree: 'toilet',
          stores: [
            StoreOffer('בנייני העיר', 789),
            StoreOffer('אבן קיסר', 740),
            StoreOffer('טמבור הום', 765),
          ],
        ),
      ]),
      ScanZone(emoji: '🚰', name: 'נקודת כיור — קיר מערבי', conf: 95, items: [
        ScanItem(
          name: 'ברז אמבטיה לכיור',
          meta: 'ברז סוללה · 6 אביזרים',
          emoji: '🚰',
          tree: 'faucet',
          stores: [
            StoreOffer('בנייני העיר', 205),
            StoreOffer('אבן קיסר', 189),
            StoreOffer('טמבור הום', 198),
          ],
        ),
        ScanItem(
          name: 'סיפון לכיור 1.1/4"',
          meta: 'ניקוז הכיור',
          emoji: '🌀',
          stores: [
            StoreOffer('בנייני העיר', 52),
            StoreOffer('אבן קיסר', 46),
            StoreOffer('טמבור הום', 49),
          ],
        ),
      ]),
      ScanZone(emoji: '🚿', name: 'מקלחת — פינה דרום-מזרחית', conf: 92, items: [
        ScanItem(
          name: 'סוללת מקלחת תרמוסטטית',
          meta: 'עם גוף סמוי · 5 אביזרים',
          emoji: '🚿',
          tree: 'shower',
          stores: [
            StoreOffer('בנייני העיר', 560),
            StoreOffer('אבן קיסר', 538),
            StoreOffer('טמבור הום', 520),
          ],
        ),
      ]),
      ScanZone(emoji: '🧺', name: 'נקודת מים — מכונת כביסה', conf: 81, items: [
        ScanItem(
          name: 'ברז מכונת כביסה 3/4"',
          meta: 'כולל אל-חזור',
          emoji: '🚰',
          stores: [
            StoreOffer('בנייני העיר', 41),
            StoreOffer('אבן קיסר', 38),
            StoreOffer('טמבור הום', 44),
          ],
        ),
        ScanItem(
          name: 'צינור ניקוז למכונה',
          meta: 'מומלץ — נשכח לעיתים',
          emoji: '🌀',
          stores: [
            StoreOffer('בנייני העיר', 26),
            StoreOffer('אבן קיסר', 24),
            StoreOffer('טמבור הום', 25),
          ],
        ),
      ]),
    ],
  ),

  // ── חשמל (electrical) · 3 zones ──
  PlanType(
    key: 'electrical',
    label: 'חשמל',
    icon: '⚡',
    sub: 'נקודות, שקעים, לוח',
    summaryUnit: 'נקודות חשמל',
    steps: [
      _scanFirst,
      'מזהה סמלי חשמל...',
      'מאתר נקודות ומעגלים...',
      _scanLast,
    ],
    zones: [
      ScanZone(emoji: '🔲', name: 'לוח חשמל — כניסה', conf: 97, items: [
        ScanItem(
          name: 'לוח חשמל 24 מודולים',
          meta: 'כולל פסי צבירה',
          emoji: '🔲',
          stores: [
            StoreOffer('חשמל ישיר', 420),
            StoreOffer('אבן קיסר', 389),
            StoreOffer('טמבור הום', 405),
          ],
        ),
        ScanItem(
          name: 'מאמ"תים + ממסר פחת',
          meta: 'הגנת המעגלים',
          emoji: '⚙️',
          stores: [
            StoreOffer('חשמל ישיר', 295),
            StoreOffer('אבן קיסר', 268),
            StoreOffer('טמבור הום', 280),
          ],
        ),
      ]),
      ScanZone(emoji: '💡', name: 'נקודת מאור — מרכז התקרה', conf: 94, items: [
        ScanItem(
          name: 'כבל חשמל 3×1.5',
          meta: "גליל 100 מ' · מעגל תאורה",
          emoji: '🟧',
          tree: 'cable',
          stores: [
            StoreOffer('חשמל ישיר', 310),
            StoreOffer('אבן קיסר', 289),
            StoreOffer('טמבור הום', 299),
          ],
        ),
        ScanItem(
          name: 'בית מנורה + מתג',
          meta: 'נקודת ההדלקה',
          emoji: '💡',
          stores: [
            StoreOffer('חשמל ישיר', 54),
            StoreOffer('אבן קיסר', 48),
            StoreOffer('טמבור הום', 51),
          ],
        ),
      ]),
      ScanZone(emoji: '🔌', name: '2× נקודות שקע — קירות', conf: 88, items: [
        ScanItem(
          name: 'שקע כפול מוגן',
          meta: '×2 — לפי התוכנית',
          emoji: '🔌',
          stores: [
            StoreOffer('חשמל ישיר', 38),
            StoreOffer('אבן קיסר', 33),
            StoreOffer('טמבור הום', 36),
          ],
        ),
        ScanItem(
          name: 'קופסאות התקנה + שרוול',
          meta: 'הכנת הנקודות בקיר',
          emoji: '⬛',
          stores: [
            StoreOffer('חשמל ישיר', 62),
            StoreOffer('אבן קיסר', 57),
            StoreOffer('טמבור הום', 60),
          ],
        ),
      ]),
    ],
  ),

  // ── אדריכלות (architectural) · 3 zones ──
  PlanType(
    key: 'architectural',
    label: 'אדריכלות',
    icon: '🏛️',
    sub: 'קירות, גבס, פתחים',
    summaryUnit: 'אלמנטי בנייה',
    steps: [
      _scanFirst,
      'מזהה קירות ומחיצות...',
      'מחשב שטחים ואורכים...',
      _scanLast,
    ],
    zones: [
      ScanZone(emoji: '🧱', name: "מחיצת גבס — אורך 3.40 מ'", conf: 96, items: [
        ScanItem(
          name: 'פרופיל גבס 70 מ"מ',
          meta: 'שלד המחיצה · 5 אביזרים',
          emoji: '⬜',
          tree: 'profile',
          stores: [
            StoreOffer('בנייני העיר', 26),
            StoreOffer('אבן קיסר', 24),
            StoreOffer('גבס מרכז', 25),
          ],
        ),
        ScanItem(
          name: 'לוח גבס ירוק 12.5 מ"מ',
          meta: 'עמיד לחות — חדר רטוב',
          emoji: '🟩',
          stores: [
            StoreOffer('בנייני העיר', 58),
            StoreOffer('אבן קיסר', 52),
            StoreOffer('גבס מרכז', 55),
          ],
        ),
      ]),
      ScanZone(emoji: '🧱', name: "מחיצת גבס — אורך 2.10 מ'", conf: 91, items: [
        // proto abbreviated this profile's stores as `[...,24,...]` — identical
        // product to zone-1's profile, so the same [26,24,25] offers apply.
        ScanItem(
          name: 'פרופיל גבס 70 מ"מ',
          meta: 'שלד המחיצה',
          emoji: '⬜',
          tree: 'profile',
          stores: [
            StoreOffer('בנייני העיר', 26),
            StoreOffer('אבן קיסר', 24),
            StoreOffer('גבס מרכז', 25),
          ],
        ),
        ScanItem(
          name: 'צמר סלעים לבידוד',
          meta: 'בידוד אקוסטי',
          emoji: '🧵',
          stores: [
            StoreOffer('בנייני העיר', 44),
            StoreOffer('אבן קיסר', 39),
            StoreOffer('גבס מרכז', 42),
          ],
        ),
      ]),
      ScanZone(emoji: '🚪', name: 'פתח דלת — קיר צפוני', conf: 84, items: [
        ScanItem(
          name: 'משקוף + כנף דלת',
          meta: 'פתח סטנדרטי 80 ס"מ',
          emoji: '🚪',
          stores: [
            StoreOffer('בנייני העיר', 520),
            StoreOffer('אבן קיסר', 485),
            StoreOffer('גבס מרכז', 499),
          ],
        ),
      ]),
    ],
  ),

  // ── גמר (finishing) · 3 zones ──
  PlanType(
    key: 'finishing',
    label: 'גמר',
    icon: '🎨',
    sub: 'ריצוף, חיפוי, צבע',
    summaryUnit: 'אזורי גמר',
    steps: [
      _scanFirst,
      'מזהה אזורי ריצוף וחיפוי...',
      'מחשב שטחים נדרשים...',
      _scanLast,
    ],
    zones: [
      ScanZone(emoji: '🟫', name: 'ריצוף רצפה — 8.5 מ"ר', conf: 95, items: [
        ScanItem(
          name: 'אריחי גרניט פורצלן 60×60',
          meta: '14 מ"ר כולל פחת',
          emoji: '⬜',
          stores: [
            StoreOffer('בנייני העיר', 95),
            StoreOffer('אבן קיסר', 89),
            StoreOffer('קרמיקה פלוס', 92),
          ],
        ),
        ScanItem(
          name: 'דבק אריחים גמיש',
          meta: '8 שקים · התקנת רצפה',
          emoji: '🪣',
          stores: [
            StoreOffer('בנייני העיר', 56),
            StoreOffer('אבן קיסר', 52),
            StoreOffer('קרמיקה פלוס', 54),
          ],
        ),
      ]),
      ScanZone(emoji: '🪨', name: 'חיפוי קיר — 6.2 מ"ר', conf: 90, items: [
        ScanItem(
          name: 'קרמיקת חיפוי 25×40',
          meta: '8 מ"ר כולל פחת',
          emoji: '🟧',
          stores: [
            StoreOffer('בנייני העיר', 72),
            StoreOffer('אבן קיסר', 66),
            StoreOffer('קרמיקה פלוס', 69),
          ],
        ),
        ScanItem(
          name: 'רובה אפוקסי',
          meta: 'מילוי מישקים עמיד מים',
          emoji: '🎨',
          stores: [
            StoreOffer('בנייני העיר', 82),
            StoreOffer('אבן קיסר', 78),
            StoreOffer('קרמיקה פלוס', 80),
          ],
        ),
      ]),
      ScanZone(emoji: '🎨', name: 'צביעת תקרה ושטחים יבשים', conf: 83, items: [
        ScanItem(
          name: 'צבע אקרילי לבן',
          meta: '2 דליים · 2 שכבות',
          emoji: '🪣',
          stores: [
            StoreOffer('בנייני העיר', 168),
            StoreOffer('אבן קיסר', 149),
            StoreOffer('קרמיקה פלוס', 158),
          ],
        ),
      ]),
    ],
  ),
];

/// Index of the lowest-price store offer (proto §9c, L9747).
/// Returns 0 for an empty list (defensive; callers pass non-empty `stores`).
int bestStore(List<StoreOffer> stores) {
  if (stores.isEmpty) return 0;
  var best = 0;
  for (var i = 1; i < stores.length; i++) {
    if (stores[i].price < stores[best].price) best = i;
  }
  return best;
}

// ─────────────────────────────────────────────────────────────────────────────
// §3a · Project budget — proto [L7150-7152]. total/spent + 4 categories
//   (Σ categories == spent). Used by budget box/detail (T6 alerts, T19 budget).
// ─────────────────────────────────────────────────────────────────────────────
class BudgetCategory {
  const BudgetCategory(this.name, this.icon, this.amount);
  final String name;
  final String icon;
  final int amount;
}

const int kBudgetTotal = 15000;
const int kBudgetSpent = 9840; // == sum(kBudgetCategories.amount)
const List<BudgetCategory> kBudgetCategories = [
  BudgetCategory('אינסטלציה', '🔧', 3740),
  BudgetCategory('חשמל', '⚡', 2660),
  BudgetCategory('גמר', '🎨', 2070),
  BudgetCategory('אחר', '📦', 1370),
];

// ─────────────────────────────────────────────────────────────────────────────
// §1 · Home department tiles (8) — proto [L4443-4453]. (icon + verbatim name.)
// ─────────────────────────────────────────────────────────────────────────────
class DeptTile {
  const DeptTile(this.icon, this.name);
  final String icon;
  final String name;
}

const List<DeptTile> kDeptTiles = [
  DeptTile('🔧', 'כלי עבודה'),
  DeptTile('🚿', 'אינסטלציה'),
  DeptTile('⚡', 'חשמל'),
  DeptTile('🧱', 'בנייה'),
  DeptTile('🎨', 'גמר וצבע'),
  DeptTile('🔩', 'חיבורים'),
  DeptTile('🦺', 'בטיחות'),
  DeptTile('➕', 'הכל'),
];

// ─────────────────────────────────────────────────────────────────────────────
// Formatting helpers (T0.3) — `fMoney` (proto finMoney) + `caToday`.
// ─────────────────────────────────────────────────────────────────────────────
/// '₪' + thousands-separated integer (e.g. 9840 → "₪9,840"). Proto finMoney.
String fMoney(num v) {
  final neg = v < 0;
  final digits = v.round().abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${neg ? '-' : ''}₪$buf';
}

/// Today's date as DD/MM/YYYY (proto `caToday`; the prototype's exact glyph
/// format isn't transcribed in proto/04 — standard he-IL numeric date used).
String caToday([DateTime? now]) {
  final d = now ?? DateTime.now();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return '$dd/$mm/${d.year}';
}
