// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_screen:_CompanyCatalogImportCard (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2, label3, label4, onTap
// התוכן: new/dart-data-bs/auto/screens__catalog_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/data/catalog_source.dart';

class CompanyCatalogImportCard extends StatelessWidget {
  CompanyCatalogImportCard({required this.label, required this.label2, required this.label3, required this.label4, required this.onTap});
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFEEEEEE),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    resolvedCatalogProducts.isNotEmpty
                        ? '${label2}${resolvedCatalogProducts.length}${label3}'
                        : label4,
                    style: const TextStyle(color: Colors.black38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}
