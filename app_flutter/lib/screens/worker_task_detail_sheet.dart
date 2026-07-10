import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 WORKER TASK DETAIL SHEET (board W, task #71) — tapping any task card on
/// the worker board opens this: the task's REAL data from the live
/// [tasksProvider] (the §6 engine — verbatim `detail`/`steps` seeds, the
/// existing `photo`/`note` fields), rendered as description + step checklist +
/// progress + the existing worker actions. Style mirrors `tasks_screen.dart`'s
/// `_TaskSheet`, scoped to the WORKER role only (no manager decide block —
/// the manager decides on their own board).
///
/// No new fake state: every action is an existing engine call
/// ([TasksNotifier.attachPhoto] / [TasksNotifier.submitForReview], routed
/// through [submitWorkerTaskForReview]); the step ticks write
/// [TasksNotifier.toggleStep] — per-step completion lives on
/// [TaskItem.doneSteps] and persists with the engine overlay (#3), so the
/// checklist survives sheet close/reopen and an app restart.

/// WORKER submit — "שלח לאישור" onto the single unified [tasksProvider] (Wave
/// T1 collapsed the old dual-engine bridge into one source of truth — the
/// manager's approvals queue derives off this same engine now, so the
/// submission still surfaces there live). The auto-advance promotes the
/// worker's next queued task (proto :8133-8145); the call is a no-op outside a
/// worker-owned status. The acting [BoardSession] (board gate guarantees one)
/// stamps the server-ready identity fields: `workerUid` ← `session.uid` and
/// `employerId` ← `session.employerId` (the engine writes them only when
/// non-empty, mirroring `Order.contractorUid`), so the task carries who did it
/// and for whom.
void submitWorkerTaskForReview(WidgetRef ref, int id, {String? note}) {
  final session = ref.read(boardAuthProvider);
  ref.read(tasksProvider.notifier).submitForReview(
        id,
        note: note,
        workerUid: session?.uid,
        employerId: session?.employerId,
      );
}

/// Renders a task's proof photo (#85ב): a real data-URL
/// ('data:image/...;base64,…') decodes to the actual [Image.memory] thumbnail;
/// the legacy `'demo'` marker keeps the old honest placeholder; null renders
/// nothing. Shared by the worker detail sheet AND the manager's אישורי-עובדים
/// row (`manager_dashboard_screen.dart`) so both sides see the same proof.
Widget taskPhotoWidget(String? photo, {double height = 140, BuildContext? context}) {
  if (photo == null) return const SizedBox.shrink();
  // Apple-readiness hide (reversible): the legacy 'demo' marker carries NO real
  // image, so under [kHideUnderConstruction] its "(הדגמה)" placeholder is hidden
  // entirely — every render site (worker sheet, manager approvals row, POD
  // preview) collapses to nothing rather than showing a self-declared demo box.
  // A REAL photo (data-URL / https) is unaffected; flip the flag to restore.
  if (kHideUnderConstruction && photo == 'demo') return const SizedBox.shrink();
  // Dual-render (A14): a base64 data-URL decodes locally; an uploaded
  // `https://…` URL (kCloudPhotos ON) streams from R2 — both via the single
  // [imageProviderForRef] helper. A non-photo ref (legacy 'demo'/malformed)
  // keeps the honest placeholder.
  final provider = imageProviderForRef(photo);
  if (provider != null) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      child: Image(
        image: provider,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        // A corrupt payload / failed fetch renders the placeholder, never a crash.
        errorBuilder: (_, __, ___) => _photoPlaceholder(),
      ),
    );
  }
  return _photoPlaceholder();
}

/// The legacy 'demo' placeholder — kept verbatim for seeded photos (#85ב
/// keeps pre-photo submissions honest: "הדגמה", never a fake image).
Widget _photoPlaceholder() => Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: CfgText(
        'worker_task_detail_sheet.t01',
        '📷 תמונה מהשטח (הדגמה)',
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
      ),
    );

/// #85ב — the MANDATORY-proof submit flow, shared by the board's quick
/// "שלח לאישור" button (`worker_app_screen.dart`) and this detail sheet:
///  1. reuse an already-attached REAL photo, else open [pickTaskPhoto];
///  2. no photo → toast 'חובה לצלם הוכחת-ביצוע' and NO submit;
///  3. photo → preview dialog (thumbnail) → confirm →
///     [TasksNotifier.attachPhoto] with the data-URL + the unified submit
///     ([submitWorkerTaskForReview]).
/// Returns true only when the task was actually submitted.
Future<bool> submitWithProofPhoto(
  BuildContext context,
  WidgetRef ref,
  TaskItem task, {
  String? note,
}) async {
  final existing = task.photo;
  // A real (data-URL) photo attached earlier in the sheet is reused; the
  // legacy 'demo' marker does NOT count as proof.
  final dataUrl = (existing != null && existing.startsWith('data:image'))
      ? existing
      : await pickTaskPhoto(context);
  if (!context.mounted) return false;
  if (dataUrl == null) {
    showToast(context, 'חובה לצלם הוכחת-ביצוע');
    return false;
  }
  final confirmed = await _confirmProofPhoto(context, dataUrl);
  if (!confirmed || !context.mounted) return false;
  ref.read(tasksProvider.notifier).attachPhoto(task.id, dataUrl);
  submitWorkerTaskForReview(ref, task.id, note: note);
  showToast(context, '📸 נשלח לאישור המנהל');
  return true;
}

/// The proof-photo preview/confirm dialog — the worker SEES the thumbnail
/// before it goes to the manager. White card, RTL, ≥48dp actions.
Future<bool> _confirmProofPhoto(BuildContext context, String dataUrl) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: CfgText(
          'worker_task_detail_sheet.t02',
          '📸 הוכחת ביצוע',
          style: TextStyle(color: BsTokens.inkLight),
        ),
        // Fixed-width content: AlertDialog sizes itself with IntrinsicWidth,
        // and a stretched Column can feed it a non-finite intrinsic width
        // (layout crash — surfaced by the approval widget test with a 1x1
        // proof photo). A concrete width keeps every photo shape safe.
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              taskPhotoWidget(dataUrl, height: 180, context: dialogCtx),
              const SizedBox(height: BsTokens.space3),
              CfgText(
                'worker_task_detail_sheet.t03',
                'לשלוח את המשימה לאישור המנהל עם התמונה הזו?',
                style: TextStyle(color: Colors.black54, fontSize: 13.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: CfgText('worker_task_detail_sheet.t04', 'ביטול'),
          ),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(64, 48)),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: CfgText('worker_task_detail_sheet.t05', 'שלח לאישור'),
          ),
        ],
      ),
    ),
  );
  return ok ?? false;
}

/// Opens the worker task-detail sheet for [taskId] (#71 — any task card).
Future<void> showWorkerTaskDetailSheet(
  BuildContext context, {
  required int taskId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WorkerTaskDetailSheet(taskId: taskId),
  );
}

class WorkerTaskDetailSheet extends ConsumerStatefulWidget {
  const WorkerTaskDetailSheet({required this.taskId, super.key});

  /// The [TaskItem.id] to show — resolved LIVE off [tasksProvider] on build,
  /// so a submit/photo from inside the sheet reflects at once.
  final int taskId;

  @override
  ConsumerState<WorkerTaskDetailSheet> createState() =>
      _WorkerTaskDetailSheetState();
}

class _WorkerTaskDetailSheetState
    extends ConsumerState<WorkerTaskDetailSheet> {
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final match =
        ref.read(tasksProvider).where((x) => x.id == widget.taskId).toList();
    _note = TextEditingController(text: match.isEmpty ? '' : match.first.note);
  }

  /// Whether a [VoiceService] session is live right now (#6 voice honesty) —
  /// drives the mic button's "🎙️ מקליט..." state; reset on final transcript,
  /// engine error, no-result ending or manual stop.
  bool _dictating = false;

  @override
  void dispose() {
    // Don't leave the engine listening after the sheet is gone.
    if (_dictating) VoiceService.instance.stop();
    _note.dispose();
    super.dispose();
  }

  /// #85ב — submit is gated on a REAL proof photo: pick → preview → confirm →
  /// attach + submit (all inside [submitWithProofPhoto]); only then the
  /// sheet closes. A cancel anywhere leaves the task untouched.
  Future<void> _submit(TaskItem t) async {
    final submitted =
        await submitWithProofPhoto(context, ref, t, note: _note.text);
    if (submitted && mounted) Navigator.of(context).pop();
  }

  /// 🎙️ הערה קולית (#85ה) — VoiceService (he-IL). The final transcript is
  /// APPENDED to the note text with a newline (the engine's `note` is a single
  /// string, set only via submitForReview — no engine change needed) and is
  /// persisted through the existing submit path. #6 voice honesty: while
  /// listening the button shows a live "מקליט" state and a second tap stops
  /// the session; an engine error / no-result ending resets the state with an
  /// honest failure toast instead of silently doing nothing.
  Future<void> _dictateNote() async {
    if (_dictating) {
      // Second tap = explicit stop. The engine then delivers either the final
      // transcript (onFinal) or a no-result (onError) — both reset the state.
      await VoiceService.instance.stop();
      return;
    }
    setState(() => _dictating = true);
    final ok = await VoiceService.instance.listen(
      onFinal: (text) {
        if (!mounted) return;
        setState(() => _dictating = false);
        if (text.trim().isEmpty) {
          // An empty final transcript carries nothing to append — honest fail.
          showToast(context, 'הזיהוי נכשל — נסו שוב');
          return;
        }
        setState(() {
          _note.text = _note.text.trim().isEmpty
              ? text
              : '${_note.text.trimRight()}\n$text';
        });
        showToast(context, '🎙️ ההערה נקלטה — תישמר בשליחה לאישור');
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _dictating = false);
        showToast(context, 'הזיהוי נכשל — נסו שוב');
      },
    );
    if (!ok && mounted) {
      setState(() => _dictating = false);
      showToast(context, 'זיהוי דיבור אינו זמין בדפדפן הזה');
    }
  }

  /// 'מה להביא' (#85ה) — the install-kit recommendation aggregated over the
  /// task's mapped catalog products ([productsForTask] →
  /// [recommendedKitForProduct]), deduped by label (e.g. both SmartLock
  /// products recommend the same DN50 nut wrench — shown once). Returns []
  /// when the task has no SKU mapping (e.g. task 3 איטום — the plumbing
  /// catalogs carry no waterproofing products), so the section is omitted.
  List<Widget> _bringSection(BuildContext context, TaskItem t) {
    final products = productsForTask(t.id);
    if (products.isEmpty) return const [];
    final kit = <String, KitItem>{};
    for (final p in products) {
      for (final k in recommendedKitForProduct(p)) {
        kit.putIfAbsent(k.label, () => k);
      }
    }
    return [
      const SizedBox(height: BsTokens.space3),
      const _SecH('מה להביא'),
      // The mapped products — tapping a chip opens the REAL catalog product
      // sheet (the same sheet the catalog screens open).
      Wrap(
        spacing: BsTokens.space2,
        runSpacing: BsTokens.space1,
        children: [
          for (final p in products)
            ActionChip(
              label: Text(
                p.nameHe,
                style: const TextStyle(fontSize: 12.5),
              ),
              onPressed: () =>
                  showLipskeyProductSheet(context, p, catalogSiblingsFor(p)),
            ),
        ],
      ),
      if (kit.isEmpty)
        // Honest: the mapped products carry no kit recommendation.
        Padding(
          padding: const EdgeInsets.only(top: BsTokens.space2),
          child: CfgText(
            'worker_task_detail_sheet.t09',
            'אין המלצת ערכת התקנה למוצרי המשימה',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          ),
        )
      else
        for (final k in kit.values) _KitRow(item: k),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Re-read live so an attach/submit from inside the sheet reflects.
    final match =
        ref.watch(tasksProvider).where((x) => x.id == widget.taskId).toList();
    if (match.isEmpty) {
      // Honest empty state — the id no longer exists on the engine.
      return _sheetShell(
        children: [
          CfgText(
            'worker_task_detail_sheet.t06',
            'המשימה לא נמצאה',
            textAlign: TextAlign.center,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ],
      );
    }
    final t = match.first;

    // Worker-owned statuses can report; review/done are already submitted.
    final canReport = t.status == 'active' || t.status == 'rejected';
    final submitted = t.status == 'review' || t.status == 'done';
    final stepsTotal = t.steps.length;
    // ☑️ #3 — the persisted per-step ticks live on the engine (doneSteps).
    final stepsDone = submitted ? stepsTotal : t.doneSteps.length;
    final progress =
        stepsTotal == 0 ? (submitted ? 1.0 : 0.0) : stepsDone / stepsTotal;

    return _sheetShell(
      children: [
        // ── header: status + name + meta ──
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E3),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(
              kTaskStatusLabel[t.status] ?? '',
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        Text(
          t.name,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '🕒 ${t.days} ימים · ${t.steps.length} שלבים',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        // ⏱️ task clock (#85ו): elapsed since 'התחל עבודה'; freezes at submit.
        if (taskClockLabel(t) != null) ...[
          const SizedBox(height: 2),
          Text(
            t.completedAt != null
                ? '⏱️ זמן עבודה: ${taskClockLabel(t)}'
                : '⏱️ בעבודה: ${taskClockLabel(t)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
        if (t.status == 'pending') ...[
          const SizedBox(height: BsTokens.space2),
          // Honest: this is exactly the engine's auto-advance behavior.
          CfgText(
            'worker_task_detail_sheet.t07',
            'משימה בתור — תעבור לביצוע אוטומטית כשתוגש המשימה הנוכחית.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],

        // ── description / instructions (verbatim seed `detail`) ──
        const SizedBox(height: BsTokens.space3),
        const _SecH('תיאור והוראות'),
        Text(
          t.detail.isNotEmpty ? t.detail : 'אין הוראות נוספות למשימה זו',
          style: TextStyle(
            color: t.detail.isNotEmpty ? BsTokens.inkLight : BsTokens.mutedLight,
            fontSize: 13.5,
          ),
        ),

        // ── step checklist (verbatim seed `steps`) + progress ──
        const SizedBox(height: BsTokens.space3),
        const _SecH('שלבי ביצוע'),
        if (t.steps.isEmpty)
          // Honest: this task has no step list on the seed.
          CfgText(
            'worker_task_detail_sheet.t08',
            'לא הוגדרו שלבים למשימה זו',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          )
        else
          for (var i = 0; i < t.steps.length; i++)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: BsTokens.brand,
              // Submitted/approved tasks show the full checklist done; an open
              // task ticks straight onto the engine's persisted doneSteps
              // (#3 — TasksNotifier.toggleStep; the provider watch rebuilds).
              value: submitted || t.doneSteps.contains(i),
              onChanged: canReport
                  ? (_) =>
                      ref.read(tasksProvider.notifier).toggleStep(t.id, i)
                  : null,
              title: Text(
                t.steps[i],
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
              ),
            ),
        if (t.steps.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space2),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          Text(
            submitted
                ? (t.status == 'done' ? 'המשימה אושרה ✓' : 'הוגש לאישור המנהל')
                : 'סומנו $stepsDone מתוך $stepsTotal שלבים',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],

        // ── מה להביא (#85ה) — kit over the task's mapped products; omitted
        // entirely when the task has no SKU mapping (see task_skus_local).
        ..._bringSection(context, t),

        // ── photo (the existing TaskItem.photo field) ──
        if (t.photo != null) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('תמונת ביצוע'),
          // #85ב — real data-URL renders the actual photo; the legacy 'demo'
          // marker keeps the honest placeholder.
          taskPhotoWidget(t.photo, context: context),
        ],

        // ── worker note (read-only when not reporting) ──
        if (t.note.isNotEmpty && !canReport) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('הערת העובד'),
          Text(
            '"${t.note}"',
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
          ),
        ],

        // ── WORKER report block — the existing actions, wired to the engine ──
        if (canReport) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('דווח על הביצוע'),
          if (t.startedAt == null) ...[
            // ⏱️ task clock (#85ו): stamps TaskItem.startedAt on the engine;
            // the submit below stamps completedAt. One-shot — once started
            // the button disappears and the elapsed line in the header shows.
            _PrimaryBtn(
              key: const ValueKey('worker-task-start'),
              label: '🔨 התחל עבודה',
              onTap: () {
                ref.read(tasksProvider.notifier).startWork(t.id);
                showToast(context, '⏱️ שעון העבודה הופעל');
              },
            ),
            const SizedBox(height: BsTokens.space2),
          ],
          OutlinedButton(
            onPressed: () async {
              // #85ב — a REAL capture (webcam on web / camera on mobile);
              // null = honest cancel, nothing attached.
              final dataUrl = await pickTaskPhoto(context);
              if (!context.mounted) return;
              if (dataUrl == null) {
                showToast(context, 'לא צולמה תמונה');
                return;
              }
              ref.read(tasksProvider.notifier).attachPhoto(t.id, dataUrl);
              showToast(context, '📷 תמונת ההוכחה צורפה');
            },
            child: Text(t.photo != null ? '📷 החלף תמונה' : '📷 העלה תמונת ביצוע'),
          ),
          const SizedBox(height: BsTokens.space2),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'הערה — מה בוצע, ומה נשאר (אופציונלי)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          // 🎙️ (#85ה) — speech-to-text into the note (see _dictateNote).
          // #6: while a session is live the button is an honest stop-toggle.
          OutlinedButton.icon(
            onPressed: _dictateNote,
            icon: Icon(
              _dictating ? Icons.stop_circle_outlined : Icons.mic_none,
              color: _dictating ? BsTokens.danger : null,
            ),
            label: Text(_dictating ? '🎙️ מקליט... עצור' : 'הקלט הערה בקול'),
          ),
          const SizedBox(height: BsTokens.space3),
          _PrimaryBtn(
            key: const ValueKey('worker-task-submit'),
            label: '📸 שלח לאישור',
            onTap: () => _submit(t),
          ),
        ] else ...[
          const SizedBox(height: BsTokens.space4),
          _PrimaryBtn(
            label: 'סגור',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }

  /// The shared sheet chrome — RTL + draggable rounded container with the grab
  /// handle (mirrors `tasks_screen.dart`'s `_TaskSheet` shell).
  Widget _sheetShell({required List<Widget> children}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              // #85ג: grab handle + an explicit 48dp X close (the
              // contractor_tools_sheets idiom) — the sheet closes with one
              // tap, not only by drag/scrim.
              SizedBox(
                height: 48,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(top: BsTokens.space1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDDDDD),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: 'סגור',
                        child: IconButton(
                          tooltip: 'סגור',
                          icon: const Icon(Icons.close,
                              color: Color(0xFF888888)),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small section header (the `_SecH` idiom from `tasks_screen.dart`).
class _SecH extends StatelessWidget {
  const _SecH(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space1),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Brand-fill pill action (the worker app's own accent — matches the board's
/// "שלח לאישור" button style).
class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: 11,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bsOnAccent(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One 'מה להביא' line (#85ה) — kind icon (🔧 כלי / 🧴 איטום / ⚠️ בטיחות) +
/// label + reason + severity pill (חובה/מומלץ/אופציונלי), mirroring the
/// product sheet's install-kit strip colors.
class _KitRow extends StatelessWidget {
  const _KitRow({required this.item});

  final KitItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.kind) {
      KitKind.tool => '🔧',
      KitKind.sealant => '🧴',
      KitKind.safety => '⚠️',
    };
    final isRequired = item.severity == Severity.required;
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  item.reason,
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: BsTokens.space2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isRequired
                  ? const Color(0xFFFFF0E3)
                  : const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(
              item.severityHe,
              style: TextStyle(
                color: isRequired ? BsTokens.brandDark : BsTokens.mutedLight,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
