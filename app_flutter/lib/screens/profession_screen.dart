import 'package:buildsmart/screens/coming_soon_screen.dart';
import 'package:buildsmart/state/onboarding_gate.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trades that have no real content yet — picking one leads to an honest
/// "בקרוב" screen instead of an empty flow. Only אינסטלטור is fully built.
const Set<String> kComingSoonTrades = {'חשמלאי', 'קבלן שיפוצים'};

/// One trade option (pure data → unit-testable).
class TradeOption {
  const TradeOption(this.icon, this.name, this.desc);
  final IconData icon;
  final String name;
  final String desc;
}

/// The trades offered in the profession step — ported from the prototype's
/// `pickProfession` cards (Material icons, not emoji).
const List<TradeOption> kTradeOptions = [
  TradeOption(Icons.plumbing, 'אינסטלטור', 'ברזים, אסלות, צנרת, חימום מים'),
  TradeOption(
    Icons.electrical_services,
    'חשמלאי',
    'נקודות, לוחות, כבלים, גופי תאורה',
  ),
  TradeOption(Icons.handyman, 'קבלן שיפוצים', 'פרויקט שלם — מבנייה ועד גמר'),
];

/// Profession picker — ported from the prototype's `screen-profession`.
/// Picking a trade saves it to the profile and advances to the onboarding step.
class ProfessionScreen extends ConsumerWidget {
  const ProfessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void pick(String name) {
      // Trades without real content yet → honest "בקרוב" screen (keeps the
      // user on the picker via back). Only אינסטלטור proceeds into the app.
      if (kComingSoonTrades.contains(name)) {
        Navigator.of(context).push(ComingSoonScreen.route(name));
        return;
      }
      ref.read(userProfileProvider.notifier).setProfession(name);
      ref.read(startupStepProvider.notifier).state = 2;
    }

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      body: HelpModeScaffold(
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.all(BsTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  HelpTarget(
                    title: 'חזרה',
                    body: 'חוזר אחורה למסך הקודם (מסך הפתיחה / ההרשמה).',
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(startupStepProvider.notifier).state = 0,
                      icon: const Icon(Icons.chevron_right,
                          color: BsTokens.mutedLight),
                      label: const Text('חזור',
                          style: TextStyle(color: BsTokens.mutedLight)),
                    ),
                  ),
                  const Spacer(),
                  const HelpToggleButton(),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              const Text(
                'מה התחום שלך?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: BsTokens.inkLight,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              const Text(
                'נתאים לך את האפליקציה — קטלוג, כלים והמלצות לפי המקצוע',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
              const SizedBox(height: BsTokens.space5),
              for (final t in kTradeOptions) ...[
                HelpTarget(
                  title: t.name,
                  body: 'בחירת התחום "${t.name}" (${t.desc}). אמורה להתאים '
                      'קטלוג/כלים/המלצות למקצוע — כרגע אינסטלטור פעיל, השאר בקרוב.',
                  child: _TradeCard(trade: t, onTap: () => pick(t.name)),
                ),
                const SizedBox(height: BsTokens.space3),
              ],
              const Spacer(),
              const Text(
                'תוכל לשנות את הבחירה בכל עת מההגדרות',
                textAlign: TextAlign.center,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  const _TradeCard({required this.trade, required this.onTap});

  final TradeOption trade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x1AFF7A18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(trade.icon, color: BsTokens.brand, size: 28),
              ),
              const SizedBox(width: BsTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: BsTokens.inkLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trade.desc,
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
            ],
          ),
        ),
      ),
    );
  }
}
