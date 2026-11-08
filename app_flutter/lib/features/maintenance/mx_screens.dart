/// Maintenance module — screens (Hebrew, RTL, light, phone-first).
///
/// [MxHome] is the whole module: a role switch (manager / tech / home staff /
/// store) and per-role tabs. Drill-downs are pushed routes that watch
/// [mxDbProvider], so every screen updates live after any action.
///
/// UX rules (critique round 1): sticky main action, urgent safety faults,
/// nothing irreversible in one tap, 6 s announced toasts with "בטל", no
/// internal codes. Design rules (critique round 2): one petrol chrome on
/// every screen, red only for safety / overdue / destructive, one card, one
/// chip family, Hebrew date + ב״ה, the home arch, full-screen moments.
library;

import 'dart:async';

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_hebdate.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';
import 'package:buildsmart/features/maintenance/mx_ui.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo identities (real auth maps users to these).
const String kMxTechName = 'יוסי – טכנאי';
const String kMxStaffUnit = 'jrs-3';
const String kMxStaffLabel = 'צוות הבית – דירה 3';
const String kMxStoreId = 'st-tambur';
const String kMxManagerName = 'מנהל האחזקה';

const Color _brand = kMxPrimary;
const Color _bad = kMxBad;
const Color _warn = kMxWarn;
const Color _ok = kMxOk;

/// Separator that never starts a line: NBSP + middle dot.
const String _sep = ' · ';

/// Keep an LTR run (phone, number) intact inside RTL text.
String _ltr(String s) =>
    '${String.fromCharCode(0x2066)}$s${String.fromCharCode(0x2069)}';

ThemeData mxTheme() => mxBrandTheme();

/// A floating 6-second toast, announced to screen readers. [undo] adds a
/// "בטל" button with a ring that counts the 6 seconds down.
void _toast(
  BuildContext context,
  String? error,
  String success, {
  VoidCallback? undo,
}) {
  final msg = error ?? success;
  if (msg.isEmpty) return;
  const life = Duration(seconds: 6);
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: life,
        backgroundColor: error == null ? kMxPrimary : _bad,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 8),
        content: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: error == null ? kMxAccent : Colors.white24,
              ),
              child: Icon(
                error == null ? Icons.check_rounded : Icons.error_outline,
                size: 16,
                color: error == null ? kMxPrimary : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
            if (error == null && undo != null)
              TextButton(
                key: const Key('toast-undo'),
                style: TextButton.styleFrom(foregroundColor: kMxAccent),
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  undo();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1, end: 0),
                      duration: life,
                      builder:
                          (_, v, _) => SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              value: v,
                              strokeWidth: 2,
                              color: kMxAccent,
                              backgroundColor: Colors.white24,
                            ),
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'בטל',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  SemanticsService.announce(msg, TextDirection.rtl);
}

/// Toast for a local step that can be undone.
void _undoable(
  BuildContext context,
  WidgetRef ref,
  String? error,
  String success,
) => _toast(
  context,
  error,
  success,
  undo: () {
    if (ref.read(mxDbProvider.notifier).undo() && context.mounted) {
      _toast(context, null, 'הפעולה בוטלה');
    }
  },
);

/// Two buttons, always the same pattern in every sheet: primary full width
/// (52), secondary as a quiet full-width text button (44) under it.
Widget _sheetButtons({
  required Key okKey,
  required String ok,
  required VoidCallback? onOk,
  required VoidCallback onCancel,
  Key? cancelKey,
  String cancel = 'ביטול',
  bool danger = false,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    SizedBox(
      height: 52,
      child: FilledButton(
        key: okKey,
        style: danger ? FilledButton.styleFrom(backgroundColor: _bad) : null,
        onPressed: onOk,
        child: Text(ok),
      ),
    ),
    const SizedBox(height: 8),
    SizedBox(
      height: 44,
      child: TextButton(
        key: cancelKey,
        style: TextButton.styleFrom(foregroundColor: kMxMuted),
        onPressed: onCancel,
        child: Text(cancel),
      ),
    ),
  ],
);

/// Sheet header: H2 title (+ optional body), 24 dp side padding.
Widget _sheetTitle(String title, [String body = '']) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
    if (body.isNotEmpty) ...[
      const SizedBox(height: 8),
      Text(body, style: const TextStyle(fontSize: 16, height: 1.45)),
    ],
    const SizedBox(height: 16),
  ],
);

/// Yes/no confirmation (a sheet, like every other choice in the app).
Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String ok,
  bool danger = false,
}) async =>
    await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sheetTitle(title, body),
                  _sheetButtons(
                    okKey: const Key('confirm-yes'),
                    ok: ok,
                    danger: danger,
                    onOk: () => Navigator.pop(ctx, true),
                    cancelKey: const Key('confirm-no'),
                    onCancel: () => Navigator.pop(ctx, false),
                  ),
                ],
              ),
            ),
          ),
    ) ??
    false;

Future<void> _call(WidgetRef ref, BuildContext context, String phone) async {
  unawaited(HapticFeedback.mediumImpact());
  final ok = await ref.read(urlLauncherProvider)(
    Uri(scheme: 'tel', path: phone.replaceAll(RegExp('[^0-9+]'), '')),
  );
  if (!ok && context.mounted) _toast(context, 'לא ניתן לחייג מהמכשיר', '');
}

/// A group of list rows on one card (no border — elevation only).
Widget _listCard(List<Widget> tiles) => Container(
  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
  decoration: const BoxDecoration(
    color: Colors.white,
    borderRadius: kMxCardRadius,
    boxShadow: kMxShadow,
  ),
  clipBehavior: Clip.antiAlias,
  child: Material(
    type: MaterialType.transparency,
    child: Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
          tiles[i],
        ],
      ],
    ),
  ),
);

/// One list row style: 16/600 title, 14 muted subtitle (one line).
Widget _row({
  required Widget leading,
  required String title,
  Key? key,
  String subtitle = '',
  Widget? trailing,
  VoidCallback? onTap,
  Color? titleColor,
}) => ListTile(
  key: key,
  minVerticalPadding: 12,
  contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 12, 0),
  leading: leading,
  title: Text(
    title,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: titleColor ?? kMxInk,
    ),
  ),
  subtitle:
      subtitle.isEmpty
          ? null
          : Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: kMxMuted),
          ),
  trailing: trailing,
  onTap: onTap,
);

/// List-row icon standing in a small doorway arch; the arch's color is the
/// status (gold ok · petrol in progress · crimson fault/urgent).
Widget _dot(Object icon, {Color color = kMxPrimary}) => MxArchBadge(
  icon,
  color: switch (color) {
    kMxBad => kMxBad,
    kMxWarn => kMxPrimary,
    kMxMuted => const Color(0xFFC9C6B5),
    _ => kMxAccent,
  },
  iconColor: color == kMxBad ? kMxBad : kMxPrimary,
);

/// The delivery truck, mirrored so it drives "forward" in RTL.
Widget _truck({double size = 20, Color? color}) => Transform.flip(
  flipX: true,
  child: Icon(Icons.local_shipping_outlined, size: size, color: color),
);

/// Quiet end-of-list line ("זה הכול · 2 מסגרות").
Widget _endNote(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
  child: Center(
    child: Text(text, style: const TextStyle(fontSize: 12, color: kMxMuted)),
  ),
);

/// Page title for tab bodies (H1 24/700 + one muted line).
Widget _pageTitle(String title, [String sub = '']) => Padding(
  padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 8),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
      if (sub.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            mxNb(sub),
            style: const TextStyle(color: kMxMuted, fontSize: 14, height: 1.4),
          ),
        ),
    ],
  ),
);

String _woStatus(MxWoStatus s) => switch (s) {
  MxWoStatus.open => 'חדשה',
  MxWoStatus.assigned => 'אצל טכנאי',
  MxWoStatus.waitingPart => 'ממתין לחלק',
  MxWoStatus.done => 'טופלה',
  MxWoStatus.cancelled => 'בוטלה',
};

/// Red is not a status color any more: new = petrol, waiting = gold.
Color _woColor(MxWoStatus s) => switch (s) {
  MxWoStatus.open => _brand,
  MxWoStatus.assigned || MxWoStatus.waitingPart => _warn,
  _ => kMxMuted,
};

String _poStatus(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval => 'ממתין לאישור',
  MxPoStatus.approved => 'אושר – טרם נשלח',
  MxPoStatus.sent => 'נשלח לחנות',
  MxPoStatus.storeConfirmed => 'החנות אישרה',
  MxPoStatus.storePartial => 'חסרים פריטים',
  MxPoStatus.ready => 'מוכן',
  MxPoStatus.received => 'התקבל',
  MxPoStatus.rejected => 'נדחה',
};

Color _poColor(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval ||
  MxPoStatus.approved ||
  MxPoStatus.storePartial => _warn,
  MxPoStatus.received || MxPoStatus.rejected => kMxMuted,
  _ => _brand,
};

/// "8 בנוב׳" — Hebrew short date (no LTR digit run to flip).
String _date(DateTime d) => mxShortDate(d);

/// "8 בנוב׳ · 16:10".

String _byRole(MxRole role) => switch (role) {
  MxRole.staff => kMxStaffLabel,
  MxRole.tech => kMxTechName,
  _ => kMxManagerName,
};

// ── shell ────────────────────────────────────────────────────────────────────

class MxHome extends ConsumerStatefulWidget {
  const MxHome({super.key});
  @override
  ConsumerState<MxHome> createState() => _MxHomeState();
}

typedef _Tab = (String key, MxGlyph icon, String label);

const List<(MxRole, String, String)> _roles = [
  (MxRole.manager, 'מנהל', 'לוח, קריאות, תחזוקה ורכש'),
  (MxRole.tech, 'טכנאי', 'המשימות שלי, חלקים'),
  (MxRole.staff, 'צוות בית', 'דיווח תקלה מהדירה'),
  (MxRole.store, 'חנות', 'מה שבעל הטמבור רואה'),
];

/// The staff report wizard hides the bottom navigation while it runs.
final _wizardProvider = StateProvider<bool>((_) => false);

class _MxHomeState extends ConsumerState<MxHome> {
  int _tab = 0;

  List<_Tab> _tabs(MxRole role) => switch (role) {
    MxRole.manager => const [
      ('home', MxGlyphs.board, 'לוח'),
      ('sites', MxGlyphs.sites, 'מסגרות'),
      ('wo', MxGlyphs.wrench, 'קריאות'),
      ('pm', MxGlyphs.calendarCheck, 'תחזוקה'),
      ('buy', MxGlyphs.cart, 'רכש'),
    ],
    MxRole.tech => const [
      ('wo', MxGlyphs.wrench, 'המשימות שלי'),
      ('sites', MxGlyphs.sites, 'מסגרות'),
      ('buy', MxGlyphs.cart, 'רכש'),
    ],
    MxRole.staff => const [
      ('report', MxGlyphs.megaphone, 'דיווח תקלה'),
      ('wo', MxGlyphs.list, 'הדיווחים שלי'),
    ],
    MxRole.store => const [('store', MxGlyphs.store, 'הזמנות')],
  };

  void _go(String key, {String? sub}) {
    final i = _tabs(ref.read(mxRoleProvider)).indexWhere((t) => t.$1 == key);
    if (sub != null) ref.read(_buySectionProvider.notifier).state = sub;
    if (i >= 0) setState(() => _tab = i);
  }

  /// Role-scoped badge: only what this person has to act on.
  int _badge(MxDb db, MxRole role, String key) => switch ((role, key)) {
    (MxRole.manager, 'wo') =>
      db.workOrders.where((w) => w.status == MxWoStatus.open).length,
    (MxRole.manager, 'buy') => db.pendingApproval.length,
    (MxRole.tech, 'wo') =>
      db.workOrders
          .where(
            (w) =>
                w.isOpen &&
                (w.assignee == kMxTechName ||
                    (w.status == MxWoStatus.open && w.urgent)),
          )
          .length,
    (MxRole.staff, 'wo') =>
      db.workOrders
          .where((w) => w.isOpen && w.reportedBy == kMxStaffLabel)
          .length,
    _ => 0,
  };

  Future<void> _reset() async {
    final yes = await _confirm(
      context,
      title: 'לאפס את ההדגמה?',
      body:
          'כל הקריאות, ההזמנות והשינויים שנעשו כאן יימחקו, והנתונים יחזרו לדוגמה.',
      ok: 'אפס את ההדגמה',
      danger: true,
    );
    if (!yes || !mounted) return;
    ref.read(mxDbProvider.notifier).reset();
    _toast(context, null, 'ההדגמה אופסה');
  }

  Future<void> _pickRole() async {
    final cur = ref.read(mxRoleProvider);
    final picked = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (ctx) => SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: _sheetTitle(
                      'החלפת תפקיד',
                      'בהדגמה בלבד. במערכת האמיתית כל אחד נכנס עם המשתמש שלו.',
                    ),
                  ),
                  for (final (r, label, sub) in _roles)
                    _row(
                      key: Key('role-$label'),
                      leading: MxAvatar(label, size: 40),
                      title: label,
                      subtitle: sub,
                      trailing:
                          r == cur
                              ? const Icon(Icons.check_rounded, color: _brand)
                              : null,
                      onTap: () => Navigator.pop(ctx, r),
                    ),
                  const Divider(height: 16, indent: 24, endIndent: 24),
                  _row(
                    key: const Key('mx-sample'),
                    leading: _dot(Icons.play_circle_outline_rounded),
                    title: 'טעינת יום עבודה לדוגמה',
                    subtitle: 'קריאות, הזמנות ותקלה דחופה, להצגה',
                    onTap: () => Navigator.pop(ctx, 'sample'),
                  ),
                  _row(
                    key: const Key('mx-reset'),
                    leading: _dot(Icons.restart_alt_rounded, color: _bad),
                    title: 'איפוס נתוני ההדגמה',
                    titleColor: _bad,
                    onTap: () => Navigator.pop(ctx, 'reset'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
    );
    if (!mounted) return;
    if (picked == 'reset') return _reset();
    if (picked == 'sample') {
      _loadSampleDay(ref);
      setState(() => _tab = 0);
      return _toast(context, null, 'נטען יום עבודה לדוגמה');
    }
    if (picked is MxRole && picked != cur) {
      ref.read(mxRoleProvider.notifier).state = picked;
      ref.read(_wizardProvider.notifier).state = false;
      setState(() => _tab = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(mxRoleProvider);
    final db = ref.watch(mxDbProvider);
    final wizard = ref.watch(_wizardProvider) && role == MxRole.staff;
    final tabs = _tabs(role);
    final tab = _tab.clamp(0, tabs.length - 1);
    final roleLabel = _roles.firstWhere((r) => r.$1 == role).$2;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        // ב״ה sits fixed in the top corner, above the wordmark — it never
        // moves with the role chip.
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ב״ה',
              style: TextStyle(
                color: kMxAccent,
                fontSize: 10,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: kMxWordmark,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '  $kMxSubtitle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xB3FFFFFF),
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          MxRoleChip(
            key: const Key('mx-roles'),
            label: roleLabel,
            onTap: _pickRole,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: switch (tabs[tab].$1) {
        'home' => _Dashboard(onGo: _go),
        'sites' => const _SitesPage(),
        'wo' => const _WorkOrdersPage(),
        'pm' => const _PmPage(),
        'buy' => const _BuyPage(),
        'report' => _ReportPage(onSent: () => _go('wo')),
        _ => const _StoreInbox(),
      },
      bottomNavigationBar:
          tabs.length < 2 || wizard
              ? null
              : DecoratedBox(
                decoration: const BoxDecoration(boxShadow: kMxShadow2),
                child: NavigationBar(
                  selectedIndex: tab,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  height: 68,
                  onDestinationSelected: (i) {
                    HapticFeedback.selectionClick();
                    setState(() => _tab = i);
                  },
                  destinations: [
                    for (final t in tabs)
                      NavigationDestination(
                        icon: Badge(
                          isLabelVisible: _badge(db, role, t.$1) > 0,
                          label: Text('${_badge(db, role, t.$1)}'),
                          child: MxNavIcon(t.$2),
                        ),
                        selectedIcon: Badge(
                          isLabelVisible: _badge(db, role, t.$1) > 0,
                          label: Text('${_badge(db, role, t.$1)}'),
                          child: MxNavIcon(t.$2, selected: true),
                        ),
                        label: t.$3,
                      ),
                  ],
                ),
              ),
    );
  }
}

/// A realistic "Sunday morning" for a live demo: an urgent outlet in a
/// kitchen, a dripping faucet with the technician, a toilet waiting for a
/// part, a new light fault — on top of the demo data (resets clean).
void _loadSampleDay(WidgetRef ref) {
  final n = ref.read(mxDbProvider.notifier);
  MxDb db() => ref.read(mxDbProvider);
  String pt(String unit, String room, String type) {
    final r = db().roomsOf(unit).firstWhere((r) => r.name.contains(room));
    return db().pointsOf(r.id).firstWhere((p) => p.type == type).id;
  }

  bool free(String id) => mxOpenOnPoint(db(), id) == null;
  final faucet = pt('bsh-1', 'מטבח', 'ברז');
  if (free(faucet) && n.report(faucet, 'מטפטף', 'צוות הבית – דירה 1') == null) {
    n.assign(n.lastCreatedId!, kMxTechName);
  }
  final toilet = pt('jrs-1', 'רחצה', 'אסלה');
  if (free(toilet) &&
      n.report(toilet, 'לא מפסיק למלא', 'צוות הבית – דירה 1') == null) {
    final id = n.lastCreatedId!;
    n
      ..assign(id, kMxTechName)
      ..requestPart(id, 1, kMxTechName);
  }
  final light = pt('jrs-2', 'מטבח', 'גוף תאורה');
  if (free(light)) n.report(light, 'מהבהב', 'צוות הבית – דירה 2');
  final outlet = pt(kMxStaffUnit, 'מטבח', 'שקע');
  if (free(outlet)) {
    n.report(outlet, 'ניצוצות / ריח שרוף – ליד הכיור', kMxStaffLabel);
  }
}

/// Which section of the "רכש" tab is open ('orders' / 'stock').
final _buySectionProvider = StateProvider<String>((_) => 'orders');

// ── dashboard ────────────────────────────────────────────────────────────────

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.onGo});
  final void Function(String, {String? sub}) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final due = db.pmDue(now);
    final overdue = due.where((d) => d.$2 == MxDue.overdue).length;
    final soon = due.where((d) => d.$2 == MxDue.soon).length;
    final openList = mxSortedOpen(db.openWorkOrders);
    final urgent = openList.where((w) => w.urgent).toList();
    final open = openList.length;
    final pending = db.pendingApproval.length;
    String unitOf(MxWorkOrder w) {
      final u = db.unit(db.room(db.point(w.pointId).roomId).unitId);
      return '${db.site(u.siteId).city} ${u.name}';
    }

    final parts = <String>[
      if (overdue > 0)
        overdue == 1 ? 'בדיקה אחת באיחור' : '$overdue בדיקות באיחור',
      if (pending > 0)
        pending == 1 ? 'הזמנה אחת לאישורך' : '$pending הזמנות לאישורך',
    ];
    // Urgent changes the greeting itself — never "all calm" over a fire.
    final summary =
        urgent.isNotEmpty
            ? '${urgent.first.desc.split(' – ').first}$_sep${unitOf(urgent.first)}$_sep${mxAgo(urgent.first.createdAt, now)}'
            : parts.isEmpty
            ? 'הבית מטופל. אין משימות דחופות.'
            : '${parts.join(', ')}.';
    final stats = [
      (
        'urgent',
        urgent.length,
        'תקלות דחופות',
        MxGlyphs.warning,
        _bad,
        () => onGo('wo'),
      ),
      ('wo', open, 'קריאות פתוחות', MxGlyphs.wrench, _brand, () => onGo('wo')),
      (
        'overdue',
        overdue,
        'בדיקות באיחור',
        MxGlyphs.calendarCheck,
        _bad,
        () => onGo('pm'),
      ),
      (
        'soon',
        soon,
        'בדיקות השבוע',
        MxGlyphs.calendarCheck,
        _warn,
        () => onGo('pm'),
      ),
      (
        'po',
        pending,
        'הזמנות לאישור',
        MxGlyphs.cart,
        _warn,
        () => onGo('buy', sub: 'orders'),
      ),
      (
        'low',
        db.lowStock.length,
        'חלקים להזמין',
        MxGlyphs.box,
        _warn,
        () => onGo('buy', sub: 'stock'),
      ),
    ];
    final active = stats.where((x) => x.$2 > 0).toList();
    final calm = stats.where((x) => x.$2 == 0).toList();
    // The street: every apartment as an arch, by site.
    final street = [
      for (final site in db.sites)
        (
          '${site.city} – ${site.name}',
          [
            for (final u in db.unitsOf(site.id))
              (
                u.id,
                u.name,
                openList.any((w) => w.urgent && _inUnit(db, w, u.id))
                    ? 2
                    : openList.any((w) => _inUnit(db, w, u.id))
                    ? 1
                    : 0,
              ),
          ],
        ),
    ];
    final allGood = street.every((g) => g.$2.every((h) => h.$3 == 0));
    final shabbat = allGood && now.weekday == DateTime.friday && now.hour >= 10;
    final todo = [
      for (final (r, d) in due.where((d) => d.$2 != MxDue.ok))
        _row(
          leading: _dot(
            r.isLegal ? MxGlyphs.legal : MxGlyphs.calendarCheck,
            color: d == MxDue.overdue ? _bad : _warn,
          ),
          title: r.title,
          subtitle: '${r.scope}$_sep${_date(r.nextDue)}',
          trailing: MxTag(
            d == MxDue.overdue ? 'באיחור' : 'השבוע',
            d == MxDue.overdue ? _bad : _warn,
          ),
          onTap: () => onGo('pm'),
        ),
      for (final w in openList.where((w) => !w.urgent))
        _row(
          leading: _dot(mxPointGlyph(db.point(w.pointId).type)),
          title: w.desc,
          subtitle: db.pointPath(w.pointId),
          trailing: MxTag(_woStatus(w.status), _woColor(w.status)),
          onTap: () => _open(context, _WorkOrderPage(w.id)),
        ),
    ];
    Widget tile((String, int, String, MxGlyph, Color, VoidCallback) x, int i) =>
        Expanded(
          child: MxAppear(
            index: i * 2,
            child: MxStatCard(
              key: Key('kpi-${x.$1}'),
              value: x.$2,
              label: x.$3,
              icon: x.$4,
              color: x.$5,
              onTap: x.$6,
            ),
          ),
        );
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        for (final w in urgent)
          MxAppear(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Material(
                color: kMxPink,
                borderRadius: kMxCardRadius,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: Key('urgent-${w.id}'),
                  onTap: () => _open(context, _WorkOrderPage(w.id)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _dot(MxGlyphs.warning, color: _bad),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'דחוף: ${w.desc}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _bad,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${db.pointPath(w.pointId)}$_sep${_woStatus(w.status)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: kMxInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: _bad),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        MxHero(
          eyebrow: mxHebrewDate(now),
          eyebrow2: mxDateLabel(now),
          title: urgent.isNotEmpty ? 'תקלה דחופה' : mxGreeting(now),
          subtitle: summary,
          count: open,
          countLabel: 'קריאות\nפתוחות',
          alert: urgent.isNotEmpty,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < active.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 12),
                Row(
                  children: [
                    tile(active[i], i),
                    const SizedBox(width: 12),
                    if (i + 1 < active.length)
                      tile(active[i + 1], i + 1)
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Zero metrics fold into one calm line (still tappable).
        if (calm.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final x in calm)
                  Semantics(
                    button: true,
                    label: '${x.$3}: אין',
                    excludeSemantics: true,
                    onTap: x.$6,
                    child: InkWell(
                      key: Key('kpi-${x.$1}'),
                      borderRadius: BorderRadius.circular(kMxR12),
                      onTap: x.$6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(kMxR12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const MxIcon(
                              MxGlyphs.check,
                              size: 16,
                              color: kMxAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              x.$3,
                              style: const TextStyle(
                                fontSize: 14,
                                color: kMxMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        MxSectionTitle(
          shabbat
              ? 'הבית בסדר. שבת שלום.'
              : allGood
              ? 'הבתים · הכול בסדר'
              : 'הבתים',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: MxCard(
            margin: EdgeInsets.zero,
            child: MxStreet(
              groups: street,
              celebrate: shabbat,
              onTap: (id) => _open(context, _UnitPage(id)),
            ),
          ),
        ),
        const MxSectionTitle('מה לטפל היום'),
        if (todo.isEmpty)
          const MxEmpty(
            icon: MxGlyphs.check,
            success: true,
            title: 'הבית מטופל',
            body: 'אין בדיקות או קריאות שמחכות היום.',
          )
        else
          _listCard(todo),
      ],
    );
  }
}

bool _inUnit(MxDb db, MxWorkOrder w, String unitId) =>
    db.room(db.point(w.pointId).roomId).unitId == unitId;

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

/// A pushed page: the same petrol bar as everywhere, optional sticky bar.
Scaffold _page(String title, Widget body, {Widget? bottom, bool back = true}) =>
    Scaffold(
      appBar: AppBar(automaticallyImplyLeading: back, title: Text(title)),
      body: body,
      bottomNavigationBar: bottom,
    );

// ── sites → unit → room → point ──────────────────────────────────────────────

class _SitesPage extends ConsumerStatefulWidget {
  const _SitesPage();
  @override
  ConsumerState<_SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends ConsumerState<_SitesPage> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    int faulty(String siteId) => [
      for (final u in db.unitsOf(siteId)) db.faultyCountOfUnit(u.id),
    ].fold(0, (a, b) => a + b);
    final q = _q.trim();
    bool hit(String s) => q.isNotEmpty && s.contains(q);
    final sites =
        q.isEmpty
            ? db.sites
            : db.sites
                .where((s) => hit('${s.city} ${s.name} ${s.address}'))
                .toList();
    final points =
        q.isEmpty
            ? const <MxPoint>[]
            : db.points
                .where((p) => hit('${p.label} ${db.pointPath(p.id)}'))
                .take(40)
                .toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(
          'המסגרות',
          '${db.sites.length} מסגרות$_sep${db.points.length} נקודות במעקב',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            key: const Key('site-search'),
            onChanged: (v) => setState(() => _q = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded, color: kMxMuted),
              hintText: 'חיפוש מסגרת, דירה או נקודה',
            ),
          ),
        ),
        if (sites.isNotEmpty)
          _listCard([
            for (final s in sites)
              _row(
                key: Key('site-${s.id}'),
                leading: _dot(Icons.apartment_outlined),
                title: '${s.city} – ${s.name}',
                subtitle:
                    '${db.unitsOf(s.id).length} דירות${s.address.isEmpty ? '' : '$_sep${s.address}'}',
                trailing:
                    faulty(s.id) > 0
                        ? MxTag('${faulty(s.id)} תקלות', _bad)
                        : const Icon(
                          Icons.chevron_right_rounded,
                          color: kMxZero,
                        ),
                onTap: () => _open(context, _SitePage(s.id)),
              ),
          ]),
        if (q.isEmpty)
          _endNote(
            'זה הכול$_sep${mxCount(sites.length, 'מסגרת אחת', 'מסגרות')}',
          ),
        if (points.isNotEmpty) ...[
          MxSectionTitle('נקודות', count: points.length),
          _listCard([
            for (final p in points)
              _row(
                key: Key('find-${p.id}'),
                leading: _dot(
                  mxPointGlyph(p.type),
                  color: p.status == MxPointStatus.faulty ? _bad : _brand,
                ),
                title: p.label,
                subtitle: db.pointPath(p.id),
                onTap: () => _open(context, _PointPage(p.id)),
              ),
          ]),
        ],
        if (q.isNotEmpty && sites.isEmpty && points.isEmpty)
          const MxEmpty(
            icon: Icons.search_off_rounded,
            title: 'לא נמצא',
            body: 'נסו מילה אחרת, למשל "ברז" או "דירה 3".',
          ),
      ],
    );
  }
}

class _SitePage extends ConsumerWidget {
  const _SitePage(this.siteId);
  final String siteId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final s = db.site(siteId);
    return _page(
      '${s.city} – ${s.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          MxSectionTitle('דירות', count: db.unitsOf(siteId).length),
          MxTileGrid(
            children: [
              for (final u in db.unitsOf(siteId))
                MxTile(
                  key: Key('unit-${u.id}'),
                  icon: Icons.door_front_door_outlined,
                  label: u.name,
                  caption:
                      db.faultyCountOfUnit(u.id) > 0
                          ? '${db.faultyCountOfUnit(u.id)} תקלות פתוחות'
                          : '${db.pointCountOfUnit(u.id)} נקודות, תקין',
                  alert: db.faultyCountOfUnit(u.id) > 0,
                  onTap: () => _open(context, _UnitPage(u.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitPage extends ConsumerWidget {
  const _UnitPage(this.unitId);
  final String unitId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final u = db.unit(unitId);
    return _page(
      '${db.site(u.siteId).city}$_sep${u.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          () {
            final open = db.openWorkOrders.where((w) => _inUnit(db, w, u.id));
            final urgent = open.any((w) => w.urgent);
            return MxCard(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Hero(
                    tag: 'house-${u.id}',
                    child: Container(
                      width: 32,
                      height: 42,
                      decoration: ShapeDecoration(
                        color:
                            urgent
                                ? kMxBad
                                : open.isNotEmpty
                                ? kMxTealTint
                                : kMxGoldTint,
                        shape: MxArchBorder(
                          side: BorderSide(
                            color: mxArchTone(
                              fault: urgent,
                              open: open.isNotEmpty,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      open.isEmpty
                          ? 'הכול תקין בדירה'
                          : urgent
                          ? 'יש תקלה דחופה בדירה'
                          : mxCount(
                            open.length,
                            'קריאה פתוחה אחת',
                            'קריאות פתוחות',
                          ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: urgent ? kMxBad : kMxInk,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }(),
          MxSectionTitle('חדרים', count: db.roomsOf(unitId).length),
          MxTileGrid(
            children: [
              for (final r in db.roomsOf(unitId))
                MxTile(
                  key: Key('room-${r.id}'),
                  icon: mxRoomGlyph(r.name),
                  label: r.name,
                  caption: '${db.pointsOf(r.id).length} נקודות',
                  alert: db
                      .pointsOf(r.id)
                      .any((p) => p.status == MxPointStatus.faulty),
                  onTap: () => _open(context, _RoomPage(r.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A room's points as a compact list grouped by type; a location shared by
/// the whole group moves up to the group title instead of repeating.
class _RoomPage extends ConsumerWidget {
  const _RoomPage(this.roomId);
  final String roomId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final r = db.room(roomId);
    final u = db.unit(r.unitId);
    final pts = db.pointsOf(roomId);
    final bad = pts.where((p) => p.status == MxPointStatus.faulty).length;
    final types = <String>{for (final p in pts) p.type}.toList();
    return _page(
      '${u.name}$_sep${r.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          MxCard(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // The printed door sticker: petrol, gold arch, QR inside.
                Container(
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: kMxPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const MxArch(
                    width: 40,
                    height: 56,
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: 20,
                      color: Colors.white,
                      semanticLabel: 'מדבקת QR של החדר',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bad == 0
                            ? '${pts.length} נקודות, הכול תקין'
                            : '${pts.length} נקודות, $bad תקולות',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: bad == 0 ? kMxInk : _bad,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'מדבקה על דלת החדר פותחת את המסך הזה.',
                        style: TextStyle(color: kMxMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final t in types) ...[
            () {
              final group = pts.where((p) => p.type == t).toList();
              final shared =
                  group.every((p) => p.loc == group.first.loc)
                      ? group.first.loc
                      : '';
              return MxSectionTitle(
                shared.isEmpty ? t : '$t$_sep$shared',
                count: group.length,
              );
            }(),
            _listCard([
              for (final p in pts.where((p) => p.type == t))
                _row(
                  key: Key('pt-${p.id}'),
                  leading: _dot(
                    mxPointGlyph(p.type),
                    color: p.status == MxPointStatus.faulty ? _bad : _brand,
                  ),
                  title: '${p.type} ${p.num}',
                  subtitle:
                      pts.where((x) => x.type == t).every((x) => x.loc == p.loc)
                          ? ''
                          : p.loc,
                  trailing:
                      p.status == MxPointStatus.faulty
                          ? const MxTag('תקול', _bad)
                          : const Icon(
                            Icons.chevron_right_rounded,
                            color: kMxZero,
                          ),
                  onTap: () => _open(context, _PointPage(p.id)),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// After an urgent report: the full-screen safety takeover.
Future<void> _showSafety(
  BuildContext context,
  WidgetRef ref,
  MxWorkOrder w,
  String type, {
  VoidCallback? onMine,
}) => mxShowSafety(
  context,
  title: mxSafetyTitle(type, w.desc),
  steps: mxSafetySteps(type, w.desc),
  callLabel:
      kMxManagerPhone.isEmpty
          ? 'התקשרו ל$kMxManagerTitle'
          : 'התקשרו ל$kMxManagerTitle ${_ltr(kMxManagerPhone)}',
  onCall: () => _call(ref, context, kMxManagerPhone),
  onDone: onMine ?? () {},
);

class _PointPage extends ConsumerWidget {
  const _PointPage(this.pointId);
  final String pointId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final p = db.point(pointId);
    final part = db.part(p.sku);
    final role = ref.watch(mxRoleProvider);
    final faulty = p.status == MxPointStatus.faulty;
    final low = db.qty(p.sku) < part.min;
    final openWo = mxOpenOnPoint(db, pointId);
    return _page(
      '${p.type} ${p.num}',
      ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          MxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MxArch(
                      width: 48,
                      height: 60,
                      color: faulty ? _bad : kMxAccent,
                      child: mxIcon(
                        mxPointGlyph(p.type),
                        size: 22,
                        color: faulty ? _bad : _brand,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.spec,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (p.loc.isNotEmpty)
                            Text(
                              p.loc,
                              style: const TextStyle(
                                color: kMxMuted,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (faulty)
                      const MxTag('תקול', _bad)
                    else
                      const MxTag('תקין', _ok),
                  ],
                ),
                const Divider(height: 24),
                MxInfoRow(
                  Icons.place_outlined,
                  'מיקום',
                  Text(db.pointPath(pointId)),
                ),
                MxInfoRow(
                  Icons.build_circle_outlined,
                  'חלק החלפה',
                  Text(part.name),
                ),
                MxInfoRow(
                  Icons.inventory_2_outlined,
                  'במלאי',
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${db.qty(p.sku)} יח׳'),
                      if (low) const MxTag('מתחת למינימום', _warn),
                    ],
                  ),
                ),
                MxInfoRow(
                  Icons.event_repeat_outlined,
                  'תחזוקה',
                  Text(p.pm.isEmpty ? 'אין' : p.pm),
                ),
              ],
            ),
          ),
          if (openWo != null)
            _listCard([
              _row(
                key: const Key('point-open-wo'),
                leading: _dot(
                  openWo.urgent ? Icons.warning_amber_rounded : Icons.build,
                  color: openWo.urgent ? _bad : _brand,
                ),
                title: '${mxWoLabel(openWo.id)} פתוחה: ${openWo.desc}',
                subtitle: _woStatus(openWo.status),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _open(context, _WorkOrderPage(openWo.id)),
              ),
            ]),
          MxSectionTitle('היסטוריה', count: p.history.length),
          if (p.history.isEmpty)
            const MxEmpty(
              icon: Icons.history_rounded,
              title: 'עוד אין טיפולים',
              body: 'כל תיקון בנקודה הזו יירשם כאן אוטומטית.',
            )
          else
            _listCard([
              for (final e in p.history)
                _row(
                  leading: MxAvatar(e.by),
                  title: e.text,
                  subtitle:
                      '${_date(e.at)}$_sep${e.by}${e.costAgorot > 0 ? '$_sep${mxShekels(e.costAgorot)}' : ''}',
                ),
            ]),
        ],
      ),
      bottom: MxBottomBar(
        children: [
          if (openWo != null)
            MxPrimaryButton(
              key: const Key('report-point'),
              label: 'כבר דווח – הוסיפו הערה לקריאה',
              icon: Icons.add_comment_outlined,
              onPressed: () async {
                final text = await _askText(
                  context,
                  'הערה ל${mxWoLabel(openWo.id)}',
                  'מה עוד חשוב לדעת?',
                );
                if (text == null || text.trim().isEmpty || !context.mounted) {
                  return;
                }
                _toast(
                  context,
                  ref
                      .read(mxDbProvider.notifier)
                      .comment(openWo.id, text, _byRole(role)),
                  'ההערה נוספה ל${mxWoLabel(openWo.id)}',
                );
              },
            )
          else
            MxPrimaryButton(
              key: const Key('report-point'),
              label: 'דווחו על תקלה בנקודה הזו',
              icon: Icons.campaign_outlined,
              onPressed: () async {
                final text = await _askFault(context, p.type);
                if (text == null || !context.mounted) return;
                final n = ref.read(mxDbProvider.notifier);
                final err = n.report(pointId, text, _byRole(role));
                if (err != null) return _toast(context, err, '');
                final w = ref.read(mxDbProvider).workOrder(n.lastCreatedId!);
                if (w.urgent) {
                  await _showSafety(context, ref, w, p.type);
                } else {
                  _toast(context, null, 'נפתחה ${mxWoLabel(w.id)}');
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Same ready-made reasons as the staff report, in a sheet.
Future<String?> _askFault(BuildContext context, String type) {
  final text = TextEditingController();
  var reason = '';
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setSheet) => Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  0,
                  24,
                  16 + MediaQuery.viewInsetsOf(ctx).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sheetTitle('מה קרה?'),
                    _reasonChips(
                      'fault-reason',
                      type,
                      reason,
                      (r) => setSheet(() => reason = reason == r ? '' : r),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const Key('fault-text'),
                      controller: text,
                      onChanged: (_) => setSheet(() {}),
                      decoration: const InputDecoration(
                        labelText: 'פרטים נוספים (לא חובה)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sheetButtons(
                      okKey: const Key('fault-send'),
                      ok: 'פתחו קריאה',
                      onOk:
                          reason.isEmpty && text.text.trim().isEmpty
                              ? null
                              : () => Navigator.pop(
                                ctx,
                                [
                                  reason,
                                  text.text.trim(),
                                ].where((x) => x.isNotEmpty).join(' – '),
                              ),
                      onCancel: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
        ),
  );
}

/// Ready-made fault reasons (choice chips, 44 dp); urgent ones carry a ⚠.
Widget _reasonChips(
  String keyPrefix,
  String type,
  String selected,
  ValueChanged<String> onTap,
) => Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    for (final (i, r) in mxQuickReasons(type).indexed)
      ChoiceChip(
        key: Key('$keyPrefix-$i'),
        avatar:
            mxIsUrgentText(r)
                ? Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: selected == r ? Colors.white : _bad,
                )
                : null,
        label: Text(
          r,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected == r ? Colors.white : kMxInk,
          ),
        ),
        selected: selected == r,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        selectedColor: kMxPrimary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected == r ? kMxPrimary : const Color(0xFFC9C7B4),
        ),
        onSelected: (_) {
          HapticFeedback.selectionClick();
          onTap(r);
        },
      ),
  ],
);

/// Quantity for a part request: quick picks (one tap) or + / − and confirm.
Future<int?> _askQty(BuildContext context, String partName) {
  var q = 1;
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder:
        (ctx) => StatefulBuilder(
          builder:
              (ctx, setSheet) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _sheetTitle('כמה להזמין?', partName),
                      const Text(
                        'בחירה מהירה',
                        style: TextStyle(color: kMxMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final v in const [1, 2, 4, 10]) ...[
                            if (v != 1) const SizedBox(width: 8),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: OutlinedButton(
                                  key: Key('qty-$v'),
                                  onPressed: () => Navigator.pop(ctx, v),
                                  child: Text(
                                    '$v',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: kMxTabular,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'כמות אחרת',
                        style: TextStyle(color: kMxMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          MxStepper(
                            keyPrefix: 'qty',
                            value: q,
                            min: 1,
                            onChanged: (v) => setSheet(() => q = v),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton(
                                key: const Key('qty-ok'),
                                onPressed: () => Navigator.pop(ctx, q),
                                child: Text('הזמינו $q'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ),
  );
}

/// A short text question (comment, rejection reason, price list).
/// [ltr] = machine text (CSV): left-to-right, monospace.
Future<String?> _askText(
  BuildContext context,
  String title,
  String hint, {
  String initial = '',
  List<String> quick = const [],
  String ok = 'אישור',
  int maxLines = 3,
  bool ltr = false,
  String help = '',
}) {
  final c = TextEditingController(text: initial);
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (ctx) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            16 + MediaQuery.viewInsetsOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sheetTitle(title, help),
              if (quick.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (i, s) in quick.indexed)
                      ActionChip(
                        key: Key('ask-quick-$i'),
                        label: Text(s),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFC9C7B4)),
                        onPressed: () => c.text = s,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                key: const Key('ask-text'),
                controller: c,
                autofocus: quick.isEmpty && !ltr,
                maxLines: maxLines,
                minLines: 1,
                textDirection: ltr ? TextDirection.ltr : null,
                style:
                    ltr
                        ? const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          height: 1.45,
                        )
                        : null,
                decoration: InputDecoration(hintText: hint),
              ),
              const SizedBox(height: 16),
              _sheetButtons(
                okKey: const Key('ask-ok'),
                ok: ok,
                onOk: () => Navigator.pop(ctx, c.text),
                onCancel: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
  );
}

String _load(int n) => switch (n) {
  0 => 'פנוי, אין קריאות פתוחות',
  1 => 'קריאה פתוחה אחת',
  _ => '$n קריאות פתוחות',
};

/// Pick a technician; each row shows how many open jobs they already hold.
Future<String?> _askTech(BuildContext context, MxDb db) =>
    showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: _sheetTitle('למי לשייך?'),
                ),
                for (final (i, t) in kMxTechs.indexed)
                  _row(
                    key: Key('tech-$i'),
                    leading: MxAvatar(t, size: 40),
                    title: t,
                    subtitle: _load(mxOpenCountFor(db, t)),
                    onTap: () => Navigator.pop(ctx, t),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );

// ── work orders ──────────────────────────────────────────────────────────────

class _WorkOrdersPage extends ConsumerStatefulWidget {
  const _WorkOrdersPage();
  @override
  ConsumerState<_WorkOrdersPage> createState() => _WorkOrdersPageState();
}

class _WorkOrdersPageState extends ConsumerState<_WorkOrdersPage> {
  String _filter = 'open';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final mine = switch (role) {
      MxRole.staff => db.workOrders.where((w) => w.reportedBy == kMxStaffLabel),
      MxRole.tech => db.workOrders.where(
        (w) => w.assignee == kMxTechName || w.status == MxWoStatus.open,
      ),
      _ => db.workOrders,
    };
    final open = mxSortedOpen(mine.where((w) => w.isOpen));
    final closed = mine.where((w) => !w.isOpen).toList().reversed.toList();
    final list = switch (_filter) {
      'urgent' => open.where((w) => w.urgent).toList(),
      'new' => open.where((w) => w.status == MxWoStatus.open).toList(),
      'waiting' =>
        open.where((w) => w.status == MxWoStatus.waitingPart).toList(),
      'done' => closed,
      'all' => [...open, ...closed],
      _ => open,
    };
    final (title, sub) = switch (role) {
      MxRole.tech => ('המשימות שלי', 'קריאות ששויכו אליך וקריאות חדשות'),
      MxRole.staff => ('הדיווחים שלי', 'מה דיווחתם ומה מצב כל דיווח'),
      _ => ('קריאות שירות', 'דחופות קודם, אחר כך מהחדשה לישנה'),
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(title, sub),
        MxFilterChips(
          keyPrefix: 'wo-filter',
          items: [
            ('open', 'פתוחות', open.length),
            ('urgent', 'דחופות', open.where((w) => w.urgent).length),
            if (role != MxRole.staff)
              (
                'new',
                'חדשות',
                open.where((w) => w.status == MxWoStatus.open).length,
              ),
            ('waiting', 'ממתינות לחלק', null),
            ('done', 'טופלו', null),
            ('all', 'הכול', null),
          ],
          selected: _filter,
          onSelect: (k) => setState(() => _filter = k),
        ),
        if (list.isEmpty)
          MxEmpty(
            icon: Icons.inbox_outlined,
            success: _filter == 'open' || _filter == 'urgent',
            title:
                _filter == 'open' || _filter == 'urgent'
                    ? 'אין קריאות פתוחות'
                    : 'אין כאן קריאות',
            body:
                _filter == 'open' || _filter == 'urgent'
                    ? 'הכול מטופל. כל הכבוד!'
                    : '',
          )
        else
          _listCard([
            for (final w in list)
              _row(
                key: Key('wo-${w.id}'),
                leading: _dot(
                  w.urgent && w.isOpen
                      ? Icons.warning_amber_rounded
                      : mxPointGlyph(db.point(w.pointId).type),
                  color: w.urgent && w.isOpen ? _bad : _brand,
                ),
                title: w.desc,
                subtitle: '${mxWoLabel(w.id)}$_sep${db.pointPath(w.pointId)}',
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (w.urgent && w.isOpen) ...[
                      const MxTag('דחוף', _bad),
                      const SizedBox(height: 4),
                    ],
                    MxTag(_woStatus(w.status), _woColor(w.status)),
                  ],
                ),
                onTap: () => _open(context, _WorkOrderPage(w.id)),
              ),
          ]),
        if (list.isNotEmpty)
          _endNote(
            'זה הכול$_sep${mxCount(list.length, 'קריאה אחת', 'קריאות')}',
          ),
      ],
    );
  }
}

class _WorkOrderPage extends ConsumerWidget {
  const _WorkOrderPage(this.woId);
  final String woId;

  List<MxStep> _steps(MxWorkOrder w) {
    final s = w.status;
    final assignedOrLater = s != MxWoStatus.open;
    return [
      ('נפתחה', true, false),
      (
        s == MxWoStatus.open ? 'ממתין לטכנאי' : 'אצל טכנאי',
        assignedOrLater && s != MxWoStatus.assigned,
        s == MxWoStatus.open || s == MxWoStatus.assigned,
      ),
      if (s == MxWoStatus.waitingPart || w.poId.isNotEmpty)
        ('ממתין לחלק', s == MxWoStatus.done, s == MxWoStatus.waitingPart),
      ('טופלה', s == MxWoStatus.done, false),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    final w = db.workOrder(woId);
    final p = db.point(w.pointId);
    final part = db.part(p.sku);
    final inStock = db.qty(p.sku);
    final po = w.poId.isEmpty ? null : db.po(w.poId);
    final worker = role == MxRole.tech || role == MxRole.manager;
    final canWork =
        role == MxRole.tech &&
        (w.status == MxWoStatus.open || w.status == MxWoStatus.assigned);
    final waiting = worker && w.status == MxWoStatus.waitingPart;
    final rejected =
        w.isOpen && w.status != MxWoStatus.waitingPart
            ? w.log
                .where((e) => e.text.startsWith('בקשת החלק נדחתה'))
                .firstOrNull
            : null;
    final actions = <Widget>[
      if (role == MxRole.manager && w.status == MxWoStatus.open)
        MxPrimaryButton(
          key: const Key('wo-assign'),
          label: 'שייכו לטכנאי',
          icon: Icons.person_add_alt_rounded,
          onPressed: () async {
            final t = await _askTech(context, db);
            if (t == null || !context.mounted) return;
            _toast(context, n.assign(woId, t), 'שויך ל$t');
          },
        ),
      if (canWork) ...[
        MxPrimaryButton(
          key: const Key('wo-fix'),
          label:
              inStock < 1
                  ? 'החלק חסר במלאי – הזמינו חלק'
                  : 'תוקן, השתמשתי בחלק אחד',
          icon: Icons.check_circle_outline_rounded,
          onPressed:
              inStock < 1
                  ? null
                  : () => _undoable(
                    context,
                    ref,
                    n.closeWithPart(woId, kMxTechName),
                    'כל הכבוד! הקריאה נסגרה וירד חלק אחד מהמלאי',
                  ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    key: const Key('wo-fix-nopart'),
                    onPressed:
                        () => _undoable(
                          context,
                          ref,
                          n.closeNoPart(woId, kMxTechName),
                          'הקריאה נסגרה בלי חלק',
                        ),
                    child: const Text('תוקן בלי חלק'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    key: const Key('wo-need'),
                    onPressed: () async {
                      final qty = await _askQty(context, part.name);
                      if (qty == null || !context.mounted) return;
                      final err = n.requestPart(woId, qty, kMxTechName);
                      _toast(
                        context,
                        err,
                        'הבקשה נשלחה למנהל לאישור (${mxPoLabel(n.lastCreatedId ?? '')})',
                      );
                    },
                    child: const Text('צריך חלק'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      if (waiting) ...[
        MxPrimaryButton(
          key: const Key('wo-found'),
          label: 'מצאתי חלק ותיקנתי',
          icon: Icons.check_circle_outline_rounded,
          onPressed: () async {
            final yes = await _confirm(
              context,
              title: 'מצאתם את החלק?',
              body:
                  'הקריאה תיסגר כמתוקנת, ובקשת החלק שעוד לא נשלחה לחנות תבוטל.',
              ok: 'כן, תוקן',
            );
            if (!yes || !context.mounted) return;
            _toast(context, n.foundPart(woId, _byRole(role)), 'הקריאה נסגרה');
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SizedBox(
            height: 44,
            width: double.infinity,
            child: TextButton(
              key: const Key('wo-cancel-req'),
              onPressed: () async {
                final yes = await _confirm(
                  context,
                  title: 'לבטל את בקשת החלק?',
                  body: 'הקריאה תחזור לטכנאי, ובקשת החלק תבוטל.',
                  ok: 'בטלו את הבקשה',
                  danger: true,
                );
                if (!yes || !context.mounted) return;
                _toast(
                  context,
                  n.cancelRequest(woId, _byRole(role)),
                  'בקשת החלק בוטלה',
                );
              },
              child: const Text('בטל בקשת חלק'),
            ),
          ),
        ),
      ],
    ];
    Widget info(IconData icon, String text, {Color? color}) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? kMxPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.35,
                color: color ?? kMxInk,
                fontWeight: color == null ? null : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    final log = [
      ...w.log,
      MxEvent(at: w.createdAt, text: 'הקריאה נפתחה', by: w.reportedBy),
    ];
    return _page(
      mxWoLabel(w.id),
      ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          if (w.urgent && w.isOpen)
            MxUrgentBanner(
              title: mxSafetyTitle(p.type, w.desc),
              body: mxSafetyInstruction(p.type, w.desc),
              onCall:
                  role == MxRole.manager
                      ? null
                      : () => _call(ref, context, kMxManagerPhone),
            ),
          const SizedBox(height: 16),
          MxCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _dot(
                      mxPointGlyph(p.type),
                      color: w.urgent && w.isOpen ? _bad : _brand,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        w.desc,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MxTag(_woStatus(w.status), _woColor(w.status)),
                  ],
                ),
                const SizedBox(height: 8),
                info(Icons.place_outlined, db.pointPath(w.pointId)),
                info(
                  Icons.person_outline_rounded,
                  'דיווח: ${w.reportedBy}, ${_date(w.createdAt)}',
                ),
                if (w.assignee.isNotEmpty)
                  info(Icons.engineering_outlined, 'טכנאי: ${w.assignee}'),
                info(
                  Icons.inventory_2_outlined,
                  'חלק: ${part.name}, במלאי $inStock',
                ),
                if (po != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        _truck(color: kMxPrimary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${mxPoLabel(po.id)}: ${_poStatus(po.status)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (rejected != null)
                  info(Icons.info_outline_rounded, rejected.text, color: _bad),
                if (w.hasPhoto)
                  info(Icons.photo_camera_outlined, 'צורפה תמונה מהדירה'),
              ],
            ),
          ),
          if (w.status == MxWoStatus.done)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: _ok),
                  SizedBox(width: 8),
                  Text(
                    'הקריאה טופלה ונסגרה',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          MxTimeline(_steps(w)),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 8, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'יומן הקריאה',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton.icon(
                  key: const Key('wo-comment'),
                  icon: const Icon(Icons.add_comment_outlined, size: 20),
                  label: const Text('הוספת הערה'),
                  onPressed: () async {
                    final text = await _askText(
                      context,
                      'הערה ל${mxWoLabel(w.id)}',
                      'מה חשוב לדעת?',
                    );
                    if (text == null ||
                        text.trim().isEmpty ||
                        !context.mounted) {
                      return;
                    }
                    _toast(
                      context,
                      n.comment(woId, text, _byRole(role)),
                      'ההערה נוספה',
                    );
                  },
                ),
              ],
            ),
          ),
          MxCard(
            child: Column(
              children: [
                for (final (i, e) in log.indexed)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // The rail connects the entries, newest on top.
                        SizedBox(
                          width: 32,
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              if (i < log.length - 1)
                                const Positioned(
                                  top: 16,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: 2,
                                    child: ColoredBox(color: kMxLine),
                                  ),
                                ),
                              MxAvatar(e.by),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: i < log.length - 1 ? 16 : 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${mxAgo(e.at, now)}$_sep${e.by}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kMxMuted,
                                    fontFeatures: kMxTabular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottom: actions.isEmpty ? null : MxBottomBar(children: actions),
    );
  }
}

// ── home-staff report ────────────────────────────────────────────────────────

class _ReportPage extends ConsumerStatefulWidget {
  const _ReportPage({required this.onSent});
  final VoidCallback onSent;
  @override
  ConsumerState<_ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<_ReportPage> {
  String? _room;
  String? _point;
  String _reason = '';
  String _photo = '';
  final _text = TextEditingController();

  int get _step => _room == null ? 1 : (_point == null ? 2 : 3);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Every step change also tells the shell to hide / show the nav bar.
  void _set(VoidCallback f) {
    setState(f);
    ref.read(_wizardProvider.notifier).state = _step > 1;
  }

  void _back() => _set(() {
    if (_point != null) {
      _point = null;
      _reason = '';
    } else {
      _room = null;
    }
  });

  void _clear() => _set(() {
    _room = null;
    _point = null;
    _reason = '';
    _photo = '';
    _text.clear();
  });

  Future<void> _takePhoto() async {
    final shot = await ref.read(taskPhotoPickerProvider)(context);
    if (shot == null || shot.isEmpty || !mounted) return;
    setState(() => _photo = shot);
  }

  String get _desc =>
      [_reason, _text.text.trim()].where((s) => s.isNotEmpty).join(' – ');

  Future<void> _send() async {
    final n = ref.read(mxDbProvider.notifier);
    final existing = mxOpenOnPoint(ref.read(mxDbProvider), _point!);
    if (existing != null) {
      final err = n.comment(existing.id, _desc, kMxStaffLabel);
      if (err != null) return _toast(context, err, '');
      _clear();
      _toast(
        context,
        null,
        'נוסף ל${mxWoLabel(existing.id)} שכבר פתוחה על הנקודה הזו',
      );
      return;
    }
    final type = ref.read(mxDbProvider).point(_point!).type;
    final err = n.report(
      _point!,
      _desc,
      kMxStaffLabel,
      photo: _photo.isNotEmpty,
      photoData: _photo,
    );
    if (err != null) return _toast(context, err, '');
    final w = ref.read(mxDbProvider).workOrder(n.lastCreatedId!);
    _clear();
    if (w.urgent) {
      await _showSafety(context, ref, w, type, onMine: widget.onSent);
      return;
    }
    await mxShowSuccess(
      context,
      title: 'הדיווח נשלח',
      body:
          'מנהל האחזקה כבר יודע. תודה שדיווחת.\n${mxWoLabel(w.id)}$_sepאפשר לעקוב ב״הדיווחים שלי״.',
      actions: [
        ('לדיווחים שלי', const Key('success-mine'), widget.onSent),
        ('דיווח נוסף', const Key('success-again'), () {}),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final u = db.unit(kMxStaffUnit);
    final titles = ['איפה התקלה?', 'מה לא עובד?', 'מה קרה?'];
    final list = ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 16, 16, 4),
          child: Row(
            children: [
              if (_step > 1)
                IconButton(
                  key: const Key('rep-back'),
                  tooltip: 'חזרה',
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: _back,
                )
              else
                const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[_step - 1],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'שלב $_step מתוך 3$_sep${db.site(u.siteId).city}$_sep${u.name}',
                      style: const TextStyle(color: kMxMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              for (var i = 1; i <= 3; i++) ...[
                if (i > 1) const SizedBox(width: 4),
                Expanded(
                  child: AnimatedContainer(
                    duration: kMxEnter,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          i < _step
                              ? kMxPrimary
                              : i == _step
                              ? kMxAccent
                              : kMxLine,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: kMxEnter,
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder:
              (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
          child: Column(
            key: ValueKey(_step),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_step == 1)
                MxTileGrid(
                  children: [
                    for (final r in db.roomsOf(kMxStaffUnit))
                      MxTile(
                        key: Key('rep-room-${r.id}'),
                        icon: mxRoomGlyph(r.name),
                        label: r.name,
                        caption: '${db.pointsOf(r.id).length} פריטים',
                        alert: db
                            .pointsOf(r.id)
                            .any((p) => p.status == MxPointStatus.faulty),
                        onTap: () => _set(() => _room = r.id),
                      ),
                  ],
                ),
              if (_step == 2)
                MxTileGrid(
                  children: [
                    for (final p in db.pointsOf(_room!))
                      MxTile(
                        key: Key('rep-point-${p.id}'),
                        icon: mxPointGlyph(p.type),
                        label: '${p.type} ${p.num}',
                        caption:
                            mxOpenOnPoint(db, p.id) != null
                                ? 'כבר דווח'
                                : p.loc,
                        alert: p.status == MxPointStatus.faulty,
                        onTap: () => _set(() => _point = p.id),
                      ),
                  ],
                ),
              if (_step == 3) ..._details(db),
            ],
          ),
        ),
      ],
    );
    if (_step < 3) return list;
    final existing = mxOpenOnPoint(db, _point!);
    return Column(
      children: [
        Expanded(child: list),
        MxBottomBar(
          children: [
            MxPrimaryButton(
              key: const Key('rep-send'),
              label: existing == null ? 'שלחו דיווח' : 'הוסיפו לקריאה הקיימת',
              icon: Icons.send_rounded,
              onPressed: _desc.isEmpty ? null : _send,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _details(MxDb db) {
    final p = db.point(_point!);
    final existing = mxOpenOnPoint(db, p.id);
    return [
      _listCard([
        _row(
          leading: _dot(mxPointGlyph(p.type)),
          title: p.label,
          subtitle: db.room(p.roomId).name,
        ),
      ]),
      if (existing != null)
        Container(
          key: const Key('rep-existing'),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kMxGoldTint,
            borderRadius: BorderRadius.circular(kMxR12),
          ),
          child: Text(
            'כבר דווח על הנקודה הזו (${mxWoLabel(existing.id)}: ${existing.desc}). '
            'מה שתכתבו יתווסף לקריאה הקיימת.',
            style: const TextStyle(fontSize: 16, height: 1.45),
          ),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: _reasonChips(
          'rep-reason',
          p.type,
          _reason,
          (r) => setState(() => _reason = _reason == r ? '' : r),
        ),
      ),
      if (mxIsUrgentText(_desc))
        MxUrgentBanner(
          title: 'זו תקלה דחופה',
          body: mxSafetyInstruction(p.type, _desc),
        ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          key: const Key('rep-text'),
          controller: _text,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'פרטים נוספים (לא חובה)',
            hintText: 'לדוגמה: התחיל אתמול בערב',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const Key('rep-photo'),
            icon: Icon(
              _photo.isNotEmpty
                  ? Icons.check_circle_rounded
                  : Icons.photo_camera_outlined,
            ),
            label: Text(
              _photo.isNotEmpty
                  ? 'התמונה צורפה (לחצו לצילום מחדש)'
                  : 'צלמו תמונה (עוזר לטכנאי)',
            ),
            onPressed: _takePhoto,
          ),
        ),
      ),
    ];
  }
}

// ── preventive maintenance ───────────────────────────────────────────────────

class _PmPage extends ConsumerWidget {
  const _PmPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final all = db.pmDue(now);
    final groups = [
      ('באיחור', MxDue.overdue, _bad),
      ('השבוע', MxDue.soon, _warn),
      ('בהמשך', MxDue.ok, _brand),
    ];
    Widget card(MxPmRule r, MxDue d, Color c) => MxCard(
      key: Key('pm-${r.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              MxTag(mxDaysLabel(r.nextDue, now), c),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${r.scope}$_sepיעד ${_date(r.nextDue)}',
            style: const TextStyle(color: kMxMuted, fontSize: 14),
          ),
          if (r.isLegal)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.gavel_outlined, size: 16, color: _brand),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'חובה: ${r.legalBasis}',
                      style: const TextStyle(
                        color: _brand,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (d != MxDue.ok)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  key: Key('pm-done-${r.id}'),
                  icon: const Icon(Icons.task_alt_rounded, size: 20),
                  label: const Text('סמנו כבוצע'),
                  onPressed:
                      () => _undoable(
                        context,
                        ref,
                        ref.read(mxDbProvider.notifier).completePm(r.id),
                        'נרשם כבוצע, והמועד הבא נקבע',
                      ),
                ),
              ),
            ),
        ],
      ),
    );
    final legal = db.pmRules.where((r) => r.isLegal).length;
    final pendingNow = all.where((x) => x.$2 != MxDue.ok).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(
          'בדיקות ותחזוקה',
          '$legal בדיקות חובה בחוק. המערכת זוכרת את המועד הבא של כל אחת.',
        ),
        if (pendingNow == 0)
          const MxEmpty(
            icon: Icons.event_available_outlined,
            success: true,
            title: 'כל הבדיקות בזמן',
            body: 'אין בדיקות באיחור או השבוע.',
          ),
        for (final (title, due, color) in groups)
          if (all.any((x) => x.$2 == due)) ...[
            MxSectionTitle(
              title,
              count: all.where((x) => x.$2 == due).length,
              color: color,
            ),
            for (final (i, (r, d)) in all.where((x) => x.$2 == due).indexed)
              MxAppear(index: i, child: card(r, d, color)),
          ],
      ],
    );
  }
}

// ── purchasing: orders + stock in one tab ────────────────────────────────────

class _BuyPage extends ConsumerWidget {
  const _BuyPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(_buySectionProvider);
    final db = ref.watch(mxDbProvider);
    final pending = db.pendingApproval.length;
    final low = db.lowStock.length;
    Widget seg(String text, int n, String key, {required bool on}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, key: Key(key)),
        if (n > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: on ? kMxGoldTint : Colors.white,
              borderRadius: BorderRadius.circular(kMxR6),
            ),
            child: Text(
              '$n',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kMxWarn,
                fontFeatures: kMxTabular,
              ),
            ),
          ),
        ],
      ],
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: MxSwitch<String>(
            items: [
              (
                'orders',
                seg('הזמנות', pending, 'buy-orders', on: section == 'orders'),
              ),
              ('stock', seg('מלאי', low, 'buy-stock', on: section == 'stock')),
            ],
            selected: section,
            onChanged: (v) => ref.read(_buySectionProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: kMxEnter,
            child:
                section == 'stock'
                    ? const _StockPage(key: ValueKey('stock'))
                    : const _OrdersPage(key: ValueKey('orders')),
          ),
        ),
      ],
    );
  }
}

// ── stock ────────────────────────────────────────────────────────────────────

class _StockPage extends ConsumerStatefulWidget {
  const _StockPage({super.key});
  @override
  ConsumerState<_StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<_StockPage> {
  String _filter = 'הכול';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final types = <String>{for (final p in db.parts) p.storeType};
    final shown =
        db.parts.where((p) {
          if (_filter == 'הכול') return true;
          if (_filter == 'להזמין') return db.qty(p.sku) < p.min;
          return p.storeType == _filter;
        }).toList();
    final low = db.lowStock.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(
          low == 0 ? 'המלאי מלא' : '$low חלקים להזמין',
          low == 0
              ? 'כל החלקים מעל המינימום.'
              : 'לחיצה אחת יוצרת הזמנה נפרדת לכל חנות, לאישורך.',
        ),
        if (role == MxRole.manager) ...[
          MxPrimaryButton(
            key: const Key('auto-reorder'),
            label: low == 0 ? 'אין מה להזמין' : 'הזמינו את כל מה שחסר',
            icon: Icons.add_shopping_cart_rounded,
            onPressed:
                low == 0
                    ? null
                    : () {
                      final err = ref.read(mxDbProvider.notifier).autoReorder();
                      _toast(
                        context,
                        err,
                        'נוצרו בקשות הזמנה, אחת לכל חנות. הן מחכות לאישורך.',
                      );
                      if (err == null) {
                        ref.read(_buySectionProvider.notifier).state = 'orders';
                      }
                    },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: SizedBox(
              height: 44,
              width: double.infinity,
              child: TextButton.icon(
                key: const Key('import-prices'),
                icon: const Icon(Icons.upload_file_outlined, size: 20),
                label: const Text('קיבלתי מחירון מהחנות (אקסל או CSV)'),
                onPressed: _importPrices,
              ),
            ),
          ),
        ],
        MxFilterChips(
          keyPrefix: 'stock-filter',
          items: [
            ('הכול', 'הכול', null),
            ('להזמין', 'להזמין', low),
            for (final t in types) (t, t, null),
          ],
          selected: _filter,
          onSelect: (k) => setState(() => _filter = k),
        ),
        if (shown.isEmpty)
          const MxEmpty(
            icon: Icons.inventory_2_outlined,
            success: true,
            title: 'אין מה להזמין כאן',
            body: 'כל הפריטים בסינון הזה מעל המינימום.',
          )
        else
          _listCard([
            for (final p in shown)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${db.qty(p.sku)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            fontFeatures: kMxTabular,
                            color: db.qty(p.sku) < p.min ? _bad : kMxInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MxStockBar(qty: db.qty(p.sku), min: p.min),
                    const SizedBox(height: 4),
                    Text(
                      '${p.storeType}$_sepמינימום ${p.min}$_sep${mxShekels(db.priceAt(kMxStoreId, p.sku))}'
                      '${db.onOrder(p.sku) > 0 ? '$_sepבהזמנה ${db.onOrder(p.sku)}' : ''}',
                      style: const TextStyle(
                        color: kMxMuted,
                        fontSize: 14,
                        fontFeatures: kMxTabular,
                      ),
                    ),
                  ],
                ),
              ),
          ]),
      ],
    );
  }

  Future<void> _importPrices() async {
    const sample =
        'מק"ט,שם,מחיר\nEL-T8,פלורסנט LED T8,19.90\nEL-SK16,מנגנון שקע 16A,16.50\nHW-WSTOP,מעצור חלון,29\n';
    final db = ref.read(mxDbProvider);
    final preview = mxParsePriceList(sample, db.parts);
    Widget cell(String t, {bool head = false, bool ltr = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        t,
        textDirection: ltr ? TextDirection.ltr : null,
        style: TextStyle(
          fontSize: 14,
          fontWeight: head ? FontWeight.w600 : FontWeight.w400,
          color: head ? kMxMuted : kMxInk,
          fontFeatures: kMxTabular,
        ),
      ),
    );
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sheetTitle(
                    'המחירון שהתקבל מ${db.store(kMxStoreId).name}',
                    'כך יקלטו המחירים. אפשר להדביק מחירון אחר מאקסל.',
                  ),
                  Container(
                    key: const Key('price-preview'),
                    decoration: BoxDecoration(
                      border: Border.all(color: kMxLine),
                      borderRadius: BorderRadius.circular(kMxR12),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        2: IntrinsicColumnWidth(),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: kMxPanel),
                          children: [
                            cell('מק״ט', head: true),
                            cell('פריט', head: true),
                            cell('מחיר', head: true),
                          ],
                        ),
                        for (final r in preview.rows)
                          TableRow(
                            children: [
                              cell(r.storeSku, ltr: true),
                              cell(r.name),
                              cell(mxShekels(r.agorot)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetButtons(
                    okKey: const Key('ask-ok'),
                    ok:
                        'קלטו ${mxCount(preview.matched.length, 'מחיר אחד', 'מחירים')}',
                    onOk: () => Navigator.pop(ctx, 'ok'),
                    cancelKey: const Key('price-paste'),
                    cancel: 'הדבקת מחירון אחר',
                    onCancel: () => Navigator.pop(ctx, 'paste'),
                  ),
                ],
              ),
            ),
          ),
    );
    if (choice == null || !mounted) return;
    var csv = sample;
    if (choice == 'paste') {
      final pasted = await _askText(
        context,
        'הדביקו את המחירון',
        'מק"ט,שם,מחיר',
        help: 'שורה לכל פריט: מק״ט, שם ומחיר, מופרדים בפסיק.',
        ok: 'קלטו מחירים',
        maxLines: 8,
        ltr: true,
      );
      if (pasted == null || !mounted) return;
      csv = pasted;
    }
    final (err, imp) = ref
        .read(mxDbProvider.notifier)
        .importPrices(kMxStoreId, csv);
    final extra =
        imp == null || imp.errors.isEmpty
            ? ''
            : ', ${imp.errors.length} שורות לא נקלטו';
    _toast(
      context,
      err,
      'נקלטו ${mxCount(imp?.matched.length ?? 0, 'מחיר אחד', 'מחירים')} מ${ref.read(mxDbProvider).store(kMxStoreId).name}$extra',
    );
  }
}

// ── purchase orders (manager / tech) ─────────────────────────────────────────

const List<String> _poLabels = ['אישור', 'נשלחה', 'בחנות', 'מוכנה', 'התקבלה'];

int _poRank(MxPurchaseOrder o) => switch (o.status) {
  MxPoStatus.pendingApproval => 0,
  MxPoStatus.approved => 1,
  MxPoStatus.sent || MxPoStatus.storeConfirmed || MxPoStatus.storePartial => 2,
  MxPoStatus.ready => 3,
  MxPoStatus.received => 4,
  MxPoStatus.rejected => -1,
};

/// Open WhatsApp with the order; on success mark it sent. Returns whether
/// WhatsApp opened.
Future<bool> _sendWhatsApp(
  BuildContext context,
  WidgetRef ref,
  String poId,
) async {
  final n = ref.read(mxDbProvider.notifier);
  try {
    final db = ref.read(mxDbProvider);
    final uri = mxWhatsAppUri(
      db,
      db.po(poId),
      baseUrl: kMxStoreBaseUrl,
      orgName: kMxOrgName,
    );
    final ok = await ref.read(urlLauncherProvider)(uri);
    if (ok && ref.read(mxDbProvider).po(poId).status == MxPoStatus.approved) {
      n.markSent(poId);
    }
    return ok;
  } on MxError catch (e) {
    if (context.mounted) _toast(context, e.message, '');
    return false;
  }
}

class _OrdersPage extends ConsumerStatefulWidget {
  const _OrdersPage({super.key});
  @override
  ConsumerState<_OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<_OrdersPage> {
  String _filter = 'open';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    // Rebuild when the store moves its order on the BuildSmart dashboard.
    ref.watch(ordersEngineProvider);
    if (db.purchaseOrders.isEmpty) {
      return const MxEmpty(
        icon: Icons.shopping_cart_outlined,
        title: 'אין הזמנות עדיין',
        body: 'הזמנה נוצרת כשטכנאי מבקש חלק, או מהמלאי בלחיצה אחת.',
      );
    }
    final pending = db.pendingApproval.length;
    final all = db.purchaseOrders.reversed.toList();
    final open = all.where((o) => o.isOpen).toList();
    final list = switch (_filter) {
      'pending' =>
        all.where((o) => o.status == MxPoStatus.pendingApproval).toList(),
      'closed' => all.where((o) => !o.isOpen).toList(),
      'all' => all,
      _ => open,
    };
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(
          pending == 0 ? 'הזמנות לחנויות' : '$pending מחכות לאישורך',
          'הזמנה מאושרת נשלחת לחנות בוואטסאפ, ומופיעה גם בלוח החנות.',
        ),
        MxFilterChips(
          keyPrefix: 'po-filter',
          items: [
            ('open', 'פתוחות', open.length),
            ('pending', 'לאישור', pending),
            ('closed', 'סגורות', null),
            ('all', 'הכול', null),
          ],
          selected: _filter,
          onSelect: (k) => setState(() => _filter = k),
        ),
        if (list.isEmpty)
          _filter == 'open'
              ? const MxEmpty(
                icon: Icons.inventory_outlined,
                success: true,
                title: 'כל ההזמנות הגיעו',
                body: 'אין הזמנות פתוחות. הכול במלאי.',
              )
              : const MxEmpty(
                icon: Icons.inbox_outlined,
                title: 'אין כאן הזמנות',
              ),
        for (final (i, o) in list.indexed)
          MxAppear(index: i, child: _poCard(context, db, n, role, o)),
        if (list.isNotEmpty)
          _endNote(
            'זה הכול$_sep${mxCount(list.length, 'הזמנה אחת', 'הזמנות')}',
          ),
      ],
    );
  }

  Widget _poCard(
    BuildContext context,
    MxDb db,
    MxNotifier n,
    MxRole role,
    MxPurchaseOrder o,
  ) {
    final stage = n.storeStageOf(o);
    return MxCard(
      key: Key('po-${o.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _dot(Icons.storefront_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      db.store(o.storeId).name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${mxPoLabel(o.id)}$_sep${o.requestedBy}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kMxMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MxTag(_poStatus(o.status), _poColor(o.status)),
            ],
          ),
          const SizedBox(height: 12),
          for (final l in o.lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l.missing
                          ? '${db.part(l.sku).name}: יש ${l.supplied} מתוך ${l.qty}'
                          : '${l.qty} × ${db.part(l.sku).name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: l.missing ? _warn : kMxInk,
                      ),
                    ),
                  ),
                  Text(
                    mxShekels(l.totalAgorot),
                    style: const TextStyle(
                      color: kMxMuted,
                      fontSize: 14,
                      fontFeatures: kMxTabular,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'סה״כ לפני מע״מ',
                  style: TextStyle(color: kMxMuted, fontSize: 14),
                ),
              ),
              Text(
                mxShekels(o.totalAgorot),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFeatures: kMxTabular,
                ),
              ),
            ],
          ),
          if (o.status == MxPoStatus.rejected && o.note.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'סיבת הדחייה: ${o.note}',
                style: const TextStyle(color: kMxMuted, fontSize: 14),
              ),
            ),
          if (o.status != MxPoStatus.rejected)
            MxSegments(labels: _poLabels, rank: _poRank(o)),
          if (stage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'בלוח החנות: ${mxStageLabel(stage)}',
                key: Key('po-bs-${o.id}'),
                style: const TextStyle(color: kMxMuted, fontSize: 14),
              ),
            ),
          if (o.fulfil == MxFulfil.delivery && o.status == MxPoStatus.ready)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _truck(size: 18, color: kMxPrimary),
                  const SizedBox(width: 8),
                  const Text(
                    'החנות שלחה את ההזמנה במשלוח',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          if (o.invoiceNo.isNotEmpty)
            Text(
              'חשבונית ${o.invoiceNo}${o.allocationNo.isEmpty ? '' : ', מספר הקצאה ${o.allocationNo}'}',
              style: const TextStyle(fontSize: 14, color: kMxMuted),
            ),
          if (role == MxRole.manager) ..._poActions(context, db, n, o),
        ],
      ),
    );
  }

  List<Widget> _poActions(
    BuildContext context,
    MxDb db,
    MxNotifier n,
    MxPurchaseOrder o,
  ) {
    Widget wide(Widget b, {double h = 48}) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(width: double.infinity, height: h, child: b),
    );
    final store = db.store(o.storeId).name;
    return [
      if (o.status == MxPoStatus.pendingApproval) ...[
        wide(
          FilledButton.icon(
            key: Key('po-approve-${o.id}'),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: const Text('אשרו ושלחו בוואטסאפ'),
            onPressed: () async {
              final err = n.approve(o.id);
              if (err != null) return _toast(context, err, '');
              final sent = await _sendWhatsApp(context, ref, o.id);
              if (!context.mounted) return;
              _toast(
                context,
                null,
                sent
                    ? 'אושר, ונפתח וואטסאפ אל $store. לחצו שם "שלח".'
                    : 'אושר, אבל טרם נשלח. אפשר לשלוח שוב מהכרטיס.',
              );
            },
          ),
          h: 52,
        ),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            key: Key('po-reject-${o.id}'),
            style: TextButton.styleFrom(foregroundColor: kMxMuted),
            onPressed: () async {
              final why = await _askText(
                context,
                'למה לדחות?',
                'הסיבה תוצג לטכנאי',
                quick: const [
                  'יש במחסן',
                  'יקר מדי – לבדוק חנות אחרת',
                  'לא דחוף עכשיו',
                ],
                ok: 'דחו בקשה',
              );
              if (why == null || !context.mounted) return;
              _toast(
                context,
                n.reject(o.id, reason: why),
                'הבקשה נדחתה, והטכנאי רואה את הסיבה',
              );
            },
            child: const Text('דחו'),
          ),
        ),
      ],
      if (o.token.isNotEmpty && o.isOpen) ...[
        if (o.status == MxPoStatus.approved)
          wide(
            FilledButton.icon(
              key: Key('po-wa-${o.id}'),
              icon: const Icon(Icons.chat_outlined, size: 20),
              label: const Text('שלחו לחנות בוואטסאפ'),
              onPressed: () async {
                final ok = await _sendWhatsApp(context, ref, o.id);
                if (!context.mounted) return;
                _toast(
                  context,
                  ok ? null : 'לא ניתן לפתוח וואטסאפ',
                  'נפתח וואטסאפ עם ההזמנה',
                );
              },
            ),
            h: 52,
          ),
        if (o.status != MxPoStatus.approved)
          wide(
            OutlinedButton.icon(
              key: Key('po-receive-${o.id}'),
              icon: const Icon(Icons.inventory_outlined, size: 20),
              label: const Text('קיבלתי את הסחורה'),
              onPressed: () async {
                final arriving = [
                  for (final l in o.lines)
                    if (l.supplied > 0)
                      '${l.supplied} × ${db.part(l.sku).name}',
                ];
                final yes = await _confirm(
                  context,
                  title: 'לקלוט את הסחורה למלאי?',
                  body:
                      arriving.isEmpty
                          ? 'לא סומנו פריטים שהגיעו.'
                          : 'יתווספו למלאי:\n${arriving.join('\n')}',
                  ok: 'קלטו למלאי',
                );
                if (!yes || !context.mounted) return;
                _toast(
                  context,
                  n.receive(o.id),
                  'המלאי עודכן. קריאות שחיכו לחלק חזרו לטכנאי.',
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 4,
            children: [
              if (o.status != MxPoStatus.approved)
                TextButton.icon(
                  key: Key('po-wa-${o.id}'),
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('שלחו שוב בוואטסאפ'),
                  onPressed: () => _sendWhatsApp(context, ref, o.id),
                ),
              TextButton.icon(
                icon: const Icon(Icons.link_rounded, size: 18),
                label: const Text('העתקת קישור'),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: mxStoreLink(kMxStoreBaseUrl, o.token)),
                  );
                  if (context.mounted) _toast(context, null, 'הקישור הועתק');
                },
              ),
              TextButton.icon(
                key: Key('po-storeview-${o.id}'),
                icon: const Icon(Icons.storefront_outlined, size: 18),
                label: const Text('מה החנות רואה'),
                onPressed: () => _open(context, MxStorePage(token: o.token)),
              ),
              if (mxCanReroute(db, o))
                TextButton.icon(
                  key: Key('po-reroute-${o.id}'),
                  icon: const Icon(Icons.alt_route_rounded, size: 18),
                  label: const Text('החוסרים לחנות אחרת'),
                  onPressed:
                      () => _toast(
                        context,
                        n.reroute(o.id),
                        'נוצרה הזמנה לחנות חלופית, והיא מחכה לאישורך',
                      ),
                ),
            ],
          ),
        ),
      ],
    ];
  }
}

// ── store side (link page + store inbox) ─────────────────────────────────────

class _StoreInbox extends ConsumerWidget {
  const _StoreInbox();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final mine =
        db.purchaseOrders
            .where((o) => o.storeId == kMxStoreId && o.token.isNotEmpty)
            .toList()
            .reversed
            .toList();
    final open = mine.where((o) => o.isOpen).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _pageTitle(
          'שלום, ${db.store(kMxStoreId).name}',
          open == 0
              ? 'אין הזמנות פתוחות כרגע.'
              : open == 1
              ? 'הזמנה אחת מחכה לך משיח סוד'
              : '$open הזמנות מחכות לך משיח סוד',
        ),
        if (mine.isEmpty)
          const MxEmpty(
            icon: Icons.storefront_outlined,
            title: 'עוד אין הזמנות',
            body: 'כשמחלקת האחזקה תאשר הזמנה, היא תופיע כאן ותגיע גם בוואטסאפ.',
          )
        else
          _listCard([
            for (final o in mine)
              _row(
                key: Key('inbox-${o.id}'),
                leading: _dot(Icons.receipt_long_outlined),
                title:
                    '${mxPoLabel(o.id)}$_sep${mxCount(o.lines.length, 'פריט אחד', 'פריטים')}',
                subtitle:
                    '${mxShekels(o.totalAgorot)}$_sep${_date(o.createdAt)}',
                trailing: MxTag(_poStatus(o.status), _poColor(o.status)),
                onTap: () => _open(context, MxStorePage(token: o.token)),
              ),
          ]),
      ],
    );
  }
}

/// The page a store owner reaches from the WhatsApp link `/s/<token>` —
/// no login; the token is the only key. Also used from the store dashboard.
/// [fromLink]: opened directly from WhatsApp, so there is nowhere to go back.
class MxStorePage extends ConsumerStatefulWidget {
  const MxStorePage({required this.token, this.fromLink = false, super.key});
  final String token;
  final bool fromLink;
  @override
  ConsumerState<MxStorePage> createState() => _MxStorePageState();
}

class _MxStorePageState extends ConsumerState<MxStorePage> {
  final _invoice = TextEditingController();
  final _alloc = TextEditingController();

  @override
  void dispose() {
    _invoice.dispose();
    _alloc.dispose();
    super.dispose();
  }

  Future<void> _ready(MxFulfil how) async {
    final n = ref.read(mxDbProvider.notifier);
    final err = n.storeReady(
      widget.token,
      invoiceNo: _invoice.text,
      allocationNo: _alloc.text,
      fulfil: how,
    );
    if (err != null) return _toast(context, err, '');
    final db = ref.read(mxDbProvider);
    final o = db.poByToken(widget.token)!;
    final prep = [
      for (final l in o.lines)
        if (l.supplied > 0) '${l.supplied}\u00A0× ${db.part(l.sku).name}',
    ].join(', ');
    await mxShowSuccess(
      context,
      title: 'תודה, ${db.store(o.storeId).name}',
      body:
          how == MxFulfil.delivery
              ? 'מחלקת האחזקה של $kMxOrgName קיבלה הודעה שההזמנה יצאה למשלוח.'
              : 'מחלקת האחזקה של $kMxOrgName קיבלה הודעה שההזמנה מוכנה לאיסוף.\nלהכין: $prep',
      actions: [('סגירה', const Key('store-thanks-ok'), () {})],
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final n = ref.read(mxDbProvider.notifier);
    final o = db.poByToken(widget.token);
    if (o == null) {
      return _page(
        'הזמנה',
        back: !widget.fromLink,
        const MxEmpty(
          icon: Icons.link_off_rounded,
          title: 'הקישור לא תקף',
          body: 'ייתכן שההזמנה בוטלה. אפשר לפנות למחלקת האחזקה.',
        ),
      );
    }
    final store = db.store(o.storeId);
    final closed = !o.isOpen;
    final needsAlloc = mxNeedsAllocation(o);
    final site = mxPoDeliverySite(db, o);
    final address =
        site.address.isEmpty ? '${site.city} – ${site.name}' : site.address;
    final anyMissing = o.lines.any((l) => l.missing);
    final have = o.lines.where((l) => l.supplied > 0).length;
    final unconfirmed =
        o.status == MxPoStatus.sent || o.status == MxPoStatus.approved;
    return Scaffold(
      // Branded header: who is ordering, greeting the store by name.
      appBar: AppBar(
        automaticallyImplyLeading: !widget.fromLink,
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('שלום, ${store.name}'),
            Text(
              mxHebrewDate(now),
              style: const TextStyle(
                color: kMxAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // The org's face to the store: the arch frames the order number.
          Container(
            color: kMxPrimary,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                MxArch(
                  width: 84,
                  height: 112,
                  stroke: 2,
                  draw: true,
                  child: Text(
                    o.id.split('-').last,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFeatures: kMxTabular,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'הזמנה משיח סוד',
                          style: TextStyle(
                            color: kMxAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          mxShekels(o.totalAgorot),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            fontFeatures: kMxTabular,
                          ),
                        ),
                        Text(
                          '${mxCount(o.lines.length, 'פריט אחד', 'פריטים')}$_sepלפני מע״מ',
                          style: const TextStyle(
                            color: Color(0xB3FFFFFF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MxTag(_poStatus(o.status), Colors.white),
                ),
              ],
            ),
          ),
          MxCard(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxInfoRow(Icons.place_outlined, 'כתובת', Text(address)),
                MxInfoRow(
                  Icons.person_outline_rounded,
                  'איש קשר',
                  Text(
                    kMxManagerPhone.isEmpty
                        ? kMxManagerTitle
                        : '$kMxManagerTitle, ${_ltr(kMxManagerPhone)}',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('store-call'),
                        icon: const MxIcon(MxGlyphs.phone, size: 20),
                        label: const Text('חיוג'),
                        onPressed: () => _call(ref, context, kMxManagerPhone),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        key: const Key('store-nav'),
                        icon: const Icon(Icons.near_me_outlined, size: 20),
                        label: const Text('ניווט'),
                        onPressed:
                            () => ref.read(urlLauncherProvider)(
                              Uri.https('waze.com', '/ul', {
                                'q': address,
                                'navigate': 'yes',
                              }),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!closed)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'חסר לכם משהו? שנו את הכמות שיש לכם, או לחצו "אין לי".',
                style: TextStyle(color: kMxMuted, fontSize: 16, height: 1.4),
              ),
            ),
          _listCard([
            for (final l in o.lines)
              Padding(
                key: Key('store-line-${l.sku}'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _dot(
                          mxPointGlyph(
                            db.points
                                    .where((p) => p.sku == l.sku)
                                    .firstOrNull
                                    ?.type ??
                                '',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Heebo',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: l.supplied == 0 ? kMxMuted : kMxInk,
                              decoration:
                                  l.supplied == 0
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            child: Text(db.part(l.sku).name),
                          ),
                        ),
                        if (l.missing)
                          MxTag(
                            l.supplied == 0
                                ? 'אין'
                                : 'יש ${l.supplied} מתוך ${l.qty}',
                            _warn,
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 52),
                      child: Text(
                        'הוזמנו ${l.qty}$_sep${mxShekels(l.unitAgorot)} ליח׳',
                        style: const TextStyle(
                          color: kMxMuted,
                          fontSize: 14,
                          fontFeatures: kMxTabular,
                        ),
                      ),
                    ),
                    if (!closed)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 52,
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            MxStepper(
                              keyPrefix: 'store-sup-${l.sku}',
                              value: l.supplied,
                              max: l.qty,
                              onChanged:
                                  (v) => _undoable(
                                    context,
                                    ref,
                                    n.storeSupplied(widget.token, l.sku, v),
                                    'עודכן: יש $v מתוך ${l.qty}',
                                  ),
                            ),
                            const Spacer(),
                            if (l.supplied > 0)
                              Flexible(
                                child: OutlinedButton(
                                  key: Key('store-missing-${l.sku}'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    foregroundColor: kMxInk,
                                    side: const BorderSide(color: kMxInk),
                                  ),
                                  onPressed:
                                      () => _undoable(
                                        context,
                                        ref,
                                        n.storeMissing(widget.token, l.sku),
                                        'סומן שאין לכם את הפריט',
                                      ),
                                  child: const Text('אין לי'),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ]),
          if (!closed) ...[
            const MxSectionTitle('כשההזמנה מוכנה'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                key: const Key('store-invoice'),
                controller: _invoice,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'מספר חשבונית (לא חובה)',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                key: const Key('store-alloc'),
                controller: _alloc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      needsAlloc
                          ? 'מספר הקצאה (חובה מעל 5,000 ₪)'
                          : 'מספר הקצאה (אם יש)',
                ),
              ),
            ),
          ] else
            const MxEmpty(
              icon: Icons.verified_outlined,
              success: true,
              title: 'ההזמנה סגורה',
              body: 'תודה על השירות!',
            ),
        ],
      ),
      bottomNavigationBar:
          closed
              ? null
              : MxBottomBar(
                children: [
                  if (unconfirmed)
                    MxPrimaryButton(
                      key: const Key('store-confirm'),
                      label:
                          anyMissing
                              ? 'מאשר את מה שיש ($have מתוך ${o.lines.length})'
                              : 'מאשר, יש לי הכול',
                      icon: Icons.thumb_up_alt_outlined,
                      color: kMxAccent,
                      foreground: kMxPrimary,
                      onPressed:
                          () => _toast(
                            context,
                            n.storeConfirm(widget.token),
                            'תודה! ההזמנה אושרה',
                          ),
                    )
                  else
                    MxPrimaryButton(
                      key: const Key('store-ready'),
                      label: 'ההזמנה מוכנה לאיסוף',
                      icon: Icons.storefront_outlined,
                      onPressed: () => _ready(MxFulfil.pickup),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        if (unconfirmed) ...[
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                key: const Key('store-ready'),
                                onPressed: () => _ready(MxFulfil.pickup),
                                child: const FittedBox(
                                  child: Text('מוכן לאיסוף'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              key: const Key('store-ship'),
                              icon: _truck(),
                              label: const FittedBox(child: Text('יצא למשלוח')),
                              onPressed: () => _ready(MxFulfil.delivery),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

/// Standalone app wrapper (used by the demo entry and tests): RTL + theme.
class MxApp extends StatelessWidget {
  const MxApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'ניהול אחזקה ורכש',
    theme: mxTheme(),
    locale: const Locale('he'),
    builder:
        (context, child) =>
            Directionality(textDirection: TextDirection.rtl, child: child!),
    home: const MxHome(),
  );
}
