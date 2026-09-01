// ✨ חולל ע"י capability.mjs (מרכיב) — כוונה⇒הרכבה (§23). המשפט: "אני צריך לנטר את הטמפרטורה ולקבל התראה כשהטמפרטורה חורגת מהמקסימום".
// **המבנה נגזר, לא חרוט:** 1 יחידות (1 תנאים) ⇒ 1× ערך⇒GaugeMeter/PremiumRing + 1× התראה⇒AlertBanner.
// אפס שם-אטום חרוט · אפס-מילון-דומייני · מספר-היחידות מהמבנה (§20-ב · הרכבה-עד-שמושג).
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/premium/dataviz/gauge_meter.dart';
import '../dart-ui-bs/premium/showcase/premium_ring.dart';
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
  double _v0 = 55;
  @override
  Widget build(BuildContext context) {
    return DsScaffold(
      title: 'מסך שחולל',
      subtitle: '11 ניטורים',
      icon: '📟',
      children: [
        Padding(padding: const EdgeInsets.only(top: 10, right: 14), child: Align(alignment: Alignment.centerRight, child: Text('טמפרטורה', style: const TextStyle(color: DsPure.mut, fontSize: 13)))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Center(child: GaugeMeter(value: (_v0 / 100).clamp(0.0, 1.0)))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: PremiumRing(value: _v0, label: (_v0 > 60) ? 'חריגה · טמפרטורה' : 'תקין · טמפרטורה')),
        if (_v0 > 60)
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: AlertBanner(label: 'חריגה — טמפרטורה', height: 46, radius: 14, accentColor: DsPure.err, baseColor: DsPure.raised, fillColor: DsPure.surface)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Slider(value: _v0, max: 100, onChanged: (v) => setState(() => _v0 = v))),
        const Divider(color: DsPure.hair, height: 24),
      ],
    );
  }
}
