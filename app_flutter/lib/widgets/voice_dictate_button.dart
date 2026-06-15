import 'package:buildsmart/services/voice.dart';
import 'package:flutter/material.dart';

/// Signature of [VoiceService.listen] — injectable so widget tests drive
/// dictation without a real microphone.
typedef VoiceListenFn = Future<bool> Function({
  required void Function(String text) onFinal,
  void Function(String reason)? onError,
  String localeId,
});

/// 🎤 #36 — a small per-field dictation toggle for the WORKER board: tap to
/// dictate (existing on-device STT, [VoiceService]); the recognized text is
/// APPENDED into [controller] so the worker can speak a task instead of typing.
/// Tapping again while listening stops the session. The field still types
/// normally — this only ADDS a voice path (decision #36: worker board only,
/// NOT app-wide). [listenFn]/[stopFn] are test seams (default: VoiceService).
class VoiceDictateButton extends StatefulWidget {
  const VoiceDictateButton({
    required this.controller,
    this.listenFn,
    this.stopFn,
    super.key,
  });

  final TextEditingController controller;
  final VoiceListenFn? listenFn;
  final Future<void> Function()? stopFn;

  @override
  State<VoiceDictateButton> createState() => _VoiceDictateButtonState();
}

class _VoiceDictateButtonState extends State<VoiceDictateButton> {
  bool _listening = false;

  Future<void> _toggle() async {
    if (_listening) {
      await (widget.stopFn ?? VoiceService.instance.stop)();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final listen = widget.listenFn ?? VoiceService.instance.listen;
    final started = await listen(
      onFinal: (text) {
        _append(text);
        if (mounted) setState(() => _listening = false);
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (started && mounted) setState(() => _listening = true);
  }

  /// Append dictated [text] to the field (space-joined when the field already
  /// has content), cursor at end — dictation AUGMENTS typing, never erases.
  void _append(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final cur = widget.controller.text;
    final joined = cur.isEmpty ? t : '$cur $t';
    widget.controller.value = TextEditingValue(
      text: joined,
      selection: TextSelection.collapsed(offset: joined.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_listening ? Icons.mic : Icons.mic_none),
      color: _listening ? Colors.redAccent : null,
      tooltip: _listening ? 'הקש לעצירה' : 'הכתבה קולית',
      onPressed: _toggle,
    );
  }
}
