/// Compile-time flag gating the atom assembly engine.
///
/// Default `false`: the engine, atoms and controller are unreachable and the
/// tree-shaker drops them, so the release `main.dart.js` is byte-for-byte
/// identical to the pre-engine build (see `atom-engine/ENGINE-SPEC.md` §2).
///
/// Turn on for the toggle-matrix / on-state proof:
/// `flutter build web --release --dart-define=ATOM_ENGINE=true`.
const bool kAtomEngine = bool.fromEnvironment('ATOM_ENGINE');
