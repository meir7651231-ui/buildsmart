import 'package:flutter/foundation.dart';

/// Catalog drill-down tree. Three logical levels:
///   L1 — main category (e.g. "ניקוז וצנרת")
///   L2 — sub-category (e.g. "סיפונים")
///   L3 — sub-sub-category / leaf (e.g. "מחסומי רצפה")
/// Leaves carry [brandIds] + an optional [lipskeyCategory] that maps to
/// Lipskey's own categoryHe field (so we can pull products from kLipskeyCatalog).
@immutable
class CatalogNode {
  const CatalogNode({
    required this.id,
    required this.title,
    required this.emoji,
    this.children = const [],
    this.brandIds = const [],
    this.lipskeyCategory,
  });

  final String id;
  final String title;
  final String emoji;
  final List<CatalogNode> children;
  final List<String> brandIds;
  final String? lipskeyCategory;

  bool get isLeaf => children.isEmpty;
}

const List<CatalogNode> kCatalogTree = [
  // ── ניקוז וצנרת ───────────────────────────────────────────────────────────
  CatalogNode(
    id: 'drainage',
    title: 'ניקוז וצנרת',
    emoji: '🕳️',
    children: [
      CatalogNode(
        id: 'drainage.traps',
        title: 'סיפונים ומחסומים',
        emoji: '🌀',
        children: [
          CatalogNode(
            id: 'drainage.traps.floor',
            title: 'מחסומי רצפה',
            emoji: '🕳️',
            brandIds: ['lipskey', 'plasson'],
            lipskeyCategory: 'מחסומי רצפה',
          ),
          CatalogNode(
            id: 'drainage.traps.visible',
            title: 'מחסומים גלויים',
            emoji: '🚰',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחסומים (סיפונים) גלויים',
          ),
          CatalogNode(
            id: 'drainage.traps.manifold',
            title: 'מסעפים וחיבורי אסלה',
            emoji: '🔗',
            brandIds: ['lipskey', 'hagor'],
            lipskeyCategory: 'מסעפים וחיבורי אסלה',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.collectors',
        title: 'מאספים וקולטים',
        emoji: '📥',
        children: [
          CatalogNode(
            id: 'drainage.collectors.roof',
            title: 'קולטי גג',
            emoji: '🏠',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מאספים וקולטים',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.pipes',
        title: 'צינורות ומצמדים',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'drainage.pipes.couplers',
            title: 'מצמדים וצינורות',
            emoji: '🔩',
            brandIds: ['lipskey', 'plasson'],
            lipskeyCategory: 'מצמדים וצינורות',
          ),
          CatalogNode(
            id: 'drainage.pipes.pvc',
            title: 'צינורות PVC',
            emoji: '📏',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות',
          ),
          CatalogNode(
            id: 'drainage.pipes.elbows',
            title: 'ברכיים וזוויות',
            emoji: '↩️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברכיים',
          ),
          CatalogNode(
            id: 'drainage.pipes.couplings',
            title: 'מחברים ומצמדי שקע',
            emoji: '🔌',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי שקע-תקע',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.accessories',
        title: 'אביזרי ביוב נוספים',
        emoji: '🚿',
        children: [
          CatalogNode(
            id: 'drainage.accessories.funnel',
            title: 'משפכים ואביזרים',
            emoji: '🚿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי ביוב',
          ),
          CatalogNode(
            id: 'drainage.accessories.connect',
            title: 'אביזרי חיבור',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי חיבור',
          ),
          CatalogNode(
            id: 'drainage.accessories.tighten',
            title: 'סטי הידוק וחיבורים',
            emoji: '🧰',
            brandIds: ['lipskey'],
            lipskeyCategory: 'סטי הידוק וחיבורים',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.covers',
        title: 'מכסים ורשתות',
        emoji: '⬜',
        children: [
          CatalogNode(
            id: 'drainage.covers.all',
            title: 'מכסים ורשתות לרצפה',
            emoji: '⬜',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מכסים ורשתות',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.channels',
        title: 'תעלות ניקוז',
        emoji: '📐',
        children: [
          CatalogNode(
            id: 'drainage.channels.shower',
            title: 'תעלות מקלחת',
            emoji: '📐',
            brandIds: ['lipskey'],
            lipskeyCategory: 'תעלות ניקוז',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.traps.bucket',
        title: 'סיפונים נוספים',
        emoji: '🌀',
        children: [
          CatalogNode(
            id: 'drainage.traps.bucket.all',
            title: 'סיפונים — כל הסוגים',
            emoji: '🌀',
            brandIds: ['lipskey'],
            lipskeyCategory: 'סיפונים',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.hdpe',
        title: 'מחברי HDPE (פלסטיק מקצועי)',
        emoji: '🔗',
        children: [
          CatalogNode(
            id: 'drainage.hdpe.all',
            title: 'מחברי HDPE — כל הגדלים',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחברי HDPE',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.ntm',
        title: 'מחברי NTM',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'drainage.ntm.all',
            title: 'מחברי NTM — כל הגדלים',
            emoji: '🔧',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחברי NTM',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.clamps',
        title: 'חבקים ועוגנים',
        emoji: '🔩',
        children: [
          CatalogNode(
            id: 'drainage.clamps.hanging',
            title: 'חבקי תליה',
            emoji: '🔩',
            brandIds: ['lipskey'],
            lipskeyCategory: 'חבקי תליה',
          ),
          CatalogNode(
            id: 'drainage.clamps.omega',
            title: 'חבקי צינור (אומגה)',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'חבקי צינור',
          ),
          CatalogNode(
            id: 'drainage.clamps.anchors',
            title: 'עוגנים ובנדים',
            emoji: '⚓',
            brandIds: ['lipskey'],
            lipskeyCategory: 'עוגנים ובנדים',
          ),
        ],
      ),
      CatalogNode(
        id: 'drainage.rooftop',
        title: 'ניקוז גג',
        emoji: '🌧️',
        children: [
          CatalogNode(
            id: 'drainage.rooftop.all',
            title: 'ברכי מי גשם',
            emoji: '🌧️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ניקוז גג',
          ),
        ],
      ),
    ],
  ),

  // ── ברזים וכיורים ─────────────────────────────────────────────────────────
  CatalogNode(
    id: 'taps',
    title: 'ברזים וכיורים',
    emoji: '🚰',
    children: [
      CatalogNode(
        id: 'taps.faucets',
        title: 'ברזים',
        emoji: '🚰',
        children: [
          CatalogNode(
            id: 'taps.faucets.kitchen',
            title: 'ברז למטבח',
            emoji: '🍽️',
            brandIds: ['grohe', 'hamat'],
          ),
          CatalogNode(
            id: 'taps.faucets.basin',
            title: 'ברז לכיור',
            emoji: '🚰',
            brandIds: ['grohe', 'hamat'],
          ),
          CatalogNode(
            id: 'taps.faucets.shower',
            title: 'סוללת מקלחת',
            emoji: '🚿',
            brandIds: ['grohe', 'hamat'],
          ),
        ],
      ),
      CatalogNode(
        id: 'taps.sinks',
        title: 'כיורים',
        emoji: '🪣',
        children: [
          CatalogNode(
            id: 'taps.sinks.bathroom',
            title: 'כיור אמבטיה',
            emoji: '🪣',
            brandIds: ['hamat'],
          ),
          CatalogNode(
            id: 'taps.sinks.kitchen',
            title: 'כיור מטבח',
            emoji: '🍳',
            brandIds: ['hamat'],
          ),
        ],
      ),
      CatalogNode(
        id: 'taps.bathtub',
        title: 'אמבטיות ואגניות',
        emoji: '🛁',
        children: [
          CatalogNode(
            id: 'taps.bathtub.tub',
            title: 'אמבטיה',
            emoji: '🛁',
            brandIds: ['lipskey', 'hamat'],
            lipskeyCategory: 'אמבט ואגנית',
          ),
        ],
      ),
      CatalogNode(
        id: 'taps.shutoffs',
        title: 'ברזי ניל וניתוק',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'taps.shutoffs.nil',
            title: 'ברזי ניל',
            emoji: '🔧',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברזי ניל',
          ),
          CatalogNode(
            id: 'taps.shutoffs.bucket',
            title: 'ברזי דלי',
            emoji: '🪣',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברזי דלי',
          ),
          CatalogNode(
            id: 'taps.shutoffs.waterpoints',
            title: 'נקודות מים',
            emoji: '💧',
            brandIds: ['lipskey'],
            lipskeyCategory: 'נקודות מים',
          ),
          CatalogNode(
            id: 'taps.shutoffs.transit',
            title: 'ברזי מעבר כדוריים',
            emoji: '⚙️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברזי מעבר',
          ),
        ],
      ),
      CatalogNode(
        id: 'taps.distribution',
        title: 'מחלקים וארונות',
        emoji: '🔀',
        children: [
          CatalogNode(
            id: 'taps.distribution.manifolds',
            title: 'מחלקים — יציאות מים',
            emoji: '🔀',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחלקים',
          ),
          CatalogNode(
            id: 'taps.distribution.cabinets',
            title: 'ארונות מחלק',
            emoji: '📦',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ארונות מחלק',
          ),
        ],
      ),
    ],
  ),

  // ── אסלות ────────────────────────────────────────────────────────────────
  CatalogNode(
    id: 'toilets',
    title: 'אסלות',
    emoji: '🚽',
    children: [
      CatalogNode(
        id: 'toilets.seats',
        title: 'מושבי אסלה',
        emoji: '⭕',
        children: [
          CatalogNode(
            id: 'toilets.seats.standard',
            title: 'מושב אסלה רגיל',
            emoji: '⭕',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מושבי אסלה',
          ),
        ],
      ),
      CatalogNode(
        id: 'toilets.tanks',
        title: 'מיכלי הדחה',
        emoji: '🚿',
        children: [
          CatalogNode(
            id: 'toilets.tanks.high',
            title: 'התקנה גבוהה',
            emoji: '🔺',
            brandIds: ['lipskey'],
            lipskeyCategory: 'התקנה גבוהה',
          ),
          CatalogNode(
            id: 'toilets.tanks.low',
            title: 'התקנה נמוכה',
            emoji: '🔻',
            brandIds: ['lipskey'],
            lipskeyCategory: 'התקנה נמוכה',
          ),
          CatalogNode(
            id: 'toilets.tanks.monoblock',
            title: 'מונובלוק (צמוד)',
            emoji: '⬜',
            brandIds: ['lipskey'],
            lipskeyCategory: 'התקנה צמודה',
          ),
        ],
      ),
      CatalogNode(
        id: 'toilets.connections',
        title: 'חיבורי אסלה',
        emoji: '🔗',
        children: [
          CatalogNode(
            id: 'toilets.connections.bend',
            title: 'זקיף אסלה',
            emoji: '🚽',
            brandIds: ['lipskey'],
            lipskeyCategory: 'זקיף אסלה',
          ),
        ],
      ),
      CatalogNode(
        id: 'toilets.parts',
        title: 'חלקים פנימיים',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'toilets.parts.float',
            title: 'מצופים וחלקים סניטריים',
            emoji: '🔧',
            brandIds: ['lipskey'],
            lipskeyCategory: 'חלקים סניטריים',
          ),
          CatalogNode(
            id: 'toilets.parts.accessories',
            title: 'אביזרי אסלה',
            emoji: '🧷',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי אסלה',
          ),
          CatalogNode(
            id: 'toilets.parts.mechanisms',
            title: 'מנגנונים',
            emoji: '⚙️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מונגנונים',
          ),
        ],
      ),
      CatalogNode(
        id: 'toilets.units',
        title: 'אסלות וכיורים — יחידות מלאות',
        emoji: '🚽',
        children: [
          CatalogNode(
            id: 'toilets.units.complete',
            title: 'יחידות אסלה+כיור',
            emoji: '🚽',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אסלות וכיורים',
          ),
        ],
      ),
    ],
  ),

  // ── מקלחות ואמבטיות ──────────────────────────────────────────────────────
  CatalogNode(
    id: 'showers',
    title: 'מקלחות ואמבטיות',
    emoji: '🚿',
    children: [
      CatalogNode(
        id: 'showers.heads',
        title: 'ראשי מקלחת',
        emoji: '🚿',
        children: [
          CatalogNode(
            id: 'showers.heads.all',
            title: 'ראשי מקלחת',
            emoji: '🚿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ראשי מקלחת',
          ),
        ],
      ),
      CatalogNode(
        id: 'showers.sprayers',
        title: 'מזלפים וצינורות',
        emoji: '〰️',
        children: [
          CatalogNode(
            id: 'showers.sprayers.hand',
            title: 'מזלפי יד',
            emoji: '🤚',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מזלפי יד',
          ),
          CatalogNode(
            id: 'showers.sprayers.flexHose',
            title: 'צינורות גמישים',
            emoji: '〰️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות גמישים',
          ),
          CatalogNode(
            id: 'showers.sprayers.showerHose',
            title: 'צינורות מקלחת',
            emoji: '🚿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות מקלחת',
          ),
        ],
      ),
      CatalogNode(
        id: 'showers.arms',
        title: 'זרועות ואביזרים',
        emoji: '⤴️',
        children: [
          CatalogNode(
            id: 'showers.arms.shower',
            title: 'זרועות דוש',
            emoji: '⤴️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'זרועות דוש',
          ),
          CatalogNode(
            id: 'showers.arms.accessories',
            title: 'אביזרי מקלחת',
            emoji: '🧴',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי מקלחת',
          ),
        ],
      ),
      CatalogNode(
        id: 'showers.systems',
        title: 'מערכות שטיפה ופינוק',
        emoji: '✨',
        children: [
          CatalogNode(
            id: 'showers.systems.rinse',
            title: 'מערכות שטיפה',
            emoji: '🚿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מערכות שטיפה',
          ),
          CatalogNode(
            id: 'showers.systems.bath',
            title: 'מערכות אמבטיה',
            emoji: '🛁',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מערכות אמבטיה',
          ),
          CatalogNode(
            id: 'showers.systems.kits',
            title: 'ערכות רחצה',
            emoji: '🎁',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ערכות רחצה',
          ),
        ],
      ),
    ],
  ),

  // ── אביזרי קצה וחיבורים ──────────────────────────────────────────────────
  CatalogNode(
    id: 'endparts',
    title: 'אביזרי קצה וחיבורים',
    emoji: '🔗',
    children: [
      CatalogNode(
        id: 'endparts.threading',
        title: 'אביזרי תבריג',
        emoji: '🔩',
        children: [
          CatalogNode(
            id: 'endparts.threading.fittings',
            title: 'מחברים מותברגים',
            emoji: '🔩',
            brandIds: ['lipskey', 'hagor'],
            lipskeyCategory: 'אביזרי תבריג',
          ),
        ],
      ),
      CatalogNode(
        id: 'endparts.seals',
        title: 'אטמים ופקקים',
        emoji: '⚫',
        children: [
          CatalogNode(
            id: 'endparts.seals.gaskets',
            title: 'אטמים, אומים ופקקים',
            emoji: '⚫',
            brandIds: ['lipskey', 'hagor'],
            lipskeyCategory: 'אטמים אומים ופקקים',
          ),
        ],
      ),
      CatalogNode(
        id: 'endparts.copper',
        title: 'אביזרי נחושת',
        emoji: '🟫',
        children: [
          CatalogNode(
            id: 'endparts.copper.all',
            title: 'אביזרי נחושת — כל הסוגים',
            emoji: '🟫',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי נחושת',
          ),
        ],
      ),
      CatalogNode(
        id: 'endparts.pressure',
        title: 'מכשירי לחץ ומצופים',
        emoji: '📊',
        children: [
          CatalogNode(
            id: 'endparts.pressure.devices',
            title: 'מכשירי לחץ',
            emoji: '📊',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מכשירי לחץ',
          ),
          CatalogNode(
            id: 'endparts.pressure.floats',
            title: 'מצופים נחושת',
            emoji: '🔵',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מצופים',
          ),
          CatalogNode(
            id: 'endparts.pressure.checkValves',
            title: 'ברזי אל-חזור',
            emoji: '🔄',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אל חזור',
          ),
        ],
      ),
    ],
  ),

  // ── גינון והשקיה (חדש) ───────────────────────────────────────────────────
  CatalogNode(
    id: 'garden',
    title: 'גינון והשקיה',
    emoji: '🌱',
    children: [
      CatalogNode(
        id: 'garden.equipment',
        title: 'ציוד גן',
        emoji: '🌿',
        children: [
          CatalogNode(
            id: 'garden.equipment.all',
            title: 'צינורות וציוד גן',
            emoji: '🌿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ציוד גן',
          ),
        ],
      ),
      CatalogNode(
        id: 'garden.taps',
        title: 'ברזי גן',
        emoji: '🚰',
        children: [
          CatalogNode(
            id: 'garden.taps.all',
            title: 'ברזי גן כבדים',
            emoji: '🚰',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברזי גן',
          ),
          CatalogNode(
            id: 'garden.taps.ntm',
            title: 'ברז NTM איטלקי',
            emoji: '🇮🇹',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברזים',
          ),
        ],
      ),
    ],
  ),

  // ── אביזרים נלווים ───────────────────────────────────────────────────────
  CatalogNode(
    id: 'acc',
    title: 'אביזרים נלווים',
    emoji: '🧰',
    children: [
      CatalogNode(
        id: 'acc.tools',
        title: 'כלי עבודה',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'acc.tools.wrench',
            title: 'מפתחות וכלי הברגה',
            emoji: '🔧',
            brandIds: ['lipskey'],
            lipskeyCategory: 'כלי עבודה',
          ),
        ],
      ),
      CatalogNode(
        id: 'acc.bathroom',
        title: 'אביזרי חדר רחצה',
        emoji: '🛁',
        children: [
          CatalogNode(
            id: 'acc.bathroom.fittings',
            title: 'מתלים, סבוניות, נייר',
            emoji: '🧴',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי חדר רחצה',
          ),
          CatalogNode(
            id: 'acc.bathroom.handles',
            title: 'ידיות אחיזה',
            emoji: '🤝',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ידיות אחיזה',
          ),
        ],
      ),
      CatalogNode(
        id: 'acc.spouts',
        title: 'דיורים ופיות',
        emoji: '🚿',
        children: [
          CatalogNode(
            id: 'acc.spouts.all',
            title: 'דיורים ופיות',
            emoji: '🚿',
            brandIds: ['lipskey'],
            lipskeyCategory: 'דיורים ופיות',
          ),
        ],
      ),
    ],
  ),
];

/// Find a node by id, walking the whole tree.
CatalogNode? findCatalogNode(String id) {
  CatalogNode? walk(CatalogNode n) {
    if (n.id == id) return n;
    for (final c in n.children) {
      final hit = walk(c);
      if (hit != null) return hit;
    }
    return null;
  }

  for (final n in kCatalogTree) {
    final hit = walk(n);
    if (hit != null) return hit;
  }
  return null;
}

/// Flatten all leaves (nodes with no children) in the tree.
List<CatalogNode> allLeaves() {
  final out = <CatalogNode>[];
  void walk(CatalogNode n) {
    if (n.isLeaf) {
      out.add(n);
    } else {
      for (final c in n.children) {
        walk(c);
      }
    }
  }

  for (final n in kCatalogTree) {
    walk(n);
  }
  return out;
}
