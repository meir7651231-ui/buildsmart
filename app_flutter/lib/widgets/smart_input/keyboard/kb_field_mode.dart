// The single shared gate predicate for the custom on-screen keyboard.
//
// One source of truth so that BOTH the text field's `readOnly` (set by a later
// wiring step) AND this keyboard host's visibility branch on the exact same
// condition. Keeping the rule in one place avoids the classic split-brain bug
// where the field suppresses the OS keyboard but the in-app keyboard never
// appears (or vice-versa).

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when our in-app keyboard should replace the system keyboard:
/// the [kSmartInputFlag] flag is ON AND no screen reader is active.
/// When false, fields stay `readOnly:false` and the OS keyboard is used
/// (the a11y fallback, or simply the feature being OFF).
bool useCustomKeyboard(WidgetRef ref, BuildContext context) =>
    ref.watch(featureFlagsProvider).contains(kSmartInputFlag) &&
    !MediaQuery.of(context).accessibleNavigation;
