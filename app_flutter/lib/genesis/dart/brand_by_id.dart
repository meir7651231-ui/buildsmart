// ⚛️ אטום-Dart · brandById
// מוצא: buildsmart/app_flutter/lib/data/brands.dart:88-94 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `Brand` (:4-20) הוטבע verbatim; הקבוע `kBrands` (:25-86) הוטבע verbatim.

class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    this.tagline = '',
    this.productCount = 0,
  });

  final String id;
  final String name;
  final String emoji;
  final int color;
  final String tagline;
  final int productCount;
}

const List<Brand> kBrands = [
  Brand(
    id: 'aquatec',
    name: 'AQUATEC',
    emoji: '💧',
    color: 0xFF2C7BE5,
    tagline: 'ברזים, מקלחות וצנרת מים',
    productCount: 601,
  ),
  Brand(
    id: 'lipskey',
    name: 'ליפסקי ברקן',
    emoji: '🏭',
    color: 0xFF3D5A80,
    tagline: 'ניקוז, סיפונים ואסלות',
    productCount: 255,
  ),
  Brand(
    id: 'plasson',
    name: 'פלסון',
    emoji: '🔧',
    color: 0xFF1F6F6B,
    tagline: 'מערכות PEX וברזי שדה',
  ),
  Brand(
    id: 'hagor',
    name: 'חגור',
    emoji: '🛡️',
    color: 0xFF5A4A8C,
    tagline: 'אטמים ומחברים',
  ),
  Brand(
    id: 'grohe',
    name: 'גרוהה',
    emoji: '💎',
    color: 0xFF8C5A3D,
    tagline: 'ברזים פרימיום',
  ),
  Brand(
    id: 'hamat',
    name: 'חמת',
    emoji: '🚿',
    color: 0xFF3D8C5A,
    tagline: 'ברזים ומקלחות',
  ),
  Brand(
    id: 'polyroll',
    name: 'פולירול',
    emoji: '🔵',
    color: 0xFF1565C0,
    tagline: 'מערכות צנרת PPR — מים ומיזוג אוויר',
    productCount: 779,
  ),
  Brand(
    id: 'huliot',
    name: 'חוליות',
    emoji: '🟢',
    color: 0xFF14764A,
    tagline: 'SmartLock — מערכת דלוחין PP 32-63 מ"מ',
    productCount: 170,
  ),
];

/// מותג לפי [id], או null אם אין. PURE.
Brand? brandById(String id) {
  for (final b in kBrands) {
    if (b.id == id) return b;
  }
  return null;
}
