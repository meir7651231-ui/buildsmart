// #6 — role-request sheet: a signed-in (backend) user picks ONE operational
// role to request; submitting writes roleRequests/{uid} (status: pending) and
// the matrix-designated approver reviews it (functions/reviewRoleRequest). The
// sheet states WHO approves each tier so the user knows what to expect.

import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/state/role_requests.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One-line purpose per requestable role (mirrors role_picker_sheet's
/// kPersonaDesc for the same ids).
const Map<String, String> _kRoleDesc = {
  'worker': 'המשימות שהוקצו לי בשטח',
  'courier': 'משלוחים ועדכוני סטטוס',
  'store': 'הזמנות נכנסות, מלאי החנות',
  'contractor': 'הזמנת חומרים, מלאי, משימות',
};

/// WHO signs off each requested role (the #6 approval matrix, user-facing).
const Map<String, String> kRoleApproverHe = {
  'worker': 'מאושר ע״י קבלן',
  'courier': 'מאושר ע״י חנות/ספק',
  'store': 'מאושר ע״י מנהל',
  'contractor': 'מאושר ע״י מנהל',
};

/// Open the role-request sheet (a bottom sheet, RTL, the pod-sheet idiom).
Future<void> showRoleRequestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RoleRequestSheet(),
  );
}

class _RoleRequestSheet extends ConsumerStatefulWidget {
  const _RoleRequestSheet();

  @override
  ConsumerState<_RoleRequestSheet> createState() => _RoleRequestSheetState();
}

class _RoleRequestSheetState extends ConsumerState<_RoleRequestSheet> {
  bool _busy = false;

  Future<void> _request(String role) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await submitRoleRequest(ref, role);
    if (!mounted) return;
    if (ok) {
      showToast(context, '✓ בקשתך נשלחה — ממתינה לאישור');
      await Navigator.of(context).maybePop();
    } else {
      setState(() => _busy = false);
      showToast(context, 'לא ניתן לשלוח בקשה כעת');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space3,
          BsTokens.space4,
          BsTokens.space5,
        ),
        decoration: const BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BsTokens.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
              ),
              const Text(
                '🪪 בקשת תפקיד',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  color: BsTokens.inkLight,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'בחר תפקיד — הבקשה תישלח לאישור הגורם המתאים',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              for (final role in kRequestableRoles)
                _RoleRequestRow(
                  role: role,
                  busy: _busy,
                  onTap: () => _request(role),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleRequestRow extends StatelessWidget {
  const _RoleRequestRow({
    required this.role,
    required this.busy,
    required this.onTap,
  });

  final String role;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final matches = kPersonas.where((p) => p.id == role);
    final persona = matches.isEmpty ? null : matches.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space3,
              vertical: BsTokens.space3,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    persona?.emoji ?? '🪪',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona?.title ?? role,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: BsTokens.inkLight,
                        ),
                      ),
                      Text(
                        _kRoleDesc[role] ?? '',
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                      Text(
                        kRoleApproverHe[role] ?? '',
                        style: const TextStyle(
                          color: BsTokens.brandDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left, color: Color(0xFFBBBBBB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
