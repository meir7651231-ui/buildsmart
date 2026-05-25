import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around speech_to_text. On web the plugin uses the Web
/// Speech API where available; on mobile it uses native iOS/Android STT.
class VoiceService {
  VoiceService._();
  static final VoiceService instance = VoiceService._();

  final stt.SpeechToText _engine = stt.SpeechToText();
  bool _initialized = false;

  Future<bool> _ensureInitialized() async {
    if (_initialized) return true;
    return _initialized = await _engine.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
  }

  Future<bool> get available async => _ensureInitialized();

  /// Starts a listening session and invokes [onFinal] with the
  /// final transcript when the user stops speaking. Returns false
  /// if the platform doesn't support it.
  Future<bool> listen({
    required void Function(String text) onFinal,
    String localeId = 'he-IL',
  }) async {
    final ok = await _ensureInitialized();
    if (!ok) return false;
    await _engine.listen(
      onResult: (r) {
        if (r.finalResult) onFinal(r.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: false,
        cancelOnError: true,
        localeId: localeId,
      ),
    );
    return true;
  }

  Future<void> stop() => _engine.stop();

  /// Web Speech API has known stability issues in some browsers; surface
  /// a flag callers can use to render a degraded UI on web.
  static bool get isWebUnstable => kIsWeb;
}
