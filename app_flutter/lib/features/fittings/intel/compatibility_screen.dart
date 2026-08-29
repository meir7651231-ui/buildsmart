// 🧠 מנוע-אביזרים · E-lite slice 2 — מסך "תאימות-אביזרים" (יכולת-מאחורי-כפתור).
// מציג למוצר-נבחר: אילו אביזרים בקבוצה מתחברים אליו (`compatibleTargets`) ומדוע
// אחרים לא. מגודר · off-live. 🛡️ M5: מאציל ל-`canConnect` המאומת (אפס over-match).
//
// 🔒 אף מסך-חי לא מייבא `intel/` ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/fittings/intel/compatibility.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך "תאימות": מוצר-נבחר + רשימת-האביזרים שמתחברים אליו (✓) / לא (✗ + סיבה).
class CompatibilityScreen extends StatelessWidget {
  const CompatibilityScreen({
    this.product = _demoProduct,
    this.universe = _demoUniverse,
    super.key,
  });

  final LipskeyCatalogProduct product;
  final List<LipskeyCatalogProduct> universe;

  static const _demoProduct =
      LipskeyCatalogProduct(sku: 'C32', nameHe: 'מצמד 32', nameEn: '',
          categoryHe: 'אביזרי קצה HDPE', categoryEn: '', categoryEmoji: '🔧', page: 1,);

  static const _demoUniverse = [
    LipskeyCatalogProduct(sku: 'E32', nameHe: 'ברך 90° 32', nameEn: '',
        categoryHe: 'אביזרי קצה HDPE', categoryEn: '', categoryEmoji: '🔧', page: 1,),
    LipskeyCatalogProduct(sku: 'T32', nameHe: 'מסעף 32', nameEn: '',
        categoryHe: 'אביזרי קצה HDPE', categoryEn: '', categoryEmoji: '🔧', page: 1,),
    LipskeyCatalogProduct(sku: 'C50', nameHe: 'מצמד 50', nameEn: '',
        categoryHe: 'אביזרי קצה HDPE', categoryEn: '', categoryEmoji: '🔧', page: 1,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'תאימות-אביזרים · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text('מתחבר-ל: ${product.nameHe}',
                style: const TextStyle(
                    fontFamily: 'Heebo',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,),),
            const SizedBox(height: 12),
            for (final other in universe) _CompatRow(a: product, b: other),
          ],
        ),
      ),
    );
  }
}

class _CompatRow extends StatelessWidget {
  const _CompatRow({required this.a, required this.b});
  final LipskeyCatalogProduct a;
  final LipskeyCatalogProduct b;

  @override
  Widget build(BuildContext context) {
    final ok = pairCompatible(a, b);
    final reason = ok ? null : incompatibilityReason(a, b);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ok ? '✓' : '✗',
              style: TextStyle(
                  fontFamily: 'Heebo',
                  fontWeight: FontWeight.w800,
                  color: ok ? const Color(0xFF7FC08A) : const Color(0xFFE06666),),),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.nameHe,
                    style: const TextStyle(
                        fontFamily: 'Heebo', color: Colors.white, fontSize: 14,),),
                if (reason != null)
                  Text(reason,
                      style: const TextStyle(
                          fontFamily: 'Heebo',
                          color: Colors.white54,
                          fontSize: 11,),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
