import 'package:buildsmart/logic/input_validators.dart';
// #106/#107 — the pure printable-HTML builder (web-free, VM-safe); the print
// itself goes through the doc_print seam (false on VM/native → honest toast).
import 'package:buildsmart/logic/printable_docs.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/doc_print.dart';
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
// #106 honesty fix — the worker→contractor employer link resolver
// (`employerProfileProvider` → `EmployerProfile`). Replaces the direct
// `user_profile.dart` employer read: the employer block now reflects the
// contractor who EMPLOYS this worker (via `session.employerId`), not the raw
// device profile.
import 'package:buildsmart/state/employer_link.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
// #106/#107 — the reusable handwritten-signature capture sheet (pure dart:ui).
import 'package:buildsmart/widgets/signature_pad.dart';
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

  /// Tax years already sent to the contractor this session — guards the
  /// '📨 שלח לקבלן' pill against a double-tap re-posting the submission
  /// notice into the contractor thread (F-38).
  final Set<int> _sentYears = {};

  /// #106 — the worker's handwritten-signature PNG data-URL for the 101 form
  /// (captured via [showSignatureSheet]); null/'' until signed. Persisted on
  /// the saved [Form101.signature] and gates '📨 שלח לקבלן' (declared+signed).
  String? _sig101;

  /// #106 — whether the worker ticked the [kDeclarationText] declaration on the
  /// 101 form. Seeded from a saved form; gates the send alongside the signature.
  bool _declared101 = false;

  String? _errName;
  String? _errId;
  String? _errPhone;
  String? _errMarital;

  // ── בקשת חופשה fields ─────────────────────────────────────────────────────
  DateTime? _vacFrom;
  DateTime? _vacTo;
  final _vacReasonCtl = TextEditingController();

  /// #107 — the vacation request's handwritten-signature PNG data-URL; null/''
  /// until signed. Gates '🏖️ שלח בקשה' (declared+signed) and is passed into
  /// `submit(...)`.
  String? _sigVac;

  /// #107 — whether the worker ticked the [kDeclarationText] declaration on the
  /// vacation request. Gates the send alongside the signature.
  bool _declaredVac = false;

  // ── אישור מחלה fields ──────────────────────────────────────────────────────

  /// #107 — whether the worker ticked the [kDeclarationText] declaration before
  /// attaching a sick-note photo. Gates '📷 צרף צילום אישור' and is stored on
  /// the created note.
  bool _declaredSick = false;

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
        .where((r) => r.username == username && r.role == 'worker')
        .toList()
      ..sort((a, b) => b.createdTs.compareTo(a.createdTs));

    // #106 — the worker's own profile (idNumber/phone), the EMPLOYEE autofill
    // source when no 101 was saved yet. אין המצאות: only what the worker
    // actually typed in אזור-אישי; empty fields stay honest empty inputs.
    final myProfile = ref.watch(workerProfileProvider)[username];
    // #106 honesty fix — the EMPLOYER (מעסיק = the contractor) profile, shown
    // READ-ONLY. Resolved via the worker→contractor LINK (`session.employerId`)
    // through `employerProfileProvider`, NOT the raw device `userProfileProvider`
    // — so the employer block reflects who actually employs this worker (and
    // honestly empties when there is no link). SERVER-SWAP lives in the provider.
    final employer = ref.watch(employerProfileProvider(session.employerId));

    // Prefill ONCE: from the saved year-form when prefs resolve; otherwise the
    // live session name + the worker's profile (id/phone) — אין המצאות: only
    // real stored fields, never clobbering fresh typing (the _touched101 guard).
    if (!_touched101 && !_seededFromSaved) {
      if (saved != null) {
        _nameCtl.text = saved.fullName;
        _idCtl.text = saved.idNumber;
        _phoneCtl.text = saved.phone;
        _specialtyCtl.text = saved.specialty;
        _marital = saved.maritalStatus;
        // #106 — restore the saved signature/declaration so a re-open keeps the
        // signed state (and the send-gate stays satisfied).
        _sig101 = saved.signature.isEmpty ? null : saved.signature;
        _declared101 = saved.declared;
        _seededFromSaved = true;
      } else {
        if (_nameCtl.text.isEmpty) {
          _nameCtl.text = myProfile?.name.isNotEmpty == true
              ? myProfile!.name
              : session.displayName;
        }
        // #106 — id/phone autofill from the worker profile (ADDITION to the
        // name fallback). Only when the profile actually has them AND the input
        // is still empty (never clobber typing — the guard already protects us,
        // but the per-field empty check keeps a partial profile honest).
        if (_idCtl.text.isEmpty && (myProfile?.idNumber.isNotEmpty ?? false)) {
          _idCtl.text = myProfile!.idNumber;
        }
        if (_phoneCtl.text.isEmpty && (myProfile?.phone.isNotEmpty ?? false)) {
          _phoneCtl.text = myProfile!.phone;
        }
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
          _form101Card(session, saved, employer),
          const SizedBox(height: BsTokens.space4),
          _vacationCard(session, myVacations),
          const SizedBox(height: BsTokens.space4),
          _sickNoteCard(username, sickNotes),
        ],
      ),
    );
  }

  // ─── 1. טופס 101 ────────────────────────────────────────────────────────────

  Widget _form101Card(
      BoardSession session, Form101? saved, EmployerProfile employer) {
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
          ltr: true,
        ),
        _field(
          _phoneCtl,
          'טלפון נייד',
          errorText: _errPhone,
          keyboardType: TextInputType.phone,
          ltr: true,
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
        // #106 — READ-ONLY EMPLOYER (מעסיק) section, autofilled from the
        // contractor's profile. אין המצאות: shown only as a snapshot of real
        // stored data; the hint says honestly where it comes from / that it
        // will connect with the server when empty (NO fabricated values).
        _employerSection(employer),
        const SizedBox(height: BsTokens.space2),
        // #106 — the declaration + handwritten signature gate the send.
        _declarationRow(
          checked: _declared101,
          onChanged: (v) => setState(() {
            _touched101 = true;
            _declared101 = v;
          }),
        ),
        const SizedBox(height: BsTokens.space2),
        _signatureRow(
          signature: _sig101,
          onSign: () => _signFor101(),
        ),
        if (saved != null)
          Padding(
            padding: const EdgeInsets.only(
              top: BsTokens.space3,
              bottom: BsTokens.space3,
            ),
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
          )
        else
          const SizedBox(height: BsTokens.space3),
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
        const SizedBox(height: BsTokens.space2),
        _PillButton(
          label: '🖨️ הדפס / שמור PDF',
          filled: false,
          onPressed: () => _print101(employer),
        ),
      ],
    );
  }

  /// #106 — the EMPLOYER (מעסיק) read-only block. Pulls name/businessId/address
  /// from [employer] (resolved via the worker→contractor link in
  /// [employerProfileProvider], NOT the raw device profile); a field with no
  /// value is simply not rendered (אין המצאות). The hint is driven by
  /// [EmployerProfile.isEmpty]: linked → 'נמשכים מהקבלן'; no link yet →
  /// 'יוחברו עם השרת' (honest — the server connection will supply it).
  Widget _employerSection(EmployerProfile employer) {
    final rows = <(String, String)>[
      ('שם המעסיק', employer.name),
      ('ח.פ / עוסק מורשה', employer.businessId),
      ('כתובת המעסיק', employer.address),
    ].where((r) => r.$2.trim().isNotEmpty).toList();
    final hasAny = !employer.isEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'פרטי המעסיק',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasAny
                ? 'פרטי המעסיק נמשכים מהקבלן'
                : 'פרטי המעסיק יוחברו עם השרת',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
          // Render the detail rows only when at least one DISPLAYED field
          // (name/businessId/address) has a value — `hasAny` (the hint) is
          // `!isEmpty` which also counts `contact`, so guard the rows on the
          // displayed-field list to avoid a dangling empty spacer.
          if (rows.isNotEmpty) ...[
            const SizedBox(height: BsTokens.space2),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${r.$1}: ${r.$2}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// #106 — capture the worker's signature for the 101 form into [_sig101].
  Future<void> _signFor101() async {
    final dataUrl =
        await showSignatureSheet(context, title: 'חתימה — טופס 101');
    if (!mounted || dataUrl == null) return;
    setState(() {
      _touched101 = true;
      _sig101 = dataUrl;
    });
  }

  /// #106 — build the printable HTML for the saved/current 101 and hand it to
  /// the print seam (via [_printForm]); honest toast when printing isn't
  /// available (VM/native). Employer rows reflect the link-resolved read-only
  /// snapshot ([EmployerProfile] via [employerProfileProvider]).
  Future<void> _print101(EmployerProfile employer) => _printForm(
        title: 'טופס 101 — שנת $_year',
        rows: [
          (label: 'שם מלא', value: _nameCtl.text.trim()),
          (
            label: 'תעודת זהות',
            value: _idCtl.text.replaceAll(RegExp(r'[\s-]'), '')
          ),
          (label: 'טלפון נייד', value: _phoneCtl.text.trim()),
          (label: 'מקצוע / התמחות', value: _specialtyCtl.text.trim()),
          (label: 'מצב משפחתי', value: _marital),
          (label: 'שם המעסיק', value: employer.name),
          (label: 'ח.פ / עוסק מורשה', value: employer.businessId),
          (label: 'כתובת המעסיק', value: employer.address),
        ],
        signatureDataUrl: _sig101,
        declaration: _declared101 ? kDeclarationText : null,
      );

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

    // #106 — sending to the contractor requires the declaration ticked AND a
    // handwritten signature (an honest toast otherwise; the save path below is
    // never reached so a half-signed form is not submitted). Saving stays open
    // so a worker can store a draft before signing.
    final hasSignature = (_sig101 ?? '').isNotEmpty;
    if (send && (!_declared101 || !hasSignature)) {
      showToast(
        context,
        !_declared101
            ? 'יש לאשר את ההצהרה לפני שליחה'
            : 'יש להוסיף חתימה לפני שליחה',
      );
      return;
    }

    // #106 honesty fix — pull the employer snapshot at save-time via the
    // worker→contractor LINK (`session.employerId` → `employerProfileProvider`),
    // NOT the raw device profile, so a sent/printed copy stamps the contractor
    // who actually employs this worker (אין המצאות — only real stored fields,
    // and an empty link stamps empty employer fields honestly).
    final employer = ref.read(employerProfileProvider(session.employerId));
    ref.read(workerFormsProvider.notifier).saveForm101(Form101(
      username: session.username,
      year: _year,
      fullName: _nameCtl.text.trim(),
      idNumber: idDigits,
      phone: _phoneCtl.text.trim(),
      specialty: _specialtyCtl.text.trim(),
      maritalStatus: _marital,
      savedTs: DateTime.now(),
      signature: _sig101 ?? '',
      declared: _declared101,
      employerName: employer.name,
      employerBusinessId: employer.businessId,
      employerAddress: employer.address,
    ));
    if (send) {
      // Guard: a double-tap must not re-post the submission notice into the
      // contractor thread (F-38).
      if (_sentYears.contains(_year)) return;
      // Guard: send() is a silent no-op on an unknown thread — never mark
      // "sent" or toast a success that did not happen.
      final exists = ref
          .read(chatEngineProvider)
          .any((t) => t.id == 'th-worker-contractor');
      if (!exists) {
        showToast(context, 'שיחת הקבלן לא נמצאה — הטופס נשמר אך לא נשלח');
        return;
      }
      ref
          .read(workerFormsProvider.notifier)
          .markForm101Sent(session.username, _year);
      // The submission notice lands in the shared worker↔contractor thread
      // ('th-worker-contractor', sys_chat); the contractor reads it in his
      // שיחות tab, whose list admits worker-audience threads he participates
      // in (`_visibleToAudience`, chats_screen.dart — thread 'עובד — רן').
      // The form's content stays on-device; only the notice is sent. The line
      // carries the sender's display name — fromRole=worker alone is not an
      // identity when more than one worker exists (F-39 rule).
      ref.read(chatEngineProvider.notifier).send(
            'th-worker-contractor',
            BsRole.worker,
            '📄 ${session.displayName}: הגשתי טופס 101 לשנת $_year',
          );
      setState(() => _sentYears.add(_year));
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
        // #107 — the same declaration + signature gate as the 101 form.
        _declarationRow(
          checked: _declaredVac,
          onChanged: (v) => setState(() => _declaredVac = v),
        ),
        const SizedBox(height: BsTokens.space2),
        _signatureRow(
          signature: _sigVac,
          onSign: () => _signForVacation(),
        ),
        const SizedBox(height: BsTokens.space3),
        _PillButton(
          label: '🏖️ שלח בקשה לאישור הקבלן',
          onPressed: () => _submitVacation(session),
        ),
        const SizedBox(height: BsTokens.space2),
        _PillButton(
          label: '🖨️ הדפס',
          filled: false,
          onPressed: () => _printVacation(session),
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
    // #107 — declaration ticked AND a signature gate the submit (honest toast
    // otherwise), then both are carried into the shared request.
    final hasSignature = (_sigVac ?? '').isNotEmpty;
    if (!_declaredVac || !hasSignature) {
      showToast(
        context,
        !_declaredVac
            ? 'יש לאשר את ההצהרה לפני שליחה'
            : 'יש להוסיף חתימה לפני שליחה',
      );
      return;
    }
    ref.read(vacationRequestsProvider.notifier).submit(
          username: session.username,
          workerName: session.displayName,
          from: from,
          to: to,
          reason: _vacReasonCtl.text,
          employerId: session.employerId,
          signature: _sigVac ?? '',
          declared: _declaredVac,
        );
    setState(() {
      _vacFrom = null;
      _vacTo = null;
      _vacReasonCtl.clear();
      // Reset the per-request declaration + signature for the next one.
      _declaredVac = false;
      _sigVac = null;
    });
    showToast(context, '🏖️ הבקשה נשלחה לאישור הקבלן');
  }

  /// #107 — capture the worker's signature for the vacation request.
  Future<void> _signForVacation() async {
    final dataUrl =
        await showSignatureSheet(context, title: 'חתימה — בקשת חופשה');
    if (!mounted || dataUrl == null) return;
    setState(() => _sigVac = dataUrl);
  }

  /// #107 — print/save-PDF the vacation request (dates + reason + signature).
  Future<void> _printVacation(BoardSession session) {
    final from = _vacFrom;
    final to = _vacTo;
    return _printForm(
      title: 'בקשת חופשה',
      rows: [
        (label: 'שם העובד', value: session.displayName),
        (label: 'מתאריך', value: from == null ? '' : _fmtDate(from)),
        (label: 'עד תאריך', value: to == null ? '' : _fmtDate(to)),
        (label: 'סיבה', value: _vacReasonCtl.text.trim()),
      ],
      signatureDataUrl: _sigVac,
      declaration: _declaredVac ? kDeclarationText : null,
    );
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
        // #107 — the declaration must be ticked before attaching a photo
        // (honest toast in _addSickNote otherwise); stored on the created note.
        _declarationRow(
          checked: _declaredSick,
          onChanged: (v) => setState(() => _declaredSick = v),
        ),
        const SizedBox(height: BsTokens.space2),
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
  /// photo (a camera-seam data-URL or an uploaded https URL, rendered through
  /// the shared dual-render [taskPhotoWidget]) — tapping it opens the
  /// full-screen pinch/zoom viewer. A non-renderable payload keeps an honest
  /// 📷 box with no viewer.
  Widget _sickNoteRow(SickNote n) {
    final provider = imageProviderForRef(n.photo);
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
            if (provider == null)
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
                  onTap: () => showFullPhotoRefDialog(
                    context,
                    n.photo,
                    label: 'אישור מחלה · ${_fmtDate(n.ts)}',
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: provider,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      // Corrupt image bytes → the honest 📷, never a crash.
                      errorBuilder: (_, __, ___) => Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        color: const Color(0xFFF2F3F5),
                        child: const Text('📷',
                            style: TextStyle(fontSize: 18)),
                      ),
                    ),
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
    // #107 — the declaration gates the attach (honest toast when unchecked);
    // the ticked state is then stored on the created note.
    if (!_declaredSick) {
      showToast(context, 'יש לאשר את ההצהרה לפני צירוף הצילום');
      return;
    }
    // CAM-cluster seam (#85ב) — camera (mobile) / REAL webcam (web, with an
    // honest file-picker fallback); honest null on cancel → nothing is added.
    final photo = await pickTaskPhoto(context);
    if (photo == null || photo.isEmpty || !mounted) return;
    final note = await ref
        .read(workerFormsProvider.notifier)
        .addSickNote(username: username, photo: photo, declared: _declaredSick);
    if (!mounted) return;
    showToast(
      context,
      note == null ? 'התמונה גדולה מדי — לא נשמרה' : '📷 אישור המחלה נשמר',
    );
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
    // LTR for the 101 digit fields (ת.ז, טלפון) so latin digits render
    // left-to-right under the RTL layout; default stays RTL for Hebrew text.
    bool ltr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: TextField(
        controller: ctl,
        keyboardType: keyboardType,
        textDirection: ltr ? TextDirection.ltr : null,
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

  // ─── #106/#107 shared declaration + signature affordances ───────────────────

  /// #106/#107 — a tappable declaration row: a [Checkbox] + the [kDeclarationText]
  /// wording. The whole row toggles (≥48dp tap area); [excludeSemantics] keeps
  /// the row a single checkbox node for screen readers (the inner Text is the
  /// label).
  Widget _declarationRow({
    required bool checked,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      checked: checked,
      label: 'אישור הצהרה: $kDeclarationText',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!checked),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: BsTokens.brand,
              ),
              const Expanded(
                child: Text(
                  kDeclarationText,
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// #106/#107 — the '✍️ הוסף חתימה' action; once signed it shows 'חתום ✓' plus a
  /// small thumbnail of the captured PNG ([Image.memory] of the decoded data-URL
  /// with [cacheWidth] — F-43, decode at thumb size). Tapping re-opens the sheet
  /// to re-sign.
  Widget _signatureRow({
    required String? signature,
    required VoidCallback onSign,
  }) {
    final bytes = (signature == null || signature.isEmpty)
        ? null
        : decodeDataUrlPhoto(signature);
    return Row(
      children: [
        Expanded(
          child: _PillButton(
            label: bytes != null ? '✍️ עדכן חתימה' : '✍️ הוסף חתימה',
            filled: false,
            onPressed: onSign,
          ),
        ),
        // bytes is flow-promoted to non-null inside this collection-if, so
        // Image.memory gets a Uint8List (not nullable).
        if (bytes != null) ...[
          const SizedBox(width: BsTokens.space2),
          const Text(
            'חתום ✓',
            style: TextStyle(
              color: BsTokens.successDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: BsTokens.space2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              width: 56,
              height: 36,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              // Decode at thumb resolution, not full-res (F-43).
              cacheWidth:
                  (56 * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (_, __, ___) =>
                  const SizedBox(width: 56, height: 36),
            ),
          ),
        ],
      ],
    );
  }

  /// #107 — shared print/save-PDF path: builds the RTL HTML via
  /// [buildPrintableHtml] and hands it to the [printDocument] seam; an honest
  /// toast ('הדפסה זמינה בדפדפן') when printing isn't available (VM/native).
  Future<void> _printForm({
    required String title,
    required List<({String label, String value})> rows,
    String? signatureDataUrl,
    String? declaration,
  }) async {
    final html = buildPrintableHtml(
      title: title,
      rows: rows,
      signatureDataUrl: signatureDataUrl,
      declaration: declaration,
    );
    final ok = await printDocument(title: title, html: html);
    if (!mounted || ok) return;
    showToast(context, 'הדפסה זמינה בדפדפן');
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
    // excludeSemantics — the inner Text equals the label (F-50).
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
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
                // bsOnAccent on the brand fill (F-28) — high-contrast safe.
                color: filled ? bsOnAccent(context) : BsTokens.inkLight,
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
      excludeSemantics: true,
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
