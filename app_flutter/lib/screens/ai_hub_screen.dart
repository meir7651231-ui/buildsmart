import 'dart:async';

import 'package:buildsmart/data/contractor_seeds.dart' show fMoney;
import 'package:buildsmart/data/related_info.dart' show catalogProductForSku;
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/data/task_skus_local.dart' show catalogSiblingsFor;
import 'package:buildsmart/logic/ai_hub_logic.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/catalog_screen.dart'
    show searchQueryProvider;
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/screens/ai_assistant_screen.dart'
    show AiAssistantScreen;
import 'package:buildsmart/screens/business_summary_screen.dart'
    show BusinessSummaryScreen;
import 'package:buildsmart/screens/describe_to_cart_screen.dart'
    show DescribeToCartScreen;
import 'package:buildsmart/screens/home_shell.dart' show CartFab;
import 'package:buildsmart/screens/keyboard_tool_tree.dart'
    show KbToolNode;
import 'package:buildsmart/screens/lipskey_product_sheet.dart'
    show showLipskeyProductSheet;
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/services/weather.dart';
import 'package:buildsmart/state/app_profile.dart' show kProfileRawShell;
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:buildsmart/state/keyboard_screen_tools.dart' show KbScreen;
import 'package:buildsmart/state/orders_engine.dart' show ordersEngineProvider;
import 'package:buildsmart/state/smart_cart.dart'
    show SmartCartLine, smartCartProvider;
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🤖 בינה מלאכותית ואוטומציה — the AI hub (T3.H).
///
/// Faithful native port of proto Category G (`openAIHub` @21123). Nine tools.
/// Each is wired to REAL behaviour or honestly flagged:
///   • 📷 ברקוד + 🎙️ דיבור = REAL — drive the catalog's live
///     [searchQueryProvider] and switch to the catalog tab (same wiring the
///     catalog's own search-tools use).
///   • 💡 חלופות זולות + 📐 סריקת תוכניות = REAL — open the canonical contractor
///     sheets that COMPUTE over the live catalog price tiers / smart-cart.
///   • 📦 חיזוי מלאי = REAL/COMPUTED — [computeStockForecast] over the live
///     orders engine (consumption history) + cart (on-hand). No model.
///   • 📊 Analytics חכם = REAL/COMPUTED — [computeAnalyticsInsights] over the
///     live orders engine + budget + the real cheaper-alternatives scan.
///   • 🔗 התאמה משולשת · 🌦️ מזג אוויר · 🔧 זיהוי בלאי = DEFERRED — each needs an
///     EXTERNAL data source the app does not hold (supplier delivery-note &
///     invoice documents · a weather-forecast API · IoT equipment-hour sensors),
///     so they render a verbatim sample under an explicit "⚙️ בפרודקשן" note.
///
/// True while a [AIHubScreen._runVoice] recognition session is active — guards the
/// stateless-widget 🎙️ tile against overlapping listens (module-level because the
/// dispatch is a `static` method). Mirrors VoiceDictateButton's `_listening`.
bool _voiceBusy = false;

/// WIRE: reached from the home menu-dial 🤖 leaf and the home AI-hub button —
/// `Navigator.push(AIHubScreen.route())`. See the agent report's WIRE notes.
class AIHubScreen extends ConsumerWidget {
  const AIHubScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AIHubScreen());

  // Keyboard tools are built ONCE in [_kbNodes] from _visibleTiles — one leaf per
  // visible hub feature, mirroring the on-screen grid.

  /// 10 tiles — the 9 VERBATIM proto `items` (@21124-21134) + the AI
  /// describe→cart feature (#ai-describe-to-cart) at the head.
  static const List<({String id, String ic, String t, String s})> _tiles = [
    (id: 'describe', ic: '🗣️', t: 'תאר עבודה → סל', s: 'ספר מה צריך, נבנה סל'),
    (id: 'stock', ic: '📦', t: 'חיזוי מלאי', s: 'מתי להזמין שוב'),
    (id: 'barcode', ic: '📷', t: 'סורק ברקוד', s: 'זיהוי מוצר מהיר'),
    (id: 'voice', ic: '🎙️', t: 'דיבור למשימה', s: 'יצירת משימה בקול'),
    (id: 'alt', ic: '💡', t: 'חלופות זולות', s: 'מוצרים חליפיים'),
    (id: 'plan', ic: '📐', t: 'סריקת תוכניות', s: 'PDF → רשימת חומרים'),
    (id: '3way', ic: '🔗', t: 'התאמה משולשת', s: 'הזמנה·תעודה·חשבונית'),
    (id: 'weather', ic: '🌦️', t: 'אוטומציית מזג אוויר', s: 'התראות לפי תחזית'),
    (id: 'wear', ic: '🔧', t: 'זיהוי בלאי', s: 'תחזוקת ציוד'),
    (id: 'analytics', ic: '📊', t: 'Analytics חכם', s: 'תובנות ומגמות'),
    // #ai-assistant — appended at the tail so every existing tile keeps its grid
    // index (the compute/dedup widget tests tap tiles by on-screen position).
    (id: 'assistant', ic: '🤖', t: 'עוזר חכם', s: 'שאל אותי כל דבר'),
  ];

  /// The DEFERRED tools — each needs an EXTERNAL data source the app does not
  /// hold (supplier delivery-note/invoice docs · a weather API · IoT sensors),
  /// so their feature view renders a visible "⚙️ בפרודקשן" placeholder. For
  /// Apple review ([kHideUnderConstruction]) these tiles are filtered out of the
  /// hub grid; the tile data + feature views stay in code (reversible) and the
  /// matching `kAiDeferredSearchTitles` keep them out of the live search index.
  static const Set<String> _deferredToolIds = {'3way', 'weather', 'wear'};

  /// The DEFERRED (backend-blocked) tool ids — exposed for tests/guards.
  static Set<String> get deferredToolIds => _deferredToolIds;

  /// The tools a RAW company shell must not offer ([kProfileRawShell]) —
  /// 💡 חלופות זולות + 📐 סריקת תוכניות claim partner-store prices, and a
  /// company shell holds no price data (the imported catalog model carries
  /// none); 📊 Analytics' savings line folds the same invented
  /// `kHomeProductBrands` scan. Dropped from [_visibleTiles], so the grid, the
  /// keyboard mirror [_kbNodes] and [visibleToolIds] can't diverge; the tile
  /// data + dispatch stay in code (reversible). Demo/buildsmart: const-false
  /// gate ⇒ byte-identical.
  static const Set<String> _rawHiddenToolIds = {'alt', 'plan', 'analytics'};

  /// The visible tiles for this build — all 9 unless we are hiding the deferred
  /// (backend-blocked) ones for Apple review, minus [_rawHiddenToolIds] on the
  /// raw company shell (both gates const ⇒ the drop is compile-time).
  static List<({String id, String ic, String t, String s})> get _visibleTiles =>
      kHideUnderConstruction || kProfileRawShell
          ? [
            for (final t in _tiles)
              if (!(kHideUnderConstruction && _deferredToolIds.contains(t.id)))
                if (!(kProfileRawShell && _rawHiddenToolIds.contains(t.id))) t,
          ]
          : _tiles;

  /// The tool ids actually rendered on the hub grid this build — the single
  /// source of truth tests assert against (no fragile widget pump needed).
  static List<String> get visibleToolIds => [
    for (final t in _visibleTiles) t.id,
  ];

  /// REAL barcode — scan, push the code into the live catalog search, land on
  /// the catalog tab. Mirrors catalog_screen.dart:1721-1726. `static` (uses only
  /// its [context]/[ref] args) so the build-once [_kbNodes] dispatch can reach it.
  static Future<void> _runBarcode(BuildContext context, WidgetRef ref) async {
    final code = await openBarcodeScanner(context);
    if (code == null || code.isEmpty || !context.mounted) return;
    // #barcode-plus — a scanned SKU opens the product card directly; search
    // fallback only when it's not a known catalog SKU.
    final product = catalogProductForSku(code);
    if (product != null) {
      showLipskeyProductSheet(context, product, catalogSiblingsFor(product));
      return;
    }
    ref.read(searchQueryProvider.notifier).state = code;
    ref.read(mainTabProvider.notifier).state = 0;
    unawaited(Navigator.of(context).maybePop());
  }

  /// REAL voice — listen, push the transcript into the live catalog search.
  /// Mirrors catalog_screen.dart:1701-1716. `static` (uses only its
  /// [context]/[ref] args) so the build-once [_kbNodes] dispatch can reach it.
  static Future<void> _runVoice(BuildContext context, WidgetRef ref) async {
    // Busy guard: this screen is a stateless ConsumerWidget, so a second 🎙️ tap
    // while a session is already listening would start an OVERLAPPING recognition.
    // Module-level flag (mirrors the tested VoiceDictateButton `_listening` guard);
    // set before listen, cleared when the session ends (onFinal/onError) or fails
    // to start (`!ok`).
    if (_voiceBusy) return;
    _voiceBusy = true;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await VoiceService.instance.listen(
      onFinal: (t) {
        _voiceBusy = false;
        if (t.isNotEmpty) {
          ref.read(searchQueryProvider.notifier).state = t;
          ref.read(mainTabProvider.notifier).state = 0;
          if (context.mounted) unawaited(Navigator.of(context).maybePop());
        }
      },
      // Previously omitted → an errored session went unreported AND left no way to
      // clear the guard. Clear on error so the button re-arms.
      onError: (_) => _voiceBusy = false,
    );
    if (!ok) {
      _voiceBusy = false;
      messenger.showSnackBar(
        const SnackBar(
          content: CfgText(
            'ai_hub_screen.t01',
            'הדפדפן לא תומך בחיפוש קולי',
          ),
        ),
      );
    }
  }

  /// Material-icon glyph for a hub tile id (the on-screen tiles use emoji; the
  /// floating-keyboard tiles need IconData). `static` (pure switch on [id], no
  /// instance state) so the build-once [_kbNodes] can reference it.
  static IconData _kbIcon(String id) => switch (id) {
        'describe' => Icons.record_voice_over_outlined,
        'stock' => Icons.inventory_2_outlined,
        'barcode' => Icons.qr_code_scanner,
        'voice' => Icons.mic_none_outlined,
        'alt' => Icons.lightbulb_outline,
        'plan' => Icons.picture_as_pdf_outlined,
        'analytics' => Icons.analytics_outlined,
        'assistant' => Icons.smart_toy_outlined,
        '3way' => Icons.link,
        'weather' => Icons.cloud_outlined,
        'wear' => Icons.handyman_outlined,
        _ => Icons.auto_awesome_outlined,
      };

  /// Run a hub tile by id — the SAME dispatch as the on-screen grid's onTap, so
  /// a keyboard tool and its tile do exactly the same thing. `static` (uses only
  /// its [context]/[ref]/[id] args) so the build-once [_kbNodes] can reference it.
  static void _runTile(BuildContext context, WidgetRef ref, String id) {
    switch (id) {
      case 'describe':
        Navigator.of(context).push(DescribeToCartScreen.route());
      case 'assistant':
        Navigator.of(context).push(AiAssistantScreen.route());
      case 'barcode':
        _runBarcode(context, ref);
      case 'voice':
        _runVoice(context, ref);
      case 'alt':
        openCheaperAlternativesSheet(context);
      case 'plan':
        openScanPlanSheet(context);
      default:
        Navigator.of(context).push(_AIFeatureScreen.route(id));
    }
  }

  /// LIVE-MIRROR: the floating keyboard's tools for the AI hub — one leaf per
  /// VISIBLE tile (same set + dispatch as the grid), so the keyboard mirrors the
  /// hub's REAL features instead of only the 2 catalog entries.
  ///
  /// STABLE list built ONCE (a `static final`, matching stock_screen.dart:149) so
  /// [KbScreen]'s identity-compare (didUpdateWidget's `identical`) never re-registers
  /// it on a rebuild — the tile set is fixed at class-load (from the const-driven
  /// [_visibleTiles]), so a fresh list per build only churned the registration.
  /// Tree-shaken with the whole [KbScreen] path when [kKbGlobal] is off.
  static final List<KbToolNode> _kbNodes = <KbToolNode>[
    for (final t in _visibleTiles)
      KbToolNode.leaf(
        icon: _kbIcon(t.id),
        label: t.t,
        action: (ref, context) => _runTile(context, ref, t.id),
      ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The cart FAB rides above this PUSHED route too — visible only when the
    // cart has items, so adding from a tool (e.g. plan-scan) gives immediate
    // feedback here without yanking the user to the Store tab. popFirst: true →
    // tapping pops the hub, then lands on the cart tab underneath.
    final cartHasItems = ref.watch(
      smartCartProvider.select((lines) => lines.isNotEmpty),
    );
    // KbScreen: while this pushed route is front-most under [kKbGlobal], the
    // floating ▦ grid mirrors THIS hub's tools ([_kbNodes]); reverts on pop. Pure
    // pass-through (byte-identical) when the flag is off.
    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: aiAppBar(context, '🤖 בינה מלאכותית'),
        floatingActionButton:
            cartHasItems ? const CartFab(popFirst: true) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                for (final t in _visibleTiles)
                  AiFinTile(
                    ic: t.ic,
                    title: t.t,
                    sub: t.s,
                    onTap: () {
                      switch (t.id) {
                        case 'describe':
                          Navigator.of(
                            context,
                          ).push(DescribeToCartScreen.route());
                        case 'assistant':
                          Navigator.of(context).push(AiAssistantScreen.route());
                        case 'barcode':
                          _runBarcode(context, ref);
                        case 'voice':
                          _runVoice(context, ref);
                        case 'alt':
                          // Canonical R9 modal sheet (no duplicate full screen).
                          openCheaperAlternativesSheet(context);
                        case 'plan':
                          // Canonical R9 modal sheet (no duplicate full screen).
                          openScanPlanSheet(context);
                        default:
                          Navigator.of(
                            context,
                          ).push(_AIFeatureScreen.route(t.id));
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    return kKbGlobal ? KbScreen(tools: _kbNodes, child: body) : body;
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
      '3way' => const _ThreeWay(),
      'weather' => const _Weather(),
      'wear' => const _Wear(),
      'analytics' => const _Analytics(),
      _ => const SizedBox.shrink(),
    };
    // Same cart FAB as the hub — this sub-view is also a PUSHED route, so
    // popFirst pops back toward the home shell before landing on the cart tab.
    final cartHasItems = ref.watch(
      smartCartProvider.select((lines) => lines.isNotEmpty),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: aiAppBar(context, '🤖 בינה מלאכותית'),
        floatingActionButton:
            cartHasItems ? const CartFab(popFirst: true) : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
// REAL/COMPUTED: [computeStockForecast] folds the live orders engine (captured
// line-item consumption history) + the live cart (on-hand) into a per-product
// run-out forecast — deterministic, no model. Empty until real orders carry
// lines → honest "no data yet" note (never invented rows).
class _PredictStock extends ConsumerWidget {
  const _PredictStock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersEngineProvider);
    final cart = ref.watch(smartCartProvider);
    final preds = computeStockForecast(orders, cart);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '📦',
          title: 'חיזוי מלאי',
          sub: 'חיזוי מתי כל חומר ייגמר — לפי קצב הצריכה באתר.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote(
          '🧮 מחושב מתוך היסטוריית ההזמנות והעגלה החיה — קצב צריכה ומלאי נוכחי',
        ),
        const SizedBox(height: BsTokens.space2),
        if (preds.isEmpty)
          const AiCard(
            overdue: false,
            child: AiCardSub(
              'אין עדיין היסטוריית צריכה — בצע הזמנות כדי לקבל חיזוי מלאי',
            ),
          )
        else
          for (final p in preds)
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
                      onTap: () {
                        // REAL: add one unit of the running-out product to the
                        // live cart, rebuilt from the genuine captured order-line
                        // fields the forecast carries (name · emoji · unit price).
                        ref
                            .read(smartCartProvider.notifier)
                            .add(
                              SmartCartLine(
                                productKey: 'ai-restock:${p.name}',
                                productName: p.name,
                                productEmoji: p.emoji,
                                brandName: 'מומלץ AI',
                                brandPrice: p.unitPrice,
                                productQty: 1,
                                accessories: const [],
                              ),
                            );
                        showToast(context, '${p.name} נוסף לסל');
                      },
                    ),
                  ],
                ],
              ),
            ),
      ],
    );
  }
}

// ─── 67. THREE-WAY MATCHING — proto aiThreeWay @21303 ─────────────────────────
// DEFERRED (🔑): a true three-way match reconciles the ORDER against the
// supplier-issued DELIVERY NOTE and INVOICE — two external documents the app
// does not capture (the orders engine holds only the order total, no separate
// delivery/invoice amounts). Computing it would mean inventing those numbers,
// so this renders the verbatim proto sample under an explicit note. Wire for
// real once supplier delivery-notes + invoices are ingested.
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
        const AiServerNote(
          '⚙️ בפרודקשן: דורש תעודות משלוח וחשבוניות מהספק (מסמכים חיצוניים)',
        ),
        const SizedBox(height: BsTokens.space2),
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
                    _ThreeCol(
                      label: 'הזמנה',
                      value: fMoney(d.order),
                      bad: false,
                    ),
                    _ThreeCol(
                      label: 'תעודה',
                      value: fMoney(d.delivery),
                      bad: d.delivery != d.order,
                    ),
                    _ThreeCol(
                      label: 'חשבונית',
                      value: fMoney(d.invoice),
                      bad: d.invoice != d.order,
                    ),
                  ],
                ),
                if (!d.match) ...[
                  const SizedBox(height: 8),
                  const CfgText(
                    'ai_hub_screen.t02',
                    'נדרשת בדיקה — הסכומים אינם זהים',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ThreeCol extends StatelessWidget {
  const _ThreeCol({
    required this.label,
    required this.value,
    required this.bad,
  });

  final String label;
  final String value;
  final bool bad;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: bad ? const Color(0xFFC62828) : BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 68. WEATHER AUTOMATION — proto aiWeather @21333 ──────────────────────────
class _Weather extends ConsumerWidget {
  const _Weather();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // #45 — REAL forecast from Open-Meteo by device GPS (weatherForecastProvider);
    // falls back to the kWeather seed while locating / on no-GPS / network error.
    final days = ref.watch(weatherForecastProvider).asData?.value ?? kWeather;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '🌦️',
          title: 'אוטומציית מזג אוויר',
          sub: 'המערכת מתאימה את לוח העבודה לתחזית.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote('🌦️ תחזית Open-Meteo · לפי מיקום המכשיר'),
        const SizedBox(height: BsTokens.space2),
        for (final d in days)
          AiCard(
            overdue: d.warn,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AiCardTop(
                  title: '${d.ic} ${d.day}',
                  pill: d.temp,
                  danger: d.warn,
                ),
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
                  danger: g.worn,
                ),
                const SizedBox(height: 4),
                AiCardSub('${g.hours} / ${g.life} שעות עבודה'),
                const SizedBox(height: 6),
                AiBar(pct: g.pct.clamp(0, 100), danger: g.worn),
                if (g.worn) ...[
                  const SizedBox(height: 8),
                  const CfgText(
                    'ai_hub_screen.t03',
                    'מומלץ לתזמן תחזוקה',
                    style: TextStyle(
                      color: Color(0xFFC62828),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

// ─── 70. SMART ANALYTICS — proto aiAnalytics @21383 ───────────────────────────
// REAL/COMPUTED: [computeAnalyticsInsights] folds the live orders engine +
// budget + the real cheaper-alternatives scan into deterministic insights — no
// model. Every number re-derives from live providers.
class _Analytics extends ConsumerWidget {
  const _Analytics();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersEngineProvider);
    final insights = computeAnalyticsInsights(orders);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AiMdHead(
          ic: '📊',
          title: 'Analytics חכם',
          sub: 'תובנות אוטומטיות על ההתנהלות באתר.',
        ),
        const SizedBox(height: BsTokens.space3),
        const AiServerNote(
          '🧮 מחושב מנתוני אמת — מנוע ההזמנות, התקציב והשוואת המחירים בקטלוג',
        ),
        const SizedBox(height: BsTokens.space2),
        // #ai-business-summary — when AI is live, narrate the REAL computed
        // insights into a short Hebrew business check-in. gateway null (demo)
        // → not in the tree → the analytics view is byte-identical.
        if (ref.watch(claudeGatewayProvider) != null &&
            insights.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  () => Navigator.of(context).push(
                    BusinessSummaryScreen.route(
                      insightLines: [
                        for (final it in insights)
                          '${it.ic} ${it.title} — ${it.sub}',
                      ],
                    ),
                  ),
              icon: const Text('✨'),
              label: const CfgText('ai_hub_screen.t04', 'סיכום בעברית'),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
        ],
        for (final it in insights)
          AiCard(
            overdue: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${it.ic} ${it.title}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
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
      child: const CfgText(
        'ai_hub_screen.t05',
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
        Text(
          title,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
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
      borderRadius: BorderRadius.circular(cfgRadius(context)),
      child: InkWell(
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(ic, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                ),
              ),
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
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
          child: Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: danger ? const Color(0xFFFFEBEE) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(
            pill,
            style: TextStyle(
              color: danger ? const Color(0xFFC62828) : BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class AiCardSub extends StatelessWidget {
  const AiCardSub(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
  );
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
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
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
        borderRadius: BorderRadius.circular(cfgRadius(context)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
    );
  }
}
