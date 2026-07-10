import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
// CAM-cluster seam (#85ב): `pickTaskPhoto()` → data-URL String, or an honest
// null on cancel/failure (no fake placeholder ever).
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
// courier_hr.dart re-exports the shared forms models (Form101 / SickNote /
// WorkerFormsState) — NO model duplication (#86.3).
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 📄 טפסים — שליח (#86.3 · F-32) — the courier's forms hub:
///   1. טופס 101 — a structured DIGITAL form (NOT the official רשות-המסים
///      PDF) saved per tax year (bs.courier-forms.v1) and sendable to the
///      STORE through the store↔courier chat thread (the courier has no
///      contractor — the recipient is the store, like the daily report).
///      SERVER-SWAP: official filing (signed PDF) lands with the server.
///   2. בקשת חופשה — dates + reason → a pending request the MANAGER decides
///      in the SHARED [vacationRequestsProvider] queue (reused as-is, SPEC
///      #86.3), submitted with role: 'courier' (F-26 — the shared `demo`
///      username makes username-only filtering leak across boards).
///   3. אישור מחלה — photo uploads via the camera seam + the upload list,
///      with an honest quota-failure toast (the notifier rolls back).
class CourierFormsScreen extends ConsumerStatefulWidget {
  const CourierFormsScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierFormsScreen());

  @override
  ConsumerState<CourierFormsScreen> createState() => _CourierFormsScreenState();
}

class _CourierFormsScreenState extends ConsumerState<CourierFormsScreen> {
  // ── טופס 101 fields ────────────────────────────────────────────────────────
  final _nameCtl = TextEditingController();
  final _idCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _specialtyCtl = TextEditingController();
  String _marital = '';

  /// True once the user typed/picked anything in the 101 form — guards the
  /// async-prefs prefill from clobbering fresh input (the ticket-#24 idiom).
  /// EVERY input of the form must flip this: text fields via [_field]'s
  /// onChanged, the dropdown via its own onChanged — omitting one silently
  /// reintroduces bug #24.
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
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — COURIER-board screen (F-16).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }
    final username = session.username;

    final formsState = ref.watch(courierFormsProvider);
    final saved = formsState.form101For(username, _year);
    final sickNotes = formsState.sickNotesFor(username);
    // "Mine" = username AND role (F-26): the demo username is shared across
    // boards, so a demo-worker's request must not appear as a demo-courier's.
    final myVacations =
        ref
            .watch(vacationRequestsProvider)
            .where((r) => r.username == username && r.role == 'courier')
            .toList()
          ..sort((a, b) => b.createdTs.compareTo(a.createdTs));

    // Prefill ONCE (ticket-#24 idiom): from the saved year-form when prefs
    // resolve; otherwise the live session name (the only profile field that
    // exists here — phone has no seed source, so it stays an honest empty
    // input).
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
        title: const CfgText(
          'courier.forms.title',
          '📄 טפסים',
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
        const CfgText(
          'courier.forms.form101_note',
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
            // The dropdown also flips the #24 touched flag — every input does.
            onChanged:
                (v) => setState(() {
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
                  ? '✓ נשמר ונשלח לחנות ב-${_fmtDate(saved.sentTs!)}'
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
              child: HelpTarget(
                title: 'שמירת טופס 101',
                body:
                    'שומר את טופס 101 במכשיר לשנת המס הנוכחית, בלי לשלוח. '
                    'ניתן להמשיך לערוך ולשלוח מאוחר יותר.',
                child: _PillButton(
                  id: 'courier.forms.save_101',
                  label: '💾 שמור טופס',
                  filled: false,
                  onPressed: () => _save101(session, send: false),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: HelpTarget(
                title: 'שליחת טופס 101 לחנות',
                body:
                    'שומר ושולח הודעת-הגשה לחנות דרך הצ׳אט. '
                    'ההגשה הרשמית החתומה תחובר עם חיבור השרת.',
                child: _PillButton(
                  id: 'courier.forms.send_101',
                  label: '📨 שלח לחנות',
                  onPressed: () => _save101(session, send: true),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Validate → persist (bs.courier-forms.v1, keyed by year) → optionally send
  /// an honest summary line into the store↔courier chat thread (#86.3 — the
  /// courier's recipient is the STORE, not a contractor).
  void _save101(BoardSession session, {required bool send}) {
    final idDigits = _idCtl.text.replaceAll(RegExp(r'[\s-]'), '');
    setState(() {
      _errName = _nameCtl.text.trim().isEmpty ? 'נא למלא שם מלא' : null;
      // FORMAT check only (9 digits) — like input_validators.dart; a real
      // checksum/identity verification is a server concern.
      _errId =
          RegExp(r'^\d{9}$').hasMatch(idDigits)
              ? null
              : 'ת.ז חייבת להיות 9 ספרות';
      _errPhone =
          validIsraeliMobile(_phoneCtl.text)
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

    ref
        .read(courierFormsProvider.notifier)
        .saveForm101(
          Form101(
            username: session.username,
            year: _year,
            fullName: _nameCtl.text.trim(),
            idNumber: idDigits,
            phone: _phoneCtl.text.trim(),
            specialty: _specialtyCtl.text.trim(),
            maritalStatus: _marital,
            savedTs: DateTime.now(),
          ),
        );
    if (send) {
      // Guard: send() is a silent no-op on an unknown thread — never mark
      // "sent" or toast a success that did not happen.
      final exists = ref
          .read(chatEngineProvider)
          .any((t) => t.id == kCourierAttendanceReportThreadId);
      if (!exists) {
        showToast(context, 'שיחת החנות לא נמצאה — הטופס נשמר אך לא נשלח');
        return;
      }
      ref
          .read(courierFormsProvider.notifier)
          .markForm101Sent(session.username, _year);
      // The submission notice lands in the store↔courier thread
      // ('th-store-courier-pickups', audience 'store' — the supplier's chat
      // tab; the courier sees it per the F-25 audience pairing). The form's
      // content stays on-device; only the notice is sent. The line carries
      // the sender's display name — fromRole=courier alone is not an
      // identity when more than one courier exists (F-39 rule).
      ref
          .read(chatEngineProvider.notifier)
          .send(
            kCourierAttendanceReportThreadId,
            BsRole.courier,
            '📄 ${session.displayName}: הגשתי טופס 101 לשנת $_year',
          );
      showToast(context, '📨 טופס 101 נשלח לחנות');
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
              child: HelpTarget(
                title: 'תאריכי חופשה',
                body:
                    'בוחרים את תאריך ההתחלה והסיום של בקשת החופשה '
                    'דרך לוח-שנה.',
                child: _DateField(
                  label: 'מתאריך',
                  value: _vacFrom,
                  onPick: () => _pickVacDate(isFrom: true),
                ),
              ),
            ),
            const SizedBox(width: BsTokens.space2),
            Expanded(
              child: HelpTarget(
                title: 'תאריכי חופשה',
                body:
                    'בוחרים את תאריך ההתחלה והסיום של בקשת החופשה '
                    'דרך לוח-שנה.',
                child: _DateField(
                  label: 'עד תאריך',
                  value: _vacTo,
                  onPick: () => _pickVacDate(isFrom: false),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),
        TextField(
          controller: _vacReasonCtl,
          // Bounded input (F-32/F-41): a runaway reason cannot blow up the
          // request card here or in the manager's queue.
          maxLength: 120,
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
        HelpTarget(
          title: 'שליחת בקשת חופשה',
          body:
              'שולח את בקשת החופשה לאישור המנהל בתור המשותף. '
              'הסטטוס (ממתינה/אושרה/נדחתה) יתעדכן כאן.',
          child: _PillButton(
            id: 'courier.forms.vacation_submit',
            label: '🏖️ שלח בקשה לאישור המנהל',
            onPressed: () => _submitVacation(session),
          ),
        ),
        if (mine.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space4),
          const CfgText(
            'courier.forms.my_requests',
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
    final initial =
        (isFrom ? _vacFrom : _vacTo) ?? (isFrom ? now : (_vacFrom ?? now));
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
    // SHARED queue, reused as-is (SPEC #86.3) — the manager sees this in the
    // same בקשות חופשה queue; role: 'courier' tells the boards apart (F-26).
    ref
        .read(vacationRequestsProvider.notifier)
        .submit(
          username: session.username,
          workerName: session.displayName,
          from: from,
          to: to,
          reason: _vacReasonCtl.text,
          role: 'courier',
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
        const CfgText(
          'courier.forms.sicknote_hint',
          'צלם את אישור המחלה — הצילום נשמר ברשימה כאן.',
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
        ),
        const SizedBox(height: BsTokens.space3),
        HelpTarget(
          title: 'צירוף אישור מחלה',
          body: 'פותח את המצלמה לצילום אישור-מחלה; הצילום נשמר ברשימה למטה.',
          child: _PillButton(
            id: 'courier.forms.sicknote_attach',
            label: '📷 צרף צילום אישור',
            onPressed: () => _addSickNote(username),
          ),
        ),
        if (notes.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: BsTokens.space3),
            child: CfgText(
              'courier_forms_screen.t01',
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

  /// One sick-note row: leading 48dp thumbnail of the ACTUAL stored photo —
  /// tapping it opens the full-screen pinch/zoom viewer. The photo ref is
  /// resolved ONCE per build (A14 dual-render: a base64 data-URL or an
  /// uploaded https URL) and rendered with a thumb-downscaled ResizeImage
  /// (F-43 — never the worker template's double decode); a non-renderable
  /// payload keeps an honest 📷 box with no viewer.
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
                child: HelpTarget(
                  title: 'צפייה באישור מחלה',
                  body: 'הקשה על התמונה פותחת את אישור-המחלה במסך מלא.',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap:
                        () => showFullPhotoRefDialog(
                          context,
                          n.photo,
                          label: 'אישור מחלה · ${_fmtDate(n.ts)}',
                        ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        // Decode at thumb resolution, not full-res (F-43).
                        image: ResizeImage(
                          provider,
                          width:
                              (48 * MediaQuery.devicePixelRatioOf(context))
                                  .round(),
                        ),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        // Corrupt image bytes → the honest 📷, never a crash.
                        errorBuilder:
                            (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              color: const Color(0xFFF2F3F5),
                              child: const Text(
                                '📷',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
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
            HelpTarget(
              title: 'מחיקת אישור',
              body: 'מוחק את אישור-המחלה לצמיתות (עם דיאלוג אישור).',
              child: IconButton(
                tooltip: 'מחק אישור',
                icon: const Icon(
                  Icons.delete_outline,
                  color: BsTokens.mutedLight,
                ),
                onPressed: () => _removeSickNote(n),
              ),
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
    // addSickNote persists with rollback (F-8): null = the storage write
    // failed (web quota) and the in-memory state was rolled back — the toast
    // must not pretend the photo was saved.
    final note = await ref
        .read(courierFormsProvider.notifier)
        .addSickNote(username: username, photo: photo);
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
    ref.read(courierFormsProvider.notifier).removeSickNote(n.id);
    showToast(context, 'האישור נמחק');
  }

  // ─── shared field helper ───────────────────────────────────────────────────

  /// Every 101 text field routes through here so onChanged flips the
  /// ticket-#24 touched flag — the prefs prefill can then never clobber
  /// fresh typing (see [_touched101]).
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
    required this.id,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final String id;
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
            child: CfgText(
              id,
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
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
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
                      color:
                          value == null
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
                      // Bounded display (F-32) — a long reason clips honestly
                      // instead of ballooning the card.
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';
