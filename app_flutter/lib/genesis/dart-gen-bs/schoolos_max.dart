// 🏫 SchoolOS Max — מערכת-הפעלה למוסד חינוכי. נבנתה ידנית מאטומי-המדף שלנו בלבד (חוק-29):
// כל יכולת פורקה לאטומים-קיימים והורכבה מהם. אפס-widget-חדש · הכל מ-dart-ui-bs.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_pure.dart';
import '../dart-ui-bs/premium/showcase/premium_stat.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/premium/dataviz/gauge_meter.dart';
import '../dart-ui-bs/premium/dataviz/progress_ring.dart';
import '../dart-ui-bs/premium/lists/avatar_tile.dart';
import '../dart-ui-bs/bar_chart.dart';
import '../dart-ui-bs/donut_chart.dart';
import '../dart-ui-bs/heat_grid.dart';
import '../dart-ui-bs/data_grid.dart';
import '../dart-ui-bs/linear_progress.dart';
import '../dart-ui-bs/animated_tabs.dart';
import '../dart-ui-bs/ds/ds_toggle_tile.dart';
import '../dart-ui-bs/gantt_bar.dart';
import '../dart-ui-bs/map_pins.dart';
import '../dart-ui-bs/radar_chart.dart';
import '../dart-ui-bs/mini_calendar.dart';
import '../dart-ui-bs/radial_gauge.dart';
import '../dart-ui-bs/step_flow.dart';
import '../dart-ui-bs/stat_tile.dart';
import '../dart-ui-bs/search_field.dart';
import '../dart-ui-bs/seg_picker.dart';
import '../dart-ui-bs/product_card.dart';
import '../dart-ui-bs/order_card.dart';
import '../dart-ui-bs/premium/lists/timeline_item.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart';
import '../dart-ui-bs/premium/lists/nav_row.dart';
import '../dart-ui-bs/premium/lists/glass_list_tile.dart';
import '../dart-ui-bs/premium/dataviz/trend_stat.dart';
import '../dart-ui-bs/premium/dataviz/neon_bars.dart';
import '../dart-ui-bs/premium/feedback/rating_stars.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';

const _acc = DsTokens.accent, _card = DsTokens.card, _fill = DsTokens.bg2, _ink = DsTokens.ink, _mut = DsTokens.muted;

void main() => runApp(const SchoolOsMaxApp());

class SchoolOsMaxApp extends StatelessWidget {
  const SchoolOsMaxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, fontFamily: 'Heebo', scaffoldBackgroundColor: DsTokens.bg, brightness: Brightness.dark, colorScheme: ColorScheme.fromSeed(seedColor: _acc, brightness: Brightness.dark)),
        builder: (c, ch) => Directionality(textDirection: TextDirection.rtl, child: ch ?? const SizedBox.shrink()),
        home: const _Home(),
      );
}

void _go(BuildContext c, Widget s) => Navigator.push(c, MaterialPageRoute(builder: (_) => s));
Widget _bar(String v) => BarChart(height: 120, bars: 7, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill, seed: v.hashCode);
Widget _wrap(List<Widget> kids, {double gap = 12}) => Wrap(spacing: gap, runSpacing: gap, children: kids);
Widget _kpi(String glyph, String value, String label) => SizedBox(width: 168, child: KpiTile(glyph: glyph, value: value, label: label));

// ═══════════════════════ בית · דשבורד-על ═══════════════════════
class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'SchoolOS Max', subtitle: 'תיכון עתיד · שנה"ל תשפ"ו', icon: '🏫',
        children: [
          // רצועת-KPI ראשית
          _wrap([
            _kpi('🎓', '1,248', 'תלמידים'),
            _kpi('✅', '96.4%', 'נוכחות היום'),
            _kpi('💰', '₪2.41M', 'גבייה שנתית'),
            _kpi('👩‍🏫', '84', 'סגל הוראה'),
            _kpi('🚨', '7', 'התראות פתוחות'),
            _kpi('📚', '312', 'שיעורים השבוע'),
          ]),
          const SizedBox(height: 8),
          DsSection(title: 'מבט-על · אנליטיקה', trailing: const DsChip(label: 'חי', tone: 1), children: [
            _wrap([
              _panel('נוכחות שבועית', _bar('att'), 320),
              _panel('פילוח ציונים', DonutChart(height: 130, slices: 5, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill, seed: 3), 200),
              _panel('שיעור גבייה', Center(child: GaugeMeter(value: 0.82, size: 130)), 200),
            ]),
            const SizedBox(height: 12),
            _panel('מפת-חום נוכחות · 6 חודשים', HeatGrid(height: 120, cells: 90, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill, seed: 9), double.infinity),
          ]),
          DsSection(title: 'דורש-טיפול', children: [
            _alert('🔴', 'תשלומים באיחור', '23 משפחות · ₪184,500', DsTokens.magenta),
            _alert('🟠', 'תלמידים בסיכון נשירה', '11 תלמידים · זוהו ע"י AI', DsTokens.cyan),
            _alert('🟡', 'אישורים ממתינים', '9 בקשות חופשה/החלפה', DsTokens.accent),
          ]),
          DsSection(title: 'מודולים · המערכת המלאה', children: [
            _wrap([
              _mod(context, '📝', 'קבלה ורישום', 'לידים · מיון · שיבוץ', const _Admissions()),
              _mod(context, '🎓', 'תלמידים', 'פרופיל · אחים · היסטוריה', const _StudentProfile()),
              _mod(context, '✅', 'נוכחות', 'סימון כיתה בטאפ', const _Attendance()),
              _mod(context, '📊', 'ציונים', 'גיליון-מטריצה', const _Gradebook()),
              _mod(context, '🗓️', 'מערכת שעות', 'לוח שבועי', const _Timetable()),
              _mod(context, '💰', 'כספים וגבייה', 'שכ"ל · חובות · קבלות', const _Finance()),
              _mod(context, '✔️', 'אישורים', 'workflow · SLA', const _Approvals()),
              _mod(context, '💬', 'תקשורת', 'הורים · מורים · WhatsApp', const _Communication()),
              _mod(context, '📚', 'LMS ולמידה', 'שיעורים · מטלות · מבחנים', const _Lms()),
              _mod(context, '🧑‍💼', 'כוח אדם ושכר', 'HR · תלושים · הערכות', const _Hr()),
              _mod(context, '🚌', 'תחבורה', 'מסלולים · נהגים · GPS', const _Transport()),
              _mod(context, '📖', 'ספרייה', 'קטלוג · השאלה · קנסות', const _Library()),
              _mod(context, '💻', 'מלאי וציוד', 'מחשבים · מעבדות · רכש', const _Inventory()),
              _mod(context, '🏢', 'מתקנים ובטיחות', 'תחזוקה · חדרים · מצלמות', const _Facilities()),
              _mod(context, '🍽️', 'קפיטריה', 'תפריטים · רגישויות', const _Cafeteria()),
              _mod(context, '🏥', 'בריאות ואחות', 'טיפולים · חיסונים', const _Health()),
              _mod(context, '🤖', 'AI ואנליטיקה', 'סיכון · תחזיות · המלצות', const _Analytics()),
              _mod(context, '🎉', 'אירועים וקהילה', 'טקסים · בוגרים · ימי הורים', const _Events()),
              _mod(context, '🔐', 'הרשאות וארגון', 'RBAC · רב-סניפי · audit', const _Rbac()),
              _mod(context, '🔌', 'אינטגרציות ו-API', 'מובייל · אופליין · ייצוא', const _Integrations()),
            ]),
          ]),
        ],
      );
}

Widget _panel(String title, Widget body, double w) => Container(
      width: w, padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: DsPure.hair)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(color: _mut, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12), body,
      ]),
    );

Widget _alert(String glyph, String title, String sub, Color tone) => Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: DsPure.hair)),
      child: Row(children: [
        Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: tone.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)), child: Text(glyph, style: const TextStyle(fontSize: 18))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: _ink, fontSize: 14.5, fontWeight: FontWeight.w700)),
          Text(sub, style: const TextStyle(color: _mut, fontSize: 12.5)),
        ])),
        Icon(Icons.chevron_left, color: _mut),
      ]),
    );

Widget _mod(BuildContext c, String glyph, String title, String sub, Widget screen) =>
    SizedBox(width: 250, child: DsNavTile(glyph: glyph, title: title, sub: sub, onTap: () => _go(c, screen)));

// ═══════════════════════ נוכחות · גריד-סימון (workflow אמיתי) ═══════════════════════
class _Attendance extends StatefulWidget {
  const _Attendance();
  @override
  State<_Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<_Attendance> {
  final _names = const ['אבי כהן', 'נועה לוי', 'יונתן מזרחי', 'שירה פרץ', 'איתי דהן', 'מאיה ביטון', 'עומר אזולאי', 'תמר גבאי', 'רון שמעוני', 'ליאור אוחיון', 'הדר נחום', 'גיא אברהם'];
  late final Map<int, bool> _present = {for (var i = 0; i < _names.length; i++) i: true};
  @override
  Widget build(BuildContext context) {
    final here = _present.values.where((v) => v).length;
    return DsScaffold(
      title: 'נוכחות · כיתה י\'-3', subtitle: 'שיעור מתמטיקה · יום ג\' 08:00', icon: '✅',
      children: [
        _wrap([_kpi('👥', '${_names.length}', 'בכיתה'), _kpi('✅', '$here', 'נוכחים'), _kpi('❌', '${_names.length - here}', 'נעדרים')]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: DsPrimaryButton(label: 'סמן הכל נוכח', onTap: () => setState(() { for (final k in _present.keys) { _present[k] = true; } }))),
          const SizedBox(width: 10),
          const DsChip(label: 'שמור', tone: 1),
        ]),
        const SizedBox(height: 12),
        DsSection(title: 'רשימת התלמידים · טאפ = נוכח/נעדר', children: [
          for (var i = 0; i < _names.length; i++)
            DsToggleTile(label: _names[i], value: _present[i]! ? 'נוכח' : 'נעדר', onChanged: (_) => setState(() => _present[i] = !_present[i]!)),
        ]),
      ],
    );
  }
}

// ═══════════════════════ גיליון-ציונים · מטריצה ═══════════════════════
class _Gradebook extends StatelessWidget {
  const _Gradebook();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'גיליון ציונים · כיתה י\'-3', subtitle: '5 מקצועות · ממוצע כיתתי 84.2', icon: '📊',
        children: [
          _wrap([_kpi('🏆', '96', 'מצטיינת'), _kpi('📈', '84.2', 'ממוצע'), _kpi('⚠️', '4', 'נכשלים')]),
          const SizedBox(height: 8),
          _panel('מטריצת ציונים · תלמידים × מקצועות', DataGrid(height: 260, rows: 8, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill), double.infinity),
          const SizedBox(height: 12),
          DsSection(title: 'ממוצע לפי מקצוע', children: [
            for (final s in const ['מתמטיקה 82', 'אנגלית 88', 'לשון 79', 'פיזיקה 85', 'היסטוריה 87'])
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                SizedBox(width: 90, child: Text(s.split(' ')[0], style: const TextStyle(color: _ink, fontSize: 13.5))),
                Expanded(child: LinearProgress(height: 10, radius: 8, accentColor: _acc, baseColor: _card, fillColor: _fill)),
                const SizedBox(width: 10), Text(s.split(' ')[1], style: const TextStyle(color: _mut, fontSize: 13)),
              ])),
          ]),
        ],
      );
}

// ═══════════════════════ מערכת-שעות · לוח שבועי ═══════════════════════
class _Timetable extends StatelessWidget {
  const _Timetable();
  static const _days = ['א', 'ב', 'ג', 'ד', 'ה'];
  static const _subj = ['מתמטיקה', 'אנגלית', 'לשון', 'פיזיקה', 'היסטוריה', 'חנ"ג', 'אמנות', 'מדעים'];
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'מערכת שעות · כיתה י\'-3', subtitle: '5 ימים · 8 שיעורים ביום', icon: '🗓️',
        children: [
          _panel('לוח שבועי', Column(children: [
            Row(children: [const SizedBox(width: 34), for (final d in _days) Expanded(child: Center(child: Text(d, style: const TextStyle(color: _mut, fontSize: 12, fontWeight: FontWeight.w700))))]),
            const SizedBox(height: 8),
            for (var h = 0; h < 6; h++)
              Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                SizedBox(width: 34, child: Text('${h + 1}', style: const TextStyle(color: _mut, fontSize: 11))),
                for (var d = 0; d < 5; d++)
                  Expanded(child: Container(height: 34, margin: const EdgeInsets.symmetric(horizontal: 2), alignment: Alignment.center,
                      decoration: BoxDecoration(color: _acc.withValues(alpha: 0.10 + ((h + d) % 3) * 0.06), borderRadius: BorderRadius.circular(8), border: Border.all(color: DsPure.hair)),
                      child: Text(_subj[(h * 3 + d) % _subj.length], overflow: TextOverflow.ellipsis, style: const TextStyle(color: _ink, fontSize: 10)))),
              ])),
          ]), double.infinity),
        ],
      );
}

// ═══════════════════════ כרטיס-תלמיד מאוחד · טאבים ═══════════════════════
class _StudentProfile extends StatelessWidget {
  const _StudentProfile();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'כרטיס תלמיד', subtitle: 'מבט 360°', icon: '🎓',
        children: [
          const AvatarTile(initials: 'נל', title: 'נועה לוי · כיתה י\'-3', subtitle: 'ת"ז 328845112 · גיל 16 · מחזור תשפ"ו'),
          const SizedBox(height: 12),
          _wrap([_kpi('📈', '89.4', 'ממוצע'), _kpi('✅', '97%', 'נוכחות'), _kpi('💰', 'שולם', 'שכ"ל'), _kpi('⭐', '4', 'חוגים')]),
          const SizedBox(height: 8),
          AnimatedTabs(labels: const ['ציונים', 'נוכחות', 'תשלומים', 'משמעת', 'משפחה'], height: 44, radius: 12, accentColor: _acc, baseColor: _card, fillColor: _fill),
          const SizedBox(height: 12),
          DsSection(title: 'ציונים אחרונים', children: [
            for (final g in const ['מתמטיקה · מבחן · 92', 'אנגלית · עבודה · 88', 'פיזיקה · מבחן · 85', 'לשון · בוחן · 79'])
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
                Expanded(child: Text(g.split(' · ').take(2).join(' · '), style: const TextStyle(color: _ink, fontSize: 13.5))),
                Text(g.split(' · ').last, style: const TextStyle(color: _acc, fontSize: 15, fontWeight: FontWeight.w800)),
              ])),
          ]),
          _panel('התקדמות שנתית', Center(child: ProgressRing(value: 0.89, label: '89%', size: 120)), 200),
        ],
      );
}

// ═══════════════════════ כספים · דשבורד ═══════════════════════
class _Finance extends StatelessWidget {
  const _Finance();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'כספים וגבייה', subtitle: 'שנה"ל תשפ"ו · תקציב ₪2.9M', icon: '💰',
        children: [
          _wrap([
            SizedBox(width: 200, child: PremiumStat(label: 'נגבה', value: 2.41, unit: 'M₪', delta: 12, glyph: '💰')),
            SizedBox(width: 200, child: PremiumStat(label: 'חוב פתוח', value: 184, unit: 'K₪', delta: -8, glyph: '⚠️')),
            SizedBox(width: 200, child: PremiumStat(label: 'מלגות', value: 97, unit: '', delta: 5, glyph: '🎓')),
          ]),
          const SizedBox(height: 8),
          DsSection(title: 'גבייה חודשית', children: [_bar('fin')]),
          DsSection(title: 'פילוח הכנסות', children: [DonutChart(height: 150, slices: 6, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill, seed: 7)]),
          DsSection(title: 'יעד גבייה', children: [
            for (final s in const ['שכר לימוד 82%', 'הסעות 91%', 'קפיטריה 74%', 'חוגים 88%'])
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
                SizedBox(width: 90, child: Text(s.split(' ').first, style: const TextStyle(color: _ink, fontSize: 13))),
                Expanded(child: LinearProgress(height: 10, radius: 8, accentColor: _acc, baseColor: _card, fillColor: _fill)),
                const SizedBox(width: 10), Text(s.split(' ').last, style: const TextStyle(color: _mut, fontSize: 12.5)),
              ])),
          ]),
        ],
      );
}

// ═══════════════════════ מרכז אישורים · workflow ═══════════════════════
class _Approvals extends StatelessWidget {
  const _Approvals();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'מרכז אישורים', subtitle: '9 בקשות ממתינות · SLA 24ש\'', icon: '✔️',
        children: [
          const DsWorkflow(steps: ['הוגש', 'מחנך', 'רכז', 'מנהל', 'אושר'], current: 2),
          const SizedBox(height: 16),
          for (final r in const [
            ['בקשת חופשה · מורה', 'רונית ג. · 3 ימים'],
            ['החלפת שיעור', 'דוד מ. ⇄ שרה ל.'],
            ['אישור טיול', 'כיתה ח\'-2 · מוזיאון'],
            ['הנחת שכר לימוד', 'משפחת ביטון · 30%'],
          ])
            _approval(r[0], r[1]),
        ],
      );
  Widget _approval(String title, String sub) => Container(
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(14), border: Border.all(color: DsPure.hair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(title, style: const TextStyle(color: _ink, fontSize: 14.5, fontWeight: FontWeight.w700)),
          Text(sub, style: const TextStyle(color: _mut, fontSize: 12.5)),
          const SizedBox(height: 12),
          Row(children: [
            const Expanded(child: DsPrimaryButton(label: 'אשר')),
            const SizedBox(width: 10),
            Expanded(child: Container(height: 42, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: DsPure.hair)), child: Text('דחה', style: const TextStyle(color: _mut, fontWeight: FontWeight.w700)))),
          ]),
        ]),
      );
}

// ═══════════════════════ קבלה ורישום · pipeline לידים ═══════════════════════
class _Admissions extends StatelessWidget {
  const _Admissions();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'קבלה ורישום', subtitle: '48 מועמדים פעילים · מחזור תשפ"ז', icon: '📝',
        children: [
          SearchField(hint: 'חיפוש מועמד · ת"ז · טלפון', height: 48, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill),
          const SizedBox(height: 12),
          _wrap([_kpi('📥', '48', 'לידים'), _kpi('🎤', '19', 'בראיון'), _kpi('✅', '31', 'התקבלו'), _kpi('⏳', '6', 'המתנה')]),
          const SizedBox(height: 8),
          _panel('שלבי המשפך', StepFlow(height: 90, steps: 6, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill), double.infinity),
          const SizedBox(height: 12),
          DsSection(title: 'מועמדים אחרונים · לפי שלב', children: [
            _cand('דניאל אזולאי', 'טופס נשלח · ממתין לראיון', 1),
            _cand('יעל בן-דוד', 'ראיון נקבע · 12/09', 2),
            _cand('אורי כץ', 'מבחן מיון · עבר 88', 3),
            _cand('נועם שרון', 'התקבל · שובץ י\'-2', 4),
            _cand('שי לוגסי', 'רשימת המתנה · #3', 0),
          ]),
        ],
      );
  Widget _cand(String name, String stage, int tone) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: GlassListTile(title: name, subtitle: stage, trailing: const ['המתנה', 'ליד', 'ראיון', 'מיון', 'התקבל'][tone]),
      );
}

// ═══════════════════════ מרכז תקשורת · רב-ערוצי ═══════════════════════
class _Communication extends StatelessWidget {
  const _Communication();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'מרכז תקשורת', subtitle: 'הורים · מורים · תלמידים · רב-ערוצי', icon: '💬',
        children: [
          SegPicker(labels: const ['הכל', 'WhatsApp', 'SMS', 'מייל', 'דחיפה'], height: 46, radius: 12, accentColor: _acc, baseColor: _card, fillColor: _fill),
          const SizedBox(height: 12),
          const AlertBanner(message: 'הודעת חירום נשלחה ל-1,248 הורים · אישור קריאה 71%', tone: 2, glyph: '🚨'),
          const SizedBox(height: 12),
          _wrap([_kpi('📤', '3,412', 'נשלחו החודש'), _kpi('👁', '71%', 'נקראו'), _kpi('↩️', '284', 'תגובות')]),
          const SizedBox(height: 8),
          DsSection(title: 'תבניות מהירות', children: [
            _wrap([
              const DsChip(label: '📅 תזכורת אסיפה', tone: 0),
              const DsChip(label: '💰 תזכורת תשלום', tone: 3),
              const DsChip(label: '🎉 ברכת חג', tone: 1),
              const DsChip(label: '⚠️ היעדרות', tone: 2),
            ]),
          ]),
          DsSection(title: 'פיד הודעות', children: [
            const TimelineItem(title: 'משפחת כהן · אישרה הגעה לאסיפה', time: 'לפני 4 דק\''),
            const TimelineItem(title: 'קבוצת י\'-3 · הודעה על טיול', time: 'לפני 22 דק\''),
            const TimelineItem(title: 'הורי א\'-1 · סקר שביעות רצון', time: 'לפני שעה'),
            const TimelineItem(title: 'צוות מורים · עדכון מערכת', time: 'לפני 3 שע\''),
          ]),
        ],
      );
}

// ═══════════════════════ LMS · שיעורים ומטלות ═══════════════════════
class _Lms extends StatelessWidget {
  const _Lms();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'LMS · מרחב למידה', subtitle: '42 קורסים פעילים · 1,248 לומדים', icon: '📚',
        children: [
          _wrap([_kpi('📚', '42', 'קורסים'), _kpi('📝', '318', 'מטלות'), _kpi('✅', '87%', 'הגשות'), _kpi('🎯', '4.6', 'דירוג')]),
          const SizedBox(height: 8),
          DsSection(title: 'קורסים מובילים', children: [
            _wrap([
              _course('מתמטיקה 5 יח\'', 'ד"ר כהן · 32 לומדים', 5),
              _course('אנגלית מתקדמים', 'מר לוי · 28 לומדים', 4),
              _course('פיזיקה', 'גב\' מזרחי · 24 לומדים', 5),
            ]),
          ]),
          DsSection(title: 'התקדמות יחידות', children: const [
            StatRow(label: 'אלגברה · יחידה 3', value: '82%', fraction: 0.82),
            StatRow(label: 'גיאומטריה · יחידה 2', value: '64%', fraction: 0.64),
            StatRow(label: 'טריגונומטריה', value: '41%', fraction: 0.41),
          ]),
        ],
      );
  Widget _course(String t, String s, int stars) => SizedBox(width: 230, child: Column(children: [
        ProductCard(title: t, sub: s, height: 132, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill),
        RatingStars(value: stars.toDouble(), size: 16),
      ]));
}

// ═══════════════════════ כוח אדם ושכר · HR ═══════════════════════
class _Hr extends StatelessWidget {
  const _Hr();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'כוח אדם ושכר', subtitle: '84 עובדים · 71 מורים · 13 מנהלה', icon: '🧑‍💼',
        children: [
          _wrap([
            const SizedBox(width: 210, child: TrendStat(value: '84', delta: 3, label: 'סה"כ עובדים')),
            const SizedBox(width: 210, child: TrendStat(value: '₪412K', delta: 2, label: 'שכר חודשי')),
            const SizedBox(width: 210, child: TrendStat(value: '96%', delta: 5, label: 'שביעות רצון')),
          ]),
          const SizedBox(height: 8),
          DsSection(title: 'סגל הוראה', children: const [
            AvatarTile(initials: 'רכ', title: 'רונית כהן · רכזת מתמטיקה', subtitle: '12 שנות ותק · דירוג מצוין'),
            SizedBox(height: 8),
            AvatarTile(initials: 'דל', title: 'דוד לוי · מחנך י\'-3', subtitle: '8 שנות ותק · 3 חופשות ניצול'),
            SizedBox(height: 8),
            AvatarTile(initials: 'שמ', title: 'שרה מזרחי · יועצת', subtitle: '15 שנות ותק · הערכה השבוע'),
          ]),
          DsSection(title: 'התפלגות תפקידים', children: [
            NeonBars(labels: const ['מורים', 'מנהלה', 'סייעות', 'תחזוקה'], values: const [71, 13, 18, 6]),
          ]),
        ],
      );
}

// ═══════════════════════ תחבורה · מסלולים חיים ═══════════════════════
class _Transport extends StatelessWidget {
  const _Transport();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'תחבורה והסעות', subtitle: '14 מסלולים · 9 נהגים · GPS חי', icon: '🚌',
        children: [
          _wrap([_kpi('🚌', '14', 'מסלולים'), _kpi('👨‍✈️', '9', 'נהגים'), _kpi('🎒', '386', 'נוסעים'), _kpi('⏱️', '4', 'באיחור')]),
          const SizedBox(height: 8),
          _panel('מפה חיה · מיקום אוטובוסים', MapPins(height: 200, pins: 8, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill), double.infinity),
          const SizedBox(height: 12),
          _panel('לוח זמנים · מסלולים', GanttBar(height: 180, rows: 6, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill), double.infinity),
          const SizedBox(height: 12),
          DsSection(title: 'מסלולים', children: [
            NavRow(glyph: '🚌', title: 'קו 1 · צפון העיר', sub: '32 תלמידים · בזמן', onTap: () {}),
            NavRow(glyph: '🚌', title: 'קו 2 · מרכז', sub: '28 תלמידים · איחור 6 דק\'', onTap: () {}),
            NavRow(glyph: '🚌', title: 'קו 3 · דרום', sub: '35 תלמידים · בזמן', onTap: () {}),
          ]),
        ],
      );
}

// ═══════════════════════ ספרייה · קטלוג והשאלות ═══════════════════════
class _Library extends StatelessWidget {
  const _Library();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'ספרייה', subtitle: '8,420 כותרים · 312 בהשאלה', icon: '📖',
        children: [
          SearchField(hint: 'חיפוש כותר · מחבר · ISBN', height: 48, radius: 14, accentColor: _acc, baseColor: _card, fillColor: _fill),
          const SizedBox(height: 12),
          _wrap([_kpi('📚', '8,420', 'כותרים'), _kpi('📤', '312', 'בהשאלה'), _kpi('⏰', '18', 'באיחור'), _kpi('💸', '₪240', 'קנסות')]),
          const SizedBox(height: 8),
          DsSection(title: 'מומלצים החודש', children: [
            _wrap([
              ProductCard(title: 'ההיסטוריה של הכל', sub: 'זמין · 3 עותקים', height: 140, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill),
              ProductCard(title: 'מבוא לפיזיקה', sub: 'בהשאלה · חוזר 14/09', height: 140, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill),
            ]),
          ]),
          DsSection(title: 'השאלות פעילות', children: const [
            GlassListTile(title: 'נועה לוי · מתמטיקה בדידה', subtitle: 'הושאל 01/09 · חוזר 15/09', trailing: 'בזמן'),
            SizedBox(height: 8),
            GlassListTile(title: 'איתי דהן · יסודות הכימיה', subtitle: 'הושאל 20/08 · באיחור 4 ימים', trailing: 'קנס ₪12'),
          ]),
        ],
      );
}

// ═══════════════════════ מלאי וציוד ═══════════════════════
class _Inventory extends StatelessWidget {
  const _Inventory();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'מלאי וציוד', subtitle: 'מחשבים · מעבדות · רכש', icon: '💻',
        children: [
          _wrap([
            const StatTile(value: '412', label: 'פריטים', surfaceColor: _card, inkColor: _ink, mutedColor: _mut, radius: 16),
            const StatTile(value: '38', label: 'למעבדה', surfaceColor: _card, inkColor: _ink, mutedColor: _mut, radius: 16),
            const StatTile(value: '7', label: 'בתיקון', surfaceColor: _card, inkColor: _ink, mutedColor: _mut, radius: 16),
            const StatTile(value: '5', label: 'חסר במלאי', surfaceColor: _card, inkColor: _ink, mutedColor: _mut, radius: 16),
          ]),
          const SizedBox(height: 8),
          DsSection(title: 'רמות מלאי', children: const [
            StatRow(label: 'מחשבים ניידים', value: '86/100', fraction: 0.86),
            StatRow(label: 'מקרנים', value: '22/30', fraction: 0.73),
            StatRow(label: 'ערכות מעבדה', value: '14/40', fraction: 0.35),
            StatRow(label: 'ציוד ספורט', value: '58/60', fraction: 0.96),
          ]),
          DsSection(title: 'בקשות רכש', children: [
            NavRow(glyph: '🛒', title: 'ערכות רובוטיקה × 10', sub: 'ממתין לאישור · ₪18,400', onTap: () {}),
            NavRow(glyph: '🛒', title: 'החלפת מקרנים × 4', sub: 'אושר · בהזמנה', onTap: () {}),
          ]),
        ],
      );
}

// ═══════════════════════ מתקנים ובטיחות ═══════════════════════
class _Facilities extends StatelessWidget {
  const _Facilities();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'מתקנים ובטיחות', subtitle: 'תחזוקה · חדרים · בטיחות', icon: '🏢',
        children: [
          _wrap([_kpi('🚪', '48', 'חדרים'), _kpi('🔧', '6', 'קריאות פתוחות'), _kpi('🛡️', '100%', 'ציוד כיבוי'), _kpi('👤', '23', 'מבקרים היום')]),
          const SizedBox(height: 8),
          const AlertBanner(message: 'תרגיל פינוי מתוכנן ליום ה\' 10:00 · כל הכיתות', tone: 1, glyph: '🔔'),
          const SizedBox(height: 12),
          DsSection(title: 'קריאות שירות פתוחות', children: const [
            GlassListTile(title: 'מזגן · כיתה ח\'-2', subtitle: 'נפתח היום · דחיפות בינונית', trailing: 'פתוח'),
            SizedBox(height: 8),
            GlassListTile(title: 'נזילה · שירותי קומה 2', subtitle: 'נפתח אתמול · דחוף', trailing: 'בטיפול'),
            SizedBox(height: 8),
            GlassListTile(title: 'תאורה · מסדרון מזרחי', subtitle: 'נפתח 28/08', trailing: 'ממתין'),
          ]),
        ],
      );
}

// ═══════════════════════ קפיטריה · הזמנות ═══════════════════════
class _Cafeteria extends StatelessWidget {
  const _Cafeteria();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'קפיטריה', subtitle: 'תפריטים · הזמנות · רגישויות', icon: '🍽️',
        children: [
          _wrap([_kpi('🍽️', '842', 'ארוחות היום'), _kpi('🥗', '3', 'תפריטים'), _kpi('⚠️', '47', 'רגישויות'), _kpi('💳', '₪4,210', 'מכירות')]),
          const SizedBox(height: 8),
          DsSection(title: 'הזמנות פעילות', children: [
            _wrap([
              OrderCard(stageLabel: 'בהכנה', itemsLabel: 'י\'-3 · 28 מנות', sumLabel: '₪140', onTap: () {}, cardColor: _card, inkColor: _ink, mutedColor: _mut, borderColor: DsPure.hair, radius: 16, width: 220),
              OrderCard(stageLabel: 'מוכן', itemsLabel: 'ח\'-1 · 24 מנות', sumLabel: '₪120', onTap: () {}, cardColor: _card, inkColor: _ink, mutedColor: _mut, borderColor: DsPure.hair, radius: 16, width: 220),
              OrderCard(stageLabel: 'נמסר', itemsLabel: 'ט\'-2 · 30 מנות', sumLabel: '₪150', onTap: () {}, cardColor: _card, inkColor: _ink, mutedColor: _mut, borderColor: DsPure.hair, radius: 16, width: 220),
            ]),
          ]),
          DsSection(title: 'תפריט היום', children: const [
            StatRow(label: 'צמחוני', value: '312', fraction: 0.37),
            StatRow(label: 'בשרי', value: '418', fraction: 0.50),
            StatRow(label: 'ללא גלוטן', value: '112', fraction: 0.13),
          ]),
        ],
      );
}

// ═══════════════════════ בריאות ואחות ═══════════════════════
class _Health extends StatelessWidget {
  const _Health();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'בריאות ואחות', subtitle: 'ביקורים · חיסונים · רגישויות', icon: '🏥',
        children: [
          _wrap([_kpi('🏥', '14', 'ביקורים היום'), _kpi('💉', '96%', 'מחוסנים'), _kpi('⚠️', '47', 'רגישויות'), _kpi('💊', '9', 'תרופות קבועות')]),
          const SizedBox(height: 8),
          const AlertBanner(message: '3 תלמידים עם אלרגיה חמורה לאגוזים · פרוטוקול חירום פעיל', tone: 3, glyph: '⚠️'),
          const SizedBox(height: 12),
          DsSection(title: 'ביקורים אחרונים', children: const [
            TimelineItem(title: 'שירה פרץ · כאב ראש · נמדד חום 37.2', time: '09:14'),
            TimelineItem(title: 'עומר אזולאי · חבלה קלה בברך · טופל', time: '08:40'),
            TimelineItem(title: 'תמר גבאי · מתן תרופה קבועה', time: '08:05'),
          ]),
        ],
      );
}

// ═══════════════════════ AI ואנליטיקה · מודיעין ═══════════════════════
class _Analytics extends StatelessWidget {
  const _Analytics();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'AI ואנליטיקה', subtitle: 'זיהוי סיכון · תחזיות · המלצות', icon: '🤖',
        children: [
          _wrap([_kpi('🎯', '94%', 'דיוק חיזוי'), _kpi('🚨', '11', 'בסיכון גבוה'), _kpi('📉', '2.1%', 'נשירה חזויה'), _kpi('💡', '38', 'המלצות')]),
          const SizedBox(height: 8),
          _wrap([
            _panel('מדד בריאות מוסדי', RadialGauge(height: 180, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill), 260),
            _panel('פרופיל כיתה · 6 מדדים', RadarChart(height: 180, axes: 6, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill, seed: 5), 260),
          ]),
          const SizedBox(height: 12),
          _panel('מגמת ביצועים · 12 חודשים', NeonBars(labels: const ['ס', 'א', 'נ', 'ד', 'י', 'פ', 'מ', 'א', 'מ', 'י', 'י', 'א'], values: const [72, 74, 78, 81, 79, 83, 85, 84, 88, 86, 90, 92]), double.infinity),
          const SizedBox(height: 12),
          DsSection(title: 'תלמידים בסיכון · זוהו ע"י המנוע', children: const [
            GlassListTile(title: 'רון שמעוני · י\'-1', subtitle: 'ירידה בציונים + היעדרויות · ציון סיכון 84', trailing: 'גבוה'),
            SizedBox(height: 8),
            GlassListTile(title: 'ליאור אוחיון · ט\'-3', subtitle: 'שינוי דפוס נוכחות · ציון סיכון 71', trailing: 'בינוני'),
            SizedBox(height: 8),
            GlassListTile(title: 'הדר נחום · ח\'-2', subtitle: 'אירועי משמעת · ציון סיכון 63', trailing: 'בינוני'),
          ]),
        ],
      );
}

// ═══════════════════════ אירועים וקהילה ═══════════════════════
class _Events extends StatelessWidget {
  const _Events();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'אירועים וקהילה', subtitle: 'טקסים · ימי הורים · בוגרים', icon: '🎉',
        children: [
          _wrap([_kpi('📅', '12', 'אירועים החודש'), _kpi('👨‍👩‍👧', '3', 'ימי הורים'), _kpi('🎓', '218', 'בוגרים'), _kpi('⭐', '4.7', 'שביעות רצון')]),
          const SizedBox(height: 8),
          _panel('לוח אירועים', MiniCalendar(height: 220, radius: 16, accentColor: _acc, baseColor: _card, fillColor: _fill), double.infinity),
          const SizedBox(height: 12),
          DsSection(title: 'אירועים קרובים', children: const [
            TimelineItem(title: 'טקס פתיחת שנה · אולם ראשי', time: 'מחר 09:00'),
            TimelineItem(title: 'יום הורים · שכבה י\'', time: 'ה\' 17:00'),
            TimelineItem(title: 'הרצאה: בטיחות ברשת', time: '15/09 18:30'),
          ]),
          DsSection(title: 'משוב אירועים', children: const [
            RatingStars(value: 4.7, size: 22),
          ]),
        ],
      );
}

// ═══════════════════════ הרשאות וארגון · RBAC ═══════════════════════
class _Rbac extends StatelessWidget {
  const _Rbac();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'הרשאות וארגון', subtitle: 'RBAC · רב-סניפי · audit log', icon: '🔐',
        children: [
          _wrap([_kpi('👥', '142', 'משתמשים'), _kpi('🎭', '8', 'תפקידים'), _kpi('🏫', '3', 'סניפים'), _kpi('📋', '2,841', 'רשומות audit')]),
          const SizedBox(height: 8),
          DsSection(title: 'תפקידים והרשאות', children: [
            NavRow(glyph: '👑', title: 'מנהל-על', sub: 'גישה מלאה · 2 משתמשים', onTap: () {}),
            NavRow(glyph: '🎓', title: 'מנהל פדגוגי', sub: 'ציונים · נוכחות · דוחות', onTap: () {}),
            NavRow(glyph: '👩‍🏫', title: 'מורה', sub: 'כיתות משויכות בלבד', onTap: () {}),
            NavRow(glyph: '👨‍👩‍👧', title: 'הורה', sub: 'צפייה בילדים · תשלומים', onTap: () {}),
          ]),
          DsSection(title: 'יומן ביקורת · פעולות אחרונות', children: const [
            TimelineItem(title: 'רונית כהן · עדכנה ציון · מתמטיקה י\'-3', time: '09:22', body: 'IP 10.0.4.18'),
            TimelineItem(title: 'מנהל-על · שינה הרשאת תפקיד "יועץ"', time: '08:55', body: 'סניף מרכז'),
            TimelineItem(title: 'דוד לוי · ייצא דוח נוכחות', time: '08:12'),
          ]),
        ],
      );
}

// ═══════════════════════ אינטגרציות ו-API ═══════════════════════
class _Integrations extends StatelessWidget {
  const _Integrations();
  @override
  Widget build(BuildContext context) => DsScaffold(
        title: 'אינטגרציות ו-API', subtitle: 'מובייל · אופליין · webhooks · ייצוא', icon: '🔌',
        children: [
          _wrap([_kpi('🔑', '6', 'API keys'), _kpi('🔗', '11', 'webhooks'), _kpi('📱', '892', 'מכשירים'), _kpi('🔄', 'חי', 'סנכרון')]),
          const SizedBox(height: 8),
          DsSection(title: 'שירותים מחוברים', children: const [
            GlassListTile(title: 'משרד החינוך · מנב"סנט', subtitle: 'סנכרון יומי · תקין', trailing: 'מחובר'),
            SizedBox(height: 8),
            GlassListTile(title: 'מערכת סליקה · חשבונית ירוקה', subtitle: 'תשלומים בזמן אמת', trailing: 'מחובר'),
            SizedBox(height: 8),
            GlassListTile(title: 'WhatsApp Business API', subtitle: 'הודעות יוצאות', trailing: 'מחובר'),
            SizedBox(height: 8),
            GlassListTile(title: 'Google Workspace', subtitle: 'SSO · יומן · Drive', trailing: 'מחובר'),
          ]),
          DsSection(title: 'סטטוס מערכת', children: const [
            StatRow(label: 'זמינות (uptime)', value: '99.97%', fraction: 0.9997),
            StatRow(label: 'סנכרון אופליין', value: 'תקין', fraction: 1.0),
          ]),
        ],
      );
}
