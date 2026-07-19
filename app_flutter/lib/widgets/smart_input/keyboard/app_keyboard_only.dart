// APP-KEYBOARD-ONLY, app-wide — ONE keyboard for EVERY field, and no device
// keyboard anywhere. This is the second half of the owner's demand; wave-1
// ([kSmartInputFlag] + [BsKeyboardField]) was the first.
//
// WHY WAVE-BY-WAVE WIRING CANNOT FINISH THE JOB: making a field use our keyboard
// by hand is two coupled edits (`readOnly:true` + mount a host on the same
// controller) repeated for ~109 fields across ~52 files. Wave 1 converted 10. On
// the other 99 the device keyboard still pops up, so "only the app's keyboard"
// was never true — it was only ever true on the screens someone got around to.
// Worse, it silently regresses: every new field added anywhere starts out wrong.
//
// WHAT THIS DOES INSTEAD: registers a [TextInputControl] with the framework.
// That is Flutter's own supported seam for replacing the platform keyboard, and
// it inverts the problem — instead of us hunting for fields, the framework hands
// us EVERY field the moment it starts being edited:
//
//   attach(client, config) → this field is now being edited (and what it is)
//   show() / hide()        → raise / drop the keyboard for it
//   setEditingState(value) → its text or caret moved
//   detach(client)         → editing finished
//
// Coverage is therefore complete BY CONSTRUCTION and cannot drift as screens are
// added. There is nothing per-field left to remember.
//
// ⚠️ WHY THIS IS NOT THE SILENT-LOCKOUT TRAP THE EARLIER ATTEMPT WOULD HAVE BEEN:
// the first attempt at this (device_keyboard_blocker.dart, now deleted) tried to
// swallow the `TextInput.show` platform message. That is dangerous — it takes the
// device keyboard away from a field with nothing to replace it, and on the ~99
// unconverted fields, INCLUDING THE REGISTRATION FORM, that is a field nobody can
// type into and no error to explain why. (It also used `setMockMethodCallHandler`,
// a flutter_test-only API, so it did not compile outside tests at all.)
// [TextInput.setInputControl] has no such hole: the framework only routes a field
// to us in the same breath as it tells us to show a keyboard, so "blocked" and
// "replaced" are one event, not two that can drift apart.
//
// HOW THE DEVICE KEYBOARD ACTUALLY GOES AWAY: while a custom control is
// installed, the framework rewrites the platform config's `inputType` to
// [TextInputType.none] (see `_PlatformTextInputControl._configurationToJson` in
// the SDK). The platform connection stays open — selection, composing, autofill
// hints and a PHYSICAL keyboard all keep working — but the on-screen keyboard is
// never raised. That last part matters on desktop web, where taking the platform
// connection away entirely would have made every field untypable.
//
// A11Y: gated on [useCustomKeyboard], which requires `!accessibleNavigation`. A
// screen-reader user keeps the real platform keyboard — the control is not even
// installed for them.
//
// OFF ⇒ BYTE-IDENTICAL: without `--dart-define=APP_KB_ONLY=true`, [kAppKbOnly] is
// a const false, this layer is never added to the tree (a collection-`if` in
// main.dart that dart2js folds away), the control is never installed, and the app
// behaves exactly as it does today.

import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_host.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/kb_field_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Height of the app keyboard right now, in logical pixels; 0 while hidden.
///
/// Published so the app can inset for OUR keyboard exactly as it insets for the
/// device one. Without this a docked keyboard simply covers the field being
/// typed into — which on a login or registration form means typing blind. See
/// [AppKeyboardInsets], which folds this into `MediaQuery.viewInsets.bottom` so
/// every `Scaffold(resizeToAvoidBottomInset:)` and every sheet that already pads
/// for the device keyboard gets the same behaviour for free.
final appKeyboardInsetProvider = StateProvider<double>((_) => 0);

/// Whether the app keyboard belongs on screen for the field just described.
///
/// Pulled out as a pure function because its load-bearing case is unreachable
/// from a widget test: a read-only field only opens a platform connection on
/// WEB (`EditableTextState._shouldCreateInputConnection` is `kIsWeb ||
/// !readOnly`), so on the VM no test can produce the state this guards against —
/// a wave-1 `BsKeyboardField`, which is read-only AND docks its own keyboard,
/// being handed a SECOND one on top.
@visibleForTesting
bool appKeyboardVisible({
  required bool gateOpen,
  required bool asked,
  required bool hasField,
  required bool readOnly,
}) =>
    gateOpen && asked && hasField && !readOnly;

/// The app-wide keyboard: a [TextInputControl] that answers for every field.
///
/// Mounted ONCE, above the Navigator (so it clears dialogs and bottom sheets).
/// Renders nothing until the framework asks for a keyboard.
class AppKeyboardOnlyLayer extends ConsumerStatefulWidget {
  const AppKeyboardOnlyLayer({super.key, this.force = false});

  /// Bypass the compile-time [kAppKbOnly] check (the runtime
  /// [useCustomKeyboard] gate still applies).
  ///
  /// Exists because `flutter test` does NOT forward `--dart-define` to library
  /// consts, so with this false the ON path — the whole feature — would be
  /// untestable and could only ever be checked by hand on the live site. Same
  /// escape hatch, and same reason, as `BsKeyboardHost.forceShow`. Default false,
  /// and nothing in the app passes it.
  final bool force;

  @override
  ConsumerState<AppKeyboardOnlyLayer> createState() =>
      _AppKeyboardOnlyLayerState();
}

class _AppKeyboardOnlyLayerState extends ConsumerState<AppKeyboardOnlyLayer>
    with TextInputControl {
  /// The field being edited, handed to us by the framework in [attach]. Null
  /// between fields — and the reason we render nothing then.
  TextInputClient? _client;

  /// That field's configuration: what kind of input it wants, whether it is
  /// read-only, and which action its "done" key performs.
  TextInputConfiguration? _config;

  /// Whether the framework has asked for a keyboard ([show] vs [hide]).
  bool _visible = false;

  /// Whether our control is the installed one right now.
  bool _installed = false;

  /// The controller the docked [BsKeyboardHost] types into — a MIRROR of the
  /// real field's value, not the field's own controller (we never get that, and
  /// do not want it: writing a controller directly would skip the field's input
  /// formatters, its maxLength and its `onChanged`). Every edit made here is
  /// reported with [TextInput.updateEditingValue], the same door the device
  /// keyboard's input comes through, so the field cannot tell the difference.
  final TextEditingController _mirror = TextEditingController();

  /// A parked focus node for the host, which requires one but never focuses it —
  /// the real field keeps the focus the whole time. Explicitly unfocusable so it
  /// can never steal it.
  final FocusNode _sink =
      FocusNode(skipTraversal: true, canRequestFocus: false, debugLabel: 'appKb');

  /// Re-entrancy guard: true while WE are pushing the field's value into the
  /// mirror, so the mirror's own listener does not echo it straight back.
  bool _echo = false;

  /// The field's own last-known value. Kept so a keystroke we decide NOT to
  /// deliver can be rolled back off the mirror.
  TextEditingValue _fromField = TextEditingValue.empty;

  /// True when the focused field accepts newlines; drives whether the Enter key
  /// types one or performs the field's action (what a device keyboard does).
  bool get _multiline => _config?.inputType == TextInputType.multiline;

  @override
  void initState() {
    super.initState();
    _mirror.addListener(_onMirrorChanged);
  }

  @override
  void dispose() {
    // Clear the visible flag BEFORE handing the platform control back: restoring
    // notifies the focused field, which calls our own `hide()` straight back —
    // and a `setState` from inside `dispose` is an error. With the flag already
    // down, that callback is a no-op.
    _visible = false;
    if (_installed) {
      _installed = false;
      TextInput.restorePlatformInputControl();
    }
    _mirror
      ..removeListener(_onMirrorChanged)
      ..dispose();
    _sink.dispose();
    super.dispose();
  }

  // ── TextInputControl — the framework talking to us ────────────────────────

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    _client = client;
    _config = configuration;
  }

  @override
  void updateConfig(TextInputConfiguration configuration) =>
      _config = configuration;

  @override
  void detach(TextInputClient client) {
    if (!identical(_client, client)) return; // a stale field letting go
    _client = null;
    _config = null;
    _setVisible(false);
  }

  @override
  void show() => _setVisible(true);

  @override
  void hide() => _setVisible(false);

  @override
  void setEditingState(TextEditingValue value) {
    _fromField = value;
    if (_mirror.value == value) return;
    _echo = true;
    _mirror.value = value;
    _echo = false;
  }

  // ── our keyboard talking back to the framework ────────────────────────────

  /// The mirror changed because a key was tapped. Report it as user input.
  void _onMirrorChanged() {
    if (_echo || _client == null) return;
    final next = _mirror.value;

    // Enter on a single-line field is that field's ACTION, not a newline
    // character — exactly how the device keyboard treats it. The host has one
    // generic Enter key, so the distinction is made here, where the field's
    // real configuration is known.
    if (!_multiline && next.text.contains('\n')) {
      // Roll the newline back off the mirror FIRST. The action may leave the
      // field focused — `next` moves to the following field, a custom
      // `onEditingComplete` may do nothing at all — and a mirror still holding a
      // newline the field never accepted would prepend it to the next key
      // pressed.
      _echo = true;
      _mirror.value = _fromField;
      _echo = false;
      _performAction();
      return;
    }
    TextInput.updateEditingValue(next);
  }

  /// Run the focused field's own submit action (done / next / search / send …).
  /// Using the field's configured action means a form's "next" really does move
  /// to the next field, instead of every field behaving like "done".
  void _performAction() {
    final client = _client;
    if (client == null) return;
    client.performAction(_config?.inputAction ?? TextInputAction.done);
  }

  /// The keyboard's ✕ — drop focus, which closes the connection and takes the
  /// keyboard down through [detach].
  void _dismiss() => FocusManager.instance.primaryFocus?.unfocus();

  // ── plumbing ──────────────────────────────────────────────────────────────

  /// [show]/[hide] arrive from wherever the framework happens to be — including
  /// mid-build, when a field opens its connection during a rebuild. Calling
  /// `setState` there is the release-only "setState during build" crash, so a
  /// mid-frame change is deferred to the end of the frame instead.
  void _setVisible(bool next) {
    if (_visible == next) return;
    void apply() {
      if (!mounted) {
        _visible = next;
        return;
      }
      setState(() => _visible = next);
    }

    final binding = SchedulerBinding.instance;
    final midFrame =
        binding.schedulerPhase == SchedulerPhase.persistentCallbacks ||
            binding.schedulerPhase == SchedulerPhase.midFrameMicrotasks;
    if (midFrame) {
      binding.addPostFrameCallback((_) => apply());
    } else {
      apply();
    }
  }

  void _setInstalled(bool next) {
    if (_installed == next) return;
    _installed = next;
    if (next) {
      TextInput.setInputControl(this);
    } else {
      TextInput.restorePlatformInputControl();
      _setVisible(false);
    }
  }

  /// Publish our height (post-frame — never during build, and never for a value
  /// that has not actually changed, so this cannot loop).
  void _publishInset(double height) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(appKeyboardInsetProvider.notifier);
      if ((notifier.state - height).abs() < 0.5) return;
      notifier.state = height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The gate: the build-time flag AND the shared runtime predicate (feature on,
    // no screen reader). Installing/restoring is a side effect, so it waits for
    // the frame to finish — `setInputControl` notifies the focused client, which
    // can call us straight back into `show()`.
    final want =
        (kAppKbOnly || widget.force) && useCustomKeyboard(ref, context);
    if (want != _installed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setInstalled(want);
      });
    }

    // A read-only field gets NO keyboard. That covers two cases at once: a
    // genuinely read-only display field, and a wave-1 [BsKeyboardField], which
    // sets `readOnly:true` and docks its own host — without this it would show
    // two keyboards at once. (On web, read-only fields still open a platform
    // connection so text stays selectable, which is why this must be checked
    // here and not assumed away.)
    final show = appKeyboardVisible(
      gateOpen: want,
      asked: _visible,
      hasField: _client != null,
      readOnly: _config?.readOnly ?? false,
    );
    if (!show) {
      _publishInset(0);
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      // Taps on the keyboard must not read as "tapped outside the field": a
      // TextField's default `onTapOutside` unfocuses, which would close the
      // connection — and the keyboard — on the first key pressed.
      child: TextFieldTapRegion(
        // …and no key may take focus away from the field being typed into.
        child: FocusScope(
          canRequestFocus: false,
          child: _ReportHeight(
            onHeight: _publishInset,
            child: Material(
              color: Colors.transparent,
              child: BsKeyboardHost(
                controller: _mirror,
                focusNode: _sink,
                onSend: _performAction,
                onClose: _dismiss,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Folds the app keyboard's height into `MediaQuery.viewInsets.bottom`.
///
/// This is what makes the keyboard behave like a keyboard rather than a panel
/// that happens to sit on top of the screen: `Scaffold`, `SingleChildScrollView`
/// and every bottom sheet in the app already read that inset to keep the focused
/// field visible. Wrapping the app content in this gives all of them the right
/// answer with no per-screen change.
///
/// Takes the MAX of the real inset and ours, so on a build where both somehow
/// appear the content still clears the taller one.
class AppKeyboardInsets extends ConsumerWidget {
  const AppKeyboardInsets({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ours = ref.watch(appKeyboardInsetProvider);
    if (ours <= 0) return child;
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        viewInsets: mq.viewInsets.copyWith(
          bottom: mq.viewInsets.bottom > ours ? mq.viewInsets.bottom : ours,
        ),
      ),
      child: child,
    );
  }
}

/// Reports its child's laid-out height, once per real change.
class _ReportHeight extends StatefulWidget {
  const _ReportHeight({required this.child, required this.onHeight});

  final Widget child;
  final ValueChanged<double> onHeight;

  @override
  State<_ReportHeight> createState() => _ReportHeightState();
}

class _ReportHeightState extends State<_ReportHeight> {
  double _last = -1;

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final height = context.size?.height ?? 0;
      if ((height - _last).abs() < 0.5) return;
      _last = height;
      widget.onHeight(height);
    });
    return widget.child;
  }
}
