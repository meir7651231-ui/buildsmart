// 🏗️ ניהול אתר הבנייה — the site-management hub (feature track T2, proto §5).
//
// A faithful port of the prototype's site functions (`openSiteHub` +
// `siteGantt`…`siteArchive`, index.html:19856-20151). The proto renders each
// tool into a `siteFeatureOverlay`; here every tool is a pushed route with the
// shared shell, matching the existing courier/store-dashboard style (R: match
// existing style). All strings + numbers are VERBATIM from the prototype (R6/R8).
//
// ENTRY POINTS (opened from the catalog ⋮ menu — `site_tasks` case in home_shell, calls openSiteHub):
//   openSiteHub(ctx)        — the 10-tile grid (proto openSiteHub @19858).
//   openSiteGantt           T2.1 site-gantt   📅  [L19889]
//   openSiteSnagging        T2.2 site-snag    🔧  [L19913]
//   openSiteLocations       T2.3 site-loc     🏢  [L19952]
//   openSiteAttendance      T2.4 site-attend  📍  [L19972]
//   openSiteDiary           T2.5 site-diary   📓  [L20012]
//   openSiteSafety          T2.6 site-safety  🦺  [L20041]
//   openSiteDeps            T2.7 site-deps    🔗  [L20066]
//   openSitePhotos          T2.8 site-photos  📸  [L20087]
//   openSiteInspect         T2.9 site-inspect 🔍  [L20111]
//   openSiteArchive         T2.10 site-archive 🗄️ [L20143]
//
// Mutable state (snags · inspections · attendance · diary) lives in
// `state/site_hub_state.dart`, seeded from the B0 consts in `data/phaseb_seeds`.

import 'package:buildsmart/data/contractor_seeds.dart' show caToday, kSafetyTips;
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/site_hub_state.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ═════════════════════════════════════════════════════════════════════════════
// Local style constants — match the proto's site CSS (--brand teal context).
// The prototype's site screens use the teal brand (--brand:#1f6f6b), not the
// app's orange FAB brand; kept local so this track touches no shared tokens.
// ═════════════════════════════════════════════════════════════════════════════
const Color _kBrand = Color(0xFF1F6F6B); // --brand
const Color _kBrandDark = Color(0xFF155350); // --brand-dark
const Color _kAmberDeep = Color(0xFFB07400); // --amber-deep (risk-m)
const Color _kRiskH = Color(0xFFC0531F); // risk-h text
const Color _kRiskX = Color(0xFFB62A2A); // risk-x text
const Color _kOk = Color(0xFF1F8A4C); // --ok (ready / clocked-in)

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINTS
// ─────────────────────────────────────────────────────────────────────────────

/// proto `openSiteHub` @19858 — the 10-tile grid landing.
void openSiteHub(BuildContext context) => _push(context, const _SiteHubGrid());

void openSiteGantt(BuildContext context) => _push(context, const _SiteGantt());
void openSiteSnagging(BuildContext context) =>
    _push(context, const _SiteSnagging());
void openSiteLocations(BuildContext context) =>
    _push(context, const _SiteLocations());
void openSiteAttendance(BuildContext context) =>
    _push(context, const _SiteAttendance());
void openSiteDiary(BuildContext context) => _push(context, const _SiteDiary());
void openSiteSafety(BuildContext context) => _push(context, const _SiteSafety());
void openSiteDeps(BuildContext context) => _push(context, const _SiteDeps());
void openSitePhotos(BuildContext context) => _push(context, const _SitePhotos());
void openSiteInspect(BuildContext context) =>
    _push(context, const _SiteInspect());
void openSiteArchive(BuildContext context) =>
    _push(context, const _SiteArchive());

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => screen),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared shell — RTL scaffold + md-head, matching the courier/store style.
// ─────────────────────────────────────────────────────────────────────────────

class _SiteScaffold extends StatelessWidget {
  const _SiteScaffold({
    required this.appTitle,
    required this.icon,
    required this.title,
    required this.sub,
    required this.children,
  });

  final String appTitle; // appbar title
  final String icon; // md-ic glyph
  final String title; // md-title
  final String sub; // md-sub
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: Text(
            appTitle,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '‹ חזרה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            _MdHead(icon: icon, title: title, sub: sub),
            const SizedBox(height: BsTokens.space4),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// `.md-head` — big icon + title + sub.
class _MdHead extends StatelessWidget {
  const _MdHead({required this.icon, required this.title, required this.sub});
  final String icon;
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 34)),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w900,
            fontSize: 19,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      ],
    );
  }
}

/// `.ca-card` container (white card, optional amber overdue border).
class _CaCard extends StatelessWidget {
  const _CaCard({required this.child, this.overdue = false});
  final Widget child;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        border: Border.all(
          color: overdue ? const Color(0xFFF2A516) : const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// `.ca-primary` full-width action button.
class _CaPrimary extends StatelessWidget {
  const _CaPrimary({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: _kBrand,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }
}

/// `.ca-sub-title` section heading.
class _CaSubTitle extends StatelessWidget {
  const _CaSubTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      );
}

/// `.ca-empty` placeholder.
class _CaEmpty extends StatelessWidget {
  const _CaEmpty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      );
}

/// `.ca-pill` (default brand / `.done` grey).
class _CaPill extends StatelessWidget {
  const _CaPill(this.label, {this.done = false});
  final String label;
  final bool done;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: done
            ? const Color(0x24737578)
            : const Color(0x241F6F6B),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: done ? BsTokens.mutedLight : _kBrandDark,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// `.ca-card-top` row — bold left, trailing widget right.
class _CardTop extends StatelessWidget {
  const _CardTop({required this.left, required this.trailing});
  final String left;
  final Widget trailing;
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          trailing,
        ],
      );
}

Text _cardSub(String text, {bool strong = false}) => Text(
      text,
      style: TextStyle(
        color: strong ? BsTokens.inkLight : BsTokens.mutedLight,
        fontWeight: strong ? FontWeight.w800 : FontWeight.w700,
        fontSize: 11,
      ),
    );

/// `.ca-card-btn` — full-width secondary card action.
class _CardBtn extends StatelessWidget {
  const _CardBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 9),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBrandDark,
              side: const BorderSide(color: _kBrand),
              padding: const EdgeInsets.symmetric(vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ),
      );
}

/// `.ca-card-done` — green confirmation line.
class _CardDone extends StatelessWidget {
  const _CardDone(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 9),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _kOk,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline-input dialog — the proto's `prompt(...)` becomes an AlertDialog with a
// TextField (R: inline input). Returns the entered text, or null on cancel.
// ─────────────────────────────────────────────────────────────────────────────

Future<String?> _promptInput(
  BuildContext context, {
  required String title,
  required String initial,
  required String okLabel,
}) {
  final ctrl = TextEditingController(text: initial);
  return showDialog<String?>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: BsTokens.cardLight,
        title: Text(
          title,
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 16),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: BsTokens.inkLight),
          textInputAction: TextInputAction.done,
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('ביטול',
                style: TextStyle(color: BsTokens.mutedLight)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _kBrand),
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: Text(okLabel),
          ),
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// HUB GRID — proto openSiteHub @19858. 10 tiles (ic + t + s verbatim).
// ═════════════════════════════════════════════════════════════════════════════

class _SiteHubGrid extends StatelessWidget {
  const _SiteHubGrid();

  static const _tiles = <({String ic, String t, String s, void Function(BuildContext) open})>[
    (ic: '📅', t: 'תרשים גאנט', s: 'לוח זמנים אינטראקטיבי', open: openSiteGantt),
    (ic: '🔧', t: 'רשימת ליקויים', s: 'Snagging list', open: openSiteSnagging),
    (ic: '🏢', t: 'קומה · דירה · חדר', s: 'שיוך משימות למיקום', open: openSiteLocations),
    (ic: '📍', t: 'נוכחות GPS', s: 'שעון נוכחות', open: openSiteAttendance),
    (ic: '📓', t: 'יומן עבודה', s: 'יומן יומי דיגיטלי', open: openSiteDiary),
    (ic: '🦺', t: 'התראות בטיחות', s: 'תדריך בטיחות יומי', open: openSiteSafety),
    (ic: '🔗', t: 'תלויות חומרים', s: 'בין משימות', open: openSiteDeps),
    (ic: '📸', t: 'צילום לפני/אחרי', s: 'תיעוד התקדמות', open: openSitePhotos),
    (ic: '🔍', t: 'ביקורות מפקח', s: 'תזכורות ביקורת', open: openSiteInspect),
    (ic: '🗄️', t: 'ארכיון פרויקטים', s: 'פרויקטים שהושלמו', open: openSiteArchive),
  ];

  @override
  Widget build(BuildContext context) {
    return _SiteScaffold(
      appTitle: '🏗️ ניהול אתר',
      icon: '🏗️',
      title: 'ניהול אתר הבנייה',
      sub: 'כל כלי הניהול של אתר הבנייה במקום אחד.',
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            for (final t in _tiles)
              _HubTile(ic: t.ic, t: t.t, s: t.s, onTap: () => t.open(context)),
          ],
        ),
      ],
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.ic,
    required this.t,
    required this.s,
    required this.onTap,
  });
  final String ic;
  final String t;
  final String s;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BsTokens.cardLight,
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(BsTokens.space3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE6E6E6)),
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ic, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                t,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                s,
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.1 — GANTT. proto siteGantt @19889. RTL bars + done %. span = 27.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteGantt extends StatelessWidget {
  const _SiteGantt();

  @override
  Widget build(BuildContext context) {
    final span = ganttSpan(); // 27
    return _SiteScaffold(
      appTitle: '📅 גאנט',
      icon: '📅',
      title: 'תרשים גאנט',
      sub: 'לוח הזמנים של הפרויקט — $span שבועות.',
      children: [
        for (final t in kGanttTasks) ...[
          _GanttRow(task: t, span: span),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _GanttRow extends StatelessWidget {
  const _GanttRow({required this.task, required this.span});
  final GanttTask task;
  final int span;

  @override
  Widget build(BuildContext context) {
    final leftFrac = task.start / span; // .sc-gantt-bar right:leftPct%
    final widFrac = task.len / span; // width:widPct%
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.name,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        // .sc-gantt-track — RTL: the bar is offset from the RIGHT edge.
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final barW = w * widFrac;
            final rightOffset = w * leftFrac;
            return Container(
              height: 22,
              decoration: BoxDecoration(
                color: BsTokens.bgLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: rightOffset,
                    top: 0,
                    bottom: 0,
                    width: barW,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0x381F6F6B), // rgba(31,111,107,.22)
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // .sc-gantt-fill — done% of the bar, filling from the
                          // start edge (right, under RTL) like the proto's bar.
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: task.done / 100,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _kBrand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          // .sc-gantt-pct — right:6px.
                          Positioned(
                            right: 6,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                '${task.done}%',
                                style: const TextStyle(
                                  color: BsTokens.inkLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 9.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.2 — SNAGGING LIST. proto siteSnagging @19913. inline add + fix CRUD.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteSnagging extends ConsumerWidget {
  const _SiteSnagging();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snags = ref.watch(siteSnagsProvider);
    return _SiteScaffold(
      appTitle: '🔧 ליקויים',
      icon: '🔧',
      title: 'רשימת ליקויים',
      sub: 'תיעוד ומעקב אחר ליקויים ותקלות באתר.',
      children: [
        _CaPrimary(
          label: '+ דווח ליקוי חדש',
          onTap: () => _add(context, ref),
        ),
        const SizedBox(height: 12),
        if (snags.isEmpty)
          const _CaEmpty('אין ליקויים פתוחים ✓')
        else
          for (final s in snags) _snagCard(context, ref, s),
      ],
    );
  }

  Widget _snagCard(BuildContext context, WidgetRef ref, SiteSnag s) {
    final fixed = s.status == 'טופל';
    final (Color sevFg, Color sevBg) = switch (s.severity) {
      'חמור' => (_kRiskX, const Color(0x21C82A2A)),
      'בינוני' => (_kAmberDeep, const Color(0x29F2A516)),
      _ => (_kRiskH, const Color(0x24D66228)),
    };
    return _CaCard(
      overdue: !fixed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTop(
            left: s.id,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: sevBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                s.severity,
                style: TextStyle(
                  color: sevFg,
                  fontWeight: FontWeight.w800,
                  fontSize: 9.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          _cardSub(s.what, strong: true),
          const SizedBox(height: 3),
          _cardSub('📍 ${s.loc} · ${s.status}'),
          if (fixed)
            const _CardDone('✓ הליקוי טופל')
          else
            _CardBtn(
              label: 'סמן כטופל',
              onTap: () {
                ref.read(siteSnagsProvider.notifier).fix(s.id);
                showToast(context, 'הליקוי ${s.id} סומן כטופל ✓');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final what = await _promptInput(
      context,
      title: 'תאר את הליקוי:',
      initial: 'סדק בקיר',
      okLabel: 'דווח',
    );
    if (what == null) return; // proto: prompt cancel → return
    ref.read(siteSnagsProvider.notifier).add(what);
    if (context.mounted) showToast(context, 'ליקוי דווח ✓');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.3 — FLOOR → APARTMENT → ROOM. proto siteLocations @19952. 3 floors.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteLocations extends StatelessWidget {
  const _SiteLocations();

  @override
  Widget build(BuildContext context) {
    return _SiteScaffold(
      appTitle: '🏢 מיקומים',
      icon: '🏢',
      title: 'קומה · דירה · חדר',
      sub: 'מבנה האתר ההיררכי — לשיוך משימות למיקום מדויק.',
      children: [
        for (final f in kSiteTree) _floor(f),
      ],
    );
  }

  Widget _floor(SiteFloor f) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏢 ${f.floor}',
            style: const TextStyle(
              color: _kBrandDark,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          for (final a in f.apts) _apt(a),
        ],
      ),
    );
  }

  Widget _apt(SiteApartment a) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🚪 ${a.n}',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final r in a.rooms) _room(r),
            ],
          ),
        ],
      ),
    );
  }

  Widget _room(String r) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          border: Border.all(color: const Color(0xFFE6E6E6)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          r,
          style: const TextStyle(
            color: BsTokens.mutedLight,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.4 — GPS ATTENDANCE. proto siteAttendance @19972. clock in/out + history.
//   camera/GPS → simulated demo result (the geo coordinate is a demo value).
// ═════════════════════════════════════════════════════════════════════════════

class _SiteAttendance extends ConsumerWidget {
  const _SiteAttendance();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(siteAttendanceProvider);
    final notifier = ref.read(siteAttendanceProvider.notifier);
    final open = notifier.open;
    return _SiteScaffold(
      appTitle: '📍 נוכחות',
      icon: '📍',
      title: 'שעון נוכחות GPS',
      sub: 'החתמת כניסה ויציאה עם אימות מיקום באתר.',
      children: [
        // .sc-attend-box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: BsTokens.bgLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                open != null
                    ? '🟢 נוכח באתר מ-${open.timeIn}'
                    : '⚪ לא מחותם כרגע',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: open != null ? _kOk : BsTokens.mutedLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _CaPrimary(
                label: open != null ? 'החתם יציאה' : 'החתם כניסה 📍',
                onTap: () => _clock(context, ref, isIn: open == null),
              ),
            ],
          ),
        ),
        if (log.isNotEmpty) ...[
          const SizedBox(height: 6),
          const _CaSubTitle('היסטוריית נוכחות'),
          for (final a in log) _entry(a),
        ],
      ],
    );
  }

  Widget _entry(AttendanceEntry a) {
    return _CaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTop(
            left: '📅 ${a.date}',
            trailing: _CaPill(a.timeOut != null ? 'הושלם' : 'פתוח'),
          ),
          const SizedBox(height: 5),
          _cardSub(
            'כניסה ${a.timeIn}'
            '${a.timeOut != null ? ' · יציאה ${a.timeOut}' : ''}'
            ' · 📍 ${a.geo}',
          ),
        ],
      ),
    );
  }

  void _clock(BuildContext context, WidgetRef ref, {required bool isIn}) {
    // proto: new Date().toLocaleTimeString('he-IL',{hour:'2-digit',minute:'2-digit'})
    final now = TimeOfDay.now();
    final hhmm =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final n = ref.read(siteAttendanceProvider.notifier);
    if (isIn) {
      n.clockIn(hhmm);
      showToast(context, 'כניסה נרשמה ב-$hhmm 📍');
    } else {
      n.clockOut(hhmm);
      showToast(context, 'יציאה נרשמה ב-$hhmm');
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.5 — DAILY WORK DIARY. proto siteDiary @20012. inline add + weather random.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteDiary extends ConsumerWidget {
  const _SiteDiary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diary = ref.watch(siteDiaryProvider);
    return _SiteScaffold(
      appTitle: '📓 יומן',
      icon: '📓',
      title: 'יומן עבודה דיגיטלי',
      sub: 'תיעוד יומי של ההתקדמות, כוח האדם והאירועים באתר.',
      children: [
        _CaPrimary(
          label: '+ רישום יומן להיום',
          onTap: () => _add(context, ref),
        ),
        const SizedBox(height: 12),
        if (diary.isEmpty)
          const _CaEmpty('אין רישומים ביומן')
        else
          for (final d in diary) _entry(d),
      ],
    );
  }

  Widget _entry(DiaryEntry d) {
    return _CaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTop(
            left: '📅 ${d.date}',
            trailing: _CaPill('${d.workers} עובדים'),
          ),
          const SizedBox(height: 5),
          _cardSub(d.text, strong: true),
          const SizedBox(height: 3),
          _cardSub('מזג אוויר: ${d.weather}'),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final text = await _promptInput(
      context,
      title: 'מה בוצע היום באתר?',
      initial: 'יציקת רצפת קומה 3',
      okLabel: 'הוסף',
    );
    if (text == null) return;
    ref.read(siteDiaryProvider.notifier).add(text);
    if (context.mounted) showToast(context, 'רישום נוסף ליומן ✓');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.6 — SAFETY ALERTS. proto siteSafety @20041. daily tip + ack → push.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteSafety extends StatefulWidget {
  const _SiteSafety();
  @override
  State<_SiteSafety> createState() => _SiteSafetyState();
}

class _SiteSafetyState extends State<_SiteSafety> {
  bool _acked = false;

  @override
  Widget build(BuildContext context) {
    // proto: SAFETY_TIPS[new Date().getDate()%SAFETY_TIPS.length]
    final tip = kSafetyTips[DateTime.now().day % kSafetyTips.length];
    return _SiteScaffold(
      appTitle: '🦺 בטיחות',
      icon: '🦺',
      title: 'התראות בטיחות',
      sub: 'תדריך בטיחות יומי — חובה לפני תחילת העבודה.',
      children: [
        // .sc-safety-today — amber gradient banner.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE0920E), Color(0xFFB8740A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'תדריך היום',
                style: TextStyle(
                  color: Color(0xFFFFE7C2),
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                tip,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        const _CaSubTitle('כללי בטיחות כלליים'),
        for (final t in kSafetyTips) _safetyRow(t),
        const SizedBox(height: 6),
        if (_acked)
          // ack → push: simulated push confirmation shown inline.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x141F8A4C),
              border: Border.all(color: _kOk),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🦺 תדריך הבטיחות אושר',
                  style: TextStyle(
                    color: _kOk,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _cardSub('התדריך היומי אושר.'),
                _cardSub('תאריך: ${caToday()}'),
              ],
            ),
          )
        else
          _CaPrimary(
            label: '✓ קראתי ואישרתי את התדריך',
            onTap: _ack,
          ),
      ],
    );
  }

  Widget _safetyRow(String t) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          t,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 11.5,
          ),
        ),
      );

  void _ack() {
    // proto: pushNotification('תדריך הבטיחות אושר', ...) + toast(...).
    // No shared notification feed to inject into without editing a shared file;
    // surfaced as an inline simulated-push confirmation + toast (R: not a stub).
    setState(() => _acked = true);
    showToast(context, 'תדריך הבטיחות אושר ✓');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.7 — MATERIAL DEPENDENCIES. proto siteDeps @20066. 4 deps ready/blocked.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteDeps extends StatelessWidget {
  const _SiteDeps();

  @override
  Widget build(BuildContext context) {
    return _SiteScaffold(
      appTitle: '🔗 תלויות',
      icon: '🔗',
      title: 'תלויות חומרים בין משימות',
      sub: 'משימה לא יכולה להתחיל לפני שהמשימות התלויות הושלמו.',
      children: [
        for (final d in kSiteDeps) _dep(d),
      ],
    );
  }

  Widget _dep(SiteDep d) {
    return Opacity(
      opacity: d.ready ? 1 : .62, // .sc-dep opacity:.62 → .ready opacity:1
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          border: Border.all(
            color: d.ready ? _kOk : const Color(0xFFE6E6E6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${d.ready ? '🟢 ' : '🔒 '}${d.task}',
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'דורש: ${d.needs}',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              d.ready ? 'מוכן להתחלה' : 'ממתין לתלויות',
              style: const TextStyle(
                color: _kBrandDark,
                fontWeight: FontWeight.w800,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.8 — BEFORE / AFTER PHOTOS. proto sitePhotos @20087. 3 pairs.
//   camera → simulated demo result (a captured pair is appended inline, NOT a
//   toast-only stub).
// ═════════════════════════════════════════════════════════════════════════════

class _SitePhotos extends StatefulWidget {
  const _SitePhotos();
  @override
  State<_SitePhotos> createState() => _SitePhotosState();
}

class _SitePhotosState extends State<_SitePhotos> {
  // Seed pairs + any simulated captures appended at runtime.
  final List<SitePhotoPair> _pairs = [...kSitePhotoPairs];

  @override
  Widget build(BuildContext context) {
    return _SiteScaffold(
      appTitle: '📸 צילום',
      icon: '📸',
      title: 'צילום לפני / אחרי',
      sub: 'תיעוד ויזואלי של ההתקדמות — השוואת מצב לפני ואחרי.',
      children: [
        for (final p in _pairs) _pair(p),
        const SizedBox(height: 4),
        _CaPrimary(
          label: '📷 הוסף צילום חדש',
          onTap: _capture,
        ),
      ],
    );
  }

  Widget _pair(SitePhotoPair p) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.area,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _photo(p.before, 'לפני'),
              const SizedBox(width: 8),
              const Text(
                '←',
                style: TextStyle(
                  color: _kBrand,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              _photo(p.after, 'אחרי'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photo(String glyph, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BsTokens.bgLight,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(glyph, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _capture() {
    // camera → simulated demo result: append a freshly "captured" pair so the
    // action has a visible effect (R: camera → simulated demo result, not toast).
    setState(() {
      _pairs.add(SitePhotoPair(
        area: 'צילום חדש · ${caToday()}',
        before: '📷',
        after: '🏗️',
      ));
    });
    showToast(context, 'צילום נוסף לתיעוד ✓');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.9 — INSPECTION REMINDERS. proto siteInspect @20111. inline add + complete.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteInspect extends ConsumerWidget {
  const _SiteInspect();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(siteInspectionsProvider);
    return _SiteScaffold(
      appTitle: '🔍 ביקורות',
      icon: '🔍',
      title: 'ביקורות מפקח',
      sub: 'תזכורות לביקורות מפקח ורשויות.',
      children: [
        _CaPrimary(
          label: '+ תזמן ביקורת',
          onTap: () => _add(context, ref),
        ),
        const SizedBox(height: 12),
        for (final ins in list) _card(context, ref, ins),
      ],
    );
  }

  Widget _card(BuildContext context, WidgetRef ref, SiteInspection ins) {
    final done = ins.status == 'בוצעה';
    return _CaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTop(
            left: ins.id,
            trailing: _CaPill(ins.status, done: done),
          ),
          const SizedBox(height: 5),
          _cardSub(ins.what, strong: true),
          const SizedBox(height: 3),
          _cardSub('🗓️ ${ins.due}'),
          if (done)
            const _CardDone('✓ הביקורת בוצעה')
          else
            _CardBtn(
              label: 'סמן כבוצעה',
              onTap: () {
                ref.read(siteInspectionsProvider.notifier).complete(ins.id);
                showToast(context, 'הביקורת ${ins.id} סומנה כבוצעה ✓');
              },
            ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final what = await _promptInput(
      context,
      title: 'סוג הביקורת:',
      initial: 'ביקורת מהנדס',
      okLabel: 'תזמן',
    );
    if (what == null) return;
    ref.read(siteInspectionsProvider.notifier).add(what);
    if (context.mounted) showToast(context, 'ביקורת תוזמנה ✓');
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// T2.10 — PROJECT ARCHIVE. proto siteArchive @20143. 3 archived projects.
// ═════════════════════════════════════════════════════════════════════════════

class _SiteArchive extends StatelessWidget {
  const _SiteArchive();

  @override
  Widget build(BuildContext context) {
    return _SiteScaffold(
      appTitle: '🗄️ ארכיון',
      icon: '🗄️',
      title: 'ארכיון פרויקטים',
      sub: 'פרויקטים שהושלמו — לעיון והפקת לקחים.',
      children: [
        for (final p in kArchivedProjects)
          _CaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTop(
                  left: p.name,
                  trailing: _CaPill(p.status, done: true),
                ),
                const SizedBox(height: 5),
                _cardSub('📅 ${p.year} · ${p.units} יח״ד'),
              ],
            ),
          ),
      ],
    );
  }
}
