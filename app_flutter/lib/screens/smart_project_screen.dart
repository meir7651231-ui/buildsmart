// פרויקט חכם SCREEN (T3.B · proto §7 [L7348-7600]) — "מאפס עד מסירה": the
// active site's project as a flat list of day-stages. Each day-stage is
// independently markable done (progress = done/9 with the seed), each card
// expands to its steps (also markable), and a day-picker jumps to any day.
// All state is the live `smartProjectProvider` (done-marking Set, see
// state/smart_project_engine.dart) — the same pattern as stage_progress.dart.
// Title follows the active project name (proto :7438). Strings verbatim (R6/R8).
//
// Entry: openSmartProject (the leaf action) → SmartProjectScreen.route().

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/projects_engine.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the פרויקט חכם screen — the wire target for `openSmartProject`.
void openSmartProject(BuildContext context) =>
    Navigator.of(context).push(SmartProjectScreen.route());

class SmartProjectScreen extends ConsumerStatefulWidget {
  const SmartProjectScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const SmartProjectScreen());

  @override
  ConsumerState<SmartProjectScreen> createState() => _SmartProjectScreenState();
}

class _SmartProjectScreenState extends ConsumerState<SmartProjectScreen> {
  String? _expanded; // expanded day-stage key (proto `expandedStage`)
  final _scroll = ScrollController();
  final List<GlobalKey> _cardKeys = [];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = ref.watch(smartProjectProvider);
    final progress = ref.watch(smartProjectProgressProvider);
    final stages = buildDayStages();
    final active = ref.watch(activeProjectProvider);
    final title = active.name.isEmpty
        ? 'הפרויקט שלי — מאפס עד מסירה'
        : '${active.name} — מאפס עד מסירה';

    // keep one GlobalKey per card for the day-picker jump.
    if (_cardKeys.length != stages.length) {
      _cardKeys
        ..clear()
        ..addAll(List.generate(stages.length, (_) => GlobalKey()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const CfgText('smart_project_screen.t01', '🏗️ פרויקט חכם',
              style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          actions: [
            // composite-hide: whole בחר-יום button gone when the org hides this
            // element (opens the day picker → critical:false).
            CfgVisible(
              'smart_project_screen.t02',
              child: TextButton(
                onPressed: () => _openDayPicker(stages, done),
                child: const CfgText('smart_project_screen.t02', '📅 בחר יום',
                    style: TextStyle(color: BsTokens.brandDark, fontSize: 13.5)),
              ),
            ),
            // composite-hide: the whole exit button goes when the org hides it.
            CfgVisible(
              'smart_project_screen.t03',
              critical: true, // exit/back — never hideable (don't trap the user)
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const CfgText('smart_project_screen.t03', '‹ יציאה',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
              ),
            ),
          ],
        ),
        body: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(BsTokens.space4, BsTokens.space4,
              BsTokens.space4, BsTokens.space5),
          children: [
            _Hero(title: title, done: progress.done, total: progress.total,
                pct: progress.pct),
            const SizedBox(height: BsTokens.space4),
            if (stages.isEmpty)
              Container(
                padding: const EdgeInsets.all(BsTokens.space4),
                decoration: BoxDecoration(
                  color: BsTokens.cardLight,
                  borderRadius: BorderRadius.circular(cfgRadius(context)),
                ),
                child: const Column(
                  children: [
                    Text('🗓️', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 8),
                    CfgText(
                      'smart_project_screen.t04',
                      'אין ימי עבודה בתוכנית',
                      style: TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    CfgText(
                      'smart_project_screen.t05',
                      'כשתוגדר תוכנית עבודה — ימי העבודה יופיעו כאן',
                      style: TextStyle(
                          color: BsTokens.mutedLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
            for (var i = 0; i < stages.length; i++)
              Container(
                key: _cardKeys[i],
                child: _StageCard(
                  index: i,
                  stage: stages[i],
                  isDone: done.contains(stages[i].key),
                  expanded: _expanded == stages[i].key,
                  isStepDone: (si) => done.contains(stages[i].stepKey(si)),
                  onToggleExpand: () => setState(() => _expanded =
                      _expanded == stages[i].key ? null : stages[i].key),
                  onToggleDone: () {
                    ref.read(smartProjectProvider.notifier)
                        .toggle(stages[i].key);
                    final nowDone = !done.contains(stages[i].key);
                    showToast(context,
                        nowDone ? 'יום עבודה סומן כבוצע' : 'הסימון בוטל');
                  },
                  onToggleStep: (si) => ref
                      .read(smartProjectProvider.notifier)
                      .toggle(stages[i].stepKey(si)),
                ),
              ),
            if (progress.done == progress.total && progress.total > 0) ...[
              const SizedBox(height: BsTokens.space4),
              _ProjectDone(),
            ],
          ],
        ),
      ),
    );
  }

  void _openDayPicker(List<DayStage> stages, Set<String> done) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scroll) => Container(
            decoration: const BoxDecoration(
              color: BsTokens.cardLight,
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(BsTokens.radiusCard)),
            ),
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(BsTokens.space4),
              children: [
                const CfgText('smart_project_screen.t06', 'בחר יום',
                    style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: BsTokens.space3),
                for (var i = 0; i < stages.length; i++)
                  Material(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(cfgRadius(context)),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusCard),
                      onTap: () {
                        Navigator.of(context).pop();
                        _jumpToDay(i);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: BsTokens.space3, vertical: BsTokens.space3),
                        child: Row(children: [
                          Expanded(
                            child: Text('יום ${i + 1} · ${stages[i].name}',
                                style: const TextStyle(
                                    color: BsTokens.inkLight, fontSize: 13.5)),
                          ),
                          if (done.contains(stages[i].key))
                            const CfgText('smart_project_screen.t07', '✓ הושלם',
                                style: TextStyle(
                                    color: Color(0xFF1f8a4c),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.5)),
                        ]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _jumpToDay(int i) {
    final ctx = (i < _cardKeys.length) ? _cardKeys[i].currentContext : null;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          alignment: 0.3,
          curve: Curves.easeInOut);
    }
    showToast(context, 'עברת ליום ${i + 1}');
  }
}

class _Hero extends StatelessWidget {
  const _Hero(
      {required this.title,
      required this.done,
      required this.total,
      required this.pct});
  final String title;
  final int done;
  final int total;
  final int pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
          const SizedBox(height: BsTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 10,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          Text('$done מתוך $total ימים בוצעו · $pct%',
              style: const TextStyle(
                  color: BsTokens.mutedLight, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ProjectDone extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F7EE),
          borderRadius: BorderRadius.circular(cfgRadius(context)),
        ),
        child: const CfgText('smart_project_screen.t08', '🎉 כל ימי העבודה בוצעו — הפרויקט הושלם!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF1f6f3f),
                fontWeight: FontWeight.w800,
                fontSize: 15)),
      );
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.stage,
    required this.isDone,
    required this.expanded,
    required this.isStepDone,
    required this.onToggleExpand,
    required this.onToggleDone,
    required this.onToggleStep,
  });

  final int index;
  final DayStage stage;
  final bool isDone;
  final bool expanded;
  final bool Function(int) isStepDone;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleDone;
  final void Function(int) onToggleStep;

  @override
  Widget build(BuildContext context) {
    final worker = (stage.worker >= 0 && stage.worker < kWorkers.length)
        ? kWorkers[stage.worker]
        : 'לא שובץ';
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: isDone ? const Color(0xFFF1FAF3) : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              onTap: onToggleExpand,
              child: Padding(
                padding: const EdgeInsets.all(BsTokens.space4),
                child: Row(children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF1f8a4c)
                          : const Color(0xFFF2F3F5),
                      shape: BoxShape.circle,
                    ),
                    child: Text(isDone ? '✓' : '${index + 1}',
                        style: TextStyle(
                            color: isDone ? Colors.white : BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                  const SizedBox(width: BsTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stage.name,
                            style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5)),
                        const SizedBox(height: 2),
                        Text('${stage.dayTag} · ${stage.detail}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: BsTokens.mutedLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Text(isDone ? 'בוצע' : 'לא בוצע',
                      style: TextStyle(
                          color: isDone
                              ? const Color(0xFF1f8a4c)
                              : BsTokens.brandDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5)),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more,
                      color: BsTokens.mutedLight, size: 20),
                ]),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(BsTokens.space4, 0,
                    BsTokens.space4, BsTokens.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row('עובד אחראי', worker),
                    _row('היקף', '${stage.totalDays} ימי עבודה'),
                    if (stage.steps.isNotEmpty) ...[
                      const SizedBox(height: BsTokens.space2),
                      const CfgText('smart_project_screen.t09', 'שלבי ביצוע',
                          style: TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                      for (var si = 0; si < stage.steps.length; si++)
                        InkWell(
                          onTap: () => onToggleStep(si),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 5),
                            child: Row(children: [
                              Icon(
                                  isStepDone(si)
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: isStepDone(si)
                                      ? const Color(0xFF1f8a4c)
                                      : BsTokens.mutedLight),
                              const SizedBox(width: BsTokens.space2),
                              Expanded(
                                child: Text(stage.steps[si],
                                    style: TextStyle(
                                        color: BsTokens.inkLight,
                                        fontSize: 13,
                                        decoration: isStepDone(si)
                                            ? TextDecoration.lineThrough
                                            : null)),
                              ),
                              Text(isStepDone(si) ? 'בוצע' : 'לא בוצע',
                                  style: const TextStyle(
                                      color: BsTokens.mutedLight,
                                      fontSize: 11.5)),
                            ]),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(BsTokens.space4, 0,
                  BsTokens.space4, BsTokens.space3),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Material(
                  color: isDone
                      ? const Color(0xFFEDEDED)
                      : const Color(0xFFE9F7EE),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  child: InkWell(
                    key: ValueKey('day-${stage.key}'),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    onTap: onToggleDone,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: BsTokens.space4, vertical: 8),
                      child: Text(
                          isDone ? '↩ בטל סימון' : '✓ סמן יום כבוצע',
                          style: TextStyle(
                              color: isDone
                                  ? BsTokens.mutedLight
                                  : const Color(0xFF1f6f3f),
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(k,
              style: const TextStyle(
                  color: BsTokens.mutedLight, fontSize: 12.5)),
          const Spacer(),
          Text(v,
              style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5)),
        ]),
      );
}
