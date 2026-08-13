// ─────────────────────────────────────────────────────────────────────────────
// AccessLockGate — the owner's password gate over the whole app, on EVERY build.
// Wraps MaterialApp.home (gated on [kAccessLock] in main.dart, so it tree-shakes
// when off).
//
// The gate resolves the owner's access-password hash from the first source that
// answers, in priority order:
//   1. a live PUBLIC fetch of `orgConfigLive/current` ([accessHashFetchProvider]) —
//      plain HTTPS, works on store / web / tester alike;
//   2. the last hash cached on this device (fail-closed once it has connected);
//   3. the org-config-live provider (a live-update bonus where it runs).
// Then:
//   • empty hash                       → child, unwrapped (no lock set).
//   • this device already unlocked it  → child (remembered in prefs, keyed by hash).
//   • still fetching, no other source  → a brief spinner (never flash content
//                                        before a possible lock).
//   • otherwise                        → a password prompt.
//
// FAIL MODE: if the fetch errors AND nothing is cached AND the provider is empty,
// the gate opens (a never-connected fresh device cannot know a lock exists). Any
// device that has connected once caches the hash and stays fail-closed.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/config/access_lock.dart';
import 'package:buildsmart/state/org_config_store.dart' show orgConfigProvider;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The live public read of the access-password hash. Overridable in tests to
/// drive the gate without a network call.
final accessHashFetchProvider =
    FutureProvider.autoDispose<String?>((ref) => fetchAccessPasswordHash());

class AccessLockGate extends ConsumerStatefulWidget {
  const AccessLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AccessLockGate> createState() => _AccessLockGateState();
}

class _AccessLockGateState extends ConsumerState<AccessLockGate> {
  String? _unlockedHash; // hash this device already unlocked (prefs)
  String? _cachedHash; // last hash seen from the server (prefs)
  bool _loaded = false;
  final TextEditingController _ctrl = TextEditingController();
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _unlockedHash = prefs.getString(kAccessUnlockedKey);
      _cachedHash = prefs.getString(kAccessCachedHashKey);
    } on Object catch (_) {
      // No prefs platform → nothing remembered; the fetch still drives the gate.
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _cache(String hash) async {
    _cachedHash = hash;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kAccessCachedHashKey, hash);
    } on Object catch (_) {/* best-effort */}
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
      } on Object catch (_) {/* opens this session even if it cannot persist */}
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
    final fetched = ref.watch(accessHashFetchProvider);
    // Cache the fetched hash the moment it lands (so a later offline launch knows).
    ref.listen<AsyncValue<String?>>(accessHashFetchProvider, (_, next) {
      final h = next.asData?.value;
      if (h != null && h != _cachedHash) _cache(h);
    });

    final fetchedHash = fetched.asData?.value; // null while loading / on error
    final providerHash =
        ref.watch(orgConfigProvider.select((c) => c.accessPasswordHash));
    final effective = fetchedHash ?? _cachedHash ?? providerHash;

    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (effective.isEmpty) {
      // No lock known. If we are still fetching and have NO other source, wait —
      // never flash the app before a possible lock paints.
      if (fetched.isLoading && _cachedHash == null && providerHash.isEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return widget.child; // genuinely no lock
    }
    if (_unlockedHash == effective) return widget.child;
    return _lockScreen(effective);
  }

  Widget _lockScreen(String storedHash) => Scaffold(
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
                      onSubmitted:
                          _checking ? null : (_) => _submit(storedHash),
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
                        onPressed:
                            _checking ? null : () => _submit(storedHash),
                        child: _checking
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
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
