/// Feature-flag name for the NEWBIE product-finder screen (בית/מאתר).
///
/// STEP 5 of the word-finder swarm — the runtime gate. The flag-gated
/// `WordFinderScreen` self-gates on this name via
/// `ref.watch(featureFlagsProvider).contains(kWordFinderFlag)`, mirroring the
/// `kSmartInputFlag` gate in `smart_suggestion_strip.dart`. Until an operator
/// `enable`s it (or a test seeds it), the screen renders nothing.
const String kWordFinderFlag = 'kWordFinder';
