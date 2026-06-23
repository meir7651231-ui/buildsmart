/// Riverpod state for the unified card-keyboard (#38).
library;

import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show NewbieStep;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The card-keyboard DRILL STACK — the answered [NewbieStep]s of the current
/// dive (the breadcrumb the engine reads via its emptiness, and the screen
/// renders). `autoDispose` so closing the keyboard frees it rather than leaking
/// a stale dive into the next open.
///
/// IDENTITY ISOLATION (build plan §3): the stack must also reset on an
/// employer/identity switch, so one identity's dive never bleeds into another's.
/// Phase 0 establishes the `autoDispose` base; the identity family /
/// invalidate-on-switch is wired with the screen in Phase 4 (it needs the app's
/// active-identity provider, which the screen already reads).
final cardKeyboardStackProvider =
    StateProvider.autoDispose<List<NewbieStep>>((ref) => const <NewbieStep>[]);
