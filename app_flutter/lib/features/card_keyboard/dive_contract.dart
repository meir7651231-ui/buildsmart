// dive_contract.dart — the SINGLE source of the "<=6 questions to any product"
// contract numbers. Every census and the central verify gate import THESE; no other
// file hard-codes a bare 6 / 12 turn literal (a grep-guard test enforces that once
// the consumers land). Pure consts, no Flutter (build-plan v3, P0 step 3).

/// Hard ceiling: at most this many narrowing turns to reach ANY product.
const int kMaxDiveTurns = 6;

/// The dive MUST surface a pickable product list no later than this turn, so the
/// grid pick is the <=kMaxDiveTurns-th action (list-then-pick arithmetic). Derived:
/// one less than the ceiling.
const int kListThenPickTurn = kMaxDiveTurns - 1; // = 5

/// The "just pick" ShowProducts list is capped at 12 (NOT 30) and its labels must be
/// pairwise-distinct, so the single pick is genuinely one action (round-1 blocker #2:
/// a cap of 30 let the target sit at item #13-30, needing a 7th action).
const int kReachListCap = 12;
