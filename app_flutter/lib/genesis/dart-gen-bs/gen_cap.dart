// ✨ חולל ע"י capability.mjs — כוונה⇒הרכבה (§23). המשפט: "אני צריך לנטר את הטמפרטורה ולקבל התראה כשהטמפרטורה חורגת מהמקסימום".
// פירוק ממבנה-המשפט: תנאי("כש") + השוואה(">") ⇒ AlertBanner מותנה + מד-רמה + קריאה.
// אפס-מתכון · אפס-מילון-דומייני · אטומים נבחרו לפי-מטרה/צורה (§20-א).
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/premium/dataviz/gauge_meter.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/alert_banner.dart';

void main() => runApp(const _CapApp());

class _CapApp extends StatelessWidget {
  const _CapApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, colorScheme: ColorScheme.fromSeed(seedColor: DsTokens.accent)),
        builder: (c, ch) => Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        home: const GenCapScreen(),
      );
}

class GenCapScreen extends StatefulWidget {
  const GenCapScreen({super.key});
  @override
  State<GenCapScreen> createState() => _GenCapScreenState();
}

class _GenCapScreenState extends State<GenCapScreen> {
  double _x = 55; // טמפרטורה
  final double _y = 70; // מקסימום
  @override
  Widget build(BuildContext context) {
    final bool over = _x > _y; // ← פעולת-היסוד מהמשפט
    final double norm = (_x / (_y == 0 ? 1 : _y * 1.4)).clamp(0.0, 1.0);
    return DsScaffold(
      title: 'ניטור טמפרטורה',
      subtitle: 'חוּלל ממשפט · טמפרטורה > מקסימום',
      icon: '📟',
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Center(child: GaugeMeter(value: norm, size: 170))),
        Padding(padding: const EdgeInsets.all(12), child: PremiumStat(label: over ? 'חריגה · טמפרטורה' : 'תקין · טמפרטורה', value: _x, unit: '/ מקסימום', delta: _x - _y)),
        if (over)
          const Padding(padding: EdgeInsets.all(12), child: AlertBanner(label: 'חריגה — טמפרטורה מעל מקסימום', height: 46, radius: 14, accentColor: DsPure.err, baseColor: DsPure.raised, fillColor: DsPure.surface)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), child: Slider(value: _x, max: 100, onChanged: (v) => setState(() => _x = v))),
      ],
    );
  }
}
