// ─────────────────────────────────────────────────────────────────────────────
// AccessLockGate — the owner's password gate over the whole app. Wraps
// MaterialApp.home (gated on [kAccessLock] in main.dart, so it tree-shakes when
// off). Reads the synced [OrgConfig.accessPasswordHash]:
//   • empty (owner set no password)      → child, unwrapped.
//   • this device already unlocked it    → child (remembered in prefs, keyed by
//                                           the hash so rotating re-locks).
//   • otherwise                           → a password prompt; a correct entry
//                                           unlocks + persists, a wrong one errors.
//
// SOFT gate (see config/access_lock.dart): a fresh client learns the hash from
// the live org-config doc, which arrives just after first frame — so on a brand-
// new device the home can flash for an instant before the lock paints. That is
// acceptable for "no open access without the owner's password"; it is not
// leak-proof secrecy.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/access_lock.dart';
import 'package:buildsmart/state/org_config_store.dart' show orgConfigProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessLockGate extends ConsumerStatefulWidget {
  const AccessLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AccessLockGate> createState() => _AccessLockGateState();
}

class _AccessLockGateState extends ConsumerState<AccessLockGate> {
  /// The hash this device already unlocked (null until prefs load). Matching the
  /// current config hash ⇒ straight through.
  String? _unlockedHash;
  bool _loaded = false;
  final TextEditingController _ctrl = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _loadUnlock();
  }

  Future<void> _loadUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _unlockedHash = prefs.getString(kAccessUnlockedKey);
    } on Object catch (_) {
      // No prefs platform → treat as not-yet-unlocked (the prompt shows).
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _submit(String storedHash) async {
    setState(() {
      _checking = true;
      _error = null;
    });
    if (accessPasswordMatches(storedHash, _ctrl.text)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(kAccessUnlockedKey, storedHash);
      } on Object catch (_) {
        // Best-effort: an unlock that cannot persist still opens this session.
      }
      if (mounted) {
        setState(() {
          _unlockedHash = storedHash;
          _checking = false;
        });
      }
    } else if (mounted) {
      setState(() {
        _error = 'סיסמה שגויה';
        _checking = false;
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hash =
        ref.watch(orgConfigProvider.select((c) => c.accessPasswordHash));
    // No lock set, or this device already unlocked THIS password → passthrough.
    if (hash.isEmpty || _unlockedHash == hash) return widget.child;
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 56),
                  const SizedBox(height: 16),
                  const Text(
                    'הזן סיסמת גישה',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ctrl,
                    obscureText: true,
                    autofocus: true,
                    textInputAction: TextInputAction.go,
                    onSubmitted: _checking ? null : (_) => _submit(hash),
                    decoration: InputDecoration(
                      hintText: 'סיסמה',
                      prefixIcon: const Icon(Icons.key_outlined),
                      border: const OutlineInputBorder(),
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _checking ? null : () => _submit(hash),
                      child: _checking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('כניסה'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
