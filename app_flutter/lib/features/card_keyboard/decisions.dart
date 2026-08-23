// decisions.dart — the owner-gated decisions the whole unified-finder plan depends
// on, hoisted to compile-time constants so no later step silently re-decides them.
//
// Each const is the resolved answer to a product/architecture question the 9x9
// adversarial teardown surfaced (knowledge/monster-finder/MONSTER-V3-TEARDOWN-R3.md).
// The owner vetoes a choice by flipping ONE const here; every later step READS these
// and never hard-codes the decision elsewhere. Pure data, no logic.
//
// TOUCHES NO PRODUCTION BEHAVIOUR: nothing reads it yet. It is the topological root
// the P0.5 / P3 / P5 / P10 / P11 steps import (build-plan v3, P0 step 1).

/// How personal state (history, picks, favorites) is partitioned across identities.
///  • 'employer' — scoped per active employer/identity, so a shared fleet tablet
///    never bleeds employee A's data to B (the round-2 isolation blocker).
///  • 'global'   — today's single shared list (legacy behaviour).
/// Owner veto: flip to 'global' to keep one shared list.
const String kIdentityScope = 'employer';

/// Material is a GATED CO-EQUAL axis — it competes like size/colour/word and shows
/// only when it is decisive or explicitly seeded — NOT a forced "first axis".
/// Round-1 over-ranked material; round-2 confirmed materialOf classifies only a
/// minority of the pool, so a forced-first material axis is dishonest. Keep true.
const bool kMaterialIsGatedCoAxis = true;

/// The minimum distinct-card count kReachUniverse must meet — a LOWER BOUND, not an
/// equality pin, so ongoing catalog ingestion (#56) cannot red-gate the build on a
/// pure data refresh. P0 step 2 measures the real count and asserts it is >= this
/// (plus a content invariant). Conservative floor for the ~900-distinct-card pool.
const int kReachLowerBound = 800;

/// The maximum distinct-card count — the UPPER half of the reach band. A census
/// above this signals a catalog explosion/corruption (or a legit big ingestion
/// that must regen + bump the band, #56), so it RED-gates rather than passing
/// silently. Measured ~1339; loose enough for normal drift, tight enough to catch
/// an anomaly. Bumped by the ingestion regen handshake (step 36).
const int kReachUpperBound = 1600;

/// The <=6 / <=4 contract proves over 100% of kReachUniverse with NO tolerated
/// exceptions: this allowlist is EMPTY by construction, and any entry is a RED gate,
/// not a quiet pass. Real debt (if ever) lives in a SEPARATELY-named list the gate
/// ignores — never widen THIS set to make the gate green (round-1 blocker #4).
const Set<String> kReachAllowlist = <String>{};

/// Colour-axis exclusions are the COMPLEMENT of an explicit kTrueColors allowlist —
/// every finish (copper / brass / nickel / gold / graphite) is excluded BY
/// CONSTRUCTION and only real colours remain — rather than a hand-maintained
/// blocklist that silently leaks a new finish (round-2 / round-3 colour-leak).
const bool kColorExclusionsAreComplementOfAllowlist = true;

/// The opening is ONE surface with multiple INPUT METHODS (word grid + text +
/// mic), NOT a chooser of separate "mouths"/modes — the user starts typing or
/// tapping, never picks a tool first (the monster contract). OWNER-REVIEW: flip
/// to false to restore a multi-mode chooser.
const bool kOpeningSurfaceIsSingleMouth = true;

/// At most this many DECISION GROUPS on screen 1 (the opening): one — the first
/// screen never makes the user choose between tools/modes. OWNER-REVIEW.
const int kMaxScreen1Decisions = 1;

/// The <=6 census enumerates only the LIVE opening inputs (a dead AI/voice
/// engine is excluded), so the contract is proven over what the user can
/// ACTUALLY use, not a phantom input. OWNER-REVIEW: flip to count all inputs.
const bool kCensusInputsAreCapabilityGated = true;

/// The LOCKED contract ceiling — at most this many questions (decisions) from the
/// opening to ANY product (the "<=6" half of the <=6/<=4 contract). The census
/// (P4.58) proves every sampled mouth resolves within this budget. OWNER-REVIEW:
/// the monster's reason-to-exist; never raise it to make a slow path pass — fix
/// the path. Counts the opening choice as question 1.
const int kMaxQuestions = 6;

/// The other half of the contract — at most this many hops BETWEEN two products
/// (the "<=4"). Proven by the hop-graph rails (P6-P11). OWNER-REVIEW.
const int kMaxHopsBetweenProducts = 4;

/// The engine's HARD turn gate (P7.67): by turn (kMaxDiveTurns − 1 answered steps)
/// the dive STOPS asking and shows the scan-list, so it can NEVER exceed this. The
/// SAME ceiling as [kMaxQuestions] — one contract, two vantage points (the census
/// counts questions, the engine counts turns). OWNER-REVIEW.
const int kMaxDiveTurns = kMaxQuestions;
