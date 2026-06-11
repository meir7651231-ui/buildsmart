import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
// #15 — the shared data-URL thumbnail renderer (worker detail-sheet idiom).
import 'package:buildsmart/screens/worker_task_detail_sheet.dart'
    show taskPhotoWidget;
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📄 טפסים (cluster #85ח) — the worker's forms hub:
///   1. טופס 101 — a structured DIGITAL form (NOT the official רשות-המסים
///      PDF) saved per tax year (bs.worker-forms.v1) and sendable to the
///      contractor through the existing chat thread. SERVER-SWAP: official
///      filing (signed PDF) lands with the server connection.
///   2. בקשת חופשה — dates + reason → a pending request the MANAGER decides
///      in מרכז השליטה → ניהול → בקשות חופשה (shared
///      [vacationRequestsProvider], bs.vacation-requests.v1).
///   3. אישור מחלה — photo uploads via the camera seam + the upload list.
class WorkerFormsScreen extends ConsumerStatefulWidget {
  const WorkerFormsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerFormsScreen());

  @override
  ConsumerState<WorkerFormsScreen> createState() => _WorkerFormsScreenState();
}

class _WorkerFormsScreenState extends ConsumerState<WorkerFormsScreen> {
  // ── טופס 101 fields ────────────────────────────────────────────────────────
  final _nameCtl = TextEditingController();
  final _idCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _specialtyCtl = TextEditingController();
  String _marital = '';

  /// True once the user typed/picked anything in the 101 form — guards the
  /// async-prefs prefill from clobbering fresh input (the ticket-#24 idiom).
  bool _touched101 = false;

  /// True once the saved year-form has been loaded into the controllers.
  bool _seededFromSaved = false;

  String? _errName;
  String? _errId;
  String? _errPhone;
  String? _errMarital;

  // ── בקשת חופשה fields ─────────────────────────────────────────────────────
  DateTime? _vacFrom;
  DateTime? _vacTo;
  final _vacReasonCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _idCtl.dispose();
    _phoneCtl.dispose();
    _specialtyCtl.dispose();
    _vacReasonCtl.dispose();
    super.dispose();
  }

  int get _year => DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — worker-board screen.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return const WelcomeScreen(boardRole: BoardRole.worker);
    }
    final username = session.username;

    final formsState = ref.watch(workerFormsProvider);
    final saved = formsState.form101For(username, _year);
    final sickNotes = formsState.sickNotesFor(username);
    final myVacations = ref
        .watch(vacationRequestsProvider)
        .where((r) => r.username == username)
        .toList()
      ..sort((a, b) => b.createdTs.compareTo(a.createdTs));

    // Prefill ONCE: from the saved year-form when prefs resolve; otherwise
    // the live session name (the only profile field that exists — phone and
    // specialty have no seed source, so they stay honest empty inputs).
    if (!_touched101 && !_seededFromSaved) {
      if (saved != null) {
        _nameCtl.text = saved.fullName;
        _idCtl.text = saved.idNumber;
        _phoneCtl.text = saved.phone;
        _specialtyCtl.text = saved.specialty;
        _marital = saved.maritalStatus;
        _seededFromSaved = true;
      } else if (_nameCtl.text.isEmpty) {
        _nameCtl.text = session.displayName;
      }
    }

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const Text(
          '📄 טפסים',
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
          _form101Card(session, saved),
          const SizedBox(height: BsTokens.space4),
          _vacationCard(session, myVacations),
          const SizedBox(height: BsTokens.space4),
          _sickNoteCard(username, sickNotes),
        ],
      ),
    );
  }

  // ─── 1. טופס 101 ────────────────────────────────────────────────────────────

  Widget _form101Card(BoardSession session, Form101? saved) {
    return _FormCard(
      title: '📄 טופס 101 — שנת $_year',
      children: [
        // HONEST framing: a structured digital form, not the official PDF.
        const Text(
          'טופס דיגיטלי מובנה — אינו הטופס הרשמי של רשות המסים. '
          'הגשה רשמית תחובר עם חיבור השרת.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
        ),
        const SizedBox(height: BsTokens.space3),
        _field(_nameCtl, 'שם מלא', errorText: _errName),
        _field(
          _idCtl,
          'תעודת זהות (9 ספרות)',
          errorText: _errId,
          keyboardType: TextInputType.number,
        ),
        _field(
          _phoneCtl,
          'טלפון נייד',
          errorText: _errPhone,
          keyboardType: TextInputType.phone,
        ),
        _field(_specialtyCtl, 'מקצוע / התמחות'),
        Padding(
          padding: const EdgeInsets.only(bottom: BsTokens.space3),
          child: DropdownButtonFormField<String>(
            value: _marital.isEmpty ? null : _marital,
            decoration: InputDecoration(
              labelText: 'מצב משפחתי',
              errorText: _errMarital,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space3,
                vertical: BsTokens.space3,
              ),
            ),
            items: [
              for (final m in const ['רווק/ה', 'נשוי/אה', 'גרוש/ה', 'אלמן/ה'])
                DropdownMenuItem(value: m, child: Text(m)),
            ],
            onChanged: (v) => setState(() {
              _touched101 = true;
              _marital = v ?? '';
            }),
          ),
        ),
        if (saved != null)
          Padding(
            padding: const EdgeInsets.only(bottom: BsTokens.space3),
            child: Text(
              saved.sentTs != null
                  ? '✓ נשמר ונשלח לקבלן ב-${_fmtDate(saved.sentTs!)}'
                  : '💾 נשמר ב-${_fmtDate(saved.savedTs)} (טרם נשלח)',
              style: const TextStyle(
                color: BsTokens.successDark,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _PillButton(
                label: '💾 שמור טופס',
                filled: false,
                onPressed: () => _save101(session, send: false),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: _PillButton(
                label: '📨 שלח לקבלן',
                onPressed: () => _save101(session, send: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Validate → persist (bs.worker-forms.v1, keyed by year) → optionally send
  /// an honest summary line into the worker↔contractor chat thread.
  void _save101(BoardSession session, {required bool send}) {
    final idDigits = _idCtl.text.replaceAll(RegExp(r'[\s-]'), '');
    setState(() {
      _errName = _nameCtl.text.trim().isEmpty ? 'נא למלא שם מלא' : null;
      // FORMAT check only (9 digits) — like input_validators.dart; a real
      // checksum/identity verification is a server concern.
      _errId = RegExp(r'^\d{9}$').hasMatch(idDigits)
          ? null
          : 'ת.ז חייבת להיות 9 ספרות';
      _errPhone = validIsraeliMobile(_phoneCtl.text)
          ? null
          : 'מספר נייד לא תקין (05XXXXXXXX)';
      _errMarital = _marital.isEmpty ? 'נא לבחור מצב משפחתי' : null;
    });
    if (_errName != null ||
        _errId != null ||
        _errPhone != null ||
        _errMarital != null) {
      showToast(context, 'יש לתקן את השדות המסומנים');
      return;
    }

    ref.read(workerFormsProvider.notifier).saveForm101(Form101(
      username: session.username,
      year: _year,
      fullName: _nameCtl.text.trim(),
      idNumber: idDigits,
      phone: _phoneCtl.text.trim(),
      specialty: _specialtyCtl.text.trim(),
      maritalStatus: _marital,
      savedTs: DateTime.now(),
    ));
    if (send) {
      ref
          .read(workerFormsProvider.notifier)
          .markForm101Sent(session.username, _year);
      // The submission notice lands in the shared worker↔contractor thread
      // ('th-worker-contractor', sys_chat); the contractor reads it in his
      // שיחות tab, whose list admits worker-audience threads he participates
      // in (`_visibleToAudience`, chats_screen.dart — thread 'עובד — רן').
      // The form's content stays on-device; only the notice is sent.
      ref.read(chatEngineProvider.notifier).send(
            'th-worker-contractor',
            BsRole.worker,
            '📄 הגשתי טופס 101 לשנת $_year',
          );
      showToast(context, '📨 טופס 101 נשלח לקבלן');
    } else {
      showToast(context, '💾 טופס 101 נשמר לשנת $_year');
    }
  }

  // ─── 2. בקשת חופשה ─────────────────────────────────────────────────────────

  Widget _vacationCard(BoardSession session, List<VacationRequest> mine) {
    return _FormCard(
      title: '🏖️ בקשת חופשה',
      children: [
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'מתאריך',
                value: _vacFrom,
                onPick: () => _pickVacDate(isFrom: true),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: _DateField(
                label: 'עד תאריך',
                value: _vacTo,
                onPick: () => _pickVacDate(isFrom: false),
              ),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          controller: _vacReasonCtl,
          decoration: const InputDecoration(
            labelText: 'סיבה (לא חובה)',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
              vertical: BsTokens.space3,
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        _PillButton(
          label: '🏖️ שלח בקשה לאישור המנהל',
          onPressed: () => _submitVacation(session),
        ),
        if (mine.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space4),
          const Text(
            'הבקשות שלי',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: BsTokens.space2),
          for (final r in mine) _VacationRow(request: r),
        ],
      ],
    );
  }

  Future<void> _pickVacDate({required bool isFrom}) async {
    final now = DateTime.now();
    final initial = (isFrom ? _vacFrom : _vacTo) ??
        (isFrom ? now : (_vacFrom ?? now));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _vacFrom = picked;
        // Keep the range valid — a "to" before the new "from" follows it.
        if (_vacTo != null && _vacTo!.isBefore(picked)) _vacTo = picked;
      } else {
        _vacTo = picked;
      }
    });
  }

  void _submitVacation(BoardSession session) {
    final from = _vacFrom;
    final to = _vacTo;
    if (from == null || to == null) {
      showToast(context, 'נא לבחור תאריך התחלה וסיום');
      return;
    }
    if (to.isBefore(from)) {
      showToast(context, 'תאריך הסיום לפני תאריך ההתחלה');
      return;
    }
    ref.read(vacationRequestsProvider.notifier).submit(
          username: session.username,
          workerName: session.displayName,
          from: from,
          to: to,
          reason: _vacReasonCtl.text,
        );
    setState(() {
      _vacFrom = null;
      _vacTo = null;
      _vacReasonCtl.clear();
    });
    showToast(context, '🏖️ הבקשה נשלחה לאישור המנהל');
  }

  // ─── 3. אישור מחלה ─────────────────────────────────────────────────────────

  Widget _sickNoteCard(String username, List<SickNote> notes) {
    return _FormCard(
      title: '🤒 אישור מחלה',
      children: [
        const Text(
          'צלם את אישור המחלה — הצילום נשמר ברשימה כאן.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
        ),
        const SizedBox(height: BsTokens.space3),
        _PillButton(
          label: '📷 צרף צילום אישור',
          onPressed: () => _addSickNote(username),
        ),
        if (notes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: BsTokens.space3),
            child: Text(
              'אין אישורים שהועלו עדיין',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
            ),
          )
        else ...[
          const SizedBox(height: BsTokens.space3),
          for (final n in notes) _sickNoteRow(n),
        ],
      ],
    );
  }

  /// One sick-note row (#15): leading 48dp thumbnail of the ACTUAL stored
  /// photo (the camera-seam data-URL, rendered through the shared
  /// [taskPhotoWidget]) — tapping it opens the full-screen pinch/zoom viewer.
  /// A non-decodable payload keeps an honest 📷 box with no viewer.
  Widget _sickNoteRow(SickNote n) {
    final bytes = decodeDataUrlPhoto(n.photo);
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BsTokens.space3,
          vertical: BsTokens.space1,
        ),
        decoration: BoxDecoration(
          color: BsTokens.bgLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Row(
          children: [
            if (bytes == null)
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('📷', style: TextStyle(fontSize: 18)),
              )
            else
              Semantics(
                button: true,
                label: 'הצג אישור מחלה במסך מלא',
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => showFullPhotoDialog(
                    context,
                    bytes,
                    label: 'אישור מחלה · ${_fmtDate(n.ts)}',
                  ),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: taskPhotoWidget(n.photo, height: 48),
                  ),
                ),
              ),
            const SizedBox(width: BsTokens.space3),
            Expanded(
              child: Text(
                'אישור מחלה · ${_fmtDate(n.ts)}',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: 'מחק אישור',
              icon: const Icon(
                Icons.delete_outline,
                color: BsTokens.mutedLight,
              ),
              onPressed: () => _removeSickNote(n),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSickNote(String username) async {
    // CAM-cluster seam (#85ב) — camera (mobile) / REAL webcam (web, with an
    // honest file-picker fallback); honest null on cancel → nothing is added.
    final photo = await pickTaskPhoto(context);
    if (photo == null || photo.isEmpty || !mounted) return;
    ref
        .read(workerFormsProvider.notifier)
        .addSickNote(username: username, photo: photo);
    showToast(context, '📷 אישור המחלה נשמר');
  }

  Future<void> _removeSickNote(SickNote n) async {
    final ok = await confirmDestructive(
      context,
      title: 'מחיקת אישור מחלה?',
      message: 'האישור מ-${_fmtDate(n.ts)} יימחק לצמיתות.',
      confirmLabel: 'מחק',
    );
    if (!ok || !mounted) return;
    ref.read(workerFormsProvider.notifier).removeSickNote(n.id);
    showToast(context, 'האישור נמחק');
  }

  // ─── shared field helper ───────────────────────────────────────────────────

  Widget _field(
    TextEditingController ctl,
    String label, {
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: TextField(
        controller: ctl,
        keyboardType: keyboardType,
        onChanged: (_) => _touched101 = true,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: BsTokens.space3,
            vertical: BsTokens.space3,
          ),
        ),
      ),
    );
  }
}

// ─── shared widgets ───────────────────────────────────────────────────────────

/// A white form card with a bold title — the board's card style.
class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

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
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          ...children,
        ],
      ),
    );
  }
}

/// A ≥48dp pill action — brand fill, or a light outline when [filled]=false.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: filled ? BsTokens.brand : BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onPressed,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              border:
                  filled ? null : Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : BsTokens.inkLight,
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

/// A tappable date field (≥48dp) showing the picked date or its label.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value == null ? label : '$label: ${_fmtDate(value!)}',
      child: Material(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 16)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    value == null ? label : _fmtDate(value!),
                    style: TextStyle(
                      color: value == null
                          ? BsTokens.mutedLight
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
    );
  }
}

/// One of "הבקשות שלי" — range + reason + a live status pill (the manager's
/// decision flips it through the shared provider).
class _VacationRow extends StatelessWidget {
  const _VacationRow({required this.request});

  final VacationRequest request;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (request.status) {
      kVacationApproved => ('✅ אושרה', BsTokens.successDark),
      kVacationRejected => ('❌ נדחתה', BsTokens.danger),
      _ => ('⏳ ממתינה', BsTokens.warnText),
    };
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
                  Text(
                    request.range,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (request.reason.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      request.reason,
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
