import 'package:buildsmart/screens/welcome_screen.dart';
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
// courier_hr.dart re-exports the shared cert model (WorkerCert +
// CertExpiryStatus/statusAt) and owns kCourierCertPresets — NO model
// duplication (#86.4).
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🪪 תעודות נהג (#86.4 · F-17) — the courier's driver-certificate wallet:
/// name / issuer / expiry + optional photo, with the shared expiry
/// traffic-light (אדום=פג · צהוב=פג בתוך חודש · ירוק=בתוקף, via
/// [WorkerCert.statusAt] as-is) and quick-add preset chips
/// ([kCourierCertPresets]: רישיון נהיגה · ביטוח רכב · רישיון רכב) that
/// pre-fill the NAME field only — issuer and expiry stay honest user input.
///
/// Data: [courierCertsProvider] (bs.courier-certs.v1) — per logged username,
/// isolated from the worker wallet (F-7). No worker "הדרכות" section here —
/// that is worker-specific demo content, not a courier surface.
class CourierCertsScreen extends ConsumerWidget {
  const CourierCertsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierCertsScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — COURIER-board screen (F-16).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }
    final username = session.username;
    final certs =
        ref
            .watch(courierCertsProvider)
            .where((c) => c.username == username)
            .toList()
          ..sort((a, b) => a.expiry.compareTo(b.expiry));

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const CfgText(
          'courier.certs.title',
          '🪪 תעודות נהג',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: const [HelpToggleButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        children: [
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
    ref.read(courierCertsProvider.notifier).remove(cert.id);
    showToast(context, 'התעודה נמחקה');
  }

  /// "הוסף תעודה" bottom sheet — preset chips → name / issuer / expiry picker
  /// / optional photo (camera seam). X close button; saves only when valid,
  /// AWAITS the rollback-aware add (F-8) and never fakes success on a
  /// quota failure.
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BsTokens.radiusCard),
        ),
      ),
      // Explicit RTL wrap — the sheet convention (F-46); modal builders do
      // not inherit the app-level Directionality wrapper.
      builder:
          (sheetCtx) => Directionality(
            textDirection: TextDirection.rtl,
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                Future<void> pickExpiry() async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: expiry ?? now,
                    // Existing certificates may already be expired — allow
                    // recording them honestly (the red badge says so). NEVER
                    // restrict to future-only dates (F-17).
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
                  if (errName != null ||
                      errIssuer != null ||
                      errExpiry != null) {
                    return;
                  }
                  setSheetState(() => saving = true);
                  // Rollback-aware add (F-8): null = the storage write failed
                  // (web quota on an oversized photo) and the in-memory wallet
                  // was rolled back — keep the sheet open for an honest retry.
                  final cert = await ref
                      .read(courierCertsProvider.notifier)
                      .add(
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
                  // Pop through ctx (same modal route as sheetCtx) — the mounted
                  // guard above covers this context across the async gap.
                  Navigator.of(ctx).pop();
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
                                'courier.certs.sheet_title',
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
                              icon: const Icon(
                                Icons.close,
                                color: BsTokens.mutedLight,
                              ),
                              onPressed: () => Navigator.of(sheetCtx).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: BsTokens.space2),
                        // Quick-add presets (#86.4) — pre-fill the NAME field
                        // ONLY; issuer and expiry stay user input (אין המצאות:
                        // no invented issuer, no invented dates).
                        const Text(
                          'מילוי מהיר — ממלא את שם התעודה בלבד:',
                          style: TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(height: BsTokens.space2),
                        Wrap(
                          spacing: BsTokens.space2,
                          runSpacing: BsTokens.space2,
                          children: [
                            for (final p in kCourierCertPresets)
                              _PresetChip(
                                label: p,
                                selected: nameCtl.text.trim() == p,
                                onTap:
                                    () => setSheetState(() {
                                      nameCtl.text = p;
                                      errName = null;
                                    }),
                              ),
                          ],
                        ),
                        const SizedBox(height: BsTokens.space3),
                        TextField(
                          controller: nameCtl,
                          decoration: InputDecoration(
                            labelText: 'שם התעודה (למשל: רישיון נהיגה)',
                            errorText: errName,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: BsTokens.space3),
                        TextField(
                          controller: issuerCtl,
                          decoration: InputDecoration(
                            labelText: 'מנפיק (למשל: משרד הרישוי)',
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
                                horizontal: BsTokens.space3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      errExpiry == null
                                          ? const Color(0xFFE2E2E2)
                                          : BsTokens.danger,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '📅',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: BsTokens.space2),
                                  Expanded(
                                    child: Text(
                                      expiry == null
                                          ? (errExpiry ?? 'בתוקף עד')
                                          : 'בתוקף עד ${_fmtDate(expiry!)}',
                                      style: TextStyle(
                                        color:
                                            expiry == null
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
                          borderRadius: BorderRadius.circular(
                            BsTokens.radiusPill,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              BsTokens.radiusPill,
                            ),
                            onTap: attachPhoto,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  BsTokens.radiusPill,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFE2E2E2),
                                ),
                              ),
                              child:
                                  photo == null
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
                                          const SizedBox(
                                            width: BsTokens.space2,
                                          ),
                                          // 'הסר' X: clears the attached photo
                                          // without closing the sheet (tap the
                                          // pill itself to re-attach). 48dp — the
                                          // worker template's 40dp X is below the
                                          // touch floor (F-17).
                                          Tooltip(
                                            message: 'הסר צילום',
                                            child: Semantics(
                                              button: true,
                                              label: 'הסר צילום',
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap:
                                                    () => setSheetState(
                                                      () => photo = null,
                                                    ),
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
                          borderRadius: BorderRadius.circular(
                            BsTokens.radiusPill,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              BsTokens.radiusPill,
                            ),
                            onTap: saving ? null : save,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              alignment: Alignment.center,
                              child: CfgText(
                                'courier.certs.save_button',
                                '💾 שמור תעודה',
                                style: TextStyle(
                                  // bsOnAccent on the brand fill (F-28).
                                  color:
                                      saving
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

/// One quick-add preset pill (≥48dp) — fills the name field only.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: selected ? BsTokens.brand : BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border:
                  selected ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Text(
              label,
              style: TextStyle(
                // bsOnAccent on the selected brand fill (F-28).
                color: selected ? bsOnAccent(context) : BsTokens.inkLight,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── the wallet card ─────────────────────────────────────────────────────────

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
            '🪪 תעודות נהג (${certs.length})',
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
                'courier.certs.empty',
                'אין תעודות בארנק עדיין — הוסף את הראשונה.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
            )
          else
            for (final c in certs)
              _CertRow(cert: c, onRemove: () => onRemove(c)),
          // excludeSemantics — the inner Text repeats the label (F-50).
          HelpTarget(
            title: 'הוספת תעודה',
            body:
                'פותח את גיליון הוספת תעודת-נהג — שם, מנפיק, תוקף וצילום אופציונלי.',
            child: Semantics(
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
                      'courier.certs.add_button',
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
          ),
        ],
      ),
    );
  }
}

/// One wallet row — name, `issuer · בתוקף עד`, expiry traffic-light badge
/// (אדום=פג · צהוב=פג בתוך חודש · ירוק=בתוקף, [WorkerCert.statusAt] as-is —
/// an already-expired license renders honestly red), the ACTUAL cert photo as
/// a tappable thumbnail (full-screen pinch/zoom viewer), delete action.
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
    // Resolve the stored photo ref once per build (A14 dual-render: a base64
    // data-URL or an uploaded https URL); non-renderable (or no photo) keeps
    // the static 📷 / nothing, never a fake image.
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
                        // Tappable thumbnail of the REAL cert photo →
                        // full-screen viewer (48dp tap target).
                        HelpTarget(
                          title: 'צפייה בצילום התעודה',
                          body:
                              'הקשה על התמונה פותחת את צילום-התעודה במסך מלא.',
                          child: Semantics(
                            button: true,
                            label: 'הצג צילום תעודה במסך מלא',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap:
                                  () => showFullPhotoRefDialog(
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
                                    // Decode at thumb resolution (F-43) — the
                                    // full-res decode stays in the viewer only.
                                    image: ResizeImage(
                                      provider,
                                      width:
                                          (40 *
                                                  MediaQuery.devicePixelRatioOf(
                                                    context,
                                                  ))
                                              .round(),
                                    ),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    // Corrupt payload → the honest 📷.
                                    errorBuilder:
                                        (_, __, ___) => const Text(
                                          '📷',
                                          style: TextStyle(fontSize: 13),
                                        ),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            HelpTarget(
              title: 'מחיקת תעודה',
              body: 'מוחק את התעודה מהארנק לצמיתות (עם דיאלוג אישור).',
              child: IconButton(
                tooltip: 'מחק תעודה',
                icon: const Icon(
                  Icons.delete_outline,
                  color: BsTokens.mutedLight,
                ),
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
