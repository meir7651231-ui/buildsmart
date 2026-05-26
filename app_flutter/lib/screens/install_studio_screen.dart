// BuildSmart Studio — a cinematic installation designer built on install_engine.
// Dark "blueprint command-center": glowing product nodes wired by animated
// energy pipes, colour-coded by plumbing system, with a one-tap auto-assemble
// that fills every connector into an orderable bill of materials.
import 'dart:math' as math;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── palette ───────────────────────────────────────────────────────────────────
const _void0 = Color(0xFF0A0E1A); // deep background
const _void1 = Color(0xFF111827);
const _panel = Color(0xFF161D2E);
const _grid = Color(0x14_38BDF8);
const _ink = Color(0xFFF1F5F9);
const _mute = Color(0xFF7C8AA5);
const _supply = Color(0xFF22D3EE); // cyan — water supply
const _drain = Color(0xFFFBBF24); // amber — drainage
const _fixture = Color(0xFFA78BFA); // violet — fixtures (the bridge)
const _accent = Color(0xFF34D399); // emerald — assemble action

Color _systemColor(LipskeyCatalogProduct p) {
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

/// Suggests what kind of adapter/reducer to look for to bridge a gap.
String _gapHint(InstallationGap g) {
  final vA = kVerifiedSpecs[g.from.sku], vB = kVerifiedSpecs[g.to.sku];
  if (vA == null || vB == null) {
    return 'חפש מתאם בין ${g.from.categoryHe} ל-${g.to.categoryHe}';
  }
  final sizesA = vA.ends.map((e) => e.size).toSet();
  final sizesB = vB.ends.map((e) => e.size).toSet();
  final typesA = vA.ends.map((e) => e.type.name).toSet();
  final typesB = vB.ends.map((e) => e.type.name).toSet();
  if (sizesA.isNotEmpty && sizesB.isNotEmpty && sizesA.intersection(sizesB).isEmpty) {
    return 'נדרש מתאם/בושינג ${sizesA.first}↔${sizesB.first} — חפש "מתאם" בקטלוג';
  }
  if (typesA.isNotEmpty && typesB.isNotEmpty && typesA.intersection(typesB).isEmpty) {
    return 'שיטת חיבור שונה — חפש אדפטר ${typesA.first}↔${typesB.first}';
  }
  return 'אין נתיב מאומת — הוסף מוצר ביניים ידנית';
}

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
class InstallStudioScreen extends ConsumerStatefulWidget {
  const InstallStudioScreen({super.key});
  @override
  ConsumerState<InstallStudioScreen> createState() => _InstallStudioScreenState();
}

class _InstallStudioScreenState extends ConsumerState<InstallStudioScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flow =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  bool _loop = false;
  bool _showTutorial = false;
  final TextEditingController _describeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkFirstVisit();
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
    for (final p in kCompatCatalog) {
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
    return Directionality(
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
                  builder: (_, __) => CustomPaint(
                    painter: _BlueprintPainter(_flow.value),
                    child: Column(children: [
                      _header(chain, temp),
                      Expanded(child: _canvas(chain, temp)),
                      _dock(chain, temp),
                    ]),
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
  }

  // ── header: title + live system legend ──────────────────────────────────────
  Widget _header(List<LipskeyCatalogProduct> chain, int temp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 18, 6),
      child: Row(children: [
        if (Navigator.canPop(context))
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.arrow_forward, color: _ink, size: 22),
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
            Text('סטודיו התקנות',
                style: TextStyle(
                    color: _ink, fontSize: 18, fontWeight: FontWeight.w900)),
            Text('תכנן · חבר · הזמן',
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
      borderColor = const Color(0xFFEF4444); // red
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
      (80, '🌡️ חם מאוד', 'מערכת ישנה או מסחרית, 80° ומעלה', const Color(0xFFEF4444)),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      itemCount: chain.length,
      itemBuilder: (_, i) {
        final p = chain[i];
        final last = i == chain.length - 1;
        final connectsToNext =
            last ? true : canConnect(p, chain[i + 1]);
        return _NodeRow(
          product: p,
          index: i,
          isLast: last,
          flow: _flow.value,
          nextColor: last ? null : _systemColor(chain[i + 1]),
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
          'כתוב במילים מה צריך — או בחר קטגוריה',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mute, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 16),
        // Free-text "describe your line" box
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
        const SizedBox(height: 16),
        const Text('— או בחר קטגוריה —',
            style: TextStyle(color: _mute, fontSize: 11)),
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
        const Text(
          'לא מוצא? לחץ ➕ למטה לחיפוש חופשי',
          textAlign: TextAlign.center,
          style: TextStyle(color: _mute, fontSize: 11),
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
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 24)],
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
          if (temp > 20) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => setState(() => _loop = !_loop),
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
        padding: const EdgeInsets.only(left: 14),
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
            gradient: const LinearGradient(colors: [_accent, Color(0xFF059669)]),
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
  void _assemble(List<LipskeyCatalogProduct> chain, int temp) {
    final acc = ref.read(lineAccessoriesProvider);
    final mi = chain.indexWhere((p) => manifoldOutlets(p) > 0);
    final isTree = mi >= 0 && mi < chain.length - 1;
    final InstallationPlan plan;
    int branches = 0, outlets = 0;
    if (isTree) {
      final trunk = chain.sublist(0, mi + 1);
      final branchTargets = chain.sublist(mi + 1);
      branches = branchTargets.length;
      outlets = manifoldOutlets(chain[mi]);
      plan = buildTreeInstallation(trunk, branchTargets,
          tempC: temp, accessories: acc, autoCompliance: true);
    } else {
      plan = buildInstallation([...chain],
          tempC: temp, accessories: acc, loop: _loop, autoCompliance: true);
    }
    final criticalCount = plan.criticalOpen(temp, acc);
    if (criticalCount > 0) {
      _showCriticalWarning(plan, chain, branches, outlets, temp, acc, criticalCount);
    } else {
      _showBomSheet(plan, chain, branches, outlets);
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
                color: Color(0xFFEF4444), size: 22),
            const SizedBox(width: 8),
            Text('$criticalCount בעיות בטיחות בקו',
                style: const TextStyle(
                    color: Color(0xFFEF4444),
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
                  backgroundColor: const Color(0xFFEF4444),
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
  });
  final LipskeyCatalogProduct product;
  final int index;
  final bool isLast;
  final double flow;
  final Color? nextColor;
  final bool connectsToNext; // false → broken joint (red)
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = _systemColor(product);
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
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: _mute, size: 18),
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
    final c = broken ? const Color(0xFFEF4444) : _accent;
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
      ..color = Colors.white.withOpacity(0.08)
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
      this.outlets = 0});
  final InstallationPlan plan;
  final Set<String> anchorSkus;
  final int branches; // >0 when this is a branched (manifold) installation
  final int outlets; // manifold outlet count, for over-capacity warning

  @override
  ConsumerState<_BomSheet> createState() => _BomSheetState();
}

class _BomSheetState extends ConsumerState<_BomSheet> {
  // Per-pipe length in metres (pipes are sold by length, not by piece).
  final Map<String, double> _meters = {};
  // User-defined display names for zone headers (e.g. "ענף א" → "מטבח").
  final Map<String, String> _zoneAliases = {};

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
    );
  }
  double _metersOf(String sku) => _meters[sku] ?? 2.0;

  double get _totalMeters => widget.plan.items
      .where(isPipe)
      .fold(0.0, (s, p) => s + _metersOf(p.sku));

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final anchorSkus = widget.anchorSkus;
    final branches = widget.branches;
    final outlets = widget.outlets;
    final ok = plan.isComplete;
    final overCapacity = branches > 0 && outlets > 0 && branches > outlets;
    final checklist = lineComplianceChecklist(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Row(children: [
                Icon(ok ? Icons.verified : Icons.warning_amber_rounded,
                    color: ok ? _accent : _drain, size: 24),
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
                                    : const Color(0xFFEF4444).withOpacity(0.18),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$checkPassed/${checklist.length} ✓',
                                style: TextStyle(
                                  color: checkCritical == 0 ? _accent : const Color(0xFFEF4444),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            if (checkCritical > 0) ...[
                              const SizedBox(width: 6),
                              Text('$checkCritical קריטי פתוח',
                                  style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ]),
                        ),
                      if (overCapacity)
                        Text('⚠️ $branches ענפים על מחלק $outlets-יציאות',
                            style: const TextStyle(
                                color: _drain,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(height: 1, color: Color(0xFF243049)),
            Expanded(
              child: ListView(controller: ctrl, children: [
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
                      color: const Color(0xFF1A2A1A),
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
                ..._buildBomRows(plan, anchorSkus),
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
                  const Divider(height: 18, color: Color(0xFF243049)),
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
                          const Color(0xFFEF4444)),
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
                              'לחץ "📋 שלח לאינסטלטור" כדי להעתיק ולשלוח ב-WhatsApp,\nאו "הוסף לעגלה" להזמנה ישירה.',
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
                            colors: [_accent, Color(0xFF059669)]),
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
                            Text('הוסף ${plan.items.length} לעגלה',
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
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      ));
    }
    Navigator.pop(context);
    showToast(context, 'נוסף לעגלה: ${widget.plan.items.length} פריטים');
  }

  void _copyBom(BuildContext context, InstallationPlan plan) {
    final buf = StringBuffer();
    buf.writeln('רשימת קנייה — BuildSmart 🔧');
    buf.writeln('──────────────────────────');
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
    buf.writeln('סה"כ: ${plan.items.length} פריטים · ${plan.totalPieces} יחידות');
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
          iconColor = const Color(0xFFEF4444);
          icon = Icons.cancel;
        case CheckSeverity.warning:
          iconColor = _drain;
          icon = Icons.warning_amber_rounded;
        case CheckSeverity.info:
          iconColor = _mute;
          icon = Icons.info_outline;
      }
    }
    final displayLabel = _simpleLabel(ch.label);
    final displayWhy = _simpleWhy(ch.why);
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
    final c = _systemColor(p);
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

  Widget _stepBtn(IconData ic, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
              color: _void1, borderRadius: BorderRadius.circular(8)),
          child: Icon(ic, color: _ink, size: 15),
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
    final q = _q.trim();
    return kCompatCatalog.where((p) {
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
    final showGrid = _q.trim().isEmpty && _cat == null;
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
            // Search bar + optional back-to-categories chip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(children: [
                if (_cat != null) ...[
                  GestureDetector(
                    onTap: () => setState(() { _cat = null; _q = ''; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      margin: const EdgeInsets.only(left: 8),
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
              itemCount: _kCats.length,
              itemBuilder: (_, i) {
                final cat = _kCats[i];
                final count = kCompatCatalog
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
    final chain = ref.watch(chainProvider);
    return ListView.builder(
      controller: ctrl,
      itemCount: items.length,
      itemBuilder: (_, i) {
        final p = items[i];
        final c = _systemColor(p);
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
                    ? Image.asset(
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
              const Text('ברוכים הבאים לסטודיו התקנות',
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
                  'שלח לאינסטלטור ב-WhatsApp, או הוסף ישירות לעגלה'),
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
                onTap: onDismiss,
                child: const Text('דלג',
                    style: TextStyle(color: _mute, fontSize: 12)),
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
