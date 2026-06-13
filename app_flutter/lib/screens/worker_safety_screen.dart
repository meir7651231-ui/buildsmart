import 'package:buildsmart/screens/welcome_screen.dart';
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🛡️ תיק בטיחות (cluster #85ח) — two sections:
///   1. הדרכות שעברתי — DEMO SEED records (honest: no server training log
///      exists yet; an honest hint marks them as demo data).
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
        title: const Text(
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
          const _TrainingsCard(),
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
                          child: Text(
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
                              ? const Text(
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
                                    const Text(
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
                          child: Text(
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

/// DEMO SEED (honest): there is no server-side training registry yet, so
/// these are demo records — the UI says so in the hint line below the list.
/// SERVER-SWAP: replaced by the real safety-training log with the backend.
const List<({String title, String date, String by})> _kDemoTrainings = [
  (title: 'הדרכת בטיחות כללית באתר', date: '5.1.2026', by: 'ממונה בטיחות'),
  (title: 'רענון עבודה בגובה', date: '12.3.2026', by: 'מדריך מוסמך'),
  (title: 'שימוש בציוד מגן אישי', date: '2.6.2026', by: 'ממונה בטיחות'),
];

class _TrainingsCard extends StatelessWidget {
  const _TrainingsCard();

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
          const Text(
            '🎓 הדרכות שעברתי',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          for (final t in _kDemoTrainings)
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✅', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${t.date} · ${t.by}',
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: BsTokens.space1),
          // HONEST demo marker — these are seed records, not a server log.
          const Text(
            'נתוני דמו — רישום הדרכות אמיתי יחובר עם חיבור השרת.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
          ),
        ],
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
              child: Text(
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
                  child: Text(
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
    // #16 — decode the stored data-URL once; non-decodable (or no photo)
    // keeps the old static 📷 / nothing, never a fake image.
    final photoBytes = decodeDataUrlPhoto(cert.photo);
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
                      if (photoBytes != null) ...[
                        const SizedBox(width: BsTokens.space2),
                        // #16 — tappable thumbnail of the REAL cert photo →
                        // full-screen viewer (48dp tap target).
                        Semantics(
                          button: true,
                          label: 'הצג צילום תעודה במסך מלא',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => showFullPhotoDialog(
                              context,
                              photoBytes,
                              label: cert.name,
                            ),
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  photoBytes,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  // F-43 — decode to the 40px thumbnail size,
                                  // never the full-res bitmap.
                                  cacheWidth: (40 *
                                          MediaQuery.devicePixelRatioOf(
                                              context))
                                      .round(),
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
