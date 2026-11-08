/// Maintenance module — screens (Hebrew, RTL, light, phone-first).
///
/// [MxHome] is the whole module: a role switch (manager / tech / staff /
/// store) and per-role tabs. Drill-downs are pushed routes that watch
/// [mxDbProvider], so every screen updates live after any action.
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_bridge.dart';
import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_state.dart';
import 'package:buildsmart/features/maintenance/mx_store_link.dart';
import 'package:buildsmart/features/maintenance/mx_ui.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo identities (real auth maps users to these).
const String kMxTechName = 'יוסי – טכנאי';
const String kMxStaffUnit = 'jrs-3';
const String kMxStaffLabel = 'מדריך – דירה 3';
const String kMxStoreId = 'st-tambur';

const Color _brand = kMxPrimary;
const Color _bad = kMxBad;
const Color _warn = kMxWarn;
const Color _ok = kMxOk;

ThemeData mxTheme() => mxBrandTheme();

void _toast(BuildContext context, String? error, String success) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(error ?? success),
        duration: const Duration(milliseconds: 2500),
        backgroundColor: error == null ? null : _bad,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
    ),
  );
}

Widget _section(String title) => Padding(
  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
  child: Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  ),
);

Widget _listCard(List<Widget> tiles) => Container(
  margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(22),
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

String _woStatus(MxWoStatus s) => switch (s) {
  MxWoStatus.open => 'חדשה',
  MxWoStatus.assigned => 'אצל טכנאי',
  MxWoStatus.waitingPart => 'ממתין לחלק',
  MxWoStatus.done => 'טופלה',
  MxWoStatus.cancelled => 'בוטלה',
};

Color _woColor(MxWoStatus s) => switch (s) {
  MxWoStatus.open => _bad,
  MxWoStatus.assigned || MxWoStatus.waitingPart => _warn,
  _ => _ok,
};

String _poStatus(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval => 'ממתין לאישור',
  MxPoStatus.sent => 'נשלח לחנות',
  MxPoStatus.storeConfirmed => 'החנות אישרה',
  MxPoStatus.storePartial => 'חסרים פריטים',
  MxPoStatus.ready => 'מוכן לאיסוף',
  MxPoStatus.received => 'התקבל',
  MxPoStatus.rejected => 'נדחה',
};

Color _poColor(MxPoStatus s) => switch (s) {
  MxPoStatus.pendingApproval || MxPoStatus.storePartial => _warn,
  MxPoStatus.received => _ok,
  MxPoStatus.rejected => _bad,
  _ => _brand,
};

String _date(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

// ── shell ────────────────────────────────────────────────────────────────────

class MxHome extends ConsumerStatefulWidget {
  const MxHome({super.key});
  @override
  ConsumerState<MxHome> createState() => _MxHomeState();
}

typedef _Tab = (String key, IconData icon, String label);

class _MxHomeState extends ConsumerState<MxHome> {
  int _tab = 0;

  List<_Tab> _tabs(MxRole role) => switch (role) {
    MxRole.manager => const [
      ('home', Icons.dashboard_outlined, 'לוח'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('wo', Icons.build_outlined, 'קריאות'),
      ('pm', Icons.event_available_outlined, 'תחזוקה'),
      ('stock', Icons.inventory_2_outlined, 'מלאי'),
      ('po', Icons.shopping_cart_outlined, 'הזמנות'),
    ],
    MxRole.tech => const [
      ('wo', Icons.build_outlined, 'המשימות שלי'),
      ('sites', Icons.apartment_outlined, 'מסגרות'),
      ('stock', Icons.inventory_2_outlined, 'מלאי'),
      ('po', Icons.shopping_cart_outlined, 'בקשות'),
    ],
    MxRole.staff => const [
      ('report', Icons.campaign_outlined, 'דיווח תקלה'),
      ('wo', Icons.list_alt_outlined, 'הדיווחים שלי'),
    ],
    MxRole.store => const [
      ('store', Icons.storefront_outlined, 'הזמנות לחנות'),
    ],
  };

  void _go(String key) {
    final i = _tabs(ref.read(mxRoleProvider)).indexWhere((t) => t.$1 == key);
    if (i >= 0) setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(mxRoleProvider);
    final db = ref.watch(mxDbProvider);
    final tabs = _tabs(role);
    final tab = _tab.clamp(0, tabs.length - 1);
    int badge(String key) => switch (key) {
      'wo' => db.openWorkOrders.length,
      'stock' => db.lowStock.length,
      'po' => role == MxRole.manager ? db.pendingApproval.length : 0,
      _ => 0,
    };
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(128),
        child: Container(
          decoration: const BoxDecoration(
            color: _brand,
            borderRadius: BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(44),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(18, 8, 6, 0),
                  child: Row(
                    children: [
                      if (kMxSiachSod)
                        const Padding(
                          padding: EdgeInsetsDirectional.only(end: 6),
                          child: Icon(
                            Icons.local_florist,
                            color: Color(0xFFD52C48),
                            size: 22,
                          ),
                        ),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: kMxWordmark,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 23,
                                  color: Colors.white,
                                ),
                              ),
                              TextSpan(
                                text: '   $kMxSubtitle',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Color(0xCCFFFFFF),
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        tooltip: 'איפוס הדגמה',
                        color: Colors.white70,
                        icon: const Icon(Icons.restart_alt),
                        onPressed: () {
                          ref.read(mxDbProvider.notifier).reset();
                          _toast(context, null, 'ההדגמה אופסה');
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<MxRole>(
                        key: const Key('mx-roles'),
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          foregroundColor: Colors.white,
                          selectedForegroundColor: _brand,
                          selectedBackgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.transparent),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontFamily: 'Heebo',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: MxRole.manager,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('מנהל', maxLines: 1),
                            ),
                          ),
                          ButtonSegment(
                            value: MxRole.tech,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('טכנאי', maxLines: 1),
                            ),
                          ),
                          ButtonSegment(
                            value: MxRole.staff,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('מדריך', maxLines: 1),
                            ),
                          ),
                          ButtonSegment(
                            value: MxRole.store,
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('חנות', maxLines: 1),
                            ),
                          ),
                        ],
                        selected: {role},
                        onSelectionChanged: (s) {
                          ref.read(mxRoleProvider.notifier).state = s.first;
                          setState(() => _tab = 0);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: switch (tabs[tab].$1) {
        'home' => _Dashboard(onGo: _go),
        'sites' => const _SitesPage(),
        'wo' => const _WorkOrdersPage(),
        'pm' => const _PmPage(),
        'stock' => const _StockPage(),
        'po' => const _OrdersPage(),
        'report' => _ReportPage(onSent: () => _go('wo')),
        _ => const _StoreInbox(),
      },
      bottomNavigationBar:
          tabs.length < 2
              ? null
              : SafeArea(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: kMxShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: NavigationBar(
                      selectedIndex: tab,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      height: 68,
                      onDestinationSelected: (i) => setState(() => _tab = i),
                      destinations: [
                        for (final t in tabs)
                          NavigationDestination(
                            icon: Badge(
                              isLabelVisible: badge(t.$1) > 0,
                              label: Text('${badge(t.$1)}'),
                              child: Icon(t.$2),
                            ),
                            label: t.$3,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

// ── dashboard ────────────────────────────────────────────────────────────────

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.onGo});
  final void Function(String) onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final now = ref.watch(mxClockProvider)();
    final due = db.pmDue(now);
    final overdue = due.where((d) => d.$2 == MxDue.overdue).length;
    final soon = due.where((d) => d.$2 == MxDue.soon).length;
    final open = db.openWorkOrders.length;
    final pending = db.pendingApproval.length;
    final parts = <String>[
      if (open > 0) open == 1 ? 'קריאה פתוחה אחת' : '$open קריאות פתוחות',
      if (overdue > 0)
        overdue == 1 ? 'בדיקה אחת באיחור' : '$overdue בדיקות באיחור',
      if (pending > 0)
        pending == 1
            ? 'הזמנה אחת מחכה לאישורך'
            : '$pending הזמנות מחכות לאישורך',
    ];
    final summary =
        parts.isEmpty
            ? 'הכול תקין. אין משימות דחופות היום.'
            : parts.join(' · ');
    Widget stat(
      String key,
      int v,
      String label,
      IconData icon,
      Color c,
      String go,
    ) => Expanded(
      child: MxStatCard(
        key: Key('kpi-$key'),
        value: v,
        label: label,
        icon: icon,
        color: c,
        onTap: () => onGo(go),
      ),
    );
    const gap = SizedBox(width: 10, height: 10);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          eyebrow: mxDateLabel(now),
          title: mxGreeting(now),
          subtitle: summary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  stat(
                    'wo',
                    open,
                    'קריאות פתוחות',
                    Icons.build_outlined,
                    _bad,
                    'wo',
                  ),
                  gap,
                  stat(
                    'po',
                    pending,
                    'הזמנות לאישור',
                    Icons.shopping_cart_outlined,
                    _warn,
                    'po',
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  stat(
                    'overdue',
                    overdue,
                    'בדיקות באיחור',
                    Icons.event_busy_outlined,
                    _bad,
                    'pm',
                  ),
                  gap,
                  stat(
                    'soon',
                    soon,
                    'בדיקות השבוע',
                    Icons.event_outlined,
                    _warn,
                    'pm',
                  ),
                ],
              ),
              gap,
              Row(
                children: [
                  stat(
                    'low',
                    db.lowStock.length,
                    'חלקים להזמין',
                    Icons.inventory_2_outlined,
                    _warn,
                    'stock',
                  ),
                  gap,
                  Expanded(
                    child: MxStatCard(
                      key: const Key('kpi-points'),
                      value: db.points.length,
                      label: 'נקודות במעקב',
                      icon: Icons.apartment_outlined,
                      color: _brand,
                      onTap: () => onGo('sites'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _section('דחוף עכשיו'),
        _listCard([
          for (final (r, d) in due.where((d) => d.$2 != MxDue.ok))
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(
                r.isLegal ? Icons.gavel_outlined : Icons.event_outlined,
                color: d == MxDue.overdue ? _bad : _warn,
              ),
              title: Text(
                r.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${r.scope} · ${_date(r.nextDue)}'),
              trailing: _Tag(
                d == MxDue.overdue ? 'באיחור' : 'השבוע',
                d == MxDue.overdue ? _bad : _warn,
              ),
              onTap: () => onGo('pm'),
            ),
          for (final w in db.openWorkOrders)
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(mxPointIcon(db.point(w.pointId).type), color: _bad),
              title: Text(
                w.desc,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(db.pointPath(w.pointId)),
              trailing: _Tag(_woStatus(w.status), _woColor(w.status)),
              onTap: () => _open(context, _WorkOrderPage(w.id)),
            ),
          if (db.openWorkOrders.isEmpty && overdue + soon == 0)
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: _ok),
              title: Text('אין משימות דחופות'),
            ),
        ]),
      ],
    );
  }
}

void _open(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));

Scaffold _page(String title, Widget body) => Scaffold(
  appBar: AppBar(
    title: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
    ),
    toolbarHeight: 66,
    backgroundColor: _brand,
    foregroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadiusDirectional.only(
        bottomEnd: Radius.circular(36),
      ),
    ),
  ),
  body: body,
);

// ── sites → unit → room → point ──────────────────────────────────────────────

class _SitesPage extends ConsumerWidget {
  const _SitesPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    int faulty(String siteId) => [
      for (final u in db.unitsOf(siteId)) db.faultyCountOfUnit(u.id),
    ].fold(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxSectionTitle('המסגרות', count: db.sites.length),
        MxTileGrid(
          children: [
            for (final s in db.sites)
              MxTile(
                key: Key('site-${s.id}'),
                icon: Icons.apartment_outlined,
                label: '${s.city} – ${s.name}',
                caption: '${db.unitsOf(s.id).length} דירות',
                alert: faulty(s.id) > 0,
                onTap: () => _open(context, _SitePage(s.id)),
              ),
          ],
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
        padding: const EdgeInsets.only(bottom: 24),
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
                          ? '${db.faultyCountOfUnit(u.id)} תקלות פתוחות'
                          : '${db.pointCountOfUnit(u.id)} נקודות · תקין',
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
      '${db.site(u.siteId).city} · ${u.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MxSectionTitle('חדרים', count: db.roomsOf(unitId).length),
          MxTileGrid(
            children: [
              for (final r in db.roomsOf(unitId))
                MxTile(
                  key: Key('room-${r.id}'),
                  icon: mxRoomIcon(r.name),
                  label: r.name,
                  caption: '${db.pointsOf(r.id).length} נקודות',
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
    return _page(
      '${u.name} · ${r.name}',
      ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          MxHero(
            title: r.name,
            subtitle:
                bad == 0
                    ? '${pts.length} נקודות · הכול תקין'
                    : '${pts.length} נקודות · $bad תקולות',
            trailing: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 52,
                color: kMxPrimary,
                semanticLabel: 'מדבקת QR של החדר',
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Text(
              'מדבקת QR על דלת החדר פותחת את המסך הזה ישירות.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          MxTileGrid(
            children: [
              for (final p in pts)
                MxTile(
                  key: Key('pt-${p.id}'),
                  icon: mxPointIcon(p.type),
                  label: '${p.type} ${p.num}',
                  caption: p.status == MxPointStatus.faulty ? 'תקול' : p.loc,
                  alert: p.status == MxPointStatus.faulty,
                  onTap: () => _open(context, _PointPage(p.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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
    return _page(
      p.label,
      ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: (faulty ? _bad : _brand).withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          mxPointIcon(p.type),
                          size: 32,
                          color: faulty ? _bad : _brand,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.label,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              p.spec,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      if (faulty)
                        const _Tag('תקול', _bad)
                      else
                        const _Tag('תקין', _ok),
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
                    Text('${part.name} · ${part.sku}'),
                  ),
                  MxInfoRow(
                    Icons.inventory_2_outlined,
                    'במלאי',
                    Row(
                      children: [
                        Text('${db.qty(p.sku)} יח׳'),
                        const SizedBox(width: 8),
                        if (low) const _Tag('מתחת למינימום', _warn),
                      ],
                    ),
                  ),
                  MxInfoRow(
                    Icons.event_repeat_outlined,
                    'תחזוקה',
                    Text(p.pm.isEmpty ? '—' : p.pm),
                  ),
                ],
              ),
            ),
          ),
          MxSectionTitle('היסטוריה', count: p.history.length),
          if (p.history.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'עוד לא היו טיפולים בנקודה הזו.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            _listCard([
              for (final e in p.history)
                ListTile(
                  leading: const Icon(Icons.history, color: _brand),
                  title: Text(
                    e.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${_date(e.at)} · ${e.by}${e.costAgorot > 0 ? ' · ${mxShekels(e.costAgorot)}' : ''}',
                  ),
                ),
            ]),
          const SizedBox(height: 8),
          MxPrimaryButton(
            key: const Key('report-point'),
            label: 'דווח תקלה בנקודה הזו',
            icon: Icons.campaign_outlined,
            onPressed: () async {
              final text = await _askText(
                context,
                'מה קרה?',
                'לדוגמה: השקע מעלה ניצוצות',
              );
              if (text == null || !context.mounted) return;
              final n = ref.read(mxDbProvider.notifier);
              final by =
                  role == MxRole.staff
                      ? kMxStaffLabel
                      : role == MxRole.tech
                      ? kMxTechName
                      : 'מנהל אחזקה';
              final err = n.report(pointId, text, by);
              _toast(context, err, 'נפתחה קריאה ${n.lastCreatedId}');
            },
          ),
        ],
      ),
    );
  }
}

Future<String?> _askText(
  BuildContext context,
  String title,
  String hint, {
  String initial = '',
}) {
  final c = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            key: const Key('ask-text'),
            controller: c,
            autofocus: true,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ביטול'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('אישור'),
            ),
          ],
        ),
  );
}

// ── work orders ──────────────────────────────────────────────────────────────

class _WorkOrdersPage extends ConsumerWidget {
  const _WorkOrdersPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final list = switch (role) {
      MxRole.staff =>
        db.workOrders.where((w) => w.reportedBy == kMxStaffLabel).toList(),
      MxRole.tech =>
        db.workOrders
            .where(
              (w) => w.assignee == kMxTechName || w.status == MxWoStatus.open,
            )
            .toList(),
      _ => db.workOrders,
    };
    return ListView(
      children: [
        _section(
          role == MxRole.tech
              ? 'המשימות שלי'
              : role == MxRole.staff
              ? 'הדיווחים שלי'
              : 'קריאות שירות',
        ),
        _listCard([
          if (list.isEmpty) const ListTile(title: Text('אין קריאות')),
          for (final w in list)
            ListTile(
              key: Key('wo-${w.id}'),
              leading: Icon(
                mxPointIcon(db.point(w.pointId).type),
                color: _woColor(w.status),
              ),
              title: Text('${w.id} · ${w.desc}'),
              subtitle: Text(db.pointPath(w.pointId)),
              trailing: _Tag(_woStatus(w.status), _woColor(w.status)),
              onTap: () => _open(context, _WorkOrderPage(w.id)),
            ),
        ]),
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
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    final w = db.workOrder(woId);
    final p = db.point(w.pointId);
    final part = db.part(p.sku);
    final inStock = db.qty(p.sku);
    final canWork =
        role == MxRole.tech &&
        (w.status == MxWoStatus.open || w.status == MxWoStatus.assigned);
    Widget info(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
    return _page(
      'קריאה ${w.id}',
      ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _bad.withValues(alpha: 0.1),
                        child: Icon(mxPointIcon(p.type), color: _bad, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          w.desc,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      _Tag(_woStatus(w.status), _woColor(w.status)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  info(Icons.place_outlined, db.pointPath(w.pointId)),
                  info(
                    Icons.person_outline,
                    'דווח: ${w.reportedBy} · ${_date(w.createdAt)}',
                  ),
                  if (w.assignee.isNotEmpty)
                    info(Icons.engineering_outlined, 'טכנאי: ${w.assignee}'),
                  info(
                    Icons.inventory_2_outlined,
                    'חלק: ${part.name} · במלאי $inStock',
                  ),
                  if (w.poId.isNotEmpty)
                    info(
                      Icons.local_shipping_outlined,
                      'הזמנה ${w.poId}: ${_poStatus(db.po(w.poId).status)}',
                    ),
                  if (w.hasPhoto)
                    info(Icons.photo_camera_outlined, 'צורפה תמונה מהדירה'),
                ],
              ),
            ),
          ),
          MxTimeline(_steps(w)),
          const SizedBox(height: 8),
          if (role == MxRole.manager && w.status == MxWoStatus.open) ...[
            MxPrimaryButton(
              key: const Key('wo-assign'),
              label: 'שייך ליוסי – טכנאי',
              icon: Icons.engineering_outlined,
              color: kMxPrimary,
              onPressed:
                  () => _toast(
                    context,
                    n.assign(woId, kMxTechName),
                    'שויך ל$kMxTechName · נשלחה לו התראה',
                  ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                'טיפ להדגמה: עברו ל"טכנאי" למעלה כדי לראות את הצד שלו',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
          if (canWork) ...[
            MxPrimaryButton(
              key: const Key('wo-fix'),
              label: inStock < 1 ? 'החלק חסר במלאי' : 'תוקן · השתמשתי בחלק אחד',
              icon: Icons.check_circle_outline,
              color: _ok,
              onPressed:
                  inStock < 1
                      ? null
                      : () => _toast(
                        context,
                        n.closeWithPart(woId, kMxTechName),
                        'כל הכבוד! הקריאה נסגרה · ירד 1 מהמלאי · נרשם בהיסטוריה',
                      ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const Key('wo-fix-nopart'),
                        onPressed:
                            () => _toast(
                              context,
                              n.closeNoPart(woId, kMxTechName),
                              'נסגר ללא חלק',
                            ),
                        child: const Text('תוקן ללא חלק'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const Key('wo-need'),
                        onPressed: () {
                          final err = n.requestPart(woId, 4, kMxTechName);
                          _toast(
                            context,
                            err,
                            'נשלחה בקשה ${n.lastCreatedId} לאישור המנהל',
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
          if (w.status == MxWoStatus.done)
            const Padding(
              padding: EdgeInsets.all(16),
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
        ],
      ),
    );
  }
}

// ── staff report ─────────────────────────────────────────────────────────────

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
  bool _photo = false;
  final _text = TextEditingController();

  int get _step => _room == null ? 1 : (_point == null ? 2 : 3);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _back() => setState(() {
    if (_point != null) {
      _point = null;
      _reason = '';
    } else {
      _room = null;
    }
  });

  void _send() {
    final n = ref.read(mxDbProvider.notifier);
    final desc = [
      _reason,
      _text.text.trim(),
    ].where((s) => s.isNotEmpty).join(' – ');
    final err = n.report(_point!, desc, kMxStaffLabel, photo: _photo);
    if (err != null) {
      _toast(context, err, '');
      return;
    }
    final id = n.lastCreatedId;
    setState(() {
      _room = null;
      _point = null;
      _reason = '';
      _photo = false;
      _text.clear();
    });
    mxShowSuccess(
      context,
      title: 'הדיווח נשלח',
      body:
          'מנהל האחזקה קיבל את הדיווח $id ויטפל בו.\nאפשר לעקוב אחריו ב"הדיווחים שלי".',
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
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              if (_step > 1)
                IconButton(
                  key: const Key('rep-back'),
                  tooltip: 'חזרה',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _back,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titles[_step - 1],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'שלב $_step מתוך 3 · ${db.site(u.siteId).city} · ${u.name}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _step / 3,
              minHeight: 6,
              color: kMxCta,
              backgroundColor: kMxLine,
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder:
              (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.04),
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
                        icon: mxRoomIcon(r.name),
                        label: r.name,
                        caption: '${db.pointsOf(r.id).length} פריטים',
                        alert: db
                            .pointsOf(r.id)
                            .any((p) => p.status == MxPointStatus.faulty),
                        onTap: () => setState(() => _room = r.id),
                      ),
                  ],
                ),
              if (_step == 2)
                MxTileGrid(
                  children: [
                    for (final p in db.pointsOf(_room!))
                      MxTile(
                        key: Key('rep-point-${p.id}'),
                        icon: mxPointIcon(p.type),
                        label: '${p.type} ${p.num}',
                        caption: p.loc,
                        alert: p.status == MxPointStatus.faulty,
                        onTap: () => setState(() => _point = p.id),
                      ),
                  ],
                ),
              if (_step == 3) ..._details(db),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _details(MxDb db) {
    final p = db.point(_point!);
    return [
      Card(
        child: ListTile(
          minVerticalPadding: 14,
          leading: CircleAvatar(
            backgroundColor: kMxPrimary.withValues(alpha: 0.1),
            child: Icon(mxPointIcon(p.type), color: kMxPrimary),
          ),
          title: Text(
            p.label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          subtitle: Text(db.room(p.roomId).name),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, r) in mxQuickReasons(p.type).indexed)
              ChoiceChip(
                key: Key('rep-reason-$i'),
                label: Text(r, style: const TextStyle(fontSize: 15)),
                selected: _reason == r,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                selectedColor: kMxCta.withValues(alpha: 0.12),
                side: BorderSide(
                  color: _reason == r ? kMxCta : kMxLine,
                  width: _reason == r ? 2 : 1,
                ),
                shape: const StadiumBorder(),
                onSelected:
                    (_) => setState(() => _reason = _reason == r ? '' : r),
              ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
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
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: SizedBox(
          height: 56,
          child: OutlinedButton.icon(
            key: const Key('rep-photo'),
            icon: Icon(
              _photo ? Icons.check_circle : Icons.photo_camera_outlined,
              color: _photo ? _ok : null,
            ),
            label: Text(_photo ? 'התמונה צורפה' : 'צלמו תמונה (עוזר לטכנאי)'),
            onPressed: () => setState(() => _photo = true),
          ),
        ),
      ),
      MxPrimaryButton(
        key: const Key('rep-send'),
        label: 'שלח דיווח',
        icon: Icons.send_rounded,
        onPressed: _reason.isEmpty && _text.text.trim().isEmpty ? null : _send,
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
      ('בהמשך', MxDue.ok, _ok),
    ];
    Widget card(MxPmRule r, MxDue d, Color c) => MxEdgeCard(
      key: Key('pm-${r.id}'),
      color: c,
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Tag(mxDaysLabel(r.nextDue, now), c),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${r.scope} · יעד ${_date(r.nextDue)}',
            style: const TextStyle(color: Colors.black54),
          ),
          if (r.isLegal)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.gavel_outlined, size: 16, color: _bad),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'חובה: ${r.legalBasis}',
                      style: const TextStyle(
                        color: _bad,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (d != MxDue.ok)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton.icon(
                  key: Key('pm-done-${r.id}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: d == MxDue.overdue ? _bad : _brand,
                  ),
                  icon: const Icon(Icons.task_alt),
                  label: const Text('סמן כבוצע'),
                  onPressed:
                      () => _toast(
                        context,
                        ref.read(mxDbProvider.notifier).completePm(r.id),
                        'נרשם כבוצע · המועד הבא נקבע אוטומטית',
                      ),
                ),
              ),
            ),
        ],
      ),
    );
    final legal = db.pmRules.where((r) => r.isLegal).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          title: 'בדיקות ותחזוקה',
          subtitle:
              '$legal בדיקות חובה בחוק · המערכת זוכרת את המועד הבא של כל אחת',
        ),
        for (final (title, due, color) in groups)
          if (all.any((x) => x.$2 == due)) ...[
            MxSectionTitle(
              title,
              count: all.where((x) => x.$2 == due).length,
              color: color,
            ),
            for (final (r, d) in all.where((x) => x.$2 == due))
              card(r, d, color),
          ],
      ],
    );
  }
}

// ── stock ────────────────────────────────────────────────────────────────────

class _StockPage extends ConsumerStatefulWidget {
  const _StockPage();
  @override
  ConsumerState<_StockPage> createState() => _StockPageState();
}

class _StockPageState extends ConsumerState<_StockPage> {
  String _filter = 'הכול';

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final types = [
      'הכול',
      'להזמין',
      ...{for (final p in db.parts) p.storeType},
    ];
    final shown =
        db.parts.where((p) {
          if (_filter == 'הכול') return true;
          if (_filter == 'להזמין') return db.qty(p.sku) < p.min;
          return p.storeType == _filter;
        }).toList();
    final low = db.lowStock.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          title: low == 0 ? 'המלאי מלא' : '$low חלקים להזמין',
          subtitle:
              low == 0
                  ? 'כל החלקים מעל המינימום.'
                  : 'לחיצה אחת – והזמנה יוצאת לכל חנות בנפרד, לאישורך.',
        ),
        if (role == MxRole.manager) ...[
          MxPrimaryButton(
            key: const Key('auto-reorder'),
            label: 'הזמן את כל מה שחסר ($low)',
            icon: Icons.add_shopping_cart,
            onPressed:
                low == 0
                    ? null
                    : () => _toast(
                      context,
                      ref.read(mxDbProvider.notifier).autoReorder(),
                      'נוצרו בקשות הזמנה – אחת לכל חנות. מחכות לאישורך ב"הזמנות"',
                    ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('import-prices'),
                icon: const Icon(Icons.upload_file),
                label: const Text('קבלתי מחירון מהחנות (אקסל / CSV)'),
                onPressed: _importPrices,
              ),
            ),
          ),
        ],
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final t in types)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    key: Key('stock-filter-$t'),
                    label: Text(t == 'להזמין' ? 'להזמין ($low)' : t),
                    selected: _filter == t,
                    showCheckmark: false,
                    shape: const StadiumBorder(),
                    selectedColor: kMxPrimary,
                    labelStyle: TextStyle(
                      color: _filter == t ? Colors.white : kMxInk,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) => setState(() => _filter = t),
                  ),
                ),
            ],
          ),
        ),
        if (shown.isEmpty)
          const MxEmpty(
            icon: Icons.inventory_2_outlined,
            title: 'אין פריטים בסינון הזה',
          )
        else
          _listCard([
            for (final p in shown)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '${db.qty(p.sku)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: db.qty(p.sku) < p.min ? _bad : kMxInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    MxStockBar(qty: db.qty(p.sku), min: p.min),
                    const SizedBox(height: 4),
                    Text(
                      '${p.storeType} · מינימום ${p.min} · ${mxShekels(db.priceAt(kMxStoreId, p.sku))}'
                      '${db.onOrder(p.sku) > 0 ? ' · בהזמנה ${db.onOrder(p.sku)}' : ''}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
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
    final csv = await _askText(
      context,
      'הדביקו את המחירון (עמודות: מק"ט, שם, מחיר)',
      'מק"ט,שם,מחיר',
      initial: sample,
    );
    if (csv == null || !mounted) return;
    final (err, imp) = ref
        .read(mxDbProvider.notifier)
        .importPrices(kMxStoreId, csv);
    final extra =
        imp == null || imp.errors.isEmpty
            ? ''
            : ' · ${imp.errors.length} שורות לא נקלטו';
    _toast(
      context,
      err,
      'נקלטו ${imp?.matched.length ?? 0} מחירים לטמבור$extra',
    );
  }
}

// ── purchase orders (manager / tech) ─────────────────────────────────────────

List<MxStep> _poSteps(MxPurchaseOrder o) {
  final s = o.status;
  final rank = switch (s) {
    MxPoStatus.pendingApproval => 0,
    MxPoStatus.sent => 1,
    MxPoStatus.storeConfirmed || MxPoStatus.storePartial => 2,
    MxPoStatus.ready => 3,
    MxPoStatus.received => 4,
    MxPoStatus.rejected => -1,
  };
  const labels = ['אישור', 'נשלחה', 'בחנות', 'מוכנה', 'התקבלה'];
  return [
    for (var i = 0; i < labels.length; i++)
      (labels[i], i < rank || rank == 4, i == rank && rank != 4),
  ];
}

class _OrdersPage extends ConsumerWidget {
  const _OrdersPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(mxDbProvider);
    final role = ref.watch(mxRoleProvider);
    final n = ref.read(mxDbProvider.notifier);
    // Rebuild when the store moves its order on the BuildSmart dashboard.
    ref.watch(ordersEngineProvider);
    if (db.purchaseOrders.isEmpty) {
      return const MxEmpty(
        icon: Icons.shopping_cart_outlined,
        title: 'אין הזמנות עדיין',
        body: 'הזמנה נוצרת כשטכנאי מבקש חלק, או מלשונית המלאי בלחיצה אחת.',
      );
    }
    final pending = db.pendingApproval.length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          title: pending == 0 ? 'הזמנות לחנויות' : '$pending מחכות לאישורך',
          subtitle: 'כל הזמנה מאושרת נשלחת לטמבור בוואטסאפ ומופיעה בלוח החנות.',
        ),
        for (final o in db.purchaseOrders)
          MxEdgeCard(
            key: Key('po-${o.id}'),
            color: _poColor(o.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: kMxPanel,
                      child: Icon(Icons.storefront_outlined, color: _brand),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            db.store(o.storeId).name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${o.id} · ${o.requestedBy}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Tag(_poStatus(o.status), _poColor(o.status)),
                  ],
                ),
                const SizedBox(height: 10),
                for (final l in o.lines)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          l.missing
                              ? Icons.remove_circle_outline
                              : Icons.check_circle_outline,
                          size: 16,
                          color: l.missing ? _bad : _ok,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l.qty} × ${db.part(l.sku).name}${l.missing ? ' – חסר בחנות' : ''}',
                            style: TextStyle(color: l.missing ? _bad : null),
                          ),
                        ),
                        Text(
                          mxShekels(l.totalAgorot),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'סה"כ לפני מע"מ',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Text(
                      mxShekels(o.totalAgorot),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (o.status != MxPoStatus.rejected) MxTimeline(_poSteps(o)),
                if (o.orderId.isNotEmpty)
                  Text(
                    'לוח החנות ב-BuildSmart: ${o.orderId} · ${mxStageLabel(n.storeStageOf(o) ?? 'new')}',
                    key: Key('po-bs-${o.id}'),
                    style: const TextStyle(
                      color: _brand,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  )
                else if (o.matReqId.isNotEmpty)
                  const Text(
                    'ממתין בתור הבקשות של BuildSmart',
                    style: TextStyle(color: _brand, fontSize: 13),
                  ),
                if (o.invoiceNo.isNotEmpty)
                  Text(
                    'חשבונית ${o.invoiceNo}${o.allocationNo.isEmpty ? '' : ' · הקצאה ${o.allocationNo}'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                if (role == MxRole.manager)
                  ..._poActions(context, ref, n, db, o),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _poActions(
    BuildContext context,
    WidgetRef ref,
    MxNotifier n,
    MxDb db,
    MxPurchaseOrder o,
  ) {
    Widget wide(Widget b) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(width: double.infinity, height: 48, child: b),
    );
    return [
      if (o.status == MxPoStatus.pendingApproval)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    key: Key('po-approve-${o.id}'),
                    style: FilledButton.styleFrom(backgroundColor: _ok),
                    icon: const Icon(Icons.check),
                    label: const Text('אשר'),
                    onPressed:
                        () => _toast(
                          context,
                          n.approve(o.id),
                          'אושר · עכשיו שלחו לחנות בוואטסאפ',
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed:
                        () => _toast(context, n.reject(o.id), 'ההזמנה נדחתה'),
                    child: const Text('דחה'),
                  ),
                ),
              ),
            ],
          ),
        ),
      if (o.token.isNotEmpty && o.isOpen) ...[
        wide(
          FilledButton.icon(
            key: Key('po-wa-${o.id}'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F8F4E),
            ),
            icon: const Icon(Icons.chat_outlined),
            label: const Text('שלח לחנות בוואטסאפ'),
            onPressed: () async {
              try {
                final uri = mxWhatsAppUri(
                  db,
                  o,
                  baseUrl: kMxStoreBaseUrl,
                  orgName: kMxOrgName,
                );
                final ok = await ref.read(urlLauncherProvider)(uri);
                if (context.mounted) {
                  _toast(
                    context,
                    ok ? null : 'לא ניתן לפתוח וואטסאפ',
                    'נפתח וואטסאפ עם ההזמנה',
                  );
                }
              } on MxError catch (e) {
                if (context.mounted) _toast(context, e.message, '');
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.link, size: 18),
                label: const Text('העתק קישור'),
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
              if (o.status == MxPoStatus.storePartial)
                TextButton.icon(
                  key: Key('po-reroute-${o.id}'),
                  icon: const Icon(Icons.alt_route, size: 18),
                  label: const Text('חוסרים לחנות אחרת'),
                  onPressed:
                      () => _toast(
                        context,
                        n.reroute(o.id),
                        'החוסרים נשלחו לאישור מול חנות חלופית',
                      ),
                ),
            ],
          ),
        ),
        wide(
          OutlinedButton.icon(
            key: Key('po-receive-${o.id}'),
            icon: const Icon(Icons.inventory_outlined),
            label: const Text('קיבלתי את הסחורה'),
            onPressed:
                () => _toast(
                  context,
                  n.receive(o.id),
                  'התקבל · המלאי עודכן · קריאות שחיכו חזרו לטכנאי',
                ),
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
            .toList();
    final open = mine.where((o) => o.isOpen).length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        MxHero(
          title: db.store(kMxStoreId).name,
          subtitle:
              open == 0
                  ? 'אין הזמנות פתוחות כרגע.'
                  : open == 1
                  ? 'הזמנה אחת מחכה לך'
                  : '$open הזמנות מחכות לך',
        ),
        if (mine.isEmpty)
          const MxEmpty(
            icon: Icons.storefront_outlined,
            title: 'עוד אין הזמנות',
            body: 'כשמנהל האחזקה יאשר הזמנה, היא תופיע כאן ותגיע גם בוואטסאפ.',
          )
        else
          _listCard([
            for (final o in mine)
              ListTile(
                key: Key('inbox-${o.id}'),
                minVerticalPadding: 14,
                leading: const CircleAvatar(
                  backgroundColor: kMxPanel,
                  child: Icon(Icons.receipt_long_outlined, color: _brand),
                ),
                title: Text(
                  '${o.id} · ${o.lines.length} פריטים',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${mxShekels(o.totalAgorot)} · ${_date(o.createdAt)}',
                ),
                trailing: _Tag(_poStatus(o.status), _poColor(o.status)),
                onTap: () => _open(context, MxStorePage(token: o.token)),
              ),
          ]),
      ],
    );
  }
}

/// The page a store owner reaches from the WhatsApp link `/s/<token>` —
/// no login; the token is the only key. Also used from the store dashboard.
class MxStorePage extends ConsumerStatefulWidget {
  const MxStorePage({required this.token, super.key});
  final String token;
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

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(mxDbProvider);
    final n = ref.read(mxDbProvider.notifier);
    final o = db.poByToken(widget.token);
    if (o == null) {
      return _page(
        'הזמנה',
        const MxEmpty(
          icon: Icons.link_off,
          title: 'הקישור לא תקף',
          body: 'ייתכן שההזמנה בוטלה. אפשר לפנות למחלקת האחזקה.',
        ),
      );
    }
    final closed = !o.isOpen;
    final needsAlloc = mxNeedsAllocation(o);
    return _page(
      'הזמנה ${o.id}',
      ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          MxHero(
            title: mxShekels(o.totalAgorot),
            subtitle:
                'הזמנה מ$kMxOrgName · ${o.lines.length} פריטים · לפני מע"מ',
            trailing: _Tag(_poStatus(o.status), Colors.white),
          ),
          if (!closed)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'אם פריט חסר לכם – לחצו "אין לי" לידו. השאר יוזמן כרגיל.',
                style: TextStyle(color: Colors.black54, fontSize: 15),
              ),
            ),
          _listCard([
            for (final l in o.lines)
              ListTile(
                key: Key('store-line-${l.sku}'),
                minVerticalPadding: 12,
                leading: CircleAvatar(
                  backgroundColor: (l.missing ? _bad : _ok).withValues(
                    alpha: 0.1,
                  ),
                  child: Text(
                    '${l.qty}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: l.missing ? _bad : _ok,
                    ),
                  ),
                ),
                title: Text(
                  db.part(l.sku).name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: l.missing ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${mxShekels(l.unitAgorot)} ליח׳ · ${l.sku}'),
                trailing:
                    l.missing
                        ? const _Tag('חסר', _bad)
                        : closed
                        ? null
                        : OutlinedButton(
                          key: Key('store-missing-${l.sku}'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _bad,
                            side: const BorderSide(color: _bad),
                            minimumSize: const Size(72, 40),
                          ),
                          onPressed:
                              () => _toast(
                                context,
                                n.storeMissing(widget.token, l.sku),
                                'סומן כחסר',
                              ),
                          child: const Text('אין לי'),
                        ),
              ),
          ]),
          if (!closed) ...[
            if (o.status == MxPoStatus.sent)
              MxPrimaryButton(
                key: const Key('store-confirm'),
                label: 'מאשר – יש לי הכול',
                icon: Icons.thumb_up_alt_outlined,
                color: _ok,
                onPressed:
                    () => _toast(
                      context,
                      n.storeConfirm(widget.token),
                      'תודה! אישרת את ההזמנה',
                    ),
              ),
            const MxSectionTitle('כשההזמנה מוכנה'),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                key: const Key('store-alloc'),
                controller: _alloc,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      needsAlloc
                          ? 'מספר הקצאה (חובה – מעל 5,000 ₪)'
                          : 'מספר הקצאה (אם יש)',
                ),
              ),
            ),
            MxPrimaryButton(
              key: const Key('store-ready'),
              label: 'מוכן לאיסוף / נשלח',
              icon: Icons.local_shipping_outlined,
              color: kMxPrimary,
              onPressed:
                  () => _toast(
                    context,
                    n.storeReady(
                      widget.token,
                      invoiceNo: _invoice.text,
                      allocationNo: _alloc.text,
                    ),
                    'סומן מוכן – מחלקת האחזקה קיבלה עדכון',
                  ),
            ),
          ] else
            const MxEmpty(
              icon: Icons.verified_outlined,
              title: 'ההזמנה סגורה',
              body: 'תודה על השירות!',
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
