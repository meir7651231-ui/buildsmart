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
    this.smartKey,
  });

  final String id;
  final String title;
  final String emoji;
  final List<CatalogNode> children;
  final List<String> brandIds;
  final String? lipskeyCategory;

  /// Key of the matching [SmartProduct]. When set, drilling to this leaf opens
  /// the unified "ברז לכיור" sheet (brand picker + accessories + cart) instead
  /// of the raw brand-products list.
  final String? smartKey;

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
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחסומי רצפה',
            smartKey: 'floorDrain',
          ),
          CatalogNode(
            id: 'drainage.traps.visible',
            title: 'מחסומים גלויים',
            emoji: '🚰',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מחסומים גלויים',
            smartKey: 'visibleTrap',
          ),
          CatalogNode(
            id: 'drainage.traps.manifold',
            title: 'מסעפים וחיבורי אסלה',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מסעפים וחיבורי אסלה',
            smartKey: 'drainageManifold',
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
            smartKey: 'roofCollector',
          ),
          CatalogNode(
            id: 'drainage.collectors.floor',
            title: 'מאספי רצפה',
            emoji: '🕳️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'מאספי רצפה',
          ),
          CatalogNode(
            id: 'drainage.collectors.covers',
            title: 'כיסויים ורשתות',
            emoji: '⬜',
            brandIds: ['lipskey'],
            lipskeyCategory: 'כיסויים',
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
            brandIds: ['lipskey'],
            lipskeyCategory: 'מצמדים וצינורות',
            smartKey: 'drainageFittings',
          ),
          CatalogNode(
            id: 'drainage.pipes.pvc',
            title: 'צינורות PVC',
            emoji: '📏',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות',
            smartKey: 'pvcPipe',
          ),
          CatalogNode(
            id: 'drainage.pipes.gray',
            title: 'צינורות אפורות',
            emoji: '📏',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות אפורות',
          ),
          CatalogNode(
            id: 'drainage.pipes.pp',
            title: 'צנרת PP-MD-ML',
            emoji: '📏',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות PP',
          ),
          CatalogNode(
            id: 'drainage.pipes.multi',
            title: 'צנרת רב-שכבתית',
            emoji: '📏',
            brandIds: ['lipskey'],
            lipskeyCategory: 'צינורות רב שכבתי',
          ),
          CatalogNode(
            id: 'drainage.pipes.plugs',
            title: 'פקקים וצינורות',
            emoji: '⚫',
            brandIds: ['lipskey'],
            lipskeyCategory: 'פקקים וצינורות',
          ),
          CatalogNode(
            id: 'drainage.pipes.elbows',
            title: 'ברכיים וזוויות',
            emoji: '↩️',
            brandIds: ['lipskey'],
            lipskeyCategory: 'ברכיים',
            smartKey: 'drainageElbow',
          ),
          CatalogNode(
            id: 'drainage.pipes.couplings',
            title: 'מחברים ומצמדי שקע',
            emoji: '🔌',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי שקע-תקע',
            smartKey: 'drainageFittings',
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
            smartKey: 'visibleTrap',
          ),
          CatalogNode(
            id: 'drainage.accessories.connect',
            title: 'אביזרי חיבור',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי חיבור',
            smartKey: 'drainageFittings',
          ),
          CatalogNode(
            id: 'drainage.accessories.tighten',
            title: 'סטי הידוק וחיבורים',
            emoji: '🧰',
            brandIds: ['aquatec'],
            lipskeyCategory: 'סטי הידוק וחיבורים',
            smartKey: 'tighteningSet',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מכסים ורשתות',
            smartKey: 'floorCover',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'תעלות ניקוז',
            smartKey: 'drainChannel',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'סיפונים',
            smartKey: 'otherTraps',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מחברי HDPE',
            smartKey: 'hdpeConnector',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מחברי NTM',
            smartKey: 'ntmConnector',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'חבקי תליה',
            smartKey: 'pipeClamps',
          ),
          CatalogNode(
            id: 'drainage.clamps.omega',
            title: 'חבקי צינור (אומגה)',
            emoji: '🔗',
            brandIds: ['lipskey'],
            lipskeyCategory: 'חבקי צינור',
            smartKey: 'omegaClamps',
          ),
          CatalogNode(
            id: 'drainage.clamps.anchors',
            title: 'עוגנים ובנדים',
            emoji: '⚓',
            brandIds: ['aquatec'],
            lipskeyCategory: 'עוגנים ובנדים',
            smartKey: 'pipeClamps',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'ניקוז גג',
            smartKey: 'rooftopDrain',
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
            smartKey: 'kitchenFaucet',
          ),
          CatalogNode(
            id: 'taps.faucets.basin',
            title: 'ברז לכיור',
            emoji: '🚰',
            brandIds: ['grohe', 'hamat'],
            smartKey: 'faucet',
          ),
          CatalogNode(
            id: 'taps.faucets.shower',
            title: 'סוללת מקלחת',
            emoji: '🚿',
            brandIds: ['grohe', 'hamat'],
            smartKey: 'shower',
          ),
          CatalogNode(
            id: 'taps.faucets.aquaBasin',
            title: 'ברזי כיור AQUATEC',
            emoji: '🚰',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי כיור',
            smartKey: 'aquaBasinTap',
          ),
          CatalogNode(
            id: 'taps.faucets.wall',
            title: 'ברזי קיר',
            emoji: '🧱',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי קיר',
            smartKey: 'wallTap',
          ),
          CatalogNode(
            id: 'taps.faucets.aquaKitchen',
            title: 'ברזי מטבח AQUATEC',
            emoji: '🍽️',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי מטבח',
            smartKey: 'aquaKitchenTap',
          ),
          CatalogNode(
            id: 'taps.faucets.aquaBath',
            title: 'ברזי אמבטיה',
            emoji: '🛁',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי אמבטיה',
            smartKey: 'aquaBathTap',
          ),
          CatalogNode(
            id: 'taps.faucets.aquaShower',
            title: 'ברזי מקלחת AQUATEC',
            emoji: '🚿',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי מקלחת',
            smartKey: 'aquaShowerTap',
          ),
          CatalogNode(
            id: 'taps.faucets.accessories',
            title: 'אביזרי ברזים',
            emoji: '🔧',
            brandIds: ['aquatec'],
            lipskeyCategory: 'אביזרי ברזים',
            smartKey: 'tapAccessories',
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
            smartKey: 'basin',
          ),
          CatalogNode(
            id: 'taps.sinks.kitchen',
            title: 'כיור מטבח',
            emoji: '🍳',
            brandIds: ['hamat'],
            smartKey: 'kitchenSink',
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
            title: 'אביק לאמבט ואגנית',
            emoji: '🛁',
            brandIds: ['lipskey'],
            lipskeyCategory: 'אמבט ואגנית',
            smartKey: 'bathtub',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי ניל',
            smartKey: 'shutoffValve',
          ),
          CatalogNode(
            id: 'taps.shutoffs.bucket',
            title: 'ברזי דלי',
            emoji: '🪣',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי דלי',
            smartKey: 'shutoffValve',
          ),
          CatalogNode(
            id: 'taps.shutoffs.waterpoints',
            title: 'נקודות מים',
            emoji: '💧',
            brandIds: ['aquatec'],
            lipskeyCategory: 'נקודות מים',
            smartKey: 'shutoffValve',
          ),
          CatalogNode(
            id: 'taps.shutoffs.transit',
            title: 'ברזי מעבר כדוריים',
            emoji: '⚙️',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי מעבר',
            smartKey: 'transitValve',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מחלקים',
            smartKey: 'waterManifold',
          ),
          CatalogNode(
            id: 'taps.distribution.cabinets',
            title: 'ארונות מחלק',
            emoji: '📦',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ארונות מחלק',
            smartKey: 'waterManifold',
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
            smartKey: 'toiletSeat',
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
            smartKey: 'toiletTankHigh',
          ),
          CatalogNode(
            id: 'toilets.tanks.low',
            title: 'התקנה נמוכה',
            emoji: '🔻',
            brandIds: ['lipskey'],
            lipskeyCategory: 'התקנה נמוכה',
            smartKey: 'toiletTankLow',
          ),
          CatalogNode(
            id: 'toilets.tanks.monoblock',
            title: 'מונובלוק (צמוד)',
            emoji: '⬜',
            brandIds: ['lipskey'],
            lipskeyCategory: 'התקנה צמודה',
            smartKey: 'toiletTankMonoblock',
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
            smartKey: 'toiletBend',
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
            smartKey: 'toiletParts',
          ),
          CatalogNode(
            id: 'toilets.parts.accessories',
            title: 'אביזרי אסלה',
            emoji: '🧷',
            brandIds: ['aquatec'],
            lipskeyCategory: 'אביזרי אסלה',
            smartKey: 'toiletAccessories',
          ),
          CatalogNode(
            id: 'toilets.parts.mechanisms',
            title: 'מנגנונים',
            emoji: '⚙️',
            brandIds: ['aquatec'],
            lipskeyCategory: 'מנגנונים',
            smartKey: 'toiletMechanism',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'אסלות וכיורים',
            smartKey: 'toiletUnit',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'ראשי מקלחת',
            smartKey: 'showerHead',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מזלפי יד',
            smartKey: 'handSprayer',
          ),
          CatalogNode(
            id: 'showers.sprayers.flexHose',
            title: 'צינורות גמישים',
            emoji: '〰️',
            brandIds: ['aquatec'],
            lipskeyCategory: 'צינורות גמישים',
            smartKey: 'flexHose',
          ),
          CatalogNode(
            id: 'showers.sprayers.showerHose',
            title: 'צינורות מקלחת',
            emoji: '🚿',
            brandIds: ['aquatec'],
            lipskeyCategory: 'צינורות מקלחת',
            smartKey: 'showerHose',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'זרועות דוש',
            smartKey: 'showerArm',
          ),
          CatalogNode(
            id: 'showers.arms.accessories',
            title: 'אביזרי מקלחת',
            emoji: '🧴',
            brandIds: ['aquatec'],
            lipskeyCategory: 'אביזרי מקלחת',
            smartKey: 'showerAccessories',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מערכות שטיפה',
            smartKey: 'showerSystem',
          ),
          CatalogNode(
            id: 'showers.systems.bath',
            title: 'מערכות אמבטיה',
            emoji: '🛁',
            brandIds: ['aquatec'],
            lipskeyCategory: 'מערכות אמבטיה',
            smartKey: 'bathSystem',
          ),
          CatalogNode(
            id: 'showers.systems.kits',
            title: 'ערכות רחצה',
            emoji: '🎁',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ערכות רחצה',
            smartKey: 'bathingKit',
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
            brandIds: ['lipskey'],
            lipskeyCategory: 'אביזרי תבריג',
            smartKey: 'threadFittings',
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
            brandIds: ['lipskey'],
            lipskeyCategory: 'אטמים ופקקים',
            smartKey: 'sealsAndPlugs',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'אביזרי נחושת',
            smartKey: 'copperFittings',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'מכשירי לחץ',
            smartKey: 'pressureDevices',
          ),
          CatalogNode(
            id: 'endparts.pressure.floats',
            title: 'מצופים נחושת',
            emoji: '🔵',
            brandIds: ['aquatec'],
            lipskeyCategory: 'מצופים',
            smartKey: 'pressureDevices',
          ),
          CatalogNode(
            id: 'endparts.pressure.checkValves',
            title: 'ברזי אל-חזור',
            emoji: '🔄',
            brandIds: ['aquatec'],
            lipskeyCategory: 'אל חזור',
            smartKey: 'pressureDevices',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'ציוד גן',
            smartKey: 'gardenHose',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזי גן',
            smartKey: 'gardenTap',
          ),
          CatalogNode(
            id: 'garden.taps.ntm',
            title: 'ברז NTM איטלקי',
            emoji: '🇮🇹',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ברזים',
            smartKey: 'gardenTap',
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
            smartKey: 'tools',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'אביזרי חדר רחצה',
            smartKey: 'bathroomFittings',
          ),
          CatalogNode(
            id: 'acc.bathroom.handles',
            title: 'ידיות אחיזה',
            emoji: '🤝',
            brandIds: ['aquatec'],
            lipskeyCategory: 'ידיות אחיזה',
            smartKey: 'grabBars',
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
            brandIds: ['aquatec'],
            lipskeyCategory: 'דיורים ופיות',
            smartKey: 'spoutHousings',
          ),
        ],
      ),
    ],
  ),

  // ── צנרת PPR · פולירול / הלירומה ───────────────────────────────────────────
  CatalogNode(
    id: 'ppr',
    title: 'צנרת PPR (פולירול)',
    emoji: '🔵',
    children: [
      CatalogNode(
        id: 'ppr.pipes',
        title: 'צינורות',
        emoji: '🟦',
        children: [
          CatalogNode(
            id: 'ppr.pipes.supply',
            title: 'צינורות אספקת מים',
            emoji: '🔵',
            brandIds: ['polyroll'],
            lipskeyCategory: 'צינורות PPR אספקת מים',
          ),
          CatalogNode(
            id: 'ppr.pipes.fiber',
            title: 'צינורות פייזר',
            emoji: '🟦',
            brandIds: ['polyroll'],
            lipskeyCategory: 'צינורות PPR פייזר',
          ),
          CatalogNode(
            id: 'ppr.pipes.ac',
            title: 'צינורות מיזוג אוויר',
            emoji: '❄️',
            brandIds: ['polyroll'],
            lipskeyCategory: 'צינורות PPR מיזוג אוויר',
          ),
        ],
      ),
      CatalogNode(
        id: 'ppr.fittings',
        title: 'אביזרי ריתוך',
        emoji: '🔧',
        children: [
          CatalogNode(
            id: 'ppr.fittings.elbows',
            title: 'ברכיים',
            emoji: '↪️',
            brandIds: ['polyroll'],
            lipskeyCategory: 'ברכיים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.tees',
            title: 'מסעפים',
            emoji: '🔱',
            brandIds: ['polyroll'],
            lipskeyCategory: 'מסעפים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.couplers',
            title: 'מצמדים',
            emoji: '🔗',
            brandIds: ['polyroll'],
            lipskeyCategory: 'מצמדים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.adapters',
            title: 'מתאמים',
            emoji: '🔩',
            brandIds: ['polyroll'],
            lipskeyCategory: 'מתאמים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.saddles',
            title: 'רוכבים',
            emoji: '🪢',
            brandIds: ['polyroll'],
            lipskeyCategory: 'רוכבים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.plugs',
            title: 'פקקים',
            emoji: '🔘',
            brandIds: ['polyroll'],
            lipskeyCategory: 'פקקים PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.omega',
            title: 'אומגה',
            emoji: '🛟',
            brandIds: ['polyroll'],
            lipskeyCategory: 'אומגה PPR',
          ),
          CatalogNode(
            id: 'ppr.fittings.collars',
            title: 'צווארונים ואוגנים',
            emoji: '⭕',
            brandIds: ['polyroll'],
            lipskeyCategory: 'צווארונים ואוגנים PPR',
          ),
        ],
      ),
      CatalogNode(
        id: 'ppr.valves',
        title: 'ברזים',
        emoji: '🚰',
        brandIds: ['polyroll'],
        lipskeyCategory: 'ברזים PPR',
      ),
      CatalogNode(
        id: 'ppr.electrofusion',
        title: 'ריתוך חשמלי',
        emoji: '⚡',
        brandIds: ['polyroll'],
        lipskeyCategory: 'אביזרי ריתוך חשמלי PPR',
      ),
      CatalogNode(
        id: 'ppr.tools',
        title: 'כלי ריתוך',
        emoji: '🛠️',
        brandIds: ['polyroll'],
        lipskeyCategory: 'כלי ריתוך PPR',
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

/// Explicit taxonomy — the title path root→…→leaf for a Lipskey category
/// (צעד 74). Used for breadcrumbs/navigation context. Empty if not found.
List<String> categoryPathFor(String lipskeyCategory) {
  List<String>? search(CatalogNode n, List<String> trail) {
    final here = [...trail, n.title];
    if (n.lipskeyCategory == lipskeyCategory) return here;
    for (final c in n.children) {
      final hit = search(c, here);
      if (hit != null) return hit;
    }
    return null;
  }

  for (final n in kCatalogTree) {
    final hit = search(n, const []);
    if (hit != null) return hit;
  }
  return const [];
}
