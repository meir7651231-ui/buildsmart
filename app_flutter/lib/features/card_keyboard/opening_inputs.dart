// opening_inputs.dart — which INPUT METHODS the single opening surface offers
// (P3 step 51). The opening is ONE surface (kOpeningSurfaceIsSingleMouth), not a
// mode chooser: word-grid + text are ALWAYS available, voice/AI only when their
// engine is live. PURE + data-only — capability is read at the CALL site and
// passed in, so the <=6 census (kCensusInputsAreCapabilityGated) enumerates only
// what the user can actually use, never a phantom input.

/// The input methods of the opening surface, in display order.
enum OpeningInput { wordGrid, text, voice, ai }

/// The opening inputs that are LIVE given the runtime capabilities: word-grid and
/// text are always present; voice/AI appear only when [voiceAvailable] /
/// [aiAvailable]. Pure — same inputs yield the same list.
List<OpeningInput> liveOpeningInputs({
  required bool aiAvailable,
  required bool voiceAvailable,
}) =>
    [
      OpeningInput.wordGrid,
      OpeningInput.text,
      if (voiceAvailable) OpeningInput.voice,
      if (aiAvailable) OpeningInput.ai,
    ];
