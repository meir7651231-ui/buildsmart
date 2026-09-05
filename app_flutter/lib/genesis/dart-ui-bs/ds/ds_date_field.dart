// ✨ קלט · DsDateField — שדה לנתון תאריך: תאריך · מועד · יום · לידה · תוקף ·
// התחלה · סיום. תווית + בורר-תאריך אמיתי (showDatePicker) ⇒ ISO. חוט-טהור, material בלבד.
// (התיאור-העצמי הזה הוא ה-he שהמנוע אוחז לפיו — הידע חי על האטום, לא במנוע.)
import 'package:flutter/material.dart';
import 'ds.dart';

class DsDateField extends StatelessWidget {
  const DsDateField({required this.label, required this.value, required this.onChanged, this.bare = false, super.key});
  final String label, value;
  final ValueChanged<String> onChanged;
  /// G13c · bare=true ⇒ בורר-התאריך בלבד (בלי תווית/ריפוד). false ⇒ ביט-זהה.
  final bool bare;

  static String _two(int n) => n < 10 ? '0$n' : '$n';

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final init = DateTime.tryParse(value) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) onChanged('${picked.year}-${_two(picked.month)}-${_two(picked.day)}');
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: bare ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!bare) Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 6),
              child: Text(label, style: const TextStyle(color: DsTokens.muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
            ),
            Material(
              color: DsTokens.cardAlt,
              borderRadius: BorderRadius.circular(DsTokens.rSm),
              child: InkWell(
                borderRadius: BorderRadius.circular(DsTokens.rSm),
                onTap: () => _pick(context),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(DsTokens.rSm),
                    border: Border.all(color: DsTokens.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 17, color: DsTokens.faint),
                      const SizedBox(width: 10),
                      Text(
                        value.isEmpty ? 'בחר תאריך' : value,
                        style: TextStyle(
                          color: value.isEmpty ? DsTokens.faint : DsTokens.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
