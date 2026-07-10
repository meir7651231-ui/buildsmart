import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';

/// "בקרוב" — an honest placeholder screen for a profession whose content
/// isn't built yet (חשמלאי / קבלן שיפוצים). Reached from the profession picker
/// when the user picks one of those trades, instead of dropping them into an
/// empty flow. Names the chosen profession and offers a clear way back to the
/// profession picker.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({required this.profession, super.key});

  /// The verbatim Hebrew profession label the user picked (e.g. "חשמלאי").
  final String profession;

  static Route<void> route(String profession) => MaterialPageRoute<void>(
        builder: (_) => ComingSoonScreen(profession: profession),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const CfgText(
            'coming_soon_screen.title',
            'בקרוב',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const CfgText(
                'coming_soon_screen.back',
                '‹ חזרה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🚧',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 64),
                ),
                const SizedBox(height: BsTokens.space4),
                const CfgText(
                  'coming_soon_screen.heading',
                  'בקרוב',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: BsTokens.inkLight,
                  ),
                ),
                const SizedBox(height: BsTokens.space2),
                Text(
                  'התוכן עבור $profession בהכנה',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: BsTokens.space6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BsTokens.brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: BsTokens.space4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusCard),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const CfgText(
                    'coming_soon_screen.back_to_picker',
                    '‹ חזור לבחירת מקצוע',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
