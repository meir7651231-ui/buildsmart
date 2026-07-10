import 'package:buildsmart/screens/welcome_screen.dart';
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🛡️ תיק בטיחות (cluster #85ח) — two sections:
///   1. הדרכות שעברתי — a real persisted training log ([workerTrainingsProvider],
///      bs.worker-trainings.v1): the worker's own rows + the shared DEMO-SEED
///      rows (#66). Each row shows title / by / date + a status pill (נרשם →
///      ממתין-לאישור → אושר), an optional uploaded document (view full-screen),
///      'שלח לאישור', add (#108) and delete. A FRESH store auto-seeds 3
///      removable DEMO rows; an honest hint marks them while any remain.
///   2. תעודות מקצועיות — a real persisted wallet ([workerCertsProvider],
///      bs.worker-certs.v1): name / issuer / expiry + optional photo, with an
///      expiry traffic-light (אדום=פג · צהוב=פג בתוך חודש).
class WorkerSafetyScreen extends ConsumerWidget {
  const WorkerSafetyScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerSafetyScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — worker-board screen.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return const WelcomeScreen(boardRole: BoardRole.worker);
    }
    final username = session.username;
    // #108 — the REAL training log: this worker's own rows PLUS the shared
    // DEMO-SEED rows (filed under [kTrainingDemoUser]), exactly like the store
    // documents ("each board sees only its own + the demo rows", #66). Watch
    // the LIST (not the notifier) so the card rebuilds on add/remove/send.
    final trainings = ref
        .watch(workerTrainingsProvider)
        .where((t) =>
            t.username == username || t.username == kTrainingDemoUser)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final certs = ref
        .watch(workerCertsProvider)
        .where((c) => c.username == username)
        .toList()
      ..sort((a, b) => a.expiry.compareTo(b.expiry));

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const CfgText(
          'worker_safety_screen.appbar_title',
          '🛡️ תיק בטיחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        children: [
          _TrainingsCard(
            trainings: trainings,
            onAdd: () => _openAddTrainingSheet(context, ref, username),
            onSend: (t) =>
                ref.read(workerTrainingsProvider.notifier).sendForApproval(t.id),
            onView: (t) {
              final bytes = decodeDataUrlPhoto(t.doc);
              if (bytes != null) {
                showFullPhotoDialog(context, bytes, label: t.title);
              }
            },
            onRemove: (t) => _removeTraining(context, ref, t),
          ),
          const SizedBox(height: BsTokens.space4),
          _CertsCard(
            certs: certs,
            onAdd: () => _openAddCertSheet(context, ref, username),
            onRemove: (c) => _removeCert(context, ref, c),
          ),
        ],
      ),
    );
  }

  Future<void> _removeCert(
    BuildContext context,
    WidgetRef ref,
    WorkerCert cert,
  ) async {
    final ok = await confirmDestructive(
      context,
      title: 'מחיקת תעודה?',
      message: '"${cert.name}" תימחק מהארנק לצמיתות.',
      confirmLabel: 'מחק',
    );
    if (!ok || !context.mounted) return;
    ref.read(workerCertsProvider.notifier).remove(cert.id);
    showToast(context, 'התעודה נמחקה');
  }

  /// #108 — delete a training (confirmed; demo rows are removable too).
  Future<void> _removeTraining(
    BuildContext context,
    WidgetRef ref,
    WorkerTraining t,
  ) async {
    final ok = await confirmDestructive(
      context,
      title: 'מחיקת הדרכה?',
      message: '"${t.title}" תימחק מהרישום לצמיתות.',
      confirmLabel: 'מחק',
    );
    if (!ok || !context.mounted) return;
    ref.read(workerTrainingsProvider.notifier).remove(t.id);
    showToast(context, 'ההדרכה נמחקה');
  }

  /// #108 · "הוסף הדרכה" bottom sheet — title / by (default ממונה בטיחות) /
  /// date picker / optional document upload (the camera seam). Mirrors the
  /// cert sheet idioms: RTL, ✕ close, in-flight `saving` guard, rollback toast
  /// on a failed (quota) persist.
  Future<void> _openAddTrainingSheet(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final titleCtl = TextEditingController();
    final byCtl = TextEditingController(text: 'ממונה בטיחות');
    DateTime? date;
    String? doc;
    String? errTitle;
    String? errDate;
    var saved = false;
    // In-flight guard (F-38): a double-tap on 'שמור הדרכה' must not run two
    // adds / pop the sheet twice.
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BsTokens.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: date ?? now,
                // Trainings happen in the past — allow back-dating; cap at today.
                firstDate: DateTime(now.year - 10),
                lastDate: now,
              );
              if (picked != null) setSheetState(() => date = picked);
            }

            Future<void> attachDoc() async {
              // CAM-cluster seam (#85ב) — honest null on cancel.
              final p = await pickTaskPhoto(ctx);
              if (p == null || p.isEmpty) return;
              setSheetState(() => doc = p);
            }

            Future<void> save() async {
              if (saving) return;
              setSheetState(() {
                errTitle =
                    titleCtl.text.trim().isEmpty ? 'נא למלא שם הדרכה' : null;
                errDate = date == null ? 'נא לבחור תאריך' : null;
              });
              if (errTitle != null || errDate != null) return;
              setSheetState(() => saving = true);
              // Rollback-aware add (F-8): null = the storage write failed (web
              // quota on an oversized document) and the in-memory log was
              // rolled back — keep the sheet open for an honest retry.
              final t = await ref.read(workerTrainingsProvider.notifier).add(
                    username: username,
                    title: titleCtl.text,
                    by: byCtl.text.trim().isEmpty
                        ? 'ממונה בטיחות'
                        : byCtl.text,
                    date: date!,
                    doc: doc,
                    // Stamp the worker→contractor link so the EMPLOYING
                    // contractor sees this row (trainingsForEmployer).
                    employerId: ref.read(boardAuthProvider)?.employerId ?? '',
                  );
              if (!ctx.mounted) return;
              if (t == null) {
                setSheetState(() => saving = false);
                showToast(ctx, 'המסמך גדול מדי — לא נשמר');
                return;
              }
              saved = true;
              Navigator.of(sheetCtx).pop();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  BsTokens.space3,
                  BsTokens.space4,
                  BsTokens.space4 + MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: CfgText(
                            'worker_safety_screen.add_training_title',
                            '🎓 הוספת הדרכה',
                            style: TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Explicit X close (sheet rule).
                        IconButton(
                          tooltip: 'סגור',
                          icon: const Icon(Icons.close,
                              color: BsTokens.mutedLight),
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: BsTokens.space2),
                    TextField(
                      controller: titleCtl,
                      decoration: InputDecoration(
                        labelText: 'שם ההדרכה (למשל: עבודה בגובה)',
                        errorText: errTitle,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    TextField(
                      controller: byCtl,
                      decoration: const InputDecoration(
                        labelText: 'מדריך/מנפיק',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Date picker row (≥48dp).
                    Material(
                      color: BsTokens.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: pickDate,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(
                              horizontal: BsTokens.space3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: errDate == null
                                  ? const Color(0xFFE2E2E2)
                                  : BsTokens.danger,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('📅', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: BsTokens.space2),
                              Expanded(
                                child: Text(
                                  date == null
                                      ? (errDate ?? 'תאריך ההדרכה')
                                      : 'תאריך: ${_fmtDate(date!)}',
                                  style: TextStyle(
                                    color: date == null
                                        ? (errDate == null
                                            ? BsTokens.mutedLight
                                            : BsTokens.danger)
                                        : BsTokens.inkLight,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Optional document via the camera seam.
                    Material(
                      color: BsTokens.cardLight,
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: attachDoc,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(BsTokens.radiusPill),
                            border:
                                Border.all(color: const Color(0xFFE2E2E2)),
                          ),
                          child: doc == null
                              ? const CfgText(
                                  'worker_safety_screen.attach_doc',
                                  '📄 צרף מסמך הדרכה (לא חובה)',
                                  style: TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CfgText(
                                      'worker_safety_screen.doc_attached',
                                      '📄 מסמך צורף ✓',
                                      style: TextStyle(
                                        color: BsTokens.inkLight,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: BsTokens.space2),
                                    // 'הסר' X — clears the attached document
                                    // without closing the sheet (tap the pill
                                    // itself to re-attach).
                                    Tooltip(
                                      message: 'הסר מסמך',
                                      child: Semantics(
                                        button: true,
                                        label: 'הסר מסמך',
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: () =>
                                              setSheetState(() => doc = null),
                                          child: const SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: BsTokens.mutedLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Save — dimmed + unreactive while the awaited persist is
                    // in flight (F-38).
                    Material(
                      color:
                          saving ? const Color(0xFFE9EAEC) : BsTokens.brand,
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: saving ? null : save,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          child: CfgText(
                            'worker_safety_screen.save_training',
                            '💾 שמור הדרכה',
                            style: TextStyle(
                              // bsOnAccent on the brand fill (F-28).
                              color: saving
                                  ? BsTokens.mutedLight
                                  : bsOnAccent(ctx),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    titleCtl.dispose();
    byCtl.dispose();
    // Toast only on an actual save (the sheet popped through `save`).
    if (saved && context.mounted) {
      showToast(context, '🎓 ההדרכה נשמרה');
    }
  }

  /// "הוסף תעודה" bottom sheet — name / issuer / expiry picker / optional
  /// photo (camera seam). X close button; saves only when valid.
  Future<void> _openAddCertSheet(
    BuildContext context,
    WidgetRef ref,
    String username,
  ) async {
    final nameCtl = TextEditingController();
    final issuerCtl = TextEditingController();
    DateTime? expiry;
    String? photo;
    String? errName;
    String? errIssuer;
    String? errExpiry;
    var saved = false;
    // In-flight guard (F-38): a double-tap on 'שמור תעודה' must not run two
    // saves / pop the sheet twice.
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: BsTokens.cardLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            Future<void> pickExpiry() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: expiry ?? now,
                // Existing certificates may already be expired — allow
                // recording them honestly (the red badge says so).
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 15),
              );
              if (picked != null) setSheetState(() => expiry = picked);
            }

            Future<void> attachPhoto() async {
              // CAM-cluster seam (#85ב) — honest null on cancel.
              final p = await pickTaskPhoto(ctx);
              if (p == null || p.isEmpty) return;
              setSheetState(() => photo = p);
            }

            Future<void> save() async {
              if (saving) return;
              setSheetState(() {
                errName =
                    nameCtl.text.trim().isEmpty ? 'נא למלא שם תעודה' : null;
                errIssuer =
                    issuerCtl.text.trim().isEmpty ? 'נא למלא מנפיק' : null;
                errExpiry = expiry == null ? 'נא לבחור תוקף' : null;
              });
              if (errName != null || errIssuer != null || errExpiry != null) {
                return;
              }
              setSheetState(() => saving = true);
              // Rollback-aware add (F-8): null = the storage write failed
              // (web quota on an oversized photo) and the in-memory wallet
              // was rolled back — keep the sheet open for an honest retry.
              final cert = await ref.read(workerCertsProvider.notifier).add(
                    username: username,
                    name: nameCtl.text,
                    issuer: issuerCtl.text,
                    expiry: expiry!,
                    photo: photo,
                    // Stamp the worker→contractor link so the EMPLOYING
                    // contractor sees this cert (certsForEmployer).
                    employerId: ref.read(boardAuthProvider)?.employerId ?? '',
                  );
              if (!ctx.mounted) return;
              if (cert == null) {
                setSheetState(() => saving = false);
                showToast(ctx, 'התמונה גדולה מדי — לא נשמרה');
                return;
              }
              saved = true;
              Navigator.of(sheetCtx).pop();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  BsTokens.space3,
                  BsTokens.space4,
                  BsTokens.space4 +
                      MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: CfgText(
                            'worker_safety_screen.add_cert_title',
                            '🪪 הוספת תעודה',
                            style: TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Explicit X close (sheet rule).
                        IconButton(
                          tooltip: 'סגור',
                          icon: const Icon(Icons.close,
                              color: BsTokens.mutedLight),
                          onPressed: () => Navigator.of(sheetCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: BsTokens.space2),
                    TextField(
                      controller: nameCtl,
                      decoration: InputDecoration(
                        labelText: 'שם התעודה (למשל: עבודה בגובה)',
                        errorText: errName,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    TextField(
                      controller: issuerCtl,
                      decoration: InputDecoration(
                        labelText: 'מנפיק (למשל: משרד העבודה)',
                        errorText: errIssuer,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Expiry picker row (≥48dp).
                    Material(
                      color: BsTokens.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: pickExpiry,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(
                              horizontal: BsTokens.space3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: errExpiry == null
                                  ? const Color(0xFFE2E2E2)
                                  : BsTokens.danger,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text('📅', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: BsTokens.space2),
                              Expanded(
                                child: Text(
                                  expiry == null
                                      ? (errExpiry ?? 'בתוקף עד')
                                      : 'בתוקף עד ${_fmtDate(expiry!)}',
                                  style: TextStyle(
                                    color: expiry == null
                                        ? (errExpiry == null
                                            ? BsTokens.mutedLight
                                            : BsTokens.danger)
                                        : BsTokens.inkLight,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Optional photo via the camera seam.
                    Material(
                      color: BsTokens.cardLight,
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: attachPhoto,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(BsTokens.radiusPill),
                            border:
                                Border.all(color: const Color(0xFFE2E2E2)),
                          ),
                          child: photo == null
                              ? const CfgText(
                                  'worker_safety_screen.attach_photo',
                                  '📷 צרף צילום תעודה (לא חובה)',
                                  style: TextStyle(
                                    color: BsTokens.inkLight,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const CfgText(
                                      'worker_safety_screen.photo_attached',
                                      '📷 צילום צורף ✓',
                                      style: TextStyle(
                                        color: BsTokens.inkLight,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: BsTokens.space2),
                                    // #16 — 'הסר' X: clears the attached
                                    // photo without closing the sheet (tap
                                    // the pill itself to re-attach).
                                    Tooltip(
                                      message: 'הסר צילום',
                                      child: Semantics(
                                        button: true,
                                        label: 'הסר צילום',
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: () => setSheetState(
                                              () => photo = null),
                                          child: const SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: Icon(
                                              Icons.close,
                                              size: 18,
                                              color: BsTokens.mutedLight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    // Save — dimmed + unreactive while the awaited persist is
                    // in flight (F-38).
                    Material(
                      color: saving
                          ? const Color(0xFFE9EAEC)
                          : BsTokens.brand,
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      child: InkWell(
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: saving ? null : save,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          alignment: Alignment.center,
                          child: CfgText(
                            'worker_safety_screen.save_cert',
                            '💾 שמור תעודה',
                            style: TextStyle(
                              // bsOnAccent on the brand fill (F-28).
                              color: saving
                                  ? BsTokens.mutedLight
                                  : bsOnAccent(ctx),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
    nameCtl.dispose();
    issuerCtl.dispose();
    // Toast only on an actual save (the sheet popped through `save`).
    if (saved && context.mounted) {
      showToast(context, '🪪 התעודה נשמרה בארנק');
    }
  }
}

// ─── 1. הדרכות שעברתי ────────────────────────────────────────────────────────

/// #108 · the REAL training log card ([workerTrainingsProvider]) — one
/// [_TrainingRow] per recorded training (title / date · by / status pill), with
/// per-row actions: view an attached document full-screen, send a recorded
/// training for approval, and delete. A '➕ הוסף הדרכה' button opens the add
/// sheet. The honest demo hint stays visible while any DEMO-SEED row remains.
class _TrainingsCard extends StatelessWidget {
  const _TrainingsCard({
    required this.trainings,
    required this.onAdd,
    required this.onSend,
    required this.onView,
    required this.onRemove,
  });

  final List<WorkerTraining> trainings;
  final VoidCallback onAdd;
  final void Function(WorkerTraining) onSend;
  final void Function(WorkerTraining) onView;
  final void Function(WorkerTraining) onRemove;

  @override
  Widget build(BuildContext context) {
    // The demo hint is honest ONLY while a seeded demo row is still present
    // (ids `train-demo-*`); once the worker deletes them all it disappears.
    final hasDemo = trainings.any((t) => t.id.startsWith('train-demo-'));
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🎓 הדרכות שעברתי (${trainings.length})',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          if (trainings.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: BsTokens.space3),
              child: CfgText(
                'worker_safety_screen.no_trainings',
                'אין הדרכות רשומות עדיין — הוסף את הראשונה.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
            )
          else
            for (final t in trainings)
              _TrainingRow(
                training: t,
                onSend: () => onSend(t),
                onView: () => onView(t),
                onRemove: () => onRemove(t),
              ),
          if (hasDemo) ...[
            const SizedBox(height: BsTokens.space1),
            // HONEST demo marker — the seeded rows are demo data, not a server
            // log; it stays until the worker removes them.
            const CfgText(
              'worker_safety_screen.demo_hint',
              'נתוני דמו — רישום הדרכות אמיתי יחובר עם חיבור השרת.',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
            ),
          ],
          const SizedBox(height: BsTokens.space3),
          Semantics(
            button: true,
            label: 'הוסף הדרכה',
            excludeSemantics: true,
            child: Material(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: onAdd,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  child: CfgText(
                    'worker_safety_screen.add_training_btn',
                    '➕ הוסף הדרכה',
                    style: TextStyle(
                      // bsOnAccent on the brand fill (F-28).
                      color: bsOnAccent(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One training row — title, `date · by`, a status pill (נרשם=grey ·
/// ממתין-לאישור=warn · אושר=success), 'צפה במסמך' when a document is attached,
/// 'שלח לאישור' ONLY while still recorded, and a delete action. All tap targets
/// ≥48dp with a11y labels.
class _TrainingRow extends StatelessWidget {
  const _TrainingRow({
    required this.training,
    required this.onSend,
    required this.onView,
    required this.onRemove,
  });

  final WorkerTraining training;
  final VoidCallback onSend;
  final VoidCallback onView;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final (pill, color) = switch (training.status) {
      kTrainingApproved => ('אושר', BsTokens.successDark),
      kTrainingPending => ('ממתין לאישור', BsTokens.warnText),
      _ => ('נרשם', BsTokens.mutedLight),
    };
    final hasDoc = training.doc != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅', style: TextStyle(fontSize: 15)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        training.title,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_fmtDate(training.date)} · ${training.by}',
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                // Status pill.
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: Text(
                    pill,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space1),
            // Row actions — each ≥48dp with an a11y label.
            Row(
              children: [
                if (hasDoc)
                  _TrainingAction(
                    icon: Icons.description_outlined,
                    label: 'צפה במסמך',
                    onTap: onView,
                  ),
                if (training.status == kTrainingRecorded)
                  _TrainingAction(
                    icon: Icons.send_outlined,
                    label: 'שלח לאישור',
                    onTap: onSend,
                  ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'מחק הדרכה',
                  excludeSemantics: true,
                  child: IconButton(
                    tooltip: 'מחק הדרכה',
                    icon: const Icon(Icons.delete_outline,
                        color: BsTokens.mutedLight),
                    onPressed: onRemove,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact text+icon row action (≥48dp tap target, a11y label) used by
/// [_TrainingRow] for 'צפה במסמך' / 'שלח לאישור'.
class _TrainingAction extends StatelessWidget {
  const _TrainingAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: BsTokens.brand),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: BsTokens.brand,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 2. תעודות מקצועיות ──────────────────────────────────────────────────────

class _CertsCard extends StatelessWidget {
  const _CertsCard({
    required this.certs,
    required this.onAdd,
    required this.onRemove,
  });

  final List<WorkerCert> certs;
  final VoidCallback onAdd;
  final void Function(WorkerCert) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🪪 תעודות מקצועיות (${certs.length})',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          if (certs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: BsTokens.space3),
              child: CfgText(
                'worker_safety_screen.no_certs',
                'אין תעודות בארנק עדיין — הוסף את הראשונה.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
            )
          else
            for (final c in certs)
              _CertRow(cert: c, onRemove: () => onRemove(c)),
          Semantics(
            button: true,
            label: 'הוסף תעודה',
            excludeSemantics: true,
            child: Material(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: onAdd,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  alignment: Alignment.center,
                  child: CfgText(
                    'worker_safety_screen.add_cert_btn',
                    '➕ הוסף תעודה',
                    style: TextStyle(
                      // bsOnAccent on the brand fill (F-28).
                      color: bsOnAccent(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One wallet row — name, `issuer · בתוקף עד`, expiry traffic-light badge
/// (אדום=פג · צהוב=פג בתוך חודש · ירוק=בתוקף), the ACTUAL cert photo as a
/// tappable thumbnail (#16 — full-screen pinch/zoom viewer), delete action.
class _CertRow extends StatelessWidget {
  const _CertRow({required this.cert, required this.onRemove});

  final WorkerCert cert;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (cert.statusAt(DateTime.now())) {
      CertExpiryStatus.expired => ('פג תוקף', BsTokens.danger),
      CertExpiryStatus.expiringSoon => ('פג בקרוב', BsTokens.warnText),
      CertExpiryStatus.valid => ('בתוקף', BsTokens.successDark),
    };
    // #16 — resolve the stored photo ref once (A14 dual-render: a base64
    // data-URL or an uploaded https URL); non-renderable (or no photo) keeps
    // the old static 📷 / nothing, never a fake image.
    final provider = imageProviderForRef(cert.photo);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space3),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cert.name,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (provider != null) ...[
                        const SizedBox(width: BsTokens.space2),
                        // #16 — tappable thumbnail of the REAL cert photo →
                        // full-screen viewer (48dp tap target).
                        Semantics(
                          button: true,
                          label: 'הצג צילום תעודה במסך מלא',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => showFullPhotoRefDialog(
                              context,
                              cert.photo,
                              label: cert.name,
                            ),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image(
                                  image: provider,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  // Corrupt payload → the old honest 📷.
                                  errorBuilder: (_, __, ___) => const Text(
                                    '📷',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (cert.photo != null) ...[
                        const SizedBox(width: BsTokens.space2),
                        const Text('📷', style: TextStyle(fontSize: 13)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cert.issuer.isEmpty ? '' : '${cert.issuer} · '}'
                    'בתוקף עד ${_fmtDate(cert.expiry)}',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            ),
            IconButton(
              tooltip: 'מחק תעודה',
              icon: const Icon(Icons.delete_outline,
                  color: BsTokens.mutedLight),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
