// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_forms_screen.dart (בנייה-חכמה main) · מחווט: 10 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/logic/printable_docs.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/doc_print.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_link.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/signature_pad.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_forms_screen.g.dart';

class WorkerFormsScreenBoard extends ConsumerWidget {
  const WorkerFormsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerFormsScreenComposed(
      onApprove: r.onApprove,
      onPressed: () {} /* TODO-לוח */,
      children: [
        // HONEST framing: a structured digital form, not the official PDF.
        CfgText(
          'worker_forms_screen.form101_note',
          'טופס דיגיטלי מובנה — אינו הטופס הרשמי של רשות המסים. '
          'הגשה רשמית תחובר עם חיבור השרת.',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
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
      filled: false,
      label: r.label,
      label2: r.label2,
      label3: r.label3,
      label4: r.label4,
      reason: r.reason,
      status: r.status,
      title: [
        // HONEST framing: a structured digital form, not the official PDF.
        CfgText(
          'worker_forms_screen.form101_note',
          'טופס דיגיטלי מובנה — אינו הטופס הרשמי של רשות המסים. '
          'הגשה רשמית תחובר עם חיבור השרת.',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
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
      ].title,
      t: WorkerFormsScreenTokens(),
    );
  }
}
