// Reusable 📞 / 💬 contact actions — used wherever a person's phone is shown
// (the worker/courier/store profile identity cards, the chat header).
//
// 📞 → opens the native dialer (`tel:<phone>` — the raw phone, the dialer
//      tolerates spaces/dashes).
// 💬 → opens WhatsApp (`https://wa.me/<international-digits>` via [waMeDigits]).
//
// NO in-app calling: both hand off to the OS through [urlLauncherProvider] (the
// injectable seam — real `launchUrl` in production, a capturing fake in tests).
//
// GUARD: when [phone] has no usable digits the whole widget collapses to
// `SizedBox.shrink()` — we never launch `tel:`/`wa.me/` with an empty number.

import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A compact pair of icon buttons (📞 dialer · 💬 WhatsApp) for [phone].
/// Renders nothing when [phone] is empty/has no digits.
class ContactActions extends ConsumerWidget {
  const ContactActions({
    required this.phone,
    super.key,
    this.iconColor = BsTokens.brand,
    this.compact = false,
  });

  /// The person's phone as displayed (free text — spaces/dashes are fine).
  final String phone;

  /// Icon tint (defaults to the brand orange).
  final Color iconColor;

  /// Tighter visual constraints for dense rows (e.g. the chat app bar).
  final bool compact;

  /// `tel:` accepts the raw phone (the dialer copes with separators); we only
  /// strip surrounding whitespace so an empty/blank string is caught by [_has].
  String get _telTarget => phone.trim();

  /// True when there is at least one digit to dial — drives the empty guard.
  bool get _has => RegExp(r'\d').hasMatch(phone);

  Future<void> _launch(BuildContext context, WidgetRef ref, Uri uri) async {
    final launcher = ref.read(urlLauncherProvider);
    final ok = await launcher(uri);
    if (!ok && context.mounted) {
      showToast(context, 'לא ניתן לפתוח את היישום');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Empty-phone guard: no buttons at all (never a tel:/wa.me with no number).
    if (!_has) return const SizedBox.shrink();

    final size = compact ? 20.0 : 22.0;
    final whatsapp = waMeDigits(phone);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'התקשר',
          visualDensity: compact ? VisualDensity.compact : null,
          icon: Icon(Icons.call, color: iconColor, size: size),
          onPressed: () =>
              _launch(context, ref, Uri.parse('tel:$_telTarget')),
        ),
        // WhatsApp only when normalization yields digits (a phone of only
        // separators would be caught by [_has], but guard the target too).
        if (whatsapp.isNotEmpty)
          IconButton(
            tooltip: 'וואטסאפ',
            visualDensity: compact ? VisualDensity.compact : null,
            icon: Icon(Icons.chat, color: iconColor, size: size),
            onPressed: () => _launch(
              context,
              ref,
              Uri.parse('https://wa.me/$whatsapp'),
            ),
          ),
      ],
    );
  }
}
