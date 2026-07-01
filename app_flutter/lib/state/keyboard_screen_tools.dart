// 🃏 keyboard_screen_tools — the STACK-AWARE registry that makes the floating
// keyboard a LIVE MIRROR of the CURRENT screen (the route at the top of the
// Navigator stack), not the last HomeShell tab.
//
// THE MODEL. The floating keyboard is an app-global overlay ABOVE the Navigator
// (kKbGlobal, main.dart). Its ▦ grid / ⚙️ gear toggles need "the tools of the
// screen I am looking at" — but `mainTabProvider` only knows the HomeShell tab,
// so on a PUSHED route (StockScreen, AIHubScreen, …) it is stale. This file
// lets EACH screen DECLARE its own tools by wrapping its body in [KbScreen];
// the wrapper pushes that tool-list onto [keyboardScreenToolsProvider] on mount
// and pops its OWN entry on unmount. The provider then mirrors the route stack
// of ADOPTING screens: the TOP entry is the front-most adopting screen's tools,
// and popping such a route reveals the parent's tools again.
//
// ADOPTION-SCOPED (not yet every route). The mirror is only as live as the set of
// screens that actually wrap their body in [KbScreen]. A pushed route that has NOT
// adopted [KbScreen] registers nothing, so while it is front-most the provider's
// top is unchanged (the keyboard keeps mirroring the last adopting surface — today
// the HomeShell tab fallback). The mirror is therefore FAITHFUL for the routes that
// adopt it and INERT for those that do not; it is not a magic global hook. See the
// adopters list in keyboard_tool_tree.dart (the routes the tool tree pushes).
//
// LIFO-CORRECTNESS WITHOUT ORDER ASSUMPTIONS. Flutter does not guarantee that a
// popped route's `dispose` runs before the next route's `initState` across every
// transition (overlapping animations, pushReplacement, maintainState). So each
// pushed entry carries a unique [token]; [KbScreen.dispose] removes ITS OWN
// entry by token (never a blind `removeLast`), which stays correct under any
// interleaving. "Top of stack" is the last surviving entry, which is exactly
// what the front-most route observes.
//
// FLAG-GATED (kKbGlobal). The whole surface only matters when the keyboard is an
// app-global overlay. With the flag OFF, [KbScreen] is a pure pass-through that
// NEVER touches the provider (no push, no pop, no watch), so a screen that wraps
// its body in [KbScreen] is byte-identical to its bare child — the provider's
// notifier methods become dead (uninstantiated) and the registration code paths
// tree-shake. The keyboard's `_onGrid` reads this provider ONLY under the same
// flag (see floating_card_keyboard.dart), so flag-OFF dispatch is unchanged.

import 'dart:async';

import 'package:buildsmart/screens/keyboard_tool_tree.dart' show KbToolNode;
import 'package:buildsmart/state/keyboard_overlay.dart' show kKbGlobal;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One registered screen's tools, tagged with an identity [token] so the owning
/// [KbScreen] can pop EXACTLY its own entry on dispose (LIFO-safe under
/// overlapping route transitions — never a blind `removeLast`). Value-equality
/// is by [token] alone (the identity is the entry); the [tools] list rides
/// along. Immutable.
@immutable
class KbScreenToolsEntry {
  const KbScreenToolsEntry(this.token, this.tools);

  /// Process-unique identity of the registering [KbScreen] State (an `Object`
  /// sentinel allocated per State — see [_KbScreenState._token]).
  final Object token;

  /// The screen's tool node-list, projected to the keyboard grid when this entry
  /// is on top. The SAME [KbToolNode] shape every other tool view uses, so the
  /// keyboard renders + dispatches it through the unchanged `kbTilesFor`/`_onTile`.
  final List<KbToolNode> tools;

  @override
  bool operator ==(Object other) =>
      other is KbScreenToolsEntry && other.token == token;

  @override
  int get hashCode => token.hashCode;
}

/// The live STACK of per-screen tool registrations (a value-based `List`, newest
/// LAST). Empty by default → the keyboard falls back to its tab tools. The top
/// (`last`) entry is the front-most screen's tools. Mutated only by [KbScreen]
/// via [push]/[removeToken]; everything else reads it.
///
/// NOTE: emits a NEW list on every mutation (value semantics), so a `ref.watch`
/// in the keyboard rebuilds when the top changes. Identity is preserved across
/// no-op reads (no churn) because [removeToken] is idempotent.
class KeyboardScreenToolsNotifier
    extends StateNotifier<List<KbScreenToolsEntry>> {
  KeyboardScreenToolsNotifier() : super(const <KbScreenToolsEntry>[]);

  /// Push a screen's entry on mount. New list (value semantics) so watchers see
  /// the new top. Idempotent on the entry's token: re-registering the same token
  /// (a hot reload / didUpdateWidget refresh) REPLACES that entry IN PLACE rather
  /// than duplicating it, so a screen never appears twice on the stack.
  ///
  /// TRUE replace-in-place: when the token already exists we swap the entry WHERE
  /// IT SITS (never remove-and-append), so a buried parent whose tools-list
  /// identity changes (didUpdateWidget re-push) can NOT reorder the stack and make
  /// itself look front-most. Only a GENUINELY new token is appended at the end, so
  /// `last == front-most` stays correct under any parent rebuild.
  void push(KbScreenToolsEntry entry) {
    if (state.any((e) => e.token == entry.token)) {
      // Existing token → swap in place, preserving position.
      state = <KbScreenToolsEntry>[
        for (final e in state) e.token == entry.token ? entry : e,
      ];
      return;
    }
    // Genuinely new token → append (becomes the new top-of-stack).
    state = <KbScreenToolsEntry>[...state, entry];
  }

  /// Pop the entry owned by [token] on unmount — removes ONLY that entry, so it
  /// is correct regardless of dispose/initState interleaving across route
  /// transitions. Idempotent: a token already gone (double dispose) is a no-op
  /// with NO state churn (same-length ⇒ keep the identical list, so no spurious
  /// rebuild).
  void removeToken(Object token) {
    if (!state.any((e) => e.token == token)) return; // no churn
    state = <KbScreenToolsEntry>[
      for (final e in state)
        if (e.token != token) e,
    ];
  }
}

/// The stack of per-screen tool registrations. Read by the floating keyboard's
/// `_onGrid`/`_onGear` (top-of-stack wins) and written by [KbScreen]. With
/// [kKbGlobal] OFF nothing ever writes to it (KbScreen is a pass-through) and
/// nothing reads it (the keyboard's read is flag-gated), so it stays the empty
/// default and has zero effect.
final keyboardScreenToolsProvider =
    StateNotifierProvider<KeyboardScreenToolsNotifier,
        List<KbScreenToolsEntry>>(
  (_) => KeyboardScreenToolsNotifier(),
);

/// Convenience read: the CURRENT (top-of-stack) screen's tools, or null when no
/// screen has registered any. The keyboard uses this as the FIRST source for its
/// grid; null ⇒ it falls back to the tab tools (`kbTabToolNodes`). A plain
/// derived getter (not a separate provider) so callers read it off the one
/// stack provider they already watch.
List<KbToolNode>? currentScreenTools(List<KbScreenToolsEntry> stack) =>
    stack.isEmpty ? null : stack.last.tools;

/// Wrap a screen's body so the floating keyboard's ▦ grid mirrors THIS screen's
/// own tools while it is the front-most route. On mount it pushes [tools] onto
/// [keyboardScreenToolsProvider]; on unmount it pops its own entry. Nested
/// screens stack correctly (LIFO by token), so popping one reveals the parent's
/// tools.
///
/// FLAG-GATED: with [kKbGlobal] OFF this is a PURE pass-through — it returns
/// [child] untouched and NEVER touches the provider. The REGISTRATION code-paths
/// (the post-frame push, the didUpdateWidget re-push, the dispose removeToken, the
/// provider read) all tree-shake to nothing under the const-false flag — no
/// push/pop/watch ever runs. The pass-through wrapper itself still occupies ONE
/// Element in the tree (it is `build => widget.child`), so adopt it knowing
/// flag-OFF is behaviorally INERT — not literally widget-tree-identical to the
/// bare child. Use it freely on every screen; it costs nothing observable until
/// the global keyboard ships.
///
/// USAGE (any screen / pushed route):
/// ```dart
/// @override
/// Widget build(BuildContext context) => KbScreen(
///   tools: _myScreenTools, // List<KbToolNode>, the screen's own grid
///   child: Scaffold(...),
/// );
/// ```
/// [tools] should be a STABLE list per screen (build it once, e.g. a top-level
/// factory like `kbHomeNodes()`), so an unrelated parent rebuild does not churn
/// the registration. [KbScreen] only re-pushes when the list identity changes
/// (its `didUpdateWidget` compares with `identical`).
class KbScreen extends ConsumerStatefulWidget {
  const KbScreen({required this.tools, required this.child, super.key});

  /// The screen's tool node-list, shown by the floating ▦ grid while this screen
  /// is front-most. Same [KbToolNode] shape as every other tool view.
  final List<KbToolNode> tools;

  /// The screen body. Returned verbatim (this wrapper adds no visual layout).
  final Widget child;

  @override
  ConsumerState<KbScreen> createState() => _KbScreenState();
}

class _KbScreenState extends ConsumerState<KbScreen> {
  /// This State's process-unique identity on the tool stack. A fresh `Object()`
  /// per State instance, so two mounts of the SAME screen class (two pushed
  /// copies) get DISTINCT tokens and both stack correctly. Allocated once and
  /// never mutated, so dispose can always remove exactly this entry.
  final Object _token = Object();

  /// The tool-stack notifier, captured in [initState] while `ref` is valid, so
  /// [dispose] can pop this screen's entry WITHOUT touching `ref`. A
  /// ConsumerState's `ref` THROWS once the element unmounts (Riverpod's
  /// `_assertNotDisposed`) — which is exactly when [dispose] runs — so reading
  /// the provider there silently threw BEFORE removeToken ran and left the token
  /// on the stack (the stale-tools bug). The notifier lives in the root
  /// container, which outlives the route, so the captured reference stays valid.
  /// Null until the post-frame push; only ever set under [kKbGlobal].
  KeyboardScreenToolsNotifier? _notifier;

  @override
  void initState() {
    super.initState();
    // FLAG-OFF FAST PATH: never register when the keyboard is not app-global.
    // The provider stays empty and the keyboard never reads it. (Tree-shaken to
    // nothing under the const-false flag.)
    if (!kKbGlobal) return;
    // Push AFTER this frame: writing a provider during initState (which runs
    // inside the parent build) would mutate provider state mid-build. A
    // post-frame callback registers once the tree is mounted; guard `mounted`
    // because a screen can be popped within the same frame it was pushed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Capture the notifier NOW (ref is valid) so dispose can pop WITHOUT ref.
      // NB: assign to the field then call on the LOCAL — `_notifier = x..push()`
      // would parse as `(_notifier = x)..push()` (cascade is lowest-precedence),
      // invoking push on the nullable FIELD's static type.
      final notifier = ref.read(keyboardScreenToolsProvider.notifier);
      _notifier = notifier;
      notifier.push(KbScreenToolsEntry(_token, widget.tools));
    });
  }

  @override
  void didUpdateWidget(covariant KbScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!kKbGlobal) return;
    // Re-push (replace-in-place by token) only when the tool list IDENTITY
    // changes — a stable list (the recommended usage) never re-registers, so an
    // unrelated parent rebuild is free. identical() not `==` because tool
    // closures are never structurally equal and we only care about a genuine
    // new list.
    if (!identical(oldWidget.tools, widget.tools)) {
      // Read + call on the LOCAL (ref is valid during didUpdateWidget), exactly
      // like initState — never `_notifier = read..push()` (cascade binds to the
      // assignment ⇒ the field's nullable static type) nor `(_notifier ??=
      // …).push` (a non-promotable field keeps its nullable type).
      final notifier = ref.read(keyboardScreenToolsProvider.notifier);
      _notifier = notifier;
      notifier.push(KbScreenToolsEntry(_token, widget.tools));
    }
  }

  @override
  void dispose() {
    // Pop OUR entry via the CAPTURED notifier — NEVER `ref`, which is already
    // dead here (a ConsumerState's ref throws post-unmount, so the old
    // `ref.read` threw before removeToken ever ran → stale tools).
    //
    // DEFER via microtask: Riverpod forbids modifying a provider SYNCHRONOUSLY
    // inside a widget lifecycle callback (dispose runs within the unmount/build
    // phase → the `_debugCanModifyProviders` assert, whose StateNotifier-listener
    // error propagates as a thrown exception). A microtask runs right after the
    // current build phase, when provider mutation is allowed again. The root
    // container outlives the route, so the captured notifier stays valid; the
    // `mounted` guard avoids mutating an already-disposed notifier, and
    // removeToken is by-token + idempotent, so deferral can never drop the wrong
    // entry or double-remove. LIFO-correct under any transition interleaving.
    if (kKbGlobal) {
      final notifier = _notifier;
      if (notifier != null) {
        final token = _token;
        Future.microtask(() {
          if (notifier.mounted) notifier.removeToken(token);
        });
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
