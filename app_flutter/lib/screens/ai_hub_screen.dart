import 'dart:async';

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/catalog_screen.dart' show searchQueryProvider;
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🤖 בינה מלאכותית ואוטומציה — the AI hub (T3.H).
///
/// Faithful native port of proto Category G (`openAIHub` @21123). Nine tools:
///   • 📷 ברקוד + 🎙️ דיבור = REAL — they drive the catalog's live
///     [searchQueryProvider] and switch to the catalog tab (same wiring the
///     catalog's own search-tools use). NOT a toast.
///   • all 7 others = SIMULATED AI result rendered ON SCREEN (predictions,
///     cheaper alternatives via [aiAlternatives]/`cheaperAlternativeBrand`,
///     weather, wear, three-way, plan-scan, analytics) — NOT a toast.
///
/// WIRE: reached from the home menu-dial 🤖 leaf and the home AI-hub button —
/// `Navigator.push(AIHubScreen.route())`. See the agent report's WIRE notes.
class AIHubScreen extends ConsumerWidget {
  const AIHubScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AIHubScreen());

  /// 9 tiles — VERBATIM fn/ic/t/s from proto `items` @21124-21134.
  static const List<({String id, String ic, String t, String s})> _tiles = [
    (id: 'stock', ic: '📦', t: 'חיזוי מלאי', s: 'מתי להזמין שוב'),
    (id: 'barcode', ic: '📷', t: 'סורק ברקוד', s: 'זיהוי מוצר מהיר'),
    (id: 'voice', ic: '🎙️', t: 'דיבור למשימה', s: 'יצירת משימה בקול'),
    (id: 'alt', ic: '💡', t: 'חלופות זולות', s: 'מוצרים חליפיים'),
    (id: 'plan', ic: '📐', t: 'סריקת תוכניות', s: 'PDF → רשימת חומרים'),
    (id: '3way', ic: '🔗', t: 'התאמה משולשת', s: 'הזמנה·תעודה·חשבונית'),
    (id: 'weather', ic: '🌦️', t: 'אוטומציית מזג אוויר', s: 'התראות לפי תחזית'),
    (id: 'wear', ic: '🔧', t: 'זיהוי בלאי', s: 'תחזוקת ציוד'),
    (id: 'analytics', ic: '📊', t: 'Analytics חכם', s: 'תובנות ומגמות'),
  ];

  /// REAL barcode — scan, push the code into the live catalog search, land on
  /// the catalog tab. Mirrors catalog_screen.dart:1721-1726.
  Future<void> _runBarcode(BuildContext context, WidgetRef ref) async {
    final code = await openBarcodeScanner(context);
    if (code == null || code.isEmpty || !context.mounted) return;
    ref.read(searchQueryProvider.notifier).state = code;
    ref.read(mainTabProvider.notifier).state = 0;
    unawaited(Navigator.of(context).maybePop());
  }

  /// REAL voice — listen, push the transcript into the live catalog search.
  /// Mirrors catalog_screen.dart:1701-1716.
  Future<void> _runVoice(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await VoiceService.instance.listen(
      onFinal: (t) {
        if (t.isNotEmpty) {
          ref.read(searchQueryProvider.notifier).state = t;
          ref.read(mainTabProvider.notifier).state = 0;
          if (context.mounted) unawaited(Navigator.of(context).maybePop());
        }
      },
    );
    if (!ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('הדפדפן לא תומך בחיפוש קולי')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: aiAppBar(context, '🤖 בינה מלאכותית'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            const AiMdHead(
              ic: '🤖',
              title: 'בינה מלאכותית ואוטומציה',
              sub: 'כלים חכמים שחוסכים זמן וטעויות.',
            ),
            const SizedBox(height: BsTokens.space4),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: BsTokens.space3,
              crossAxisSpacing: BsTokens.space3,
              childAspectRatio: 1.45,
              children: [
                for (final t in _tiles)
                  AiFinTile(
                    ic: t.ic,
                    title: t.t,
                    sub: t.s,
                    onTap: () {
                      switch (t.id) {
                        case 'barcode':
                          _runBarcode(context, ref);
                        case 'voice':
                          _runVoice(context, ref);
                        default:
                          Navigator.of(context)
                              .push(_AIFeatureScreen.route(t.id));
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One simulated-AI feature view (proto `aiFeature` overlays @21155-21399).
class _AIFeatureScreen extends ConsumerWidget {
  const _AIFeatureScreen(this.id);

  final String id;

  static Route<void> route(String id) =>
      MaterialPageRoute<void>(builder: (_) => _AIFeatureScreen(id));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = switch (id) {
      'stock' => const _PredictStock(),
      'alt' => const _Alternatives(),
      'plan' => const _PlanScan(),
      '3way' => const _ThreeWay(),
      'weather' => const _Weather(),
      'wear' => const _Wear(),
      'analytics' => const _Analytics(),
      _ => const SizedBox.shrink(),
    };
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: aiAppBar(context, '🤖 בינה מלאכותית'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [body],
        ),
      ),
    );
  }
}

// ─── 62. PREDICTIVE STOCK — proto aiPredictStock @21155 ───────────────────────
class _PredictStock extends StatelessWidget {
  const _PredictStock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '📦',
          title: 'חיזוי מלאי',
          sub: 'חיזוי מתי כל חומר ייגמר — לפי קצב הצריכה באתר.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('⚙️ בפרודקשן: מודל חיזוי מבוסס היסטוריית צריכה בשרת'),
        const SizedBox(height: BsTokens.space2),
        for (final p in kStockPreds)
          AiCard(
            overdue: p.urgent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardTop(
                  title: p.name,
                  pill: '${p.urgent ? '⚠️ ' : ''}עוד ${p.days} ימים',
                  danger: p.urgent,
                ),
                const SizedBox(height: 4),
                AiCardSub('מלאי ${p.stock} · צריכה ${p.rate}/יום'),
                if (p.urgent) ...[
                  const SizedBox(height: 8),
                  AiCardBtn(
                    label: 'הזמן עכשיו',
                    onTap: () => showToast(context, 'נוסף לרשימת רכש מומלצת'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 65. CHEAPER ALTERNATIVES — proto aiAlternatives @21232 ───────────────────
class _Alternatives extends StatelessWidget {
  const _Alternatives();

  @override
  Widget build(BuildContext context) {
    final found = aiAlternatives();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '💡',
          title: 'חלופות זולות',
          sub: 'המערכת מאתרת מוצרים חליפיים זולים יותר באותה קטגוריה.',
        ),
        const SizedBox(height: BsTokens.space3),
        if (found.isEmpty)
          const _AiEmpty('לא נמצאו חלופות זולות יותר')
        else
          for (final f in found)
            AiCard(
              overdue: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('📂 ${f.cat}',
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _AltSide(
                          name: f.fromName,
                          price: fMoney(f.fromPrice),
                          up: false,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('←', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: _AltSide(
                          name: f.toName,
                          price: fMoney(f.toPrice),
                          up: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('חיסכון אפשרי: ${fMoney(f.save)}',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
      ],
    );
  }
}

class _AltSide extends StatelessWidget {
  const _AltSide({required this.name, required this.price, required this.up});

  final String name;
  final String price;
  final bool up;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name,
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13)),
        const SizedBox(height: 2),
        Text(price,
            style: TextStyle(
              color: up ? const Color(0xFF2E7D32) : BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            )),
      ],
    );
  }
}

// ─── 66. PDF PLAN SCAN — proto aiPlanResult @21283 ────────────────────────────
class _PlanScan extends StatelessWidget {
  const _PlanScan();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '📐',
          title: 'סריקת תוכניות PDF',
          sub: 'החומרים שזוהו מהתוכנית:',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('⚙️ בפרודקשן: זיהוי תוכניות (CV/AI) בשרת'),
        const SizedBox(height: BsTokens.space2),
        Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            children: [
              for (final it in kPlanResult)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(it.name,
                          style: const TextStyle(
                              color: BsTokens.inkLight, fontSize: 14)),
                      Text(it.qty,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        AiPrimary(
          label: 'הוסף הכל לסל',
          onTap: () => showToast(context, '4 פריטים נוספו לסל'),
        ),
      ],
    );
  }
}

// ─── 67. THREE-WAY MATCHING — proto aiThreeWay @21303 ─────────────────────────
class _ThreeWay extends StatelessWidget {
  const _ThreeWay();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '🔗',
          title: 'התאמה משולשת',
          sub: 'השוואה אוטומטית: הזמנה · תעודת משלוח · חשבונית.',
        ),
        const SizedBox(height: BsTokens.space3),
        for (final d in kThreeWayDocs)
          AiCard(
            overdue: !d.match,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardTop(
                  title: '📦 ${d.id}',
                  pill: d.match ? '✓ תואם' : '⚠️ אי-התאמה',
                  danger: !d.match,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ThreeCol(label: 'הזמנה', value: fMoney(d.order), bad: false),
                    _ThreeCol(
                        label: 'תעודה',
                        value: fMoney(d.delivery),
                        bad: d.delivery != d.order),
                    _ThreeCol(
                        label: 'חשבונית',
                        value: fMoney(d.invoice),
                        bad: d.invoice != d.order),
                  ],
                ),
                if (!d.match) ...[
                  const SizedBox(height: 8),
                  const Text('נדרשת בדיקה — הסכומים אינם זהים',
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ThreeCol extends StatelessWidget {
  const _ThreeCol({required this.label, required this.value, required this.bad});

  final String label;
  final String value;
  final bool bad;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: bad ? const Color(0xFFC62828) : BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}

// ─── 68. WEATHER AUTOMATION — proto aiWeather @21333 ──────────────────────────
class _Weather extends StatelessWidget {
  const _Weather();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '🌦️',
          title: 'אוטומציית מזג אוויר',
          sub: 'המערכת מתאימה את לוח העבודה לתחזית.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('⚙️ בפרודקשן: שירות תחזית מזג אוויר חיצוני'),
        const SizedBox(height: BsTokens.space2),
        for (final d in kWeather)
          AiCard(
            overdue: d.warn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardTop(
                    title: '${d.ic} ${d.day}', pill: d.temp, danger: d.warn),
                const SizedBox(height: 4),
                AiCardSub(d.note),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 69. EQUIPMENT WEAR — proto aiWearDetect @21355 ───────────────────────────
class _Wear extends StatelessWidget {
  const _Wear();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '🔧',
          title: 'זיהוי בלאי ציוד',
          sub: 'ניטור שעות עבודה של הציוד והתראה לפני תקלה.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('⚙️ בפרודקשן: חיישני IoT וניטור צריכת חשמל בשרת'),
        const SizedBox(height: BsTokens.space2),
        for (final g in kGear)
          AiCard(
            overdue: g.worn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardTop(
                    title: '${g.ic} ${g.name}',
                    pill: '${g.pct}%',
                    danger: g.worn),
                const SizedBox(height: 4),
                AiCardSub('${g.hours} / ${g.life} שעות עבודה'),
                const SizedBox(height: 6),
                AiBar(pct: g.pct.clamp(0, 100), danger: g.worn),
                if (g.worn) ...[
                  const SizedBox(height: 8),
                  const Text('מומלץ לתזמן תחזוקה',
                      style: TextStyle(
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 70. SMART ANALYTICS — proto aiAnalytics @21383 ───────────────────────────
class _Analytics extends StatelessWidget {
  const _Analytics();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '📊',
          title: 'Analytics חכם',
          sub: 'תובנות אוטומטיות על ההתנהלות באתר.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('⚙️ בפרודקשן: מנוע אנליטיקה מבוסס נתוני אמת'),
        const SizedBox(height: BsTokens.space2),
        for (final it in kInsights)
          AiCard(
            overdue: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${it.ic} ${it.title}',
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    )),
                const SizedBox(height: 4),
                AiCardSub(it.sub),
              ],
            ),
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Shared presentation primitives (public to allow reuse; style-matched).
// ════════════════════════════════════════════════════════════════════════════

PreferredSizeWidget aiAppBar(BuildContext context, String title) => AppBar(
      backgroundColor: BsTokens.cardLight,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: BsTokens.space4,
      title: Text(
        title,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Text(
            '‹ חזרה',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ),
      ],
    );

class AiMdHead extends StatelessWidget {
  const AiMdHead({
    required this.ic,
    required this.title,
    required this.sub,
    super.key,
  });

  final String ic;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(ic, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            )),
        const SizedBox(height: 2),
        Text(sub,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
      ],
    );
  }
}

class AiFinTile extends StatelessWidget {
  const AiFinTile({
    required this.ic,
    required this.title,
    required this.sub,
    required this.onTap,
    super.key,
  });

  final String ic;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ic, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  )),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

class AiCard extends StatelessWidget {
  const AiCard({required this.child, required this.overdue, super.key});

  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(
          color: overdue ? const Color(0xFFE57373) : const Color(0xFFEEEEEE),
        ),
      ),
      child: child,
    );
  }
}

class AiCardTop extends StatelessWidget {
  const AiCardTop({
    required this.title,
    required this.pill,
    this.danger = false,
    super.key,
  });

  final String title;
  final String pill;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              )),
        ),
        const SizedBox(width: BsTokens.space2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(pill,
              style: TextStyle(
                color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              )),
        ),
      ],
    );
  }
}

class AiCardSub extends StatelessWidget {
  const AiCardSub(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13));
}

class AiBar extends StatelessWidget {
  const AiBar({required this.pct, this.danger = false, super.key});

  final int pct;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: LinearProgressIndicator(
        value: pct / 100,
        minHeight: 8,
        backgroundColor: const Color(0xFFEEEEEE),
        valueColor: AlwaysStoppedAnimation<Color>(
          danger ? const Color(0xFFE53935) : BsTokens.brand,
        ),
      ),
    );
  }
}

class AiCardBtn extends StatelessWidget {
  const AiCardBtn({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: BsTokens.brandDark,
          side: const BorderSide(color: BsTokens.brand),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class AiPrimary extends StatelessWidget {
  const AiPrimary({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: BsTokens.brand,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white)),
      ),
    );
  }
}

class AiServerNote extends StatelessWidget {
  const AiServerNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Text(text,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
    );
  }
}

class _AiEmpty extends StatelessWidget {
  const _AiEmpty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space5),
      child: Text(text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
    );
  }
}
