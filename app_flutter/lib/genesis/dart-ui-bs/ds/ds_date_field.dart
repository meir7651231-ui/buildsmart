// ✨ קלט · DsDateField — שדה לנתון תאריך: תאריך · מועד · יום · לידה · תוקף ·
// התחלה · סיום. תווית + קלט מעוגל + אייקון-לוח. חוט-טהור: אפס-דאטה, material בלבד.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsDateField extends StatelessWidget {
  const DsDateField({required this.label, super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 6),
              child: Text(label, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(DsTokens.rSm),
                border: Border.all(color: DsTokens.line),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today_outlined, size: 17, color: DsTokens.faint),
                  Spacer(),
                ],
              ),
            ),
          ],
        ),
      );
}
