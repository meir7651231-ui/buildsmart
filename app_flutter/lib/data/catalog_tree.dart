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
