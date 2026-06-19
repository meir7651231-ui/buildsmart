import 'package:flutter/foundation.dart';

/// What a [KbKey] does when tapped. `letter` inserts its text; the rest drive
/// keyboard behaviour (delete, newline, space, layer switches, send) or insert
/// punctuation. Hebrew has no shift/caps, so there is deliberately no `shift`
/// member — see [hebrew_layout.dart].
enum KeyKind { letter, backspace, enter, space, symbols, language, send, period, punct }

/// Immutable description of a single key on the on-screen keyboard. [label] is
/// what the key shows; [kind] is what it does; [output] is the text inserted on
/// tap (falls back to [label] via [effectiveOutput]); [flex] is the width
/// weight in its row (space is wide); [superscript] is the small corner hint
/// (e.g. the digit on a top-row letter) or null.
@immutable
class KbKey {
  final String label;        // shown on the key
  final KeyKind kind;
  final String? output;      // text inserted on tap; null => label
  final int flex;            // width weight (space is wide)
  final String? superscript; // small corner hint, or null
  const KbKey(this.label, {this.kind = KeyKind.letter, this.output, this.flex = 1, this.superscript});
  String get effectiveOutput => output ?? label;
}
