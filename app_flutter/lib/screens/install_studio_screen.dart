import 'package:buildsmart/theme/tokens.dart';
// BuildSmart Studio — a cinematic installation designer built on install_engine.
// Dark "blueprint command-center": glowing product nodes wired by animated
// energy pipes, colour-coded by plumbing system, with a one-tap auto-assemble
// that fills every connector into an orderable bill of materials.
import 'dart:math' as math;
import 'package:buildsmart/data/product_images.dart';

import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/catalog_source.dart'
    show companyCatalogActive;
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/repositories/catalog_local.dart'
    show catalogRepositoryProvider;
import 'package:buildsmart/domain/connection_resolver.dart'
    show ConnectionResolver;
import 'package:buildsmart/domain/connection_schema.dart'
    show ProductConnectorSpec, SystemDef;
import 'package:buildsmart/domain/trade_physics_config.dart'
    show TradePhysicsConfig;
import 'package:buildsmart/domain/trade_schema.dart' show AccessoryRule;
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/logic/pressure_drop.dart';
import 'package:buildsmart/logic/price_estimate.dart';
import 'package:buildsmart/screens/audit_screen.dart';
import 'package:buildsmart/screens/keyboard_tool_tree.dart';
import 'package:buildsmart/state/app_profile.dart' show kProfileRawShell;
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/keyboard_overlay.dart';
import 'package:buildsmart/state/keyboard_screen_tools.dart';
import 'package:buildsmart/state/saved_projects.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/trades_store.dart'
    show TradesDoc, resolvedActiveTradeIdProvider, tradesStoreProvider;
import 'package:buildsmart/widgets/chain_diagram.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── palette ───────────────────────────────────────────────────────────────────
// Light theme — matches the rest of the BuildSmart app (light + orange brand).
const _void0 = Color(0xFFFAFAFA); // app background
const _void1 = Color(0xFFFFFFFF); // dialogs / sheets
const _panel = Color(0xFFFFFFFF); // cards / tiles
const _grid = Color(0x0F1A1A1A); // very faint neutral blueprint grid
const _ink = BsTokens.inkLight; // primary text
const _mute = Color(0xFF888888); // secondary text
const _supply = Color(0xFF0284C7); // blue — water supply
const _drain = Color(0xFFD97706); // amber — drainage
const _fixture = Color(0xFF7C3AED); // violet — fixtures (the bridge)
const _accent = BsTokens.brand; // brand orange — primary action
const _ok = Color(0xFF16A34A); // green — success / "all good"

// Close (X) for the studio bottom-sheets — matches the app's product-sheet
// close: a circular grey button with a dark X, top-left under the drag handle.
class _SheetClose extends StatelessWidget {
  const _SheetClose();
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 0, 2),
          child: Material(
            color: const Color(0xFFF5F5F5),
            shape: const CircleBorder(),
            child: Semantics(
              button: true,
              label: 'סגור',
              child: Tooltip(
                message: 'סגור',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.close, color: _ink, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// ── s49b · the gated trade-config seams ───────────────────────────────────────
// Every seam in this screen funnels through ONE guard: [_authoredConfigOf].
// R1-2 KEYSTONE: when the plumbing-resolved active trade is in effect (today:
// ALWAYS — a single published trade exists) the guard returns null BEFORE any
// authored slice is touched, and every seam runs its legacy branch verbatim.
// Only a published non-plumbing trade gets a config; plumbing's hand-written
// physics/consts below are permanent and never read authored data.

/// The resolved active trade's authored slices, bundled once per build:
/// systems (+ colors), the per-sku [ProductConnectorSpec] map, the mustHave
/// [AccessoryRule]s, the s41 [TradeResolution] (REUSED — no parallel seam) and
/// the optional [TradePhysicsConfig] (v1: always null — no authoring UI yet,
/// so the flow-physics panels hide for authored trades).
class _ActiveTradeConfig {
  _ActiveTradeConfig._({
    required this.tradeId,
    required this.systems,
    required this.mustHaveAccessories,
    required this.tradeResolution,
    required Map<String, ProductConnectorSpec> specBySku,
    required Map<String, String?> systemIdByTypeId,
    required Map<String, SystemDef> systemById,
    this.physics,
  })  : _specBySku = specBySku,
        _systemIdByTypeId = systemIdByTypeId,
        _systemById = systemById;

  factory _ActiveTradeConfig.fromDoc(String tradeId, TradesDoc doc) {
    final systems = [
      for (final s in doc.systems)
        if (s.tradeId == tradeId) s,
    ];
    final connectorTypes = [
      for (final t in doc.connectorTypes)
        if (t.tradeId == tradeId) t,
    ];
    final specBySku = {
      for (final s in doc.productSpecs)
        if (s.tradeId == tradeId) s.productSku: s,
    };
    return _ActiveTradeConfig._(
      tradeId: tradeId,
      systems: systems,
      mustHaveAccessories: [
        for (final a in doc.accessories)
          if (a.tradeId == tradeId && a.mustHave) a,
      ],
      tradeResolution: TradeResolution(
        tradeId: tradeId,
        resolver: ConnectionResolver(
          rules: [
            for (final r in doc.compatRules)
              if (r.tradeId == tradeId) r,
          ],
          connectorTypes: connectorTypes,
          systems: systems,
          completionRules: [
            for (final r in doc.completionRules)
              if (r.tradeId == tradeId) r,
          ],
        ),
        specOf: (sku) => specBySku[sku],
      ),
      specBySku: specBySku,
      systemIdByTypeId: {
        for (final t in connectorTypes) t.id: t.systemId,
      },
      systemById: {
        for (final s in systems) s.id: s,
      },
      // physics stays null in v1 (no authoring UI for flow-physics yet) —
      // the slope seam hides the ת"י-1205 panel for authored trades.
    );
  }

  final String tradeId;
  final List<SystemDef> systems;
  final List<AccessoryRule> mustHaveAccessories;
  final TradeResolution tradeResolution;
  final TradePhysicsConfig? physics;
  final Map<String, ProductConnectorSpec> _specBySku;
  final Map<String, String?> _systemIdByTypeId;
  final Map<String, SystemDef> _systemById;

  /// The spec envelope's `maxTempC` for [sku], or null (no spec / no key —
  /// the product is temp-suitable, matching the legacy null→suitable rule).
  /// (Per-sku spec access goes through [tradeResolution]'s own `specOf`.)
  num? maxTempCOf(String sku) => _specBySku[sku]?.envelope['maxTempC'];

  /// [SystemDef.color] of the single authored system the sku's spec ends
  /// belong to; the legacy multi-system convention ([_fixture], the bridge)
  /// when they span more than one; null when the sku has no spec or no
  /// system-carrying end — the caller falls through to the legacy consts.
  Color? systemColorOf(String sku) {
    final spec = _specBySku[sku];
    if (spec == null) return null;
    String? seen;
    for (final end in spec.ends) {
      final sysId = _systemIdByTypeId[end.connectorTypeId];
      if (sysId == null) continue;
      if (seen == null) {
        seen = sysId;
      } else if (seen != sysId) {
        return _fixture;
      }
    }
    if (seen == null) return null;
    final def = _systemById[seen];
    return def == null ? null : Color(def.color);
  }
}

/// s49b — THE guard (R1-2): null whenever the RESOLVED active trade is
/// 'plumbing' (today: always — count==1), returned BEFORE any authored slice
/// is read, so every seam short-circuits to its legacy branch verbatim.
/// `ref.read` (not watch) on purpose — this screen's existing in-build
/// provider-read idiom; nothing live switches the active trade mid-frame yet
/// (the s43 switcher renders only when >1 published trades exist).
_ActiveTradeConfig? _authoredConfigOf(WidgetRef ref) {
  final tradeId = ref.read(resolvedActiveTradeIdProvider);
  if (tradeId == 'plumbing') return null;
  return _ActiveTradeConfig.fromDoc(tradeId, ref.read(tradesStoreProvider));
}

Color _systemColor(LipskeyCatalogProduct p, [_ActiveTradeConfig? cfg]) {
  // s49b seam: authored trade reads config (SystemDef.color via the product's
  // spec ends); plumbing = legacy verbatim (R1-2 — cfg is null there, and
  // every call-site that passes no cfg stays byte-identical).
  if (cfg != null && cfg.systems.isNotEmpty) {
    final authored = cfg.systemColorOf(p.sku);
    if (authored != null) return authored;
  }
  final s = productSystems(p);
  if (s.length > 1) return _fixture;
  return s.contains(WaterSystem.drainage) ? _drain : _supply;
}

String _roleLabel(LipskeyCatalogProduct p, bool anchor) {
  if (anchor) return 'עוגן';
  switch (flowRole(p)) {
    case FlowRole.accessory:
      return 'אביזר';
    case FlowRole.fixture:
      return 'קבועה';
    case FlowRole.connector:
      return 'מחבר';
  }
}

/// Suggests how to bridge a gap. Delegates to the shared, unit-tested
/// [gapAdviceHe] (related_info.dart), which distinguishes a cross-system gap
/// (supply↔drainage — needs a fixture, not an adapter) from a same-system
/// mismatch (names the two unmet ends).
String _gapHint(InstallationGap g) => gapAdviceHe(g.from, g.to);

// ── picker categories ─────────────────────────────────────────────────────────
class _PickerCategory {
  const _PickerCategory(this.emoji, this.label, this.cats);
  final String emoji;
  final String label;
  final Set<String>? cats; // null = everything else (catch-all)
}

const _kCats = [
  _PickerCategory('🚰', 'ברז / כיור',
      {'ברזי כיור', 'ברזי מטבח', 'ברזי מעבר', 'ברזי קיר', 'ברזי ניל',
       'נקודות מים', 'ברזים', 'אביזרי ברזים', 'ברזי דלי', 'דיורים ופיות'}),
  _PickerCategory('🚿', 'מקלחת / אמבטיה',
      {'ברזי מקלחת', 'ראשי מקלחת', 'זרועות דוש', 'מזלפי יד',
       'ברזי אמבטיה', 'ערכות רחצה', 'מערכות אמבטיה',
       'אביזרי מקלחת', 'אביזרי חדר רחצה', 'צינורות מקלחת'}),
  _PickerCategory('🪠', 'אסלה / ניקוז',
      {'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'זקיף אסלה',
       'מסעפים וחיבורי אסלה', 'מחסומי רצפה', 'מחסומים גלויים',
       'מאספי רצפה', 'מאספים וקולטים', 'סיפונים', 'תעלות ניקוז',
       'אביזרי ביוב', 'ניקוז גג', 'כיסויים', 'מכסים ורשתות'}),
  _PickerCategory('🔥', 'מים חמים', {'מים חמים ו-recirculation'}),
  _PickerCategory('🌿', 'גן', {'ברזי גן', 'ציוד גן', 'ברזי אמבטיה'}),
  _PickerCategory('🔀', 'מחלק (כמה ברזים)', {'מחלקים'}),
  _PickerCategory('🔧', 'חיבורים', null), // null = catch-all
];

/// The picker categories actually rendered. Raw shell ([kProfileRawShell]):
/// the const plumbing [_kCats] never renders — with an imported company
/// catalog active ([companyCatalogActive]) the chips derive from the LIVE
/// [chainUniverse]'s distinct `categoryHe` values (FIRST-APPEARANCE order,
/// the company_categories idiom; emoji from the first product of the
/// category, template default '📦'), capped at the const grid's own count so
/// the non-scrollable 2-col grid keeps today's visual budget; before an
/// import there are no categories to offer — honest empty, never the const
/// plumbing chips. Demo/buildsmart: [_kCats] verbatim.
List<_PickerCategory> _pickerCats() {
  if (!kProfileRawShell) return _kCats;
  if (!companyCatalogActive) return const <_PickerCategory>[];
  final out = <_PickerCategory>[];
  final seen = <String>{};
  for (final p in chainUniverse) {
    final cat = p.categoryHe;
    if (cat.isEmpty || !seen.add(cat)) continue;
    out.add(_PickerCategory(
        p.categoryEmoji.isEmpty ? '📦' : p.categoryEmoji, cat, {cat}));
    if (out.length >= _kCats.length) break;
  }
  return out;
}

bool _inCategory(_PickerCategory cat, LipskeyCatalogProduct p) {
  if (cat.cats == null) {
    // catch-all: belongs here if NOT in any named category
    return !_kCats
        .where((c) => c.cats != null)
        .any((c) => c.cats!.contains(p.categoryHe));
  }
  return cat.cats!.contains(p.categoryHe);
}

// ── plain-language compliance labels ─────────────────────────────────────────
// Maps engine-level technical labels to user-facing Hebrew without jargon.
String _simpleLabel(String label) {
  if (label.startsWith('ברז ניתוק ×3')) return '3 ברזי ניתוק (כניסה + משאבה + מניפולד)';
  if (label.startsWith('ברז ניתוק')) return 'ברז ניתוק לתחזוקה';
  if (label.contains('אל-חזור')) return 'מניעת זרימה הפוכה';
  if (label.contains('מאזן / TRV')) return 'איזון לולאת המים החמים';
  if (label.contains('מפוח')) return 'פיזור בועות אוויר';
  if (label.contains('דיאלקטרי')) return 'מגן חלודה (מתכות שונות)';
  if (label.contains('PEX')) return 'פיצוי התפשטות לצינור PEX';
  if (label.contains('PRV') || label.contains('פורק לחץ')) return 'שסתום בטיחות לחץ';
  if (label.contains('Bladder') || label.contains('כלי התפשטות')) return 'מיכל פיצוי התפשטות מים';
  if (label.contains('מסנן')) return 'מסנן להגנת המשאבה';
  if (label.contains('גמיש')) return 'בולם רעידות המשאבה';
  if (label.contains('TMTV') || label.contains('anti-scald')) return 'מגן כוויות בכל ברז';
  if (label.contains('מאזן לכל ענף') || label.contains('Balancing')) return 'איזון לחץ בין ענפים';
  if (label.contains('Legionella') && label.contains('bypass')) return 'מניעת חיידק לגיונלה';
  if (label.contains('דיגום') || label.contains('sampling')) return 'נקודת בדיקת מים';
  if (label.contains('בידוד תרמי')) return 'בידוד חום על הצנרת';
  if (label.contains('חבקים')) return 'חבקים וקיבוע צנרת';
  if (label.contains('איטום')) return 'איטום חיבורים';
  return label;
}

String _simpleWhy(String why) {
  const map = {
    'בידוד אזורי לתחזוקה': 'מאפשר לסגור חלק אחד מהקו לתחזוקה',
    'מונע זרימה הפוכה בלולאה': 'מונע מים מלזרום לאחור',
    'איזון הלולאה': 'שהמים יזרמו אחיד בכל הלולאה',
    'פליטת אוויר בלולאה': 'מוציא בועות אוויר שגורמות לרעש ואי-נוחות',
    'הפרדה גלוונית בין מתכות': 'מונע חלודה כשמתכות שונות נוגעות זו בזו',
    'PEX מתרחב בחום': 'צינור PEX גדל בחום — נדרש מפצה למניעת עיוות',
    'מערכת חמה סגורה': 'ללא שסתום — לחץ החום עלול לפוצץ את הצנרת',
    'ממברנת EPDM מפרידה N₂ ממים — חובה בכל קו חם סגור':
        'בולם את ההתפשטות של המים החמים בתוך הצנרת',
    'מונע חלקיקים מלפגוע במשאבה': 'שומר על המשאבה מנקיונית ומאריך חייה',
    'מבודד רעידות המשאבה מהצנרת': 'מונע רעש ורטט בצנרת מהמשאבה',
    'מגביל T≤45°C ביציאה — anti-scald': 'מגביל חום ל-45°C למניעת כוויות',
    'מאזן לחץ בין ענפים במערכת מסחרית': 'שכל ברז יקבל לחץ שווה',
    'פסטור 70°C/3 דקות אחת לשבוע': 'הורג חיידק הלגיונלה בטמפרטורה גבוהה',
    'נדרש לבדיקות מים תקתיות': 'לבדיקות חובה על איכות המים',
    'הפסדי חום + סכנת כוויות': 'מונע קירור מהיר ומגן מפני כוויות מגע',
    'קיבוע ושיפוע': 'מחזיק הצנרת ומאפשר ניקוז תקין',
    'אטימות כל מעבר': 'חיבורים ללא איטום — דולפים',
  };
  return map[why] ?? why;
}

// One-line description of what a product does — for non-technical users in the picker.
String _productHint(LipskeyCatalogProduct p) {
  final cat = p.categoryHe;
  if (cat.contains('מחלק')) return 'מפצל לכמה ברזים במקביל';
  if (cat.contains('מקלחת') || cat.contains('דוש') || cat.contains('זרוע')) return 'לאמבטיה ומקלחת';
  if (cat.contains('כיור') || cat.contains('מטבח')) return 'ברז לכיור / מטבח';
  if (cat.contains('אסלה') || cat.contains('שירותים')) return 'לאסלה ושטיפה';
  if (cat.contains('ניקוז') || cat.contains('ביוב') || cat.contains('מאסף') || cat.contains('תעלה')) {
    return 'מוציא מים לניקוז';
  }
  if (cat.contains('מים חמים') || cat.contains('recirculation')) return 'לקו מים חמים';
  if (cat.contains('גן') || cat.contains('גינה') || cat.contains('השקי')) return 'לגינה והשקיה';
  if (cat.contains('משאבה') || cat.contains('pump')) return 'מגביר לחץ מים';
  if (cat.contains('מסנן') || cat.contains('פילטר')) return 'מסנן חלקיקים בצינור';
  if (cat.contains('שסתום') || cat.contains('PRV')) return 'שסתום בטיחות לחץ';
  if (cat.contains('צינור') || cat.contains('פוליאתילן') || cat.contains('נחושת')) return 'צינור חיבור';
  if (cat.contains('ברז') || cat.contains('ברזים')) return 'פותח/סוגר את המים';
  switch (flowRole(p)) {
    case FlowRole.connector:
      return 'מחבר בין שני חלקים';
    case FlowRole.fixture:
      return 'נקודת קצה של הקו';
    case FlowRole.accessory:
      return 'אביזר לקו';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
/// Action hooks the mounted [InstallStudioScreen] publishes so the floating
/// keyboard's own tools can drive it against the live chain/temp providers.
class InstallStudioHooks {
  const InstallStudioHooks({
    required this.createList,
    required this.addPart,
    required this.openProjects,
  });
  final VoidCallback createList;
  final VoidCallback addPart;
  final VoidCallback openProjects;
}

/// Set by [InstallStudioScreen] while mounted (a post-frame publish); read by
/// [kbInstallStudioNodes]. A plain hook registry so the keyboard tools reach the
/// studio's own dock buttons without the screen exposing its State. Null (no-op)
/// while the screen is not mounted.
final installStudioActionsProvider =
    StateProvider<InstallStudioHooks?>((_) => null);

/// The studio's OWN keyboard tools (live-mirror): the same actions as its
/// on-screen dock — build the shopping list, add a part, open saved projects —
/// plus a jump to the audit. So the floating keyboard MIRRORS this screen
/// instead of falling back to the catalog tools. Actions route through
/// [installStudioActionsProvider]; a null registry no-ops.
List<KbToolNode> kbInstallStudioNodes() => <KbToolNode>[
      KbToolNode.leaf(
        icon: Icons.bolt,
        label: 'רשימת קנייה',
        action: (ref, context) =>
            ref.read(installStudioActionsProvider)?.createList(),
      ),
      KbToolNode.leaf(
        icon: Icons.add,
        label: 'הוסף חלק',
        action: (ref, context) =>
            ref.read(installStudioActionsProvider)?.addPart(),
      ),
      KbToolNode.leaf(
        icon: Icons.folder_open_outlined,
        label: 'פרויקטים',
        action: (ref, context) =>
            ref.read(installStudioActionsProvider)?.openProjects(),
      ),
      KbToolNode.leaf(
        icon: Icons.science_outlined,
        label: 'אודיט',
        action: (ref, context) => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const AuditScreen())),
      ),
    ];

class InstallStudioScreen extends ConsumerStatefulWidget {
  const InstallStudioScreen({super.key});
  @override
  ConsumerState<InstallStudioScreen> createState() => _InstallStudioScreenState();
}

class _InstallStudioScreenState extends ConsumerState<InstallStudioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow;

  bool _loop = false;
  bool _showTutorial = false;
  final TextEditingController _describeCtrl = TextEditingController();

  /// This screen's own keyboard tools (live-mirror), built ONCE so the stable
  /// list identity keeps KbScreen from re-pushing on every rebuild.
  late final List<KbToolNode> _kbTools = kbInstallStudioNodes();

  @override
  void initState() {
    super.initState();
    _flow = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));
    // A11Y: only animate the blueprint grid when reducedMotion is off.
    if (!ref.read(catalogSettingsProvider).reducedMotion) {
      _flow.repeat();
    }
    _checkFirstVisit();
    // Publish this screen's dock actions so the floating keyboard's tools drive
    // it (list / add / projects) against the live chain/temp providers. Post-
    // frame (a provider write during the parent build is illegal); each hook is
    // mounted-guarded so a late tap after unmount is a no-op.
    if (kKbGlobal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(installStudioActionsProvider.notifier).state =
            InstallStudioHooks(
          createList: () {
            if (mounted) {
              _assemble(ref.read(chainProvider), ref.read(lineMaxTempProvider));
            }
          },
          addPart: () {
            if (mounted) _openPicker(ref.read(lineMaxTempProvider));
          },
          openProjects: () {
            if (mounted) _openProjects();
          },
        );
      });
    }
  }

  Future<void> _checkFirstVisit() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('installStudioSeen') ?? false) && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  void _dismissTutorial() {
    SharedPreferences.getInstance()
        .then((p) => p.setBool('installStudioSeen', true));
    setState(() => _showTutorial = false);
  }

  @override
  void dispose() {
    _flow.dispose();
    _describeCtrl.dispose();
    super.dispose();
  }

  // Free-text → products. Splits on comma/newline, matches each phrase to the
  // best catalog product by token overlap, and drops the matches onto the
  // canvas for review (user then taps "⚡ צור רשימת קנייה").
  LipskeyCatalogProduct? _bestProductMatch(String phrase, int temp) {
    final words = phrase
        .toLowerCase()
        .split(RegExp(r'[\s,]+'))
        .where((w) => w.length >= 2)
        .toList();
    if (words.isEmpty) return null;
    LipskeyCatalogProduct? best;
    var bestScore = 0;
    // chainUniverse = the imported company catalog when one is active, else
    // kCompatCatalog (same object) — so תכנון חיבור serves the company universe.
    for (final p in chainUniverse) {
      if (!productSuitableForTemp(p, temp)) continue;
      final name = p.nameHe.toLowerCase();
      final cat = p.categoryHe.toLowerCase();
      var score = 0;
      for (final w in words) {
        // A name hit is a stronger signal than a category hit; longer words
        // weigh more. Prevents "אסלה" matching the "…חיבורי אסלה" category
        // over an actual toilet whose name contains the word.
        if (name.contains(w)) {
          score += w.length * 2;
        } else if (cat.contains(w)) {
          score += w.length;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }
    return bestScore > 0 ? best : null;
  }

  void _buildFromText(String text, int temp) {
    final phrases = text
        .split(RegExp(r'[\n,]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (phrases.isEmpty) return;
    final matched = <LipskeyCatalogProduct>[];
    final misses = <String>[];
    for (final ph in phrases) {
      final m = _bestProductMatch(ph, temp);
      if (m == null) {
        misses.add(ph);
      } else if (!matched.any((x) => x.sku == m.sku)) {
        matched.add(m);
      }
    }
    if (matched.isNotEmpty) {
      final cur = ref.read(chainProvider);
      ref.read(chainProvider.notifier).state = [...cur, ...matched];
    }
    _describeCtrl.clear();
    FocusScope.of(context).unfocus();
    final msg = matched.isEmpty
        ? 'לא זוהו מוצרים — נסה מילה אחרת (למשל: "ברז קיסר", "אסלה", "מחסום")'
        : 'זוהו: ${matched.map((p) => p.nameHe).join("، ")}'
            '${misses.isEmpty ? "" : "\nלא זוהה: ${misses.join("، ")}"}'
            '\nבדוק את הקו ולחץ ⚡ צור רשימת קנייה';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chain = ref.watch(chainProvider);
    final temp = ref.watch(lineMaxTempProvider);
    final Widget body = Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _void0,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 1.3,
              colors: [_void1, _void0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedBuilder(
                  animation: _flow,
                  // Build the screen content ONCE and reuse it across frames —
                  // previously the whole Column (header/canvas/dock) rebuilt on
                  // every animation tick (60fps). RepaintBoundary isolates the
                  // blueprint repaint so it doesn't dirty the rest of the tree.
                  child: Column(children: [
                    _header(chain, temp),
                    Expanded(child: _canvas(chain, temp)),
                    _dock(chain, temp),
                  ]),
                  builder: (_, child) => RepaintBoundary(
                    child: CustomPaint(
                      painter: _BlueprintPainter(_flow.value),
                      child: child,
                    ),
                  ),
                ),
                if (_showTutorial)
                  Positioned.fill(
                    child: _TutorialOverlay(onDismiss: _dismissTutorial),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    // LIVE-MIRROR: under KB_GLOBAL this screen shows ITS OWN keyboard tools
    // (list / add / projects / audit), not the catalog fallback. Flag-off →
    // pass-through, byte-identical.
    return kKbGlobal ? KbScreen(tools: _kbTools, child: body) : body;
  }

  // ── header: title + live system legend ──────────────────────────────────────
  Widget _header(List<LipskeyCatalogProduct> chain, int temp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 6),
      child: Row(children: [
        if (Navigator.canPop(context))
          Semantics(
            button: true,
            label: 'חזור',
            child: Tooltip(
              message: 'חזור',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.maybePop(context),
                // ≥48dp tap target around the small arrow (a11y), without
                // enlarging the visible glyph.
                child: const Padding(
                  padding: EdgeInsetsDirectional.only(end: 8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(Icons.arrow_forward, color: _ink, size: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(colors: [_supply, _fixture]),
            boxShadow: [
              BoxShadow(color: _supply.withOpacity(0.5), blurRadius: 14),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.hub, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('תכנון חיבור',
                style: TextStyle(
                    color: _ink, fontSize: 18, fontWeight: FontWeight.w900)),
            Text('בחר מה לחבר · נכין רשימת קנייה',
                style: TextStyle(color: _mute, fontSize: 11, letterSpacing: 1)),
          ]),
        ),
        _tempPill(temp),
      ]),
    );
  }

  Widget _tempPill(int temp) {
    final Color borderColor;
    final String label;
    if (temp >= 80) {
      borderColor = BsTokens.danger; // red
      label = 'חם מאוד';
    } else if (temp >= 60) {
      borderColor = const Color(0xFFF97316); // orange
      label = 'חם';
    } else {
      borderColor = _supply; // blue/cyan
      label = 'קר';
    }
    return GestureDetector(
      onTap: () => _showTempPicker(context, temp),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(children: [
          Icon(Icons.thermostat, color: borderColor, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: borderColor, fontSize: 12, fontWeight: FontWeight.w800)),
          const SizedBox(width: 4),
          Text('$temp°C',
              style: const TextStyle(
                  color: _mute, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  void _showTempPicker(BuildContext context, int current) {
    final opts = [
      (20, '❄️ קר', 'ברז, כיור, שירותים, גינה', _supply),
      (60, '🔥 חם', 'דוד שמש, דוד חשמלי, מחמם מיידי', const Color(0xFFF97316)),
      (80, '🌡️ חם מאוד', 'מערכת ישנה או מסחרית, 80° ומעלה', BsTokens.danger),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      // This sheet holds a typed description (_describeCtrl) + a temp pick. It is
      // an INLINE sheet (not a StatefulWidget) built off parent state, so instead
      // of a fragile PopScope retrofit here we block the main accidental-loss
      // vector — the drag-dismiss. A deliberate scrim-tap still closes it.
      enableDrag: false,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: _void1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _supply, width: 2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('סוג הקו — מה טמפרטורת המים?',
                  style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('הטמפרטורה קובעת אילו פריטי בטיחות נדרשים',
                  style: TextStyle(color: _mute, fontSize: 12)),
              const SizedBox(height: 16),
              ...opts.map((opt) {
                final (val, emoji, desc, col) = opt;
                final selected = current == val;
                return GestureDetector(
                  onTap: () {
                    ref.read(lineMaxTempProvider.notifier).state = val;
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: selected ? col.withOpacity(0.16) : _panel,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: selected ? col : _mute.withOpacity(0.3),
                          width: selected ? 2 : 1),
                    ),
                    child: Row(children: [
                      Text(emoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emoji.substring(emoji.indexOf(' ') + 1),
                                style: TextStyle(
                                    color: selected ? col : _ink,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                            Text(desc,
                                style: const TextStyle(color: _mute, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (selected) Icon(Icons.check_circle, color: col, size: 20),
                    ]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── the flow canvas — nodes wired by animated pipes ─────────────────────────
  Widget _canvas(List<LipskeyCatalogProduct> chain, int temp) {
    if (chain.isEmpty) return _emptyState(temp);
    // s49b seam: authored trade reads config; plumbing = legacy verbatim (R1-2).
    final s49bCfg = _authoredConfigOf(ref);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      itemCount: chain.length,
      itemBuilder: (_, i) {
        final p = chain[i];
        final last = i == chain.length - 1;
        // s49b seam: authored trade resolves the joint via the s41
        // connectionMethodLabel(trade:) delegation (non-empty label = mates);
        // plumbing = legacy verbatim (R1-2) — its call stays positional-only.
        final bool connectsToNext;
        if (s49bCfg != null) {
          connectsToNext = last ||
              connectionMethodLabel(p, chain[i + 1],
                      trade: s49bCfg.tradeResolution)
                  .isNotEmpty;
        } else {
          connectsToNext =
              last ? true : canConnect(p, chain[i + 1]);
        }
        return _NodeRow(
          product: p,
          index: i,
          isLast: last,
          flow: _flow.value,
          systemColorOverride:
              s49bCfg == null ? null : _systemColor(p, s49bCfg),
          nextColor: last ? null : _systemColor(chain[i + 1], s49bCfg),
          connectsToNext: connectsToNext,
          onRemove: () {
            final c = [...chain]..removeAt(i);
            ref.read(chainProvider.notifier).state = c;
          },
        );
      },
    );
  }

  Widget _emptyState(int temp) {
    // Quick-start scenarios — each maps to a _kCats index.
    const scenarios = [
      ('🚰', 'ברז / כיור', 0),
      ('🚿', 'מקלחת / אמבטיה', 1),
      ('🪠', 'שירותים', 2),
      ('🔥', 'מים חמים', 3),
      ('🌿', 'גינה', 4),
      ('🔀', 'מחלק — כמה ברזים', 5),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _supply.withOpacity(0.3), width: 2),
            boxShadow: [BoxShadow(color: _supply.withOpacity(0.15), blurRadius: 40)],
          ),
          alignment: Alignment.center,
          child: Icon(Icons.plumbing, color: _supply.withOpacity(0.8), size: 36),
        ),
        const SizedBox(height: 16),
        const Text('מה אתה רוצה לחבר?',
            style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
          'בחר מה אתה מתקין:',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mute, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        // 2×2 scenario grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.3,
          ),
          itemCount: scenarios.length,
          itemBuilder: (_, i) {
            final (emoji, label, catIdx) = scenarios[i];
            return GestureDetector(
              onTap: () => _openPicker(temp, initialCat: _kCats[catIdx]),
              child: Container(
                decoration: BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _supply.withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: _supply.withOpacity(0.07), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: _ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text('— או כתוב במילים —',
            style: TextStyle(color: _mute, fontSize: 11)),
        const SizedBox(height: 12),
        // Free-text "describe your line" box — secondary path.
        Container(
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _supply.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.fromLTRB(12, 2, 6, 2),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _describeCtrl,
                style: const TextStyle(color: _ink, fontSize: 13),
                textDirection: TextDirection.rtl,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                onSubmitted: (v) => _buildFromText(v, temp),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                  hintText: 'למשל: ברז קיסר למטבח, צינור, אסלה',
                  hintStyle: TextStyle(color: _mute, fontSize: 12),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _buildFromText(_describeCtrl.text, temp),
              child: Container(
                margin: const EdgeInsets.all(5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _supply,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('בנה',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── bottom dock: progressive 3-state layout ──────────────────────────────────
  Widget _dock(List<LipskeyCatalogProduct> chain, int temp) {
    return Container(
      decoration: const BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Color(0x1F000000), blurRadius: 24)],
      ),
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (chain.isEmpty) ...[
          // State A: empty chain — prominent first-product CTA
          SizedBox(
            width: double.infinity,
            child: _glowButton(
              icon: Icons.add,
              label: '➕ הוסף מוצר ראשון',
              enabled: true,
              onTap: () => _openPicker(temp),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _hintChip('🔵 הזנה', _supply),
              _hintChip('🟣 ברז / קבועה', _fixture),
              _hintChip('🟡 ניקוז', _drain),
            ],
          ),
        ] else if (chain.length == 1) ...[
          // State B: single item — nudge to add a second product
          SizedBox(
            width: double.infinity,
            child: _glowButton(
              icon: Icons.add,
              label: '➕ הוסף עוד מוצר',
              enabled: true,
              onTap: () => _openPicker(temp),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'חיבור צינור צריך 2 נקודות — כניסה + יציאה.\nהוסף את הנקודה השנייה (ברז, אסלה, דוד…)',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mute, fontSize: 12, height: 1.4),
          ),
        ] else ...[
          // State C: 2+ items — full controls
          Row(children: [
            Expanded(
              child: _ghostButton(
                icon: Icons.add,
                label: '➕ הוסף',
                onTap: () => _openPicker(temp),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _glowButton(
                icon: Icons.bolt,
                label: '⚡ צור רשימת קנייה',
                enabled: true,
                onTap: () => _assemble(chain, temp),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: _ghostButton(
                icon: Icons.save_outlined,
                label: '💾 שמור פרויקט',
                onTap: () => _saveProject(chain, temp),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ghostButton(
                icon: Icons.folder_open_outlined,
                label: '📂 פרויקטים',
                onTap: _openProjects,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ghostButton(
                icon: Icons.science_outlined,
                label: '🧪 אודיט',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const AuditScreen())),
              ),
            ),
          ]),
          if (temp > 20) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _loop = !_loop),
                // ≥48dp tap target around the small chip (a11y), without
                // enlarging the visible chip.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _loop ? _fixture.withOpacity(0.2) : _void1,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _loop ? _fixture : _mute.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.loop,
                            color: _loop ? _fixture : _mute, size: 14),
                        const SizedBox(width: 4),
                        Text('מחזור מים חמים',
                            style: TextStyle(
                                color: _loop ? _fixture : _mute,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('מים חמים מיד, בלי להמתין שיתחממו',
                  style: TextStyle(color: _mute, fontSize: 10)),
            ),
          ],
          const SizedBox(height: 8),
          Row(children: [
            _legendDot(_supply, 'אספקה'),
            _legendDot(_drain, 'ניקוז'),
            _legendDot(_fixture, 'קבועה'),
          ]),
        ],
      ]),
    );
  }

  Widget _hintChip(String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700)),
      );

  Widget _legendDot(Color c, String label) => Padding(
        padding: const EdgeInsetsDirectional.only(end: 14),
        child: Row(children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: c,
              boxShadow: [BoxShadow(color: c.withOpacity(0.7), blurRadius: 7)],
            ),
          ),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: _mute, fontSize: 10)),
        ]),
      );

  Widget _ghostButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _void1,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _mute.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: _ink, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: _ink, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _glowButton(
      {required IconData icon,
      required String label,
      required bool enabled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_accent, Color(0xFFE85F00)]),
            borderRadius: BorderRadius.circular(15),
            boxShadow: enabled
                ? [BoxShadow(color: _accent.withOpacity(0.45), blurRadius: 18)]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
      ),
    );
  }

  // ── actions ──────────────────────────────────────────────────────────────────
  /// Auto-fix descriptions from the most recent assembly (e.g. "swapped 1/2"
  /// bushing for 3/4""). Passed to [_BomSheet] so the user sees what the
  /// engine corrected on their behalf, without being asked.
  List<String> _autoFixes = const [];

  void _assemble(List<LipskeyCatalogProduct> chain, int temp) {
    // Auto-tick the tool-grade accessory checklist items the line requires:
    // every line needs clips + sealant; hot lines also need thermal insulation.
    // Without this the compliance checklist would always show those items
    // as un-ticked, even though they're standard installation practice.
    final acc = {...ref.read(lineAccessoriesProvider)};
    acc..add('HW-CLIP')..add('HW-SEALANT');
    if (temp >= 60) acc.add('HW-INSUL');
    ref.read(lineAccessoriesProvider.notifier).state = acc;

    // ── AUTO-FIX flow problems BEFORE building the plan ──────────────────
    // The engine fixes obvious bottlenecks (swap the narrow part for a wider
    // sibling) and adds a booster pump when ΔP exceeds 1 bar. The user sees
    // the corrected chain, not a list of "you should…" warnings.
    final fixed = autoFlowFix(chain,
        pipeLengthMeters: 5.0, flowRateLPS: 0.3, verticalRiseMeters: 0.0);
    final fixedChain = fixed.chain;
    _autoFixes = fixed.changes;

    final mi = fixedChain.indexWhere((p) => manifoldOutlets(p) > 0);
    final isTree = mi >= 0 && mi < fixedChain.length - 1;
    final InstallationPlan plan;
    int branches = 0, outlets = 0;
    if (isTree) {
      final trunk = fixedChain.sublist(0, mi + 1);
      final branchTargets = fixedChain.sublist(mi + 1);
      // Count only REAL branch targets (a target equal to the manifold itself
      // isn't a branch) — matches the engine's routing so the banner is accurate.
      branches = branchTargets.where((t) => t.sku != fixedChain[mi].sku).length;
      outlets = manifoldOutlets(fixedChain[mi]);
      plan = buildTreeInstallation(trunk, branchTargets,
          tempC: temp, accessories: acc, autoCompliance: true, loop: _loop);
    } else {
      plan = buildInstallation([...fixedChain],
          tempC: temp, accessories: acc, loop: _loop, autoCompliance: true);
    }
    final criticalCount = plan.criticalOpen(temp, acc);
    if (criticalCount > 0) {
      _showCriticalWarning(plan, fixedChain, branches, outlets, temp, acc, criticalCount);
    } else {
      _showBomSheet(plan, fixedChain, branches, outlets);
    }
  }

  void _showBomSheet(InstallationPlan plan, List<LipskeyCatalogProduct> chain,
      int branches, int outlets) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BomSheet(
        plan: plan,
        anchorSkus: {for (final a in chain) a.sku},
        branches: branches,
        outlets: outlets,
        autoFixes: _autoFixes,
      ),
    );
  }

  void _showCriticalWarning(
      InstallationPlan plan,
      List<LipskeyCatalogProduct> chain,
      int branches,
      int outlets,
      int temp,
      Set<String> acc,
      int criticalCount) {
    final critItems = plan
        .compliance(temp, acc)
        .where((c) => !c.satisfied && c.severity == CheckSeverity.critical)
        .toList();
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _void1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(children: [
            const Icon(Icons.warning_amber_rounded,
                color: BsTokens.danger, size: 22),
            const SizedBox(width: 8),
            Text('$criticalCount בעיות בטיחות בקו',
                style: const TextStyle(
                    color: BsTokens.danger,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
          ]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('הפריטים הבאים חסרים וחשובים לבטיחות:',
                  style: TextStyle(color: _mute, fontSize: 13)),
              const SizedBox(height: 12),
              ...critItems.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔴', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_simpleLabel(c.label),
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              Text(_simpleWhy(c.why),
                                  style: const TextStyle(
                                      color: _mute,
                                      fontSize: 11,
                                      height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('חזור לתכנון',
                  style: TextStyle(color: _mute, fontSize: 13)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: BsTokens.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                Navigator.pop(ctx);
                _showBomSheet(plan, chain, branches, outlets);
              },
              child: const Text('הצג רשימה בכל זאת',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  /// Persist the current chain (+ temperature + accessories) as a named
  /// project the user can reopen later. Shows a name prompt then writes via
  /// the [savedProjectsProvider] notifier.
  Future<void> _saveProject(
      List<LipskeyCatalogProduct> chain, int temp) async {
    if (chain.isEmpty) return;
    final ctrl = TextEditingController(
        text: '${chain.first.nameHe} → ${chain.last.nameHe}'.substring(
            0, ('${chain.first.nameHe} → ${chain.last.nameHe}').length.clamp(0, 40)));
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _void1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('שמור פרויקט',
              style: TextStyle(
                  color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: _ink),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'שם הפרויקט (למשל: מטבח דירת 12)',
              hintStyle: const TextStyle(color: _mute),
              filled: true,
              fillColor: _panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ביטול', style: TextStyle(color: _mute)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('שמור',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (name == null || name.isEmpty) return;
    await ref.read(savedProjectsProvider.notifier).save(
          name: name,
          anchorSkus: chain.map((p) => p.sku).toList(),
          tempC: temp,
          accessories: ref.read(lineAccessoriesProvider),
        );
    if (mounted) showToast(context, '💾 הפרויקט "$name" נשמר');
  }

  /// Show the list of saved projects, with load / rename / delete actions.
  void _openProjects() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer(builder: (ctx, ref, _) {
          final projects = ref.watch(savedProjectsProvider);
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, sc) => Container(
              decoration: const BoxDecoration(
                color: _void1,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: _accent, width: 2)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                        color: _mute,
                        borderRadius: BorderRadius.circular(2)),
                  ),
                  const _SheetClose(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(children: [
                      Icon(Icons.folder_open, color: _accent, size: 22),
                      SizedBox(width: 10),
                      Text('הפרויקטים שלי',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                    ]),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  Expanded(
                    child: projects.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                  'אין עדיין פרויקטים שמורים.\nבנה קו ולחץ "💾 שמור פרויקט".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: _mute, fontSize: 13)),
                            ),
                          )
                        : ListView.separated(
                            controller: sc,
                            itemCount: projects.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1,
                                color: Color(0xFFEEEEEE),
                                indent: 16,
                                endIndent: 16),
                            itemBuilder: (_, i) {
                              final p = projects[i];
                              return ListTile(
                                title: Text(p.name,
                                    style: const TextStyle(
                                        color: _ink,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text(
                                  '${p.anchorSkus.length} פריטים · '
                                  '${p.tempC}°C · '
                                  '${_formatDate(p.savedAt)}',
                                  style: const TextStyle(
                                      color: _mute, fontSize: 11),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert,
                                      color: _mute),
                                  color: _panel,
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'rename',
                                        child: Text('שנה שם',
                                            style: TextStyle(color: _ink))),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('מחק',
                                            style: TextStyle(
                                                color: BsTokens.danger))),
                                  ],
                                  onSelected: (v) async {
                                    if (v == 'delete') {
                                      final ok = await confirmDestructive(
                                        ctx,
                                        title: 'מחיקת פרויקט?',
                                        message:
                                            'הפרויקט "${p.name}" יימחק לצמיתות.',
                                        confirmLabel: 'מחק',
                                      );
                                      if (!ok || !ctx.mounted) return;
                                      await ref
                                          .read(savedProjectsProvider.notifier)
                                          .remove(p.id);
                                    } else if (v == 'rename') {
                                      Navigator.pop(ctx);
                                      WidgetsBinding.instance.addPostFrameCallback(
                                          (_) => _renameProject(p));
                                    }
                                  },
                                ),
                                onTap: () {
                                  // Close the saved-list sheet FIRST, then load +
                                  // auto-build (so the BOM sheet isn't popped).
                                  Navigator.pop(ctx);
                                  _loadProject(p);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  void _loadProject(SavedProject p) {
    final found = <LipskeyCatalogProduct>[];
    for (final sku in p.anchorSkus) {
      // Resolve against the UNIFIED chainUniverse (Lipskey + hot-water) — the
      // same superset the anchor pickers add from. Resolving against
      // kLipskeyCatalog alone silently DROPPED saved hot-water (HW-*) anchors,
      // which the auto-BOM `found.length >= 2` gate then turned into a no-BOM.
      final hits = chainUniverse.where((q) => q.sku == sku);
      if (hits.isNotEmpty) found.add(hits.first);
    }
    if (found.isEmpty) {
      showToast(context, '⚠️ הפרויקט ריק או שמוצריו לא נמצאים בקטלוג');
      return;
    }
    ref.read(chainProvider.notifier).state = found;
    ref.read(lineMaxTempProvider.notifier).state = p.tempC;
    ref.read(lineAccessoriesProvider.notifier).state = p.accessories;
    showToast(context, '📂 נפתח: ${p.name}');
    // #autobom — one-tap auto-BOM: a saved job carries its anchors + temp +
    // accessories, so immediately build the full bill of materials and open it
    // (reusing the exact _assemble path), instead of requiring a separate manual
    // "assemble" tap. Needs ≥2 anchors to form a real line; a single-anchor job
    // just stays on the canvas.
    if (found.length >= 2) {
      _assemble(found, p.tempC);
    }
  }

  void _renameProject(SavedProject p) async {
    final ctrl = TextEditingController(text: p.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _void1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('שנה שם לפרויקט',
              style: TextStyle(
                  color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: _ink),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              filled: true,
              fillColor: _panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ביטול',
                    style: TextStyle(color: _mute))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('שמור',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (!mounted) return;
    if (name != null && name.isNotEmpty) {
      await ref.read(savedProjectsProvider.notifier).rename(p.id, name);
    }
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    // Future timestamp (device clock rolled back after the save) or <1 min →
    // "עכשיו", never "לפני -3 דקות". Singular Hebrew forms for 1 (דקה/שעה/אתמול).
    if (diff.isNegative || diff.inMinutes < 1) return 'עכשיו';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return m == 1 ? 'לפני דקה' : 'לפני $m דקות';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return h == 1 ? 'לפני שעה' : 'לפני $h שעות';
    }
    if (diff.inDays < 7) {
      final n = diff.inDays;
      return n == 1 ? 'אתמול' : 'לפני $n ימים';
    }
    return '${d.day}/${d.month}/${d.year}';
  }

  void _openPicker(int temp, {_PickerCategory? initialCat}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductPicker(lineTemp: temp, initialCat: initialCat),
    );
  }
}

// ── one node + the pipe to the next ────────────────────────────────────────────
class _NodeRow extends StatelessWidget {
  const _NodeRow({
    required this.product,
    required this.index,
    required this.isLast,
    required this.flow,
    required this.nextColor,
    required this.connectsToNext,
    required this.onRemove,
    this.systemColorOverride,
  });
  final LipskeyCatalogProduct product;
  final int index;
  final bool isLast;
  final double flow;
  final Color? nextColor;
  final bool connectsToNext; // false → broken joint (red)
  final VoidCallback onRemove;

  /// s49b seam: the authored trade's SystemDef color for THIS node; null
  /// (always, under plumbing — R1-2) keeps the legacy inference verbatim.
  final Color? systemColorOverride;

  @override
  Widget build(BuildContext context) {
    final c = systemColorOverride ?? _systemColor(product);
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.withOpacity(0.55), width: 1.5),
          boxShadow: [BoxShadow(color: c.withOpacity(0.18), blurRadius: 20)],
        ),
        child: Row(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c,
                  boxShadow: [BoxShadow(color: c.withOpacity(0.7), blurRadius: 5)],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.withOpacity(0.16),
              border: Border.all(color: c, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text('${index + 1}',
                style: TextStyle(
                    color: c, fontSize: 17, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(product.nameHe,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(_productHint(product),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _mute, fontSize: 11)),
            ]),
          ),
          Semantics(
            button: true,
            label: 'הסר מוצר',
            child: Tooltip(
              message: 'הסר מוצר',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onRemove,
                // ≥48dp tap target around the small ✕ (a11y), without
                // enlarging the visible glyph.
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Icon(Icons.close, color: _mute, size: 18),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
      if (!isLast)
        _PipeLink(
            from: c,
            to: nextColor ?? c,
            flow: flow,
            broken: !connectsToNext),
    ]);
  }
}

// animated energy pipe between two nodes, with a join-method / status label
class _PipeLink extends StatelessWidget {
  const _PipeLink(
      {required this.from,
      required this.to,
      required this.flow,
      required this.broken});
  final Color from;
  final Color to;
  final double flow;
  final bool broken;
  @override
  Widget build(BuildContext context) {
    final c = broken ? BsTokens.danger : _accent;
    return SizedBox(
      height: 30,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 4, height: 30,
          child: CustomPaint(
            painter: _PipePainter(broken ? c : from, broken ? c : to, flow),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: c.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8)),
          child: Text(
              broken ? '⚠ אין חיבור' : '✓ מחובר',
              style: TextStyle(
                  color: c, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class _PipePainter extends CustomPainter {
  _PipePainter(this.from, this.to, this.flow);
  final Color from, to;
  final double flow;
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final track = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), track);
    // flowing pulse travelling down the pipe
    final t = (flow * 1.0) % 1.0;
    final y = t * size.height;
    final glow = Paint()
      ..shader = LinearGradient(colors: [from, to])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
        Offset(x, math.max(0, y - 8)), Offset(x, math.min(size.height, y + 8)),
        glow);
  }

  @override
  bool shouldRepaint(_PipePainter old) => old.flow != flow;
}

// faint blueprint grid + drifting scanline
class _BlueprintPainter extends CustomPainter {
  _BlueprintPainter(this.t);
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _grid
      ..strokeWidth = 1;
    const step = 34.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // drifting horizontal scan glow
    final sy = (t * size.height) % size.height;
    final scan = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, _supply.withOpacity(0.05), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, sy - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, sy - 60, size.width, 120), scan);
  }

  @override
  bool shouldRepaint(_BlueprintPainter old) => old.t != t;
}

// ── bill-of-materials sheet (dark) ─────────────────────────────────────────────
class _BomSheet extends ConsumerStatefulWidget {
  const _BomSheet(
      {required this.plan,
      required this.anchorSkus,
      this.branches = 0,
      this.outlets = 0,
      this.autoFixes = const []});
  final InstallationPlan plan;
  final Set<String> anchorSkus;
  final int branches; // >0 when this is a branched (manifold) installation
  final int outlets; // manifold outlet count, for over-capacity warning
  /// Human-readable list of fixes the engine applied automatically before
  /// building this plan (e.g. "swapped 1/2" bushing for 3/4""). Shown in the
  /// header banner so the user understands what the system did for them.
  final List<String> autoFixes;

  @override
  ConsumerState<_BomSheet> createState() => _BomSheetState();
}

class _BomSheetState extends ConsumerState<_BomSheet> {
  // Per-pipe length in metres (pipes are sold by length, not by piece).
  final Map<String, double> _meters = {};
  // User-defined display names for zone headers (e.g. "ענף א" → "מטבח").
  final Map<String, String> _zoneAliases = {};
  // Vertical rise from inlet to outlet (m). Used by the pressure-drop math
  // to account for static head ρgh — every metre of climb costs ≈ 0.1 bar.
  double _verticalRise = 0.0;
  // Drainage geometry (P3.9): horizontal run + vertical drop feed
  // checkDrainageSlope — ת"י 1205 wants ≥ 2% fall so waste doesn't pool.
  // Defaults 3 m run / 0.06 m drop = exactly 2% (the minimum).
  double _drainRun = 3.0;
  double _drainDrop = 0.06;

  String _zoneDisplayLabel(String key) => _zoneAliases[key] ?? key;

  void _renameZone(String key) {
    final ctrl = TextEditingController(text: _zoneDisplayLabel(key));
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: _void1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('שנה שם לאזור',
              style: TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: const TextStyle(color: _ink),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'למשל: מטבח, שירותים, גינה…',
              hintStyle: const TextStyle(color: _mute),
              filled: true,
              fillColor: _panel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ביטול', style: TextStyle(color: _mute)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                final name = ctrl.text.trim();
                if (name.isNotEmpty) setState(() => _zoneAliases[key] = name);
                Navigator.pop(ctx);
              },
              child: const Text('שמור', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    ).whenComplete(() => ctrl.dispose());
  }
  double _metersOf(String sku) => _meters[sku] ?? 2.0;

  double get _totalMeters => widget.plan.items
      .where(isPipe)
      .fold(0.0, (s, p) => s + _metersOf(p.sku));

  /// Render a flow-suggestion as an actionable card — problem + fix + a
  /// one-tap "החלף"/"הוסף" button that mutates [chainProvider] in place.
  Widget _suggestionCard(FlowSuggestion s) {
    final isSwap =
        s.actionKind == SuggestionKind.swap && s.replaceProduct != null;
    final isAdd =
        s.actionKind == SuggestionKind.add && s.addProductSku != null;
    final accentColor = isSwap
        ? const Color(0xFFFB923C)
        : isAdd
            ? const Color(0xFF15803D)
            : const Color(0xFFB45309);
    final icon = isSwap
        ? Icons.swap_horiz
        : isAdd
            ? Icons.add_circle
            : Icons.lightbulb_outline;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: accentColor, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(s.problem,
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 20),
            Expanded(
              child: Text('→ ${s.solution}',
                  style: const TextStyle(
                      color: _ink, fontSize: 11, height: 1.35)),
            ),
            if (isSwap || isAdd) ...[
              const SizedBox(width: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _applySuggestion(s),
                // ≥48dp tap target around the small button (a11y).
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(isSwap ? 'החלף' : 'הוסף',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  void _applySuggestion(FlowSuggestion s) {
    final chain = [...ref.read(chainProvider)];
    if (s.actionKind == SuggestionKind.swap && s.replaceProduct != null) {
      final wider = widerSiblingOf(s.replaceProduct!);
      if (wider == null) {
        showToast(context, 'לא נמצא מוצר רחב יותר במאגר');
        return;
      }
      final i =
          chain.indexWhere((p) => p.sku == s.replaceProduct!.sku);
      if (i < 0) {
        showToast(context,
            'הצוואר-בקבוק נוסף אוטומטית — לחץ "צור רשימת קנייה" לבנייה מחדש');
        return;
      }
      chain[i] = wider;
      ref.read(chainProvider.notifier).state = chain;
      Navigator.pop(context);
      showToast(
          context, '✅ "${wider.nameHe}" הוחלף — לחץ "צור רשימת קנייה" לבנייה מחדש');
    } else if (s.actionKind == SuggestionKind.add &&
        s.addProductSku != null) {
      // UNIFIED catalog (incl. hot-water) — a recommended HW-* accessory was
      // falsely reported "not in the catalog" when resolved against Lipskey only.
      final hits = chainUniverse.where((p) => p.sku == s.addProductSku);
      if (hits.isEmpty) {
        showToast(context, 'המוצר המומלץ אינו זמין במאגר');
        return;
      }
      chain.add(hits.first);
      ref.read(chainProvider.notifier).state = chain;
      Navigator.pop(context);
      showToast(context, '✅ "${hits.first.nameHe}" נוסף לקו');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final anchorSkus = widget.anchorSkus;
    final branches = widget.branches;
    final outlets = widget.outlets;
    // Supply lines get the pressure-drop check (static head); drainage lines get
    // the ת"י-1205 slope check instead — different physics per system (P3.9).
    final isSupply = lineIsSupply(plan.items);
    final ok = plan.isComplete;
    final overCapacity = branches > 0 && outlets > 0 && branches > outlets;
    // s49b seam: authored trade reads config — its checklist IS its authored
    // CompletionRule violations via the s41 trade: delegation; plumbing =
    // legacy verbatim (R1-2) — the else call stays positional-only.
    final s49bCfg = _authoredConfigOf(ref);
    final checklist = s49bCfg != null
        ? lineComplianceChecklist(
            plan.items,
            ref.read(lineMaxTempProvider),
            ref.read(lineAccessoriesProvider),
            trade: s49bCfg.tradeResolution,
          )
        : lineComplianceChecklist(
            plan.items,
            ref.read(lineMaxTempProvider),
            ref.read(lineAccessoriesProvider));
    final checkPassed = checklist.where((c) => c.satisfied).length;
    final checkCritical = checklist.where((c) => !c.satisfied && c.severity == CheckSeverity.critical).length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.4,
        maxChildSize: 0.96,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _void1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _accent, width: 2)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 42, height: 4,
              decoration: BoxDecoration(
                  color: _mute, borderRadius: BorderRadius.circular(2)),
            ),
            const _SheetClose(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(children: [
                Icon(ok ? Icons.verified : Icons.warning_amber_rounded,
                    color: ok ? _ok : _drain, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ok ? 'התקנה שלמה' : 'חסרים ${plan.gaps.length} חיבורים',
                          style: TextStyle(
                              color: ok ? _ink : _drain,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      Text(
                          '${plan.items.length} סוגים · ${plan.totalPieces} יחידות'
                          '${_totalMeters > 0 ? ' · ${_totalMeters.toStringAsFixed(1)} מ׳ צנרת' : ''}'
                          '${branches > 0 ? ' · ⑂ $branches ענפים' : ''}'
                          '${plan.zones.isNotEmpty ? ' · ${plan.zones.length} אזורים' : ''}',
                          style: const TextStyle(color: _mute, fontSize: 12)),
                      if (checklist.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: checkCritical == 0
                                    ? _accent.withOpacity(0.18)
                                    : BsTokens.danger.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$checkPassed/${checklist.length} ✓',
                                style: TextStyle(
                                  color: checkCritical == 0 ? _ok : BsTokens.danger,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (checkCritical > 0) ...[
                              const SizedBox(width: 6),
                              Text('$checkCritical קריטי פתוח',
                                  style: const TextStyle(
                                      color: BsTokens.danger,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ]),
                        ),
                      if (overCapacity)
                        Text(
                            '⚠️ $branches ענפים על מחלק $outlets-יציאות — '
                            '${branches - outlets} לא חוברו (חסר במחלק)',
                            style: const TextStyle(
                                color: _drain,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            Expanded(
              child: ListView(controller: ctrl, children: [
                // ── Auto-fix banner — tells the user what was changed ──
                if (widget.autoFixes.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF15803D).withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.auto_fix_high,
                              color: Color(0xFF15803D), size: 16),
                          SizedBox(width: 6),
                          Text('המערכת תיקנה אוטומטית:',
                              style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 4),
                        for (final c in widget.autoFixes)
                          Padding(
                            padding:
                                const EdgeInsetsDirectional.only(top: 2, start: 22),
                            child: Text(c,
                                style: const TextStyle(
                                    color: _ink, fontSize: 11, height: 1.4)),
                          ),
                      ],
                    ),
                  ),
                // ── Chain diagram — visual flow of the installation ───────
                if (plan.items.length >= 2) ...[
                  const SizedBox(height: 8),
                  Builder(builder: (_) {
                    // Show the FLOW LINE, fully materialized: explicit pipe
                    // segments are inserted at every compression joint so each
                    // link is a real direct connection (thread / press /
                    // pipe-into-fitting). Bolt-on safety stays in the checklist
                    // below — it's not part of the linear flow.
                    final temp = ref.read(lineMaxTempProvider);
                    final anchorList = plan.items
                        .where((p) => anchorSkus.contains(p.sku))
                        .toList();
                    final chain = (branches == 0 && anchorList.length >= 2)
                        ? materializeChain(
                            buildInstallation(anchorList, tempC: temp).items)
                        : materializeChain(plan.items);
                    final pd = estimatePressureDrop(
                      chain,
                      pipeLengthMeters:
                          _totalMeters > 0 ? _totalMeters : 5.0,
                      flowRateLPS: 0.3,
                      verticalRiseMeters: _verticalRise,
                    );
                    return ChainDiagram(
                      chain: chain,
                      bottleneckSku: pd.dropBar > 1.0
                          ? pd.bottleneck?.sku
                          : null,
                    );
                  }),
                  const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 16,
                      endIndent: 16),
                ],
                // ── Alternative paths — shown only for simple A→B chains ──
                Builder(builder: (_) {
                  if (anchorSkus.length != 2 || branches > 0) {
                    return const SizedBox.shrink();
                  }
                  // Reconstruct the two endpoints from anchors.
                  final anchors = plan.items
                      .where((p) => anchorSkus.contains(p.sku))
                      .toList();
                  if (anchors.length != 2) return const SizedBox.shrink();
                  final alts = findAlternativePaths(anchors[0], anchors[1],
                      k: 3, maxDepth: 8,
                      tempC: ref.read(lineMaxTempProvider));
                  if (alts.length < 2) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.alt_route,
                              color: _accent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'מסלולים חלופיים: ${alts.length} אפשרויות',
                            style: const TextStyle(
                                color: _accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        for (var ai = 0; ai < alts.length; ai++) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'אפשרות ${ai + 1}: ${alts[ai].length} חלקים',
                              style: const TextStyle(
                                  color: _ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          for (final p in alts[ai].skip(1).take(alts[ai].length - 2))
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 2, 0, 0),
                              child: Text(
                                '· ${p.nameHe}',
                                style: const TextStyle(
                                    color: _mute,
                                    fontSize: 11,
                                    height: 1.3),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                }),
                // Auto-compliance banner — shown when safety items were auto-inserted
                Builder(builder: (_) {
                  final autoAdded = plan.items
                      .where((p) => !anchorSkus.contains(p.sku))
                      .length;
                  if (autoAdded == 0) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _accent.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Text('✅', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'הוספנו $autoAdded פריטי בטיחות חובה — הם כבר ברשימה',
                          style: const TextStyle(
                              color: _accent, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ]),
                  );
                }),
                // ── Price estimate (ballpark budget) ───────────────────
                Builder(builder: (_) {
                  // Expand by quantity for a unit-count total
                  final expanded = <LipskeyCatalogProduct>[];
                  for (final p in plan.items) {
                    final q = plan.qtyOf(p.sku);
                    for (var i = 0; i < q; i++) expanded.add(p);
                  }
                  final pr = estimatePrice(expanded);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _supply.withOpacity(0.35)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.attach_money,
                          color: _supply, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'הערכת תקציב: ~₪${pr.totalILS}',
                          style: const TextStyle(
                              color: _supply,
                              fontSize: 13,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Text(
                        pr.lowConfidence
                            ? 'דיוק נמוך'
                            : '${pr.itemCount} יחידות',
                        style: TextStyle(
                            color: pr.lowConfidence
                                ? const Color(0xFFB45309)
                                : _mute,
                            fontSize: 10,
                            fontFamily: 'monospace'),
                      ),
                    ]),
                  );
                }),
                // ── Vertical-rise input — supply lines only (feeds the
                //    pressure-drop math; drainage uses the slope block below) ─
                if (isSupply)
                  Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(children: [
                    const Icon(Icons.arrow_upward, color: _mute, size: 14),
                    const SizedBox(width: 6),
                    const Text('עלייה אנכית:',
                        style: TextStyle(color: _mute, fontSize: 11)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: _supply,
                          inactiveTrackColor: _supply.withOpacity(0.25),
                          thumbColor: _supply,
                          overlayColor: _supply.withOpacity(0.1),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: _verticalRise.clamp(0, 30),
                          min: 0,
                          max: 30,
                          divisions: 30,
                          onChanged: (v) =>
                              setState(() => _verticalRise = v),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        '${_verticalRise.toStringAsFixed(0)} מ׳',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            color: _ink,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ),
                // ── Temperature suitability (heat-rating guard) ─────────
                // The engine already routes AROUND temp-unsuitable materials,
                // but a user-picked anchor (e.g. an HDPE fitting, capped ~40°C)
                // can still sit on a hot line. Flag it so they swap to a
                // heat-resistant material instead of shipping a line that melts.
                Builder(builder: (_) {
                  // s49b seam: authored trade reads the spec envelope's
                  // maxTempC; plumbing = legacy verbatim below (R1-2).
                  final s49bTempCfg = s49bCfg;
                  if (s49bTempCfg != null) {
                    final temp = ref.read(lineMaxTempProvider);
                    final unfit = plan.items.where((p) {
                      final maxT = s49bTempCfg.maxTempCOf(p.sku);
                      return maxT != null && temp > maxT;
                    }).toList();
                    if (unfit.isEmpty) return const SizedBox.shrink();
                    return _authoredTempUnfitBanner(temp, unfit, s49bTempCfg);
                  }
                  final temp = ref.read(lineMaxTempProvider);
                  final unfit = plan.items
                      .where((p) => !productSuitableForTemp(p, temp))
                      .toList();
                  if (unfit.isEmpty) return const SizedBox.shrink();
                  const warn = BsTokens.danger;
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: warn.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.local_fire_department,
                              color: warn, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'קו חם ($temp°C): ${unfit.length} מוצרים אינם עומדים בחום',
                              style: const TextStyle(
                                  color: warn,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        for (final p in unfit.take(6))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• ${p.nameHe} — עד ${productMaxTempC(p)?.toStringAsFixed(0) ?? "?"}°C',
                              style: const TextStyle(
                                  color: Color(0xFFC62828), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 4),
                        const Text(
                          'החלף לחומר עמיד-חום: PEX / נחושת / פליז.',
                          style: TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }),
                // ── Pressure-drop estimate — supply lines only ─────────
                if (isSupply)
                  Builder(builder: (_) {
                  final pd = estimatePressureDrop(
                    plan.items,
                    pipeLengthMeters:
                        _totalMeters > 0 ? _totalMeters : 5.0,
                    flowRateLPS: 0.3,
                    verticalRiseMeters: _verticalRise,
                  );
                  final ok = pd.dropBar <= 1.0 && pd.warnings.isEmpty;
                  final color =
                      ok ? const Color(0xFF15803D) : const Color(0xFFF59E0B);
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ok
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(ok ? Icons.water_drop : Icons.warning_amber,
                              color: color, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ירידת לחץ צפויה: ${pd.dropBar.toStringAsFixed(2)} בר',
                              style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            'K=${pd.totalK.toStringAsFixed(1)} · ⌀${pd.minBoreMm.toStringAsFixed(0)}mm · ${pd.frictionMetres.toStringAsFixed(0)}m',
                            style: const TextStyle(
                                color: _mute,
                                fontSize: 10,
                                fontFamily: 'monospace'),
                          ),
                        ]),
                        if (pd.bottleneck != null && !ok) ...[
                          const SizedBox(height: 4),
                          Text(
                            'צוואר-בקבוק: ${pd.bottleneck!.nameHe} (#${pd.bottleneck!.sku})',
                            style: const TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Actionable suggestions — each problem paired with
                        // a concrete fix (swap product / add product).
                        for (final s in pd.suggestions
                            .where((s) => s.actionKind != SuggestionKind.ok))
                          _suggestionCard(s),
                      ],
                    ),
                  );
                }),
                // ── Drainage slope check — drainage lines only (ת"י 1205, P3.9).
                //    Replaces the supply pressure block: gravity lines have no
                //    pressure, they need a ≥2% fall so waste doesn't pool. ─────
                if (!isSupply)
                  Builder(builder: (_) {
                    // s49b seam: an authored trade with no flow-physics
                    // (physics?.minSlopePercent == null — always in v1) hides
                    // the ת"י-1205 panel; plumbing = legacy verbatim (R1-2 —
                    // its hand-written 2% constants below are permanent).
                    if (s49bCfg != null &&
                        s49bCfg.physics?.minSlopePercent == null) {
                      return const SizedBox.shrink();
                    }
                    final res = checkDrainageSlope(
                      horizontalRunMeters: _drainRun,
                      verticalDropMeters: _drainDrop,
                    );
                    final slope = res?.slopePercent ?? 0;
                    final slopeOk = res?.ok ?? false;
                    final color = slopeOk
                        ? const Color(0xFF15803D)
                        : const Color(0xFFF59E0B);
                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: slopeOk
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(slopeOk
                                ? Icons.trending_down
                                : Icons.warning_amber,
                                color: color, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'שיפוע ניקוז: ${slope.toStringAsFixed(1)}%',
                                style: TextStyle(
                                    color: color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                            const Text('מינ׳ 2% · ת"י 1205',
                                style: TextStyle(
                                    color: _mute,
                                    fontSize: 10,
                                    fontFamily: 'monospace')),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.straighten,
                                color: _mute, size: 14),
                            const SizedBox(width: 6),
                            const Text('אורך אופקי:',
                                style: TextStyle(color: _mute, fontSize: 11)),
                            Expanded(
                              child: Slider(
                                value: _drainRun.clamp(0.5, 20),
                                min: 0.5,
                                max: 20,
                                divisions: 39,
                                activeColor: _drain,
                                onChanged: (v) =>
                                    setState(() => _drainRun = v),
                              ),
                            ),
                            SizedBox(
                              width: 52,
                              child: Text('${_drainRun.toStringAsFixed(1)} מ׳',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          Row(children: [
                            const Icon(Icons.height, color: _mute, size: 14),
                            const SizedBox(width: 6),
                            const Text('מפל אנכי:',
                                style: TextStyle(color: _mute, fontSize: 11)),
                            Expanded(
                              child: Slider(
                                value: (_drainDrop * 100).clamp(0, 100),
                                min: 0,
                                max: 100,
                                divisions: 100,
                                activeColor: _drain,
                                onChanged: (v) =>
                                    setState(() => _drainDrop = v / 100),
                              ),
                            ),
                            SizedBox(
                              width: 52,
                              child: Text(
                                  '${(_drainDrop * 100).toStringAsFixed(0)} ס״מ',
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      color: _ink,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          if (res != null) ...[
                            const SizedBox(height: 4),
                            Text(res.message,
                                style: TextStyle(
                                    color: slopeOk
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    );
                  }),
                // ── Installation kit (tools & sealants for this chain) ──
                Builder(builder: (_) {
                  // s49b seam: authored trade derives its kit from its
                  // mustHave AccessoryRules; plumbing = legacy verbatim (R1-2).
                  final s49bKitCfg = s49bCfg;
                  if (s49bKitCfg != null) {
                    return _authoredKitSection(s49bKitCfg);
                  }
                  final kit = recommendedKitFor(plan.items);
                  if (kit.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _mute.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.build_circle_outlined,
                              color: _supply, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'כלים ואיטומים לקו: ${kit.length} פריטים',
                            style: const TextStyle(
                                color: _supply,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        for (final k in kit)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: switch (k.kind) {
                                      KitKind.tool =>
                                        _supply.withOpacity(0.18),
                                      KitKind.sealant =>
                                        _accent.withOpacity(0.18),
                                      KitKind.safety =>
                                        BsTokens.danger.withOpacity(0.18),
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    switch (k.kind) {
                                      KitKind.tool => 'כלי',
                                      KitKind.sealant => 'איטום',
                                      KitKind.safety => 'בטיחות',
                                    },
                                    style: TextStyle(
                                      color: switch (k.kind) {
                                        KitKind.tool => _supply,
                                        KitKind.sealant => _accent,
                                        KitKind.safety =>
                                          BsTokens.danger,
                                      },
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(k.label,
                                          style: const TextStyle(
                                              color: _ink,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600)),
                                      Text(k.reason,
                                          style: const TextStyle(
                                              color: _mute, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                ..._buildBomRows(plan, anchorSkus),
                // #guarantee — "אין נסיעה שנייה": a branded green seal at the buy
                // moment, shown ONLY when the line is physically complete (no
                // gaps) AND no critical safety check is open. The signal is the
                // already-computed `ok`(=plan.isComplete) + `checkCritical`; this
                // is the positive counterpart to the "חסרים חיבורים" warning below.
                if (ok && checkCritical == 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                    child: Row(
                      children: const [
                        Text('🛡️', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'אחריות: הסל משלים את העבודה — אין נסיעה שנייה',
                            style: TextStyle(
                                color: _ok,
                                fontSize: 13,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (plan.gaps.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
                    child: Text('⚠️ חסרים חיבורים — הקו לא שלם',
                        style: TextStyle(
                            color: _drain,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ),
                  for (final g in plan.gaps)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✗ ${g.from.nameHe} ↮ ${g.to.nameHe}',
                              style: const TextStyle(color: _drain, fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Text(_gapHint(g),
                              style: const TextStyle(color: _mute, fontSize: 11,
                                  height: 1.4)),
                        ],
                      ),
                    ),
                ],
                if (checklist.isNotEmpty) ...[
                  const Divider(height: 18, color: Color(0xFFEEEEEE)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(children: [
                      const Text('בטיחות ותקינות',
                          style: TextStyle(
                              color: _ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      _severityBadge('קריטי',
                          checklist.where((c) =>
                              !c.satisfied && c.severity == CheckSeverity.critical).length,
                          BsTokens.danger),
                      const SizedBox(width: 4),
                      _severityBadge('אזהרה',
                          checklist.where((c) =>
                              !c.satisfied && c.severity == CheckSeverity.warning).length,
                          _drain),
                    ]),
                  ),
                  for (final ch in checklist) _checkRow(ch),
                ],
                // "מה הצעד הבא" — post-BOM guidance card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('מה הצעד הבא?',
                                style: TextStyle(
                                    color: _accent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text(
                              'לחץ "📋 שלח לאינסטלטור" כדי להעתיק ולשלוח ב-WhatsApp,\nאו "הוסף לסל" להזמנה ישירה.',
                              style: TextStyle(color: _mute, fontSize: 11, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  14, 10, 14, 12 + MediaQuery.of(context).padding.bottom),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _copyBom(context, plan),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _panel,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: _mute.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy_all, color: _mute, size: 16),
                          SizedBox(width: 6),
                          Text('📋 שלח לאינסטלטור',
                              style: TextStyle(
                                  color: _ink,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => _addToCart(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [_accent, Color(0xFFE85F00)]),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: _accent.withOpacity(0.4), blurRadius: 16)
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('הוסף ${plan.items.length} לסל',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900)),
                          ]),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── s49b authored-trade sections — NEW code, reached ONLY when the resolved
  //    active trade is authored (never under plumbing — R1-2). No legacy line
  //    above was moved into these; the legacy blocks stay verbatim in build. ──

  /// s49b seam (d): the authored heat-rating guard — products whose
  /// [ProductConnectorSpec] envelope carries a `maxTempC` below the line temp
  /// (the plumbing-material advice line is deliberately absent — PEX/copper
  /// guidance is plumbing-specific).
  Widget _authoredTempUnfitBanner(
      int temp, List<LipskeyCatalogProduct> unfit, _ActiveTradeConfig cfg) {
    const warn = BsTokens.danger;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: warn.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.local_fire_department, color: warn, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'קו חם ($temp°C): ${unfit.length} מוצרים אינם עומדים בחום',
                style: const TextStyle(
                    color: warn, fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          for (final p in unfit.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                '• ${p.nameHe} — עד ${cfg.maxTempCOf(p.sku)?.toStringAsFixed(0) ?? "?"}°C',
                style: const TextStyle(color: Color(0xFFC62828), fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  /// s49b seam (g): the authored kit — the trade's mustHave [AccessoryRule]s
  /// (emoji · name · why). No rules → nothing renders (matches the legacy
  /// empty-kit behavior).
  Widget _authoredKitSection(_ActiveTradeConfig cfg) {
    final rules = cfg.mustHaveAccessories;
    if (rules.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _mute.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.build_circle_outlined, color: _supply, size: 18),
            const SizedBox(width: 8),
            Text(
              'אביזרי חובה לקו: ${rules.length} פריטים',
              style: const TextStyle(
                  color: _supply, fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ]),
          const SizedBox(height: 6),
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.nameHe,
                            style: const TextStyle(
                                color: _ink,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        Text(r.whyHe,
                            style: const TextStyle(
                                color: _mute, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Adds every BOM line to the cart with its quantity (pipes by ceil(metres)).
  void _addToCart(BuildContext context, WidgetRef ref) {
    final cart = ref.read(smartCartProvider.notifier);
    for (final p in widget.plan.items) {
      final qty =
          isPipe(p) ? _metersOf(p.sku).ceil() : widget.plan.qtyOf(p.sku);
      cart.add(SmartCartLine(
        productKey: p.sku,
        productName: p.nameHe,
        productEmoji: p.typeEmoji,
        brandName: p.categoryHe,
        brandPrice: estimatePrice([p]).totalILS,
        productQty: qty,
        accessories: const [],
      ));
    }
    Navigator.pop(context);
    showToast(context, 'נוסף לסל: ${widget.plan.items.length} פריטים');
  }

  void _copyBom(BuildContext context, InstallationPlan plan) {
    final buf = StringBuffer();
    buf.writeln('רשימת קנייה — ${AppBrand.name} 🔧');
    buf.writeln('──────────────────────────');

    // ── BOM grouped by zone or flat list ──────────────────────────────────
    if (plan.zones.isNotEmpty) {
      final bySkU = {for (final p in plan.items) p.sku: p};
      for (final entry in plan.zones.entries) {
        buf.writeln('▸ ${_zoneDisplayLabel(entry.key)}');
        for (final sku in entry.value) {
          final p = bySkU[sku];
          if (p == null) continue;
          final qty = plan.qtyOf(sku);
          buf.writeln('  • ${p.nameHe}  ×$qty');
        }
      }
    } else {
      for (final p in plan.items) {
        buf.writeln('• ${p.nameHe}  ×${plan.qtyOf(p.sku)}');
      }
    }
    buf.writeln('──────────────────────────');
    buf.writeln(
        'סה"כ: ${plan.items.length} פריטים · ${plan.totalPieces} יחידות');

    // ── ASCII chain diagram ───────────────────────────────────────────────
    // Vertical layout so it stays readable on a narrow WhatsApp screen.
    if (plan.items.length >= 2) {
      buf.writeln('');
      buf.writeln('🔗 מבנה הקו:');
      // Each product + the joint method to the next (same wording as the
      // carousel / chain diagram), so the installer reads exactly how to join.
      buf.writeln(lineStructureText(plan.items));
    }

    // ── Price estimate ────────────────────────────────────────────────────
    final expandedForPrice = <LipskeyCatalogProduct>[];
    for (final p in plan.items) {
      final q = plan.qtyOf(p.sku);
      for (var i = 0; i < q; i++) expandedForPrice.add(p);
    }
    final pr = estimatePrice(expandedForPrice);
    buf.writeln('💵 הערכת תקציב: ~₪${pr.totalILS}'
        '${pr.lowConfidence ? " (דיוק נמוך)" : ""}');

    // ── Pressure-drop summary ─────────────────────────────────────────────
    final pd = estimatePressureDrop(
      plan.items,
      pipeLengthMeters: _totalMeters > 0 ? _totalMeters : 5.0,
      flowRateLPS: 0.3,
    );
    buf.writeln('');
    buf.writeln('💧 ירידת לחץ: ${pd.dropBar.toStringAsFixed(2)} בר');
    buf.writeln(
        '   K=${pd.totalK.toStringAsFixed(1)} · ⌀${pd.minBoreMm.toStringAsFixed(0)}mm · ${pd.frictionMetres.toStringAsFixed(0)}m');
    if (pd.bottleneck != null && pd.dropBar > 1.0) {
      buf.writeln('   צוואר-בקבוק: ${pd.bottleneck!.nameHe}');
    }
    for (final w in pd.warnings) {
      buf.writeln('   ⚠️ $w');
    }

    // ── Tools & sealants kit ──────────────────────────────────────────────
    final kit = recommendedKitFor(plan.items);
    if (kit.isNotEmpty) {
      buf.writeln('');
      buf.writeln('🔧 כלים ואיטומים (${kit.length}):');
      for (final k in kit) {
        final tag = switch (k.kind) {
          KitKind.tool => '🛠',
          KitKind.sealant => '🧪',
          KitKind.safety => '⚠️',
        };
        buf.writeln('   $tag ${k.label}');
      }
    }

    // ── Compliance summary ────────────────────────────────────────────────
    // s49b seam: authored trade reads config (the s41 trade: delegation);
    // plumbing = legacy verbatim (R1-2) — the else call stays positional-only.
    final s49bCfg = _authoredConfigOf(ref);
    final checks = s49bCfg != null
        ? lineComplianceChecklist(
            plan.items,
            ref.read(lineMaxTempProvider),
            ref.read(lineAccessoriesProvider),
            trade: s49bCfg.tradeResolution,
          )
        : lineComplianceChecklist(
            plan.items,
            ref.read(lineMaxTempProvider),
            ref.read(lineAccessoriesProvider));
    final missing = checks
        .where((c) => !c.satisfied && c.severity == CheckSeverity.critical)
        .toList();
    if (missing.isNotEmpty) {
      buf.writeln('');
      buf.writeln('🚨 חוסרים קריטיים לבטיחות:');
      for (final c in missing) {
        buf.writeln('   • ${c.label}');
      }
    }

    buf.writeln('');
    buf.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buf.writeln('נוצר ע"י ${AppBrand.name}');

    Clipboard.setData(ClipboardData(text: buf.toString()));
    showToast(context, '📋 הועתק — שתף ב-WhatsApp עם האינסטלטור שלך');
  }

  // Returns BOM rows — sectioned by zone (trunk/branches) when available,
  // or under a single "קו ראשי" header for linear installs.
  List<Widget> _buildBomRows(InstallationPlan plan, Set<String> anchorSkus) {
    if (plan.zones.isEmpty) {
      return [
        _zoneHeader('קו ראשי', count: plan.items.length),
        for (var i = 0; i < plan.items.length; i++)
          _bomRow(plan.items[i], i + 1,
              anchorSkus.contains(plan.items[i].sku),
              plan.qtyOf(plan.items[i].sku)),
      ];
    }
    final bySkU = {for (final p in plan.items) p.sku: p};
    final zonedSkus = <String>{};
    final result = <Widget>[];
    int n = 1;
    for (final entry in plan.zones.entries) {
      final zoneItems = entry.value.map((s) => bySkU[s]).whereType<LipskeyCatalogProduct>().toList();
      result.add(_zoneHeader(entry.key, count: zoneItems.length));
      for (final p in zoneItems) {
        zonedSkus.add(p.sku);
        result.add(_bomRow(p, n++, anchorSkus.contains(p.sku), plan.qtyOf(p.sku)));
      }
    }
    final unzoned = plan.items.where((p) => !zonedSkus.contains(p.sku)).toList();
    if (unzoned.isNotEmpty) {
      result.add(_zoneHeader('אביזרים', count: unzoned.length));
      for (final p in unzoned) {
        result.add(_bomRow(p, n++, anchorSkus.contains(p.sku), plan.qtyOf(p.sku)));
      }
    }
    return result;
  }

  Widget _zoneHeader(String key, {int count = 0}) {
    final display = _zoneDisplayLabel(key);
    final isRenameable = key.startsWith('ענף') || key == 'גזע';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      child: Row(children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: _supply, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: isRenameable ? () => _renameZone(key) : null,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(display,
                style: const TextStyle(
                    color: _supply,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6)),
            if (isRenameable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.edit, color: _mute, size: 11),
            ],
          ]),
        ),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: _supply.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$count פריטים',
                style: const TextStyle(color: _supply, fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ],
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: _supply.withOpacity(0.2))),
      ]),
    );
  }

  // Severity badge — only shown when count > 0.
  Widget _severityBadge(String label, int count, Color c) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Text('$count $label',
          style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }

  Widget _checkRow(LineCheck ch) {
    final Color iconColor;
    final IconData icon;
    if (ch.satisfied) {
      iconColor = _accent;
      icon = Icons.check_circle;
    } else {
      switch (ch.severity) {
        case CheckSeverity.critical:
          iconColor = BsTokens.danger;
          icon = Icons.cancel;
        case CheckSeverity.warning:
          iconColor = _drain;
          icon = Icons.warning_amber_rounded;
        case CheckSeverity.info:
          iconColor = _mute;
          icon = Icons.info_outline;
      }
    }
    // s49b seam: an authored check's text is its CompletionRule.whyHe VERBATIM
    // — the plumbing jargon-mappers must not rewrite it; plumbing = legacy
    // verbatim (R1-2).
    final s49bAuthored = _authoredConfigOf(ref) != null;
    final displayLabel = s49bAuthored ? ch.label : _simpleLabel(ch.label);
    final displayWhy = s49bAuthored ? ch.why : _simpleWhy(ch.why);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayLabel,
                style: TextStyle(
                    color: ch.satisfied ? _ink : iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            if (!ch.satisfied)
              Text(displayWhy,
                  style: const TextStyle(color: _mute, fontSize: 10, height: 1.3)),
          ]),
        ),
        if (!ch.satisfied && ch.severity != CheckSeverity.info)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ch.severity == CheckSeverity.critical ? '🔴 חסר' : '⚠️ מומלץ',
              style: TextStyle(
                  color: iconColor, fontSize: 9, fontWeight: FontWeight.w900),
            ),
          ),
      ]),
    );
  }

  Widget _bomRow(LipskeyCatalogProduct p, int n, bool anchor, int qty) {
    // s49b seam: authored trade reads config; plumbing = legacy verbatim (R1-2).
    final c = _systemColor(p, _authoredConfigOf(ref));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: c.withOpacity(0.18),
              border: Border.all(color: c)),
          alignment: Alignment.center,
          child: Text('$n',
              style: TextStyle(
                  color: c, fontSize: 12, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.nameHe,
                style: const TextStyle(
                    color: _ink, fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${_roleLabel(p, anchor)} · ${_productHint(p)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _mute, fontSize: 11)),
          ]),
        ),
        if (isPipe(p)) _metersStepper(p.sku) else _qtyBadge(qty),
      ]),
    );
  }

  Widget _qtyBadge(int qty) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: _panel, borderRadius: BorderRadius.circular(10)),
        child: Text('× $qty',
            style: const TextStyle(
                color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
      );

  // metres control for pipe products (sold by length)
  Widget _metersStepper(String sku) {
    final m = _metersOf(sku);
    return Container(
      decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _supply.withOpacity(0.4))),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _stepBtn(Icons.remove, () {
          setState(() => _meters[sku] = (m - 0.5).clamp(0.5, 999));
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('${m.toStringAsFixed(1)} מ׳',
              style: const TextStyle(
                  color: _supply, fontSize: 13, fontWeight: FontWeight.w900)),
        ),
        _stepBtn(Icons.add, () {
          setState(() => _meters[sku] = (m + 0.5).clamp(0.5, 999));
        }),
      ]),
    );
  }

  Widget _stepBtn(IconData ic, VoidCallback onTap) => Semantics(
        button: true,
        label: ic == Icons.add ? 'הוסף' : 'הפחת',
        child: Tooltip(
          message: ic == Icons.add ? 'הוסף' : 'הפחת',
          child: GestureDetector(
            onTap: onTap,
            // 48dp min tap area; opaque so the full box (not just the 24×24
            // chip) is tappable. The chip stays the visual via Center.
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                      color: _void1, borderRadius: BorderRadius.circular(8)),
                  child: Icon(ic, color: _ink, size: 15),
                ),
              ),
            ),
          ),
        ),
      );
}

// ── dark product picker ────────────────────────────────────────────────────────
class _ProductPicker extends ConsumerStatefulWidget {
  const _ProductPicker({required this.lineTemp, this.initialCat});
  final int lineTemp;
  final _PickerCategory? initialCat;
  @override
  ConsumerState<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends ConsumerState<_ProductPicker> {
  String _q = '';
  late _PickerCategory? _cat = widget.initialCat;

  List<LipskeyCatalogProduct> _filtered() {
    // s49b seam: an authored trade's picker serves ITS products — the same
    // repo read + s35 adapter + sku-sort the s50 catalog path uses (single
    // source, zero drift); temp-suitability comes from the spec envelope's
    // maxTempC (null → suitable, the legacy rule); the plumbing category
    // filter (_cat) is skipped — _kCats is plumbing-shaped and the grid is
    // bypassed for authored trades. Plumbing = legacy verbatim (R1-2).
    final s49bCfg = _authoredConfigOf(ref);
    if (s49bCfg != null) {
      final q = _q.trim();
      return ref
          .read(catalogRepositoryProvider)
          .allProducts(tradeId: s49bCfg.tradeId)
          .where((p) {
        final maxT = s49bCfg.maxTempCOf(p.sku);
        if (maxT != null && widget.lineTemp > maxT) return false;
        if (q.isEmpty) return true;
        return p.nameHe.contains(q) ||
            p.categoryHe.contains(q) ||
            p.sku.contains(q);
      }).take(120).toList();
    }
    final q = _q.trim();
    return chainUniverse.where((p) {
      if (!productSuitableForTemp(p, widget.lineTemp)) return false;
      if (_cat != null && !_inCategory(_cat!, p)) return false;
      if (q.isEmpty) return true;
      return p.nameHe.contains(q) ||
          p.categoryHe.contains(q) ||
          p.sku.contains(q);
    }).take(120).toList();
  }

  @override
  Widget build(BuildContext context) {
    // s49b seam: an authored trade skips the plumbing category grid (_kCats
    // is plumbing-shaped) and goes straight to its product list; plumbing =
    // legacy verbatim (R1-2 — the legacy expression is the && tail).
    final s49bAuthored = _authoredConfigOf(ref) != null;
    final showGrid = !s49bAuthored && _q.trim().isEmpty && _cat == null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: _void1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: _supply, width: 2)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 42, height: 4,
              decoration: BoxDecoration(
                  color: _mute, borderRadius: BorderRadius.circular(2)),
            ),
            const _SheetClose(),
            // Search bar + optional back-to-categories chip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
                if (_cat != null) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() { _cat = null; _q = ''; }),
                    // ≥48dp tap target around the small chip (a11y).
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Center(
                        widthFactor: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 9),
                          margin: const EdgeInsetsDirectional.only(end: 8),
                          decoration: BoxDecoration(
                            color: _panel,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _supply.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(_cat!.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(_cat!.label,
                                style: const TextStyle(
                                    color: _supply, fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 4),
                            const Icon(Icons.close, color: _mute, size: 14),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: TextField(
                    autofocus: false,
                    style: const TextStyle(color: _ink),
                    textDirection: TextDirection.rtl,
                    onChanged: (v) => setState(() => _q = v),
                    decoration: InputDecoration(
                      hintText: _cat == null
                          ? 'חפש בכל המוצרים…'
                          : 'חפש ב${_cat!.label}…',
                      hintStyle: const TextStyle(color: _mute),
                      prefixIcon: const Icon(Icons.search, color: _mute, size: 20),
                      filled: true,
                      fillColor: _panel,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: showGrid
                  ? _categoryGrid()
                  : _productList(ctrl),
            ),
          ]),
        ),
      ),
    );
  }

  // 2×3 grid of category buttons
  Widget _categoryGrid() {
    // Raw shell: derived company chips (honest-empty before an import) — the
    // const plumbing [_kCats] renders only on demo/buildsmart (byte-identical
    // there: _pickerCats() returns the same const list).
    final cats = _pickerCats();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('מה אתה מחפש?',
                style: TextStyle(
                    color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final cat = cats[i];
                final count = chainUniverse
                    .where((p) =>
                        productSuitableForTemp(p, widget.lineTemp) &&
                        _inCategory(cat, p))
                    .length;
                return GestureDetector(
                  onTap: () => setState(() => _cat = cat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _panel,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _supply.withOpacity(0.25)),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat.label,
                                style: const TextStyle(
                                    color: _ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            Text('$count מוצרים',
                                style: const TextStyle(
                                    color: _mute, fontSize: 10)),
                          ],
                        ),
                      ),
                    ]),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'או חפש ישירות בשדה החיפוש למעלה',
              textAlign: TextAlign.center,
              style: TextStyle(color: _mute, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productList(ScrollController ctrl) {
    final items = _filtered();
    if (items.isEmpty) {
      return const Center(
        child: Text('לא נמצאו מוצרים',
            style: TextStyle(color: _mute, fontSize: 14)),
      );
    }
    // s49b seam: authored trade reads config; plumbing = legacy verbatim (R1-2).
    final s49bCfg = _authoredConfigOf(ref);
    final chain = ref.watch(chainProvider);
    return ListView.builder(
      controller: ctrl,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final p = items[i];
        final c = _systemColor(p, s49bCfg);
        final inChain = chain.any((cp) => cp.sku == p.sku);
        return InkWell(
          onTap: () {
            ref.read(chainProvider.notifier).state = [...chain, p];
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              // Product image or color fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: p.imageAsset != null
                    ? productImage(
                        p.imageAsset!,
                        width: 56, height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgFallback(c),
                      )
                    : _imgFallback(c),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(p.nameHe,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Row(children: [
                    Expanded(
                      child: Text(_productHint(p),
                          style: const TextStyle(color: _mute, fontSize: 11)),
                    ),
                    if (inChain) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('✓ כבר נוסף',
                            style: TextStyle(
                                color: _accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ]),
                ]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: c.withOpacity(0.5)),
                ),
                child: Text('הוסף',
                    style: TextStyle(
                        color: c,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _imgFallback(Color c) => Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.3)),
        ),
        child: Icon(Icons.plumbing, color: c.withOpacity(0.6), size: 26),
      );
}

// ── first-time tutorial overlay ───────────────────────────────────────────────
class _TutorialOverlay extends StatelessWidget {
  const _TutorialOverlay({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: _void0.withOpacity(0.93),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [_supply, _fixture]),
                  boxShadow: [BoxShadow(color: _supply.withOpacity(0.4), blurRadius: 20)],
                ),
                child: const Icon(Icons.plumbing, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('ברוכים הבאים לתכנון חיבור',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _ink, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('3 צעדים לרשימת קנייה מוכנה',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _mute, fontSize: 13)),
              const SizedBox(height: 32),
              _step('1️⃣', 'בחר מה אתה מחבר',
                  'ברז, מקלחת, שירותים, גינה — לחץ על הקטגוריה הנכונה'),
              _step('2️⃣', 'הוסף 2 נקודות לפחות',
                  'כניסה + יציאה — המערכת ממלאת חיבורים אוטומטית'),
              _step('3️⃣', 'קבל רשימת קנייה',
                  'שלח לאינסטלטור ב-WhatsApp, או הוסף ישירות לסל'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: onDismiss,
                  child: const Text('הבנתי — בוא נתחיל!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                // ≥48dp tap target around the small text (a11y).
                child: const SizedBox(
                  height: 48,
                  child: Center(
                    child: Text('דלג',
                        style: TextStyle(color: _mute, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String emoji, String title, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _ink, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: const TextStyle(
                          color: _mute, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
}
