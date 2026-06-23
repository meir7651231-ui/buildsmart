// #6 inc.3 — role-request approval inbox: the signed-in caller sees the PENDING
// requests for the tier they may review (the matrix: contractor↞worker,
// store↞courier, manager↞store+contractor), and approves/denies each via the
// reviewRoleRequest callable. The list is scoped server-side (pendingRoleRequests
// reads only the tier the S5 rule lets this caller read), so it self-empties as
// decisions land (an approved/denied doc leaves the pending query).

import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/data/repositories/claude_functions.dart'
    show claudeGatewayProvider;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/screens/reject_reason_screen.dart'
    show RejectReasonScreen;
import 'package:buildsmart/state/role_requests.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleRequestsInboxScreen extends ConsumerStatefulWidget {
  const RoleRequestsInboxScreen({super.key});

  static Route<void> route() => MaterialPageRoute<void>(
        builder: (_) => const RoleRequestsInboxScreen(),
      );

  @override
  ConsumerState<RoleRequestsInboxScreen> createState() =>
      _RoleRequestsInboxScreenState();
}

class _RoleRequestsInboxScreenState
    extends ConsumerState<RoleRequestsInboxScreen> {
  /// uids currently being reviewed (buttons disabled, spinner shown).
  final Set<String> _busy = {};

  Future<void> _review(String uid, {required bool approve}) async {
    final reviewer = ref.read(roleReviewerProvider);
    if (reviewer == null || _busy.contains(uid)) return;
    setState(() => _busy.add(uid));
    try {
      await reviewer(uid, approve: approve);
      if (mounted) showToast(context, approve ? '✓ התפקיד אושר' : 'הבקשה נדחתה');
    } on Object catch (_) {
      if (mounted) showToast(context, 'הפעולה נכשלה — נסה שוב');
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(pendingRoleRequestsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          title: const Text('בקשות תפקיד'),
          backgroundColor: BsTokens.cardLight,
          foregroundColor: BsTokens.inkLight,
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const _Empty(
            icon: Icons.cloud_off,
            text: 'לא ניתן לטעון בקשות כעת',
          ),
          data: (requests) {
            if (requests.isEmpty) {
              return const _Empty(
                icon: Icons.inbox_outlined,
                text: 'אין בקשות תפקיד ממתינות',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(BsTokens.space4),
              itemCount: requests.length,
              itemBuilder: (_, i) => _RequestCard(
                doc: requests[i],
                busy: _busy.contains(requests[i].id),
                onApprove: () => _review(requests[i].id, approve: true),
                onDeny: () => _review(requests[i].id, approve: false),
              ),
              separatorBuilder: (_, __) =>
                  const SizedBox(height: BsTokens.space3),
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.doc,
    required this.busy,
    required this.onApprove,
    required this.onDeny,
  });

  final RemoteDoc doc;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final role = (doc.data['requestedRole'] as String?) ?? '';
    final name = (doc.data['displayName'] as String?)?.trim();
    final phone = (doc.data['phone'] as String?)?.trim();
    final matches = kPersonas.where((p) => p.id == role);
    final persona = matches.isEmpty ? null : matches.first;
    final who = (name != null && name.isNotEmpty) ? name : 'משתמש';

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(persona?.emoji ?? '🪪', style: const TextStyle(fontSize: 26)),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      who,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: BsTokens.inkLight,
                      ),
                    ),
                    Text(
                      'מבקש/ת: ${persona?.title ?? role}',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty)
                      Text(
                        phone,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          if (busy)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(6),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: BsTokens.brand,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('אישור'),
                  ),
                ),
                const SizedBox(width: BsTokens.space3),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDeny,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BsTokens.mutedLight,
                    ),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('דחייה'),
                  ),
                ),
              ],
            ),
          // #ai-reject-reason — when AI is live, draft a polite denial reason
          // (closed-set categories) the manager can copy. gateway null (demo) →
          // not in the tree → byte-identical.
          Consumer(builder: (context, ref, _) {
            if (ref.watch(claudeGatewayProvider) == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: BsTokens.space2),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      RejectReasonScreen.route(role: role, name: name ?? '')),
                  icon: const Text('✨'),
                  label: const Text('נסח סיבת-דחייה'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: const Color(0xFFBBBBBB)),
          const SizedBox(height: BsTokens.space3),
          Text(
            text,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
