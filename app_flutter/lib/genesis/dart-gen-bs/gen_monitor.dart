// ✨ ניסוי-הרכבה (L29 מלא) — "מוניטור-מערכת" מ-3 אטומים, שאף אחד מהם אינו מוניטור לבדו.
// הצורך: "לנטר מערכת ולקבל התראה כשחורגת מהסף". פירוק (§20-ב/L29):
//   פעולת-יסוד: השוואה (value > threshold) — קיימת · חיווט: מצב+setState+תנאי.
//   3 אטומי-תצוגה (כולם בעלי תפר-דאטה אמיתי — §20-ג): DsStat (קריאה+סטטוס) · DsBars (ערך מול
//   סף) · AlertBanner (התראה-מותנית). ההשוואה האחת מזינה את שלושתם ⇒ נולד מוניטור.
// הערה (§20-ג · פסילה מתועדת): RadialGauge נשקל ונפסל — אין לו פרמטר-ערך (אפס-דאטה, מנפיש
// ערך-מחזורי פנימי) ⇒ להראות בו את הערך = זיוף. לכן הוחלף באטום בעל-תפר.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_bars.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/alert_banner.dart';

void main() => runApp(
      const MaterialApp(debugShowCheckedModeBanner: false, home: GenMonitorScreen()),
    );

class GenMonitorScreen extends StatefulWidget {
  const GenMonitorScreen({super.key});
  @override
  State<GenMonitorScreen> createState() => _GenMonitorScreenState();
}

class _GenMonitorScreenState extends State<GenMonitorScreen> {
  double _value = 42;
  final double _threshold = 70;

  @override
  Widget build(BuildContext context) {
    // ← פעולת-היסוד היחידה: השוואה. זו הליבה שמחווטת את שלושת האטומים יחד.
    final bool over = _value > _threshold;
    final String t = _threshold.toStringAsFixed(0);
    return DsScaffold(
      title: 'מוניטור מערכת',
      subtitle: 'ניטור עם התראה · הרכבת 3 אטומים',
      icon: '📟',
      children: [
        DsSection(title: 'מצב', children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DsStat(
              label: 'ערך נוכחי',
              value: _value.toStringAsFixed(0),
              sub: over ? 'חריגה מהסף ($t)' : 'תקין · סף $t',
              glyph: over ? '⚠️' : '✅',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DsBars(
              title: 'ערך מול סף',
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
        ]),
      ],
    );
  }
}
