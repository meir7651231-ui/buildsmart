// 🌲 Time Forest — הורכב אך-ורק מאטומי-המדף הקיימים (BareStat·RippleButton·FinRow·ModalDialog)
// + הרכבה (מצב/לולאה/מתמטיקה/persist). אפס אטום-חדש. §20-ב: שולב עד שהיכולת-המלאה הושגה.
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/ripple_button.dart';
import '../dart-ui-bs/auto/fin_row.dart';
import '../dart-ui-bs/modal_dialog.dart';

class _Upgrade {
  _Upgrade(this.name, this.base, this.apply);
  final String name;
  final double base;
  final void Function(_TimeForestState) apply;
  int count = 0;
  double cost() => (base * math.pow(1.15, count)).floorToDouble();
}

class GenTimeForest extends StatefulWidget {
  const GenTimeForest({super.key});
  @override
  State<GenTimeForest> createState() => _TimeForestState();
}

class _TimeForestState extends State<GenTimeForest> {
  static const _key = 'time_forest_v1';
  static const _offlineCap = 12 * 60 * 60; // 12ש׳

  double seeds = 0, totalSeeds = 0, autoRate = 0, clickMult = 1;
  int trees = 0, gems = 0;
  Timer? _tick, _save;
  String? _welcome; // מסך-חזרה

  late final List<_Upgrade> ups = [
    _Upgrade('משקה-אוטומטי', 50, (s) => s.autoRate += 1),
    _Upgrade('יד-מהירה', 35, (s) => s.clickMult += 1),
    _Upgrade('טפטפת-נבטים', 120, (s) => s.autoRate += 3),
    _Upgrade('חממת-חלום', 300, (s) => s.autoRate += 8),
    _Upgrade('רחפן-זריעה', 25000, (s) => s.autoRate += 100),
  ];

  double get gemMult => 1 + 0.10 * gems;

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (autoRate > 0) setState(() => _earn(autoRate * gemMult));
    });
    _save = Timer.periodic(const Duration(seconds: 5), (_) => _persist());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _save?.cancel();
    _persist();
    super.dispose();
  }

  void _earn(double g) {
    seeds += g;
    totalSeeds += g;
    trees = totalSeeds ~/ 100;
  }

  void _click() => setState(() => _earn(clickMult * gemMult));

  void _buy(_Upgrade u) {
    if (seeds >= u.cost()) {
      setState(() {
        seeds -= u.cost();
        u.apply(this);
        u.count++;
      });
      _persist();
    }
  }

  void _prestige() {
    if (totalSeeds < 1e6) return;
    setState(() {
      gems += math.sqrt(totalSeeds / 1e6).floor();
      seeds = 0;
      totalSeeds = 0;
      trees = 0;
      autoRate = 0;
      clickMult = 1;
      for (final u in ups) {
        u.count = 0;
      }
    });
    _persist();
  }

  // ── persist (shared_preferences · הרכבה, לא-אטום) ──
  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
        _key,
        jsonEncode({
          'seeds': seeds, 'total': totalSeeds, 'auto': autoRate, 'click': clickMult,
          'gems': gems, 'ups': ups.map((u) => u.count).toList(), 'exit': DateTime.now().millisecondsSinceEpoch,
        }));
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      seeds = (m['seeds'] as num).toDouble();
      totalSeeds = (m['total'] as num).toDouble();
      autoRate = (m['auto'] as num).toDouble();
      clickMult = (m['click'] as num).toDouble();
      gems = m['gems'] as int;
      final counts = (m['ups'] as List).cast<int>();
      for (var i = 0; i < ups.length && i < counts.length; i++) {
        ups[i].count = counts[i];
      }
      // offline-progress (מוגבל)
      final exit = m['exit'] as int? ?? DateTime.now().millisecondsSinceEpoch;
      final elapsed = ((DateTime.now().millisecondsSinceEpoch - exit) / 1000).floor().clamp(0, _offlineCap);
      final gain = elapsed * autoRate * gemMult;
      if (gain > 0) {
        _earn(gain);
        _welcome = 'בזמן שנעדרת, היער גידל ${_fmt(gain)} זרעים 🌱';
      }
      trees = totalSeeds ~/ 100;
      if (mounted) setState(() {});
    } catch (_) {/* שמירה-פגומה ⇒ אתחול-נקי */}
  }

  // פורמט-קומפקטי (הרכבה)
  String _fmt(double n) {
    if (n >= 1e9) return '${(n / 1e9).toStringAsFixed(1)}B';
    if (n >= 1e6) return '${(n / 1e6).toStringAsFixed(1)}M';
    if (n >= 1e3) return '${(n / 1e3).toStringAsFixed(1)}K';
    return n.floor().toString();
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF8CE99A), muted = Color(0xFF3E5C46), base = Color(0xFF163A22);
    final forest = trees <= 0 ? '·' : '🌳' * math.min(trees, 40) + (trees > 40 ? ' ×$trees' : '');
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E12),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(18),
              children: [
                BareStat(value: _fmt(seeds), label: '🌱 זרעים  (+${_fmt(autoRate * gemMult)}/שנ׳)', inkColor: ink, mutedColor: muted),
                const SizedBox(height: 12),
                BareStat(value: forest, label: '🌳 היער  ($trees עצים · ${totalSeeds.floor() % 100}/100 לבא)', inkColor: const Color(0xFF69DB7C), mutedColor: muted),
                const SizedBox(height: 12),
                if (gems > 0) BareStat(value: '💎 $gems', label: 'יהלומים ירוקים  (מכפיל ×${gemMult.toStringAsFixed(2)})', inkColor: const Color(0xFF63E6BE), mutedColor: muted),
                const SizedBox(height: 20),
                RippleButton(label: '🌱 שתול זרע', height: 68, radius: 20, accentColor: const Color(0xFF2F9E44), baseColor: base, onPressed: _click),
                const SizedBox(height: 20),
                const Text('  שדרוגים', style: TextStyle(color: ink, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final u in ups) ...[
                  FinRow('${u.name}  (רמה ${u.count})', 'עלות ${_fmt(u.cost())}', valueColor: seeds >= u.cost() ? const Color(0xFF69DB7C) : const Color(0xFF6B7B70)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RippleButton(label: seeds >= u.cost() ? 'קנה ⚙️' : 'חסר תקציב', height: 42, radius: 12,
                        accentColor: seeds >= u.cost() ? const Color(0xFF66A80F) : const Color(0xFF3A4A40), baseColor: base, onPressed: () => _buy(u)),
                  ),
                ],
                const SizedBox(height: 8),
                if (totalSeeds >= 1e6)
                  RippleButton(label: '🟢 גלגל-מחדש (+${math.sqrt(totalSeeds / 1e6).floor()} 💎)', height: 56, radius: 16,
                      accentColor: const Color(0xFF0CA678), baseColor: base, onPressed: _prestige),
              ],
            ),
            if (_welcome != null)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _welcome = null),
                  child: Container(
                    color: Colors.black54,
                    alignment: Alignment.center,
                    child: ModalDialog(title: 'ברוך שובך 🌲', sub: _welcome!, height: 200, radius: 22,
                        accentColor: const Color(0xFF2F9E44), baseColor: const Color(0xFF0B1E12), fillColor: const Color(0xFF12331F)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
