// ✨ ניסוי-הרכבה (L29 · עיצוב-Pure) — "מוניטור-מערכת" מ-אטומי-Pure שכבר קיימים במדף.
// תיקון-אמת: קודם בחרתי ביד אטומים שטוחים (DsStat/DsBars); §20-א דורש הכי-טוב-למטרה. אטומי-
// הפרימיום כבר פורקו וקיימים ⇒ הרכבתי אותם: GaugeMeter (מד עם value אמיתי) · PremiumStat
// (קריאה+דלתא) · NeonBars (ערך מול סף) · AlertBanner (התראה-מותנית). פעולת-יסוד אחת: השוואה.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/premium/dataviz/gauge_meter.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/alert_banner.dart';

void main() => runApp(const _MonitorApp());

class _MonitorApp extends StatelessWidget {
  const _MonitorApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'מוניטור מערכת',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Heebo',
          scaffoldBackgroundColor: DsTokens.bg,
          colorScheme: ColorScheme.fromSeed(seedColor: DsTokens.accent),
        ),
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const GenMonitorScreen(),
      );
}

class GenMonitorScreen extends StatefulWidget {
  const GenMonitorScreen({super.key});
  @override
  State<GenMonitorScreen> createState() => _GenMonitorScreenState();
}

class _GenMonitorScreenState extends State<GenMonitorScreen> {
  double _value = 82;
  final double _threshold = 70;

  @override
  Widget build(BuildContext context) {
    final bool over = _value > _threshold; // ← פעולת-היסוד היחידה שמחווטת את הכל
    return DsScaffold(
      title: 'מוניטור מערכת',
      subtitle: 'ניטור עם התראה · הרכבת אטומי-Pure',
      icon: '📟',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(child: GaugeMeter(value: _value / 100, size: 180)),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: PremiumStat(
            label: over ? 'חריגה מהסף' : 'תקין · תחת הסף',
            value: _value,
            unit: '/100',
            delta: _value - _threshold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: NeonBars(
            labels: const ['ערך', 'סף'],
            values: [_value, _threshold],
          ),
        ),
        if (over)
          const Padding(
            padding: EdgeInsets.all(12),
            child: AlertBanner(
              label: 'המערכת חורגת מהסף — נדרש טיפול',
              height: 46,
              radius: 14,
              accentColor: DsPure.err,
              baseColor: DsPure.raised,
              fillColor: DsPure.surface,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Slider(
            value: _value,
            max: 100,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}
