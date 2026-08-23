// Wave G3b — the shared ליקויים (DEFECTS) bottom-sheet: the CONTRACTOR opens a
// defect and the WORKER reports one, BOTH over the same defect engine (Wave G3a
// added `kind=='defect'` to TaskItem + the `defectsProvider` kind-filter, and
// the contractor/worker authoring rides the same createTask/proposeTask the
// regular §6 tasks use). "ליקויים same as משימות" — a defect reuses the ENTIRE
// task lifecycle, so this surface adds NO new approve/reject UI:
//   • CONTRACTOR (the `manager`-role board that opens tasks_screen's
//     _managerView) → "➕ פתח ליקוי" mints a `pending` defect (createTask,
//     kind:'defect') addressed to a worker — it lands in that worker's queue.
//   • WORKER → "➕ דווח ליקוי" mints a `proposed` defect (proposeTask,
//     kind:'defect') addressed to themselves — it flows through the SAME
//     contractor proposal-approval block already built in Wave G1
//     (tasks_screen's _contractorProposals), no separate approval here.
//
// PARALLEL to contractor_attendance_sheet.dart — same showXSheet +
// DraggableScrollableSheet + RTL + grab-handle/header/close idiom — but the body
// is a ConsumerStatefulWidget because the add-form owns TextEditingControllers
// (disposed with the State). HONEST by construction: only defects that exist are
// listed; 🔧 מיקום / a severity badge appear only when non-empty (never an
// invented place/severity); an empty name is a no-op (no toast).
//
// SCOPING mirrors the existing idioms: the contractor sees this employer's
// defects (`d.employerId == kDemoContractorId`, the same scope
// _contractorProposals uses); the worker sees their OWN (`d.worker ==` their
// index, the same `_bucket`/`mine` filter the worker board uses).
//
// SERVER-SWAP: kDemoContractorId is the single-device demo employer id; the real
// contractor uid when the backend lands (as the other contractor sheets).

import 'package:buildsmart/data/persona_data.dart' show kTaskStatusLabel;
import 'package:buildsmart/screens/worker_profile_screen.dart'
    show workerIndexForSession;
import 'package:buildsmart/screens/tasks_screen.dart' show authoringEmployerId;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the shared ליקויים sheet — the wire target for the '🔧 ליקויים' entry on
/// both tasks_screen (contractor) and worker_app_screen (worker). The role-aware
/// body decides what each persona can do (open vs report) and what they see.
Future<void> showDefectsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _DefectsSheet(),
  );
}

/// The defect severities offered in the add forms — a small fixed choice
/// ('' = none/unspecified) rather than free text, so the badge stays honest and
/// uniform. The empty option lets the author leave it unset (no invented level).
const List<String> _kSeverities = ['חמור', 'בינוני', 'קל'];

class _DefectsSheet extends ConsumerStatefulWidget {
  const _DefectsSheet();

  @override
  ConsumerState<_DefectsSheet> createState() => _DefectsSheetState();
}

class _DefectsSheetState extends ConsumerState<_DefectsSheet> {
  // Add-form controllers (shared by both the contractor and worker forms —
  // only one form is built per session). Owned by the State, disposed below.
  final TextEditingController _name = TextEditingController();
  final TextEditingController _location = TextEditingController();

  /// The picked severity, '' = unspecified (the honest default — no badge).
  String _severity = '';

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(boardAuthProvider);
    // The contractor board is the `manager`-role board that opens tasks_screen's
    // _managerView (BuildSmart has no separate BoardRole.contractor — the
    // contractor is the main app / the manager board here).
    final isContractor = session?.role == BoardRole.manager;

    // SCOPE the live defects to the acting persona (mirrors the existing
    // idioms): the contractor sees THIS employer's defects (the same
    // employerId == kDemoContractorId scope _contractorProposals uses); the
    // worker sees their OWN (the same `t.worker == <self index>` filter the
    // worker board's `_bucket`/`mine` uses). null session → empty (honest).
    final defects = ref.watch(defectsProvider);
    final workerIndex = session == null ? null : workerIndexForSession(session);
    final scoped = isContractor
        ? [
            for (final d in defects)
              if (d.employerId == authoringEmployerId(ref) ||
                  d.employerId.isEmpty)
                d
          ]
        : [
            for (final d in defects)
              if (workerIndex != null &&
                  workerOwnsTask(d, workerIndex, session?.uid ?? ''))
                d
          ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BsTokens.radiusCard)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BsTokens.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header row — title + a ✕ close (≥48dp tap target).
              Row(
                children: [
                  const Expanded(
                    child: CfgText(
                      'defects_sheet.header',
                      '🔧 ליקויים',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('defects-close'),
                    iconSize: 24,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: 'סגור',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isContractor
                    ? 'פתח ליקוי ושייך אותו לעובד, ועקוב אחרי הליקויים הפתוחים.'
                    : 'דווח על ליקוי שמצאת — הוא יישלח לקבלן לאישור.',
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),

              // ══ LIST — רשימת ליקויים ══
              const CfgText(
                'defects_sheet.list_title',
                'רשימת ליקויים',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              if (scoped.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space4),
                  child: CfgText(
                    'defects_sheet.empty',
                    'אין ליקויים',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                )
              else
                for (final d in scoped) ...[
                  _DefectRow(defect: d),
                  const SizedBox(height: BsTokens.space2),
                ],

              // ══ ADD — role-aware ══
              const Divider(height: 32),
              if (isContractor)
                _AddDefectForm(
                  title: '➕ פתח ליקוי',
                  nameKey: 'defect-name',
                  locationKey: 'defect-location',
                  severityKey: 'defect-severity',
                  saveKey: 'defect-open',
                  saveLabel: 'פתח ליקוי',
                  name: _name,
                  location: _location,
                  severity: _severity,
                  onSeverity: (s) => setState(() => _severity = s),
                  onSave: () => _openDefect(session),
                )
              else
                _AddDefectForm(
                  title: '➕ דווח ליקוי',
                  nameKey: 'defect-report-name',
                  locationKey: 'defect-report-location',
                  severityKey: 'defect-report-severity',
                  saveKey: 'defect-report',
                  saveLabel: 'דווח ליקוי',
                  name: _name,
                  location: _location,
                  severity: _severity,
                  onSeverity: (s) => setState(() => _severity = s),
                  onSave: () => _reportDefect(session, workerIndex),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// CONTRACTOR "➕ פתח ליקוי" — mint a `pending` defect (createTask,
  /// kind:'defect') addressed to worker 0 (the default starting assignment —
  /// kept minimal per the wave scope; the contractor can reassign it from the
  /// task board). It lands in that worker's queue. Guards an empty name (no-op,
  /// no toast). Closes the sheet + honest toast.
  void _openDefect(BoardSession? session) {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    ref.read(tasksProvider.notifier).createTask(
          name: name,
          kind: 'defect',
          location: _location.text.trim(),
          severity: _severity,
          // worker defaults to 0 (createTask's default) — the starting
          // assignment; the contractor can reassign from the task board.
          // The contractor surface is the MANAGER-role board, whose session
          // carries NO employerId — so stamp the demo contractor CONSTANT (the
          // same kDemoContractorId the task author uses), NOT session.employerId
          // (which is '' for a manager → the defect would vanish from the
          // contractor's own employer-scoped list). SERVER-SWAP: real uid.
          // Wave T3 (2c) — the real contractor uid ON, else the demo constant
          // (mirrors the task author sheet). A contractor-opened defect starts
          // unassigned; they reassign it (with the directory picker) from the board.
          employerId: authoringEmployerId(ref),
        );
    Navigator.of(context).pop();
    showToast(context, 'הליקוי נפתח 🔧');
  }

  /// WORKER "➕ דווח ליקוי" — mint a `proposed` defect (proposeTask,
  /// kind:'defect') addressed to the reporter themselves (worker index + session
  /// uid), stamped with the employing contractor. It flows through the SAME Wave
  /// G1 proposal-approval block on the contractor's board (approveProposal).
  /// Guards an empty name (no-op) and a missing worker index. Closes + toast.
  void _reportDefect(BoardSession? session, int? workerIndex) {
    final name = _name.text.trim();
    if (name.isEmpty || workerIndex == null) return;
    ref.read(tasksProvider.notifier).proposeTask(
          name: name,
          worker: workerIndex,
          kind: 'defect',
          location: _location.text.trim(),
          severity: _severity,
          assignedWorkerUid: session?.uid ?? '',
          employerId: session?.employerId ?? '',
        );
    Navigator.of(context).pop();
    showToast(context, 'הליקוי דווח לקבלן לאישור 🔧');
  }
}

/// One defect row — name, 🔧 מיקום (only when non-empty), a severity badge (only
/// when non-empty), and the live status label ([kTaskStatusLabel]). HONEST: a
/// missing place/severity simply isn't rendered (no invented value).
class _DefectRow extends StatelessWidget {
  const _DefectRow({required this.defect});

  final TaskItem defect;

  @override
  Widget build(BuildContext context) {
    final hasLocation = defect.location.isNotEmpty;
    final hasSeverity = defect.severity.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  defect.name,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                kTaskStatusLabel[defect.status] ?? '',
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          if (hasLocation || hasSeverity) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (hasLocation)
                  Expanded(
                    child: Text(
                      '🔧 ${defect.location}',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12.5,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                if (hasSeverity)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E3),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                    child: Text(
                      '⚠️ ${defect.severity}',
                      style: const TextStyle(
                        color: BsTokens.brandDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// The role-aware add-form (one instance per session) — name (required) ·
/// מיקום (optional) · חומרה (a segmented choice incl. an unspecified default) ·
/// a brand-filled save. Bound to the State's controllers (disposed there); keys
/// differ per persona (`defect-*` for the contractor, `defect-report-*` for the
/// worker) so each surface is targetable in tests.
class _AddDefectForm extends StatelessWidget {
  const _AddDefectForm({
    required this.title,
    required this.nameKey,
    required this.locationKey,
    required this.severityKey,
    required this.saveKey,
    required this.saveLabel,
    required this.name,
    required this.location,
    required this.severity,
    required this.onSeverity,
    required this.onSave,
  });

  final String title;
  final String nameKey;
  final String locationKey;
  final String severityKey;
  final String saveKey;
  final String saveLabel;
  final TextEditingController name;
  final TextEditingController location;
  final String severity;
  final void Function(String) onSeverity;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          key: ValueKey(nameKey),
          controller: name,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'מה הליקוי',
            hintText: 'לדוגמה: נזילה מתחת לכיור',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          key: ValueKey(locationKey),
          controller: location,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'מיקום (אופציונלי)',
            hintText: 'לדוגמה: אמבטיה ראשית',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        const CfgText(
          'defects_sheet.severity',
          'חומרה',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        Row(
          key: ValueKey(severityKey),
          children: [
            for (var i = 0; i < _kSeverities.length; i++) ...[
              if (i > 0) const SizedBox(width: BsTokens.space2),
              Expanded(
                child: _SeverityChip(
                  label: _kSeverities[i],
                  selected: severity == _kSeverities[i],
                  // Tapping the selected chip again clears it back to
                  // unspecified (the honest '' default — no level forced).
                  onTap: () => onSeverity(
                      severity == _kSeverities[i] ? '' : _kSeverities[i]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space4),
        Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            key: ValueKey(saveKey),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onSave,
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              child: Text(
                saveLabel,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One severity choice chip — a pill that fills brand when selected (mirrors the
/// _RolePicker/_WorkerPick pill idiom). ≥48dp tap target.
class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BsTokens.brand : Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            border: Border.all(
              color: selected ? BsTokens.brand : const Color(0xFFDDDDDD),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFFFFFFFF) : BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}
