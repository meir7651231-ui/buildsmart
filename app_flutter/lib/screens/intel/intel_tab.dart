// ─────────────────────────────────────────────────────────────────────────────
// intel_tab — Studio Pillar-3 · step 98 — the 5th manager tab "📡 מודיעין לקוחות"
// (Live Customer Intelligence), a Hebrew / RTL / a11y read surface.
//
// GATING (the reconciliation): this widget is referenced ONLY inside the
// `if (kIntelLive)` branches of manager_dashboard_screen.dart, so with the
// compile-const flag OFF (every normal / test build) the tab tree-shakes away and
// the shipped dashboard is byte-identical (4 tabs). It appears only under
// `--dart-define=INTEL_LIVE=true`.
//
// DATA — the four manager READ providers (state/intel/intel_read.dart), each a
// deterministic fold of the local ring buffer (`intelLogProvider`) via the pure
// step-95/96/97 logic, so the tab is FULL OF DATA on-device WITHOUT Firebase. All
// providers are read-gated isManager (R1-5); "מי מחובר כעת" is CUSTOMER-ONLY with
// names resolved OWNER-SIDE (R1-4).
//
// STYLE (Gate-46): a LIGHT surface — every colour comes from [BsTokens] (NO raw
// hex colour literal, NO dark token), mirroring the manager dashboard's
// `_MetricTile` / `_CreditBar` / `_StagePill` (which are private to that file, so
// their look is
// reproduced here as BsTokens-only equivalents — no chart library). RTL via
// [Directionality] + [EdgeInsetsDirectional]; a11y via [Semantics] labels.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/logic/intel/funnels.dart'
    show FunnelStage, IntelInsights;
import 'package:buildsmart/logic/intel/segments.dart'
    show ActorSegment, RetentionCohort;
import 'package:buildsmart/state/intel/intel_events.dart' show IntelEvents;
import 'package:buildsmart/state/intel/intel_read.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📡 מודיעין לקוחות — the manager Live-Customer-Intelligence tab (step 98).
/// A read-only, RTL, a11y surface over the four intel read providers. Const so it
/// slots into the manager dashboard's `const` [IndexedStack] children list.
class IntelTab extends ConsumerWidget {
  const IntelTab({super.key});

  /// Hebrew labels for the funnel stages — keyed by the `IntelEvents` wire names
  /// (never a raw literal), so the stage strings never drift from funnels.dart.
  static const Map<String, String> _funnelLabel = <String, String>{
    IntelEvents.searchSubmit: 'חיפוש',
    IntelEvents.productView: 'צפייה במוצר',
    IntelEvents.addToCart: 'הוספה לסל',
    IntelEvents.cartView: 'צפייה בסל',
    IntelEvents.checkoutStart: 'תשלום',
    IntelEvents.orderPlaced: 'הזמנה',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insights = ref.watch(intelInsightsProvider);
    final segments = ref.watch(intelSegmentsProvider);
    final cohorts = ref.watch(intelRetentionProvider);
    final presence = ref.watch(intelPresenceProvider);
    final now = DateTime.now();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ColoredBox(
        color: BsTokens.bgLight,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space6,
          ),
          children: [
            const _IntelIntro(),
            const SizedBox(height: BsTokens.space4),
            _FunnelCard(insights: insights, labelOf: _funnelLabel),
            const SizedBox(height: BsTokens.space4),
            _SegmentsCard(segments: segments),
            const SizedBox(height: BsTokens.space4),
            _RetentionCard(cohorts: cohorts),
            const SizedBox(height: BsTokens.space4),
            _PresenceCard(rows: presence, now: now),
          ],
        ),
      ),
    );
  }
}

/// The tab's intro banner — names the surface + its honest on-device demo source.
class _IntelIntro extends StatelessWidget {
  const _IntelIntro();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'מודיעין לקוחות',
      header: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.brand.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: BsTokens.brand.withValues(alpha: 0.25)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📡 מודיעין לקוחות',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            SizedBox(height: BsTokens.spaceHair),
            Text(
              'משפך ההמרה, פלחי הלקוחות, שימור ומי מחובר כעת — חי מהמכשיר.',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Funnel ───────────────────────────────────────────────────────────────────

/// The conversion-funnel section — one row per stage with its reached count and a
/// cumulative-conversion bar, plus the biggest step-to-step drop-off.
class _FunnelCard extends StatelessWidget {
  const _FunnelCard({required this.insights, required this.labelOf});

  final IntelInsights insights;
  final Map<String, String> labelOf;

  String _label(String name) => labelOf[name] ?? name;

  @override
  Widget build(BuildContext context) {
    final stages = insights.funnel.stages;
    final drop = insights.funnel.biggestDropOff;
    final empty = stages.every((FunnelStage s) => s.reached == 0);
    return _IntelCard(
      title: 'משפך המרה',
      emoji: '🛒',
      child: empty
          ? const _EmptyLine()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in stages)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: BsTokens.space3,
                    ),
                    child: Semantics(
                      label: '${_label(s.name)}: ${s.reached} סשנים, '
                          '${s.conversionPct.round()} אחוז המרה',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _label(s.name),
                                  style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${s.reached}',
                                style: const TextStyle(
                                  color: BsTokens.brand,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: BsTokens.space2),
                              _IntelPill(
                                label: '${s.conversionPct.round()}%',
                                color: BsTokens.brand,
                              ),
                            ],
                          ),
                          const SizedBox(height: BsTokens.spaceHair),
                          _IntelBar(
                            pct: s.conversionPct.round(),
                            color: BsTokens.brand,
                            semanticPrefix: 'המרה',
                          ),
                        ],
                      ),
                    ),
                  ),
                if (drop != null)
                  Text(
                    'הנשירה הגדולה: ${_label(drop.fromStage)} ← '
                    '${_label(drop.toStage)} (${drop.lostPct.round()}%)',
                    style: const TextStyle(
                      color: BsTokens.dangerDark,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Segments ───────────────────────────────────────────────────────────────────

/// The customer-segments section — a stat strip (total / converted / stuck) over
/// the per-actor roll-up, then the most-recent actors with a status pill.
class _SegmentsCard extends StatelessWidget {
  const _SegmentsCard({required this.segments});

  final Map<String, ActorSegment> segments;

  @override
  Widget build(BuildContext context) {
    final actors = segments.values.toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    final converted = actors.where((a) => a.converted).length;
    final stuck = actors.fold<int>(0, (sum, a) => sum + a.stuckCount);
    return _IntelCard(
      title: 'פלחי לקוחות',
      emoji: '👥',
      child: actors.isEmpty
          ? const _EmptyLine()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _IntelStat(
                      emoji: '👥',
                      value: '${actors.length}',
                      label: 'לקוחות',
                    ),
                    const SizedBox(width: BsTokens.space2),
                    _IntelStat(emoji: '✅', value: '$converted', label: 'המירו'),
                    const SizedBox(width: BsTokens.space2),
                    _IntelStat(emoji: '⚠️', value: '$stuck', label: 'תקיעות'),
                  ],
                ),
                const SizedBox(height: BsTokens.space3),
                for (final a in actors.take(5))
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: BsTokens.space2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '👤 ${_pseudonym(a.key)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${a.sessions} סשנים',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: BsTokens.space2),
                        if (a.converted)
                          const _IntelPill(label: 'המיר', color: BsTokens.success)
                        else if (a.stuckCount > 0)
                          const _IntelPill(
                            label: 'תקוע',
                            color: BsTokens.warnBright,
                          ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Retention ───────────────────────────────────────────────────────────────────

/// The retention-cohorts section — one row per first-seen cohort with its size and
/// a day-1 return bar.
class _RetentionCard extends StatelessWidget {
  const _RetentionCard({required this.cohorts});

  final List<RetentionCohort> cohorts;

  @override
  Widget build(BuildContext context) {
    return _IntelCard(
      title: 'שימור לקוחות',
      emoji: '📈',
      child: cohorts.isEmpty
          ? const _EmptyLine()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final c in cohorts.take(6))
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: BsTokens.space3,
                    ),
                    child: Semantics(
                      label: 'מחזור ${_day(c.cohortDay)}: ${c.size} לקוחות, '
                          'שימור יום 1 ${c.retentionPct(1).round()} אחוז',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _day(c.cohortDay),
                                  style: const TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${c.size} לקוחות',
                                style: const TextStyle(
                                  color: BsTokens.mutedLight,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: BsTokens.space2),
                              _IntelPill(
                                label: 'יום 1 · ${c.retentionPct(1).round()}%',
                                color: BsTokens.successDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: BsTokens.spaceHair),
                          _IntelBar(
                            pct: c.retentionPct(1).round(),
                            color: BsTokens.successDark,
                            semanticPrefix: 'שימור יום 1',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Presence ───────────────────────────────────────────────────────────────────

/// The "מי מחובר כעת" section — the LIVE customer actors (R1-5 customer-only),
/// each row a name resolved OWNER-SIDE (R1-4) or its pseudonym, the last screen,
/// and a relative time. Never renders the event's in-memory displayName.
class _PresenceCard extends StatelessWidget {
  const _PresenceCard({required this.rows, required this.now});

  final List<IntelPresenceRow> rows;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return _IntelCard(
      title: 'מי מחובר כעת',
      emoji: '🟢',
      trailing: '${rows.length}',
      child: rows.isEmpty
          ? const _EmptyLine(text: 'אף לקוח לא מחובר כעת')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final r in rows)
                  Semantics(
                    label: 'מחובר: ${r.named ? r.name! : _pseudonym(r.key)}'
                        '${r.screen.isEmpty ? '' : ', במסך ${r.screen}'}',
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        bottom: BsTokens.space2,
                      ),
                      child: Row(
                        children: [
                          const _LiveDot(),
                          const SizedBox(width: BsTokens.space2),
                          Expanded(
                            child: Text(
                              r.named ? r.name! : '👤 ${_pseudonym(r.key)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: BsTokens.inkLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (r.screen.isNotEmpty)
                            Text(
                              r.screen,
                              style: const TextStyle(
                                color: BsTokens.mutedLight,
                                fontSize: 11.5,
                              ),
                            ),
                          const SizedBox(width: BsTokens.space2),
                          Text(
                            _relTime(r.lastSeen, now),
                            style: const TextStyle(
                              color: BsTokens.mutedLight,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ── Shared local widgets (BsTokens-only mirrors of the dashboard's private
//    _MetricTile / _CreditBar / _StagePill — no chart library) ───────────────────

/// A white section card with an emoji + title header and an optional trailing
/// count, mirroring the manager dashboard's white cardLight surfaces.
class _IntelCard extends StatelessWidget {
  const _IntelCard({
    required this.title,
    required this.emoji,
    required this.child,
    this.trailing,
  });

  final String title;
  final String emoji;
  final Widget child;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: BsTokens.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: BsTokens.space2),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (trailing != null)
                _IntelPill(label: trailing!, color: BsTokens.success),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          child,
        ],
      ),
    );
  }
}

/// A KPI stat tile — mirrors the dashboard's private `_MetricTile` (emoji · value ·
/// label, with a [Semantics] label), BsTokens-only. Expands to share a row.
class _IntelStat extends StatelessWidget {
  const _IntelStat({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$emoji $label: $value',
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space3,
          ),
          decoration: BoxDecoration(
            color: BsTokens.bgLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            border: Border.all(color: BsTokens.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: BsTokens.spaceHair),
              Text(
                value,
                style: const TextStyle(
                  color: BsTokens.brand,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A thin progress bar — mirrors the dashboard's private `_CreditBar` (a
/// [Semantics]-labelled [LinearProgressIndicator] at pct/100), BsTokens-only.
class _IntelBar extends StatelessWidget {
  const _IntelBar({
    required this.pct,
    required this.color,
    required this.semanticPrefix,
  });

  final int pct;
  final Color color;
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$semanticPrefix $pct%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: LinearProgressIndicator(
          value: (pct / 100).clamp(0.0, 1.0),
          minHeight: 7,
          backgroundColor: BsTokens.surfaceMid,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

/// A small tinted status pill — mirrors the dashboard's private `_StagePill`
/// (a [color]-tinted rounded label), BsTokens-only.
class _IntelPill extends StatelessWidget {
  const _IntelPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// The little green "live" dot in a presence row.
class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: BsTokens.success,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// A muted "no data yet" placeholder line for an empty section.
class _EmptyLine extends StatelessWidget {
  const _EmptyLine({this.text = 'אין נתונים עדיין'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
    );
  }
}

/// Short, safe pseudonym label for a stable actor key — the pseudonymous key is
/// safe to show (R1-4: it is NOT PII); shortened so a long uid stays readable.
String _pseudonym(String key) => key.length <= 8 ? key : key.substring(0, 8);

/// yyyy-mm-dd for a cohort day marker (UTC-midnight, see segments.dart).
String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Relative Hebrew time from [at] to [now] for a presence "last seen".
String _relTime(DateTime at, DateTime now) {
  final d = now.difference(at);
  if (d.inSeconds < 60) return 'לפני ${d.inSeconds < 0 ? 0 : d.inSeconds} שנ׳';
  if (d.inMinutes < 60) return 'לפני ${d.inMinutes} דק׳';
  if (d.inHours < 24) return 'לפני ${d.inHours} שע׳';
  return 'לפני ${d.inDays} ימ׳';
}
