// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_forms_screen.dart (בנייה-חכמה main) · מחווט: 10 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/courier_forms_screen.g.dart';

class CourierFormsScreenBoard extends ConsumerWidget {
  const CourierFormsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierFormsScreenComposed(
      onApprove: r.onApprove,
      onPressed: () {} /* TODO-לוח */,
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
      filled: false,
      id: '' /* TODO-לוח: String */,
      label: r.label,
      label2: r.label2,
      label3: r.label3,
      label4: r.label4,
      reason: r.reason,
      status: r.status,
      title: [
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
      ].title,
      t: CourierFormsScreenTokens(),
    );
  }
}
