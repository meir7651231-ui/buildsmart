// Wave G3b — the shared ליקויים (DEFECTS) bottom-sheet: the CONTRACTOR opens a
// defect and the WORKER reports one, BOTH over the same defect engine (Wave G3a
// added `kind=='defect'` to TaskItem + the `defectsProvider` kind-filter, and
// the contractor/worker authoring rides the same createTask/proposeTask the
// regular §6 tasks use). "ליקויים same as משימות" — a defect reuses the ENTIRE
// task lifecycle, so this surface adds NO new approve/reject UI:
//   • CONTRACTOR (the main app — no board session; reached from ניהול אתר →
//     🔧 רשימת ליקויים) → "➕ פתח ליקוי" mints a `pending` defect (createTask,
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
// invented place/severity); an empty name shows an inline error on the field.
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
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the shared ליקויים sheet — the wire target for the '🔧 ליקויים' entry on
/// both the site hub (contractor) and worker_app_screen (worker). The role-aware
/// body decides what each persona can do (open vs report) and what they see.
Future<void> showDefectsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    // Lift the sheet above the on-screen keyboard — the add form sits at the
    // bottom of the list and would otherwise be covered while typing.
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: const _DefectsSheet(),
    ),
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
  final FocusNode _nameFocus = FocusNode();

  /// The picked severity, '' = unspecified (the honest default — no badge).
  String _severity = '';

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  /// Save was tapped with an empty name — shown inline under the name field
  /// (a toast would sit behind the sheet) and cleared on the next keystroke.
  bool _nameError = false;

  void _clearNameError(String _) {
    if (_nameError) setState(() => _nameError = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(boardAuthProvider);
    // The contractor is the MAIN APP and never holds a BoardSession (BuildSmart
    // has no BoardRole.contractor). So only a logged-in WORKER board gets the
    // report variant; no session / manager / any other session is the employer
    // view (mirrors tasks_gantt_sheet.dart).
    final isContractor = session?.role != BoardRole.worker;

    // SCOPE the live defects to the acting persona (mirrors the existing
    // idioms): the contractor sees THIS employer's defects (the same
    // employerId == kDemoContractorId scope _contractorProposals uses); the
    // worker sees their OWN (the same `t.worker == <self index>` filter the
    // worker board's `_bucket`/`mine` uses).
    final defects = ref.watch(defectsProvider);
    final workerIndex = session == null ? null : workerIndexForSession(session);
    final employerId = isContractor ? authoringEmployerId(ref) : '';
    final scoped = isContractor
        ? [
            for (final d in defects)
              if (d.employerId == employerId ||
                  d.employerId.isEmpty)
                d
          ]
        : [
            for (final d in defects)
              if (workerIndex != null &&
                  workerOwnsTask(d, workerIndex, session?.uid ?? ''))
                d
          ];

    final cs = Theme.of(context).colorScheme;
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
            // + the bottom safe area, so the save button clears the home
            // indicator / gesture bar.
            padding: const EdgeInsets.all(BsTokens.space4).copyWith(
              bottom:
                  BsTokens.space4 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BsTokens.space3),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header row — title + a ✕ close (≥48dp tap target).
              Row(
                children: [
                  Expanded(
                    child: CfgText(
                      'defects_sheet.header',
                      '🔧 ליקויים',
                      style: TextStyle(
                        color: cs.onSurface,
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
                    icon: Icon(Icons.close, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isContractor
                    ? 'פתח ליקוי ועקוב אחרי הליקויים הפתוחים.'
                    : 'דווח על ליקוי שמצאת — הוא יישלח לקבלן לאישור.',
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),

              // ══ LIST — רשימת ליקויים ══
              CfgText(
                'defects_sheet.list_title',
                'רשימת ליקויים',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              if (scoped.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: BsTokens.space4),
                  child: CfgText(
                    'defects_sheet.empty',
                    'אין ליקויים',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurface,
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
                  nameError: _nameError,
                  nameFocus: _nameFocus,
                  onNameChanged: _clearNameError,
                  onSeverity: (s) => setState(() => _severity = s),
                  onSave: _openDefect,
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
                  nameError: _nameError,
                  nameFocus: _nameFocus,
                  onNameChanged: _clearNameError,
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
  /// task board). It lands in that worker's queue. An empty name is rejected
  /// with an inline error on the field (the sheet stays open). Closes the sheet
  /// + honest toast.
  void _openDefect() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      _nameFocus.requestFocus(); // brings the field (and its error) into view
      return;
    }
    ref.read(tasksProvider.notifier).createTask(
          name: name,
          kind: 'defect',
          location: _location.text.trim(),
          severity: _severity,
          // worker defaults to 0 (createTask's default) — the starting
          // assignment; the contractor can reassign from the task board.
          // The contractor has no board session (and a manager session carries
          // NO employerId), so the employer is never read from the session.
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
  /// An empty name is rejected with an inline error; a missing worker index is
  /// a no-op. Closes + toast.
  void _reportDefect(BoardSession? session, int? workerIndex) {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      _nameFocus.requestFocus(); // brings the field (and its error) into view
      return;
    }
    if (workerIndex == null) return;
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

/// Accent text that stays readable on the sheet surface in both themes: dark
/// amber on light (AA at small sizes), the brand orange on dark.
Color _accentText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? BsTokens.brand
        : BsTokens.warnText;

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
    final cs = Theme.of(context).colorScheme;
    final accent = _accentText(context);
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  defect.name,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              // Capped (not flex-shared) so a short status never takes half the
              // row from the defect name; a long one ellipsises.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * .4,
                ),
                child: Text(
                  kTaskStatusLabel[defect.status] ?? defect.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
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
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
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
                      // Lighter tint on light so the amber text keeps AA (≥4.5:1).
                      color: BsTokens.brand.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? .14
                            : .08,
                      ),
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    ),
                    child: Text(
                      '⚠️ ${defect.severity}',
                      style: TextStyle(
                        color: accent,
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
    required this.nameError,
    required this.nameFocus,
    required this.onNameChanged,
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
  final bool nameError;
  final FocusNode nameFocus;
  final ValueChanged<String> onNameChanged;
  final void Function(String) onSeverity;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          key: ValueKey(nameKey),
          controller: name,
          focusNode: nameFocus,
          textInputAction: TextInputAction.next,
          onChanged: onNameChanged,
          decoration: InputDecoration(
            labelText: 'מה הליקוי',
            hintText: 'לדוגמה: נזילה מתחת לכיור',
            errorText: nameError ? 'יש לכתוב מה הליקוי' : null,
            border: const OutlineInputBorder(),
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
        CfgText(
          'defects_sheet.severity',
          'חומרה',
          style: TextStyle(
            color: cs.onSurface,
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
        Semantics(
          button: true,
          child: Material(
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
                  style: TextStyle(
                    // white normally; dark ink in high-contrast mode
                    color: bsOnAccent(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
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
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: _chip(cs, bsOnAccent(context)),
    );
  }

  Widget _chip(ColorScheme cs, Color onAccent) {
    return Material(
      color: selected ? BsTokens.brand : cs.surface,
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
              color: selected ? BsTokens.brand : cs.outline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? onAccent : cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }
}
