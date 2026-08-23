import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around speech_to_text. On web the plugin uses the Web
/// Speech API where available; on mobile it uses native iOS/Android STT.
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final stt.SpeechToText _engine = stt.SpeechToText();
  bool _initialized = false;

  /// #6 voice honesty — [stt.SpeechToText.initialize] binds its callbacks
  /// ONCE for the engine's lifetime, so per-session routing goes through
  /// these mutable hooks: the active [listen] session registers its error
  /// sink here, and engine errors / no-result endings are forwarded to it
  /// instead of being swallowed.
  void Function(String reason)? _sessionOnError;
  bool _sessionActive = false;
  bool _sessionGotResult = false;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    // web-safety — the speech plugin can throw at the PLATFORM BOUNDARY: a
    // `MissingPluginException` on a web build where the STT plugin isn't
    // registered, or a `PlatformException` mid-handshake. The engine raises it
    // on a JS-interop microtask that BYPASSES our error zone, so an unguarded
    // throw here surfaces as an UNCAUGHT async error that can derail an
    // unrelated flow. Catch it and degrade to "no speech on this platform"
    // (`false`) — the honest, non-fatal signal callers already handle.
    try {
      return _initialized = await _engine.initialize(
        // Engine errors (mic permission, network, no-match…) end the active
        // session honestly — no more silent `(_) {}` swallow.
        onError: (e) => _failSession(e.errorMsg),
        onStatus: (status) {
          // The plugin reports BOTH 'done' and 'doneNoResult' as 'done' to this
          // listener (speech_to_text 7.x rewrites the status) — so a 'done'
          // that arrives without any final result is the no-result case.
          if (status == 'done' && !_sessionGotResult) {
            _failSession('no-result');
          }
        },
      );
    } on Object {
      return false;
    }
  }

  /// Routes a failure to the ACTIVE session's [listen]-onError exactly once;
  /// stray engine callbacks outside a session are ignored.
  void _failSession(String reason) {
    if (!_sessionActive) return;
    _sessionActive = false;
    final cb = _sessionOnError;
    _sessionOnError = null;
    cb?.call(reason);
  }

  Future<bool> get available async => _ensureInitialized();

  /// Starts a listening session and invokes [onFinal] with the final
  /// transcript when the user stops speaking. [onError] fires (at most once
  /// per session) when the engine errors out or the session ends with no
  /// recognized text — so callers never hang in a fake "recording" state.
  /// Returns false if the platform doesn't support speech at all (then
  /// [onError] is NOT called — the `false` return is the failure signal).
  Future<bool> listen({
    required void Function(String text) onFinal,
    void Function(String reason)? onError,
    String localeId = 'he-IL',
  }) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;
    _sessionActive = true;
    _sessionGotResult = false;
    _sessionOnError = onError;
    // Same platform-boundary guard as init: starting a session can throw on web
    // (MissingPluginException) AFTER a successful initialize. Clear the
    // half-open session and report `false` rather than leaking the throw.
    try {
      await _engine.listen(
        onResult: (r) {
          if (r.finalResult) {
            _sessionGotResult = true;
            _sessionActive = false;
            _sessionOnError = null;
            onFinal(r.recognizedWords);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: false,
          cancelOnError: true,
          localeId: localeId,
        ),
      );
    } on Object {
      _sessionActive = false;
      _sessionOnError = null;
      return false;
    }
    return true;
  }

  /// Stops the active session. A manual stop is NOT an error by itself: the
  /// engine may still deliver the final transcript right after; if it
  /// doesn't, the no-result path above routes through [listen]'s onError.
  Future<void> stop() async {
    // A manual stop with no live engine/session (or on a platform without the
    // plugin) must never throw — same web-safety discipline as the rest.
    try {
      await _engine.stop();
    } on Object {
      // nothing to stop — ignore
    }
  }

  /// Web Speech API has known stability issues in some browsers; surface
  /// a flag callers can use to render a degraded UI on web.
  static bool get isWebUnstable => kIsWeb;
}
