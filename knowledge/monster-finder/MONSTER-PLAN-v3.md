# MONSTER — תוכנית-v3 (אחרי סבב-קריעה 2 + הקשחת-P0.5/P12)

> **129 יחידות** · נוסף P0.5 (שער-הוכחה-ישים · גידור-WaterSystem · debounce-מאוחד · בידוד-זהות-בזרם · prefs-לפי-uid · handshake-קליטה) + P12 a11y. תוקן מ-v2 לפי 9 חוסמי-סבב-2.


## changeLog — v2→v3

- Inserted a 'P0.5 hardening' phase (steps 9-37) immediately AFTER P0 and a 'P12 a11y contract' phase (steps 119-129) at the end; renumbered all steps 1..129 with NO forward-pointing dependsOn. The load-bearing fixes (feasible proof harness 9-18, compat WaterSystem gate 10/13) sit at steps 9-18, well before the renumbered P8/P9/P11 (83+), satisfying the teardown's 'do not start P8/P9/P11 until proof-feasibility and compat-gate are fixed'.
- FEASIBLE PROOF: replaced v2 step 89's |U|^2 all-pairs <=4 BFS with single-source reachWithin4(src) per node (steps 16/91/118); replaced the contradictory 'exhaustive per-card census' with STRICTLY-GREEDY single-path greedyReach + a wrong-target mutation test (steps 15/58/71/80); added mergedKeys memoization per collapsed-pool signature (14); split per-commit seeded sample from a nightly full-|U| cron job and added wall-clock budgets (17); reconciled the central-gate prose+test to match (18/118).
- COMPAT WATERSYSTEM GATE: extracted crossesSystem(a,b) from gapAdviceHe.only() reusing the EXISTING productSystems() (step 10), filtered compat AND kit edges through it at edge-build with an EXHAUSTIVE (not sampling) hop_graph_compat_test (13), and deleted v2 step 5's false 'already WaterSystem-gated via _reallyMates' prose.
- INGESTION HANDSHAKE: publicized collapseKeyOf() so the census tests compile across the file boundary (step 9); converted kReachUniverse's length pin from equality to a TOLERANCE BAND + content invariant (11); added scripts/regen_unified_finder_baselines.sh modeled on the gen-snapshot idiom (36); installed the load-failure-ONLY CI retry that the project MEMORY recorded as proven but did not actually exist, at --concurrency=1 (37).
- UNIFIED DEBOUNCE: moved the _busy re-entrancy guard off _onWordTap onto _pushStep + the _ProductTap sheet-open + a sheet-local _hopBusy on _switchByChip (steps 19-20), with a per-surface same-frame concurrency contract test across word/text/voice/AI/rail (21).
- STREAM IDENTITY ISOLATION (re-instates teardown fix #10 that v2 merged out): prev-uid!=new-uid wipe inside the LIVE _onAuthEvent stream (step 22, not only signOut); ref.listen(currentUidProvider) -> _restart the State-held dive stack (23) and clear _hopHistory/_chipOverride + pop the sheet (24); a STREAM-path E2E with a negative control (25); plus a flag-gated ref.invalidate wipe of all identity-coupled persisted stores on the same transition (31).
- UID-NAMESPACED PREFS: a single scopedPrefsKey helper (uid==null preserves today's global key) (26); uid-scoped + try/catch recently_viewed/product_favorites/saved_configs (27-29, the last adding the missing _userTouched guard); REPLACED v2's lossy/irreversible savedConfigs->favorites migration with an SKU-correct, additive (new v2 key), reversible dual-store reporting unresolvable pairs (30).
- P12 A11Y CONTRACT: fixed the ROOT #41 destination chip (real Icons.north_east glyph, not colour-only) (119); a11y_contract.dart with an EMPTY waiver list (120); 48dp tap targets decoupled from the 30px cell (121); RTL OrderedTraversalPolicy with the decisive chip focus-first (122); per-chip axis+label announce reusing the EXISTING semanticLabel seam (123); throttled liveRegion status node (124); operable hop-rail + individually-labelled ShowProducts (125); modal FocusScope trap (126); the self-testing allowlist-EMPTY a11y gate in the central .sh (129).
- softTilt/card_soft RECONCILE (R2 blocker #7): softTilt now biases via history/kit/compat SET-overlap (live on the wide merge pool), NOT anchorOf (which card_soft.dart proves inert); ONE soft module enforced (no orphan soft_tilt.dart); the tilted golden built from a REAL seeded run; WordKey destination reuses the EXISTING axisGlyph seam instead of v2 step 70's colliding isDestination field (steps 96-100, 127).
- DROP-NOTHING cross-check folded the un-themed R2 majors into in-place patches so no earlier fix was lost: AI try/catch + promptSafeText (34), 'where is my copper' material-token path + Hebrew \b fiction + מרפק sample (35), category-edge finderGroupFor-null isolate -> raw-categoryHe (8/85), _forcedOnFlags reconciliation + GATING TABLE (114), and hiddenCatalogSections persisted-write -> pure render-time hide with catalogSectionProvider reset (117). All v2 fixes the teardown's 'תיקונים שאושרו' confirmed (P0 contract phase, :4506/:4395 correction, cap-at-12, empty-allowlists, STAR arithmetic, one-surface, capability-gating, owner-decisions, off-corpus surfacing, infoGain-out-of-equality) are preserved verbatim.
- Unit count grew from 89 to 129 (P0=8, P0.5=29, P1-P11=81 renumbered 38-118, P12=11). Every step stays behind kUnifiedFinder/kCardKeyboard so production is byte-identical until the owner says 'תדחוף'; the compat filter and mergedKeys memo live in census/edge-build paths so the live sheet's compatibleProductsFor and live mergedKeys are unchanged; every persisted patch's uid==null path keeps today's exact legacy key and bytes.

## buildReadiness

SAFE TO START NOW: P0 (1-8) and the entire P0.5 hardening pass (9-37) are build-ready and should be built first. Within P0.5, the LOAD-BEARING cluster (feasible proof harness 9-18 and the compat WaterSystem gate 10/13) must complete before any of P8/P9/P11, exactly as the round-2 verdict demanded — those are the gates for the whole <=4 honesty claim. P1 data (38-45) and P2 state (46-49) can start as soon as their P0.5 prerequisites land: the persistence patches (26-31) must precede the state mutations (47-48) so recently-viewed/savedConfigs are uid-safe before a card writer/migration touches them, and step 9 (collapseKeyOf) must precede step 2's census fold. P3-P7 (50-82) can proceed once the new-surface debounce (19-21) and stream identity isolation (22-25) are in, since every new surface (text/voice/AI/tap) routes through the now-gated _pushStep and every dive/sheet is identity-isolated. RESIDUAL GATE before P8/P9/P11 (83-118): steps 9-18 (feasible proof + band + memo + single-source BFS + the split per-commit/nightly CI) and steps 10/13 (crossesSystem filter, exhaustive test) MUST be green and wired into protocol-enforce.yml with the load-failure-only retry (37) — until then the <=4/<=6 censuses cannot finish per commit and the cross-WaterSystem honesty is unproven. P12 a11y (119-129) and the softTilt reconcile (96-98, capstoned at 127) need not block P0 step 1 but MUST land before P9 ships its merged-chip surface (the destination glyph 119 precedes the WordKey seam 99) and the a11y gate (129) hooks the same central .sh as the math gate. One owner decision remains an explicit veto-able const, not a blocker: kInstallStudioDisposition (absorbTree vs rebrandFlat, step 109) — either branch is build-ready and line_branch_scope_test proves no capability is silently lost. Production stays byte-identical (flags default false; every patch's uid==null/flag-OFF path is the legacy bytes) until the owner says 'תדחוף'.

## הוכחת-החוזה (ישימה + כנה)

The <=6 / <=4 proof is now BOTH honest AND computationally feasible — the two things v2 had only one of each. FEASIBILITY: the <=4 contract is no longer the |U|^2 all-pairs BFS v2 step 89 mandated (~10^6 pairs × ~5.5e9 edge-visits = timeout). It is a SINGLE-SOURCE directed depth-4 BFS run ONCE PER NODE (reachWithin4(src), step 16/91), ~10^3 BFS at O(V·E) total, asserting for every src that relatedTargetsOf(src) ⊆ reachWithin4(src) — i.e. the union of unreachable RELATED pairs is EMPTY. A pair (a,b) is <=4 iff b∈reachWithin4(a), mathematically equivalent but O(V·E) not O(V^2·E), with a Stopwatch wall-clock budget (kReachProofBudgetMs) and a structural guard asserting exactly divePoolBySku.length BFS calls (never the quadratic form). The <=6 census is pinned STRICTLY GREEDY single-path (greedyReach, step 15/58/71/80) — the contradictory 'EXHAUSTIVE info-gain BFS for EACH card' wording is DELETED; mergedKeys is memoized per collapsed-pool signature (step 14) so converging intermediate pools are computed once; per-commit runs a deterministic ~200-card seeded sample + structural self-tests + the budget, while the full-|U| sweep moves to a nightly cron job (step 17), and heavy censuses run at --concurrency=1 inside a load-failure-ONLY retry (step 37). HONESTY: hidden-target honesty comes from NOT feeding the target to chip-SELECTION (chips ranked by _AxisScore/distinctCardCount gain only) — proven by a grep-guard plus a wrong-target MUTATION test asserting an identical chip sequence for (target, wrong-target) pairs; success is survival inside the <=12 pairwise-distinct cut, not the engine's single best guess; all allowlists (kReachAllowlist, census unreachable, over4Allowlist, kHopPairOverride, kA11yWaiverList) assert .isEmpty with debt in separately-named lists the gate ignores. The denominator is the single uncapped kReachUniverse folded on the PUBLIC collapseKeyOf (step 9 — _collapseKey was library-private, making v2's census citations uncompilable), pinned as a TOLERANCE BAND (step 11) not an equality so an ingestion-only PR (#56) doesn't red-gate, with a content invariant that every hasSpec card stays reachable. The <=4 scope is honestly '<=4 to a RELATED product over the tagged graph, no cross-WaterSystem' — and that boundary is now ENFORCED by crossesSystem(a,b) (step 10/13, extracted from gapAdviceHe.only() reusing the EXISTING productSystems() at install_engine.dart:359, NOT the false _reallyMates 'already gated' claim), with an EXHAUSTIVE hop_graph_compat_test asserting NO compat or kit edge has crossesSystem==true. The gate is a REAL bash .sh on the ubuntu CI with an INJECT_OVER4 bool.fromEnvironment self-test that forces RED, plus a workflow-define-leak guard.

## פאזות

- P0 shared-contracts (1-8) — UNCHANGED from v2: decisions.dart owner sign-off (1), divePoolBySku + UNCAPPED kReachUniverse (2), kMaxDiveTurns single-source-of-<=6 (3), EdgeKind + hop_graph skeleton (4) and its 4 tagged edge populations (5-8). Two in-place patches landed here: step 5 drops v2's false 'already WaterSystem-gated via _reallyMates' and gains the crossesSystem filter (from P0.5), and step 8's category edges use RAW-categoryHe for 100% isolation-coverage (R2 major on finderGroupFor-null isolates).
- P0.5 hardening — feasible proof + compat gate, LOAD-BEARING (9-18): publicize collapseKeyOf + divePoolBySku fold (9, unblocks every census), crossesSystem from gapAdviceHe.only() reusing the EXISTING productSystems() (10), kReachUniverse equality->BAND + content invariant (11), relatedPairs() oracle (12), EXHAUSTIVE compat+kit crossesSystem filter/test (13), mergedKeys memo per collapsed-pool signature (14), STRICTLY-GREEDY target-blind census walker with wrong-target mutation (15), single-source depth-4 BFS replacing |U|^2 all-pairs (16), per-commit-sample-vs-nightly-full split (17), central-gate prose reconciliation (18). These precede P8/P9/P11 (steps 83+) as the teardown demanded.
- P0.5 hardening — new-surface debounce (19-21): move _busy onto _pushStep so word/text/voice/AI/_SeedTap share ONE gate (19), gate the _ProductTap sheet-open + a _switchByChip _hopBusy guard (20), per-surface same-frame concurrency contract test across all five surfaces (21). Re-instates teardown fix #10's uniform-surface hardening for re-entrancy.
- P0.5 hardening — identity isolation (22-25): prev-uid!=new-uid wipe inside the LIVE _onAuthEvent stream (22), ref.listen(currentUidProvider) -> _restart the State-held dive stack (23), the sheet listener clears _hopHistory/_chipOverride + pops (24), STREAM-path E2E with a negative control (25). Re-instates teardown fix #10 (uniform stack/_hopHistory/cardPicks isolation) that v2 merged out.
- P0.5 hardening — persistence (26-33): uid-namespaced prefs key helper (26), uid-scope + try/catch recently_viewed/product_favorites/saved_configs (27-29, the last adds the missing _userTouched guard), SKU-correct additive reversible savedConfigs->favorites migration replacing the lossy one (30), flag-gated ref.invalidate wipe of all identity-coupled persisted stores on the stream transition (31), the State-field+persisted composition net (32), and a flag-OFF on-disk+in-memory single-truth sweep + define-leak guard (33).
- P0.5 hardening — ingestion handshake + pre-resolved P4/P5 majors (34-37): AI try/catch + promptSafeText contract (34, R2 major), the 'where is my copper' material-token->productsOfMaterial path dropping the Hebrew \b fiction and fixing the מרפק=zero-hits sample (35, R2 major), scripts/regen_unified_finder_baselines.sh #56 handshake (36), and the load-failure-ONLY CI retry wrap at concurrency=1 (37).
- P1 data (38-45) / P2 state (46-49) — v2's data + state fixes preserved verbatim (canonicalSize dictionary, dims['חומר'] materialOf, material gated co-axis, kTrueColors complement, taxonomy reconcile, <=12 category groups, infoGain out of equality, recently-viewed dual-write keeping :4506 and :4395-brandHistory, savedConfigs migration now wired to the reversible step-30 store, single-truth sweep). The persistence patches (steps 27-30) make the state mutations uid-safe.
- P3 entry-surface (50-53) / P4 text-voice (54-59) / P5 ai-surface (60-63) — the 6-mouth chooser stays DELETED to ONE OpeningSurface; the census is now STRICTLY-GREEDY target-blind over the feasible harness (58/59); synonym_bridge/resolveQuery carry the step-35 copper fix; resolveAiSeed/AI-chip carry the step-34 try/catch + promptSafeText fix.
- P6 tap-chips (64-72) / P7 merged-brain (73-82) — CardSeed seam, four seed sources (DROP-empty, distinct sentinels, 100% category coverage), browse + merged-brain censuses re-pinned to greedyReach (single-path, target-blind, memoized) with per-commit-sample/nightly-full, top-K-by-gain golden, HARD <=6 turn-gate.
- P8 hop-graph (83-95) — directed adjacency crossesSystem-filtered (83), 1-adjacent multi-superHub STAR with the raw-categoryHe catch-all eliminating the real isolate set (85), dual-path sheet hop UI keeping _chipOverride + the _hopBusy/uid-listener guards, the HONEST <=4 census now single-source reachWithin4 per node (91), the real .sh gate at concurrency=1 in the load-retry (94).
- P9 hidden-signals (96-104) — softTilt RECONCILED with card_soft.dart: biases via history/kit/compat SET-overlap (live on the wide merge pool), NOT anchorOf; ONE soft module (no orphan soft_tilt.dart); the tilted golden built from a REAL seeded run; WordKey destination reuses the EXISTING axisGlyph seam (no colliding isDestination field); identity-scoped historySkusProvider.
- P10 terminus (105-113) / P11 cut-over (114-118) — identity-scoped cardPicks (wipe via the flag-gated step-31 invalidate), planLineFromPicks RETURNING unresolvedSkus at depth-4, the 9->1 absorb-vs-rebrand decision, the _forcedOnFlags reconciliation + GATING TABLE (114), pure render-time pill-hide with NO persisted write + catalogSectionProvider reset (117, R2 major), and the central gate re-pinned to the feasible band+greedy+single-source harness (118).
- P12 a11y-contract (119-129) — the ROOT #41 chip gains a real Icons.north_east glyph (119), a11y_contract.dart with an EMPTY waiver list (120), 48dp tap targets decoupled from the 30px cell (121), RTL OrderedTraversalPolicy with the decisive chip focus-first (122), per-chip axis+label screen-reader announce (123), throttled liveRegion status node (124), operable hop-rail + individually-labelled ShowProducts list (125), modal FocusScope trap (126), the softTilt no-orphan capstone (127), cold-start/off-corpus/naming-coherence doc-as-test (128), and the self-testing allowlist-EMPTY a11y gate wired into the central .sh (129).

---

## כל השלבים


### P0 shared-contracts

**1. decisions.dart owner sign-off constants (topological root)**  
NEW pure const file: kIdentityScope, kMaterialIsGatedCoAxis=true, kReachLowerBound, kReachAllowlist={} EMPTY, kColorExclusionsAreComplementOfAllowlist=true. No logic.  
*קבצים:* `lib/features/card_keyboard/decisions.dart (new)` · `test/features/card_keyboard/decisions_test.dart (new)` · *בדיקה:* decisions_test: kReachAllowlist.isEmpty; kMaterialIsGatedCoAxis==true; kIdentityScope legal; kReachLowerBound>0. analyze zero-new. · *תלוי:* []

**2. divePoolBySku map + UNCAPPED kReachUniverse helper**  
Extend dive_pool.dart (kDivePool byte-identical): divePoolBySku={p.sku:p}, kReachUniverse=_reachUniverse() distinct-by-card, NO take/sublist/cap, folds by distinctCardCount. Public reachUniverseSize(). P0.5b publicizes the fold key.  
*קבצים:* `lib/features/word_finder/dive_pool.dart` · `test/features/word_finder/reach_universe_test.dart (new)` · *בדיקה:* divePoolBySku.length==kDivePool.length, sku round-trips; kReachUniverse.length>=kReachLowerBound AND ==distinctCardCount(kDivePool); grep-guard no .take/.sublist; a known HW- card present. · *תלוי:* [1]

**3. kMaxDiveTurns — single source of <=6**  
NEW dive_contract.dart: const kMaxDiveTurns=6; kListThenPickTurn=5; kReachListCap=12. Pure. P0.5 adds kReachUpperBound + a11y consts here too.  
*קבצים:* `lib/features/card_keyboard/dive_contract.dart (new)` · `test/features/card_keyboard/dive_contract_test.dart (new)` · *בדיקה:* kMaxDiveTurns==6; kReachListCap==12; kListThenPickTurn==5; grep-guard no bare <=6/>6 turn literal outside dive_contract.dart. · *תלוי:* [1]

**4. EdgeKind enum + hop_graph skeleton (node-set==kReach, no virtual nodes)**  
NEW hop_graph.dart: enum EdgeKind{compat,variant,kit,category}; HopGraph nodes==divePoolBySku.keys; kindsBetween(a,b). Edge population is steps 5-8. Directed adjacency.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart (new)` · `test/features/card_keyboard/hop_graph_skeleton_test.dart (new)` · *בדיקה:* node-set==divePoolBySku.keys; EdgeKind has 4 values; empty graph kindsBetween=={}. · *תלוי:* [2]

**5. compat edges into hop_graph (FILTERED through crossesSystem, not assumed gated)**  
PATCHED by P0.5: populate EdgeKind.compat from compatibleProductsFor(p) for each sku, then WRAP the neighbour iteration so p->q is added ONLY IF !crossesSystem(p,q) (step 13). DELETE v2's false 'already WaterSystem-gated via _reallyMates'. compatibleProductsFor stays byte-identical (live carousel unaffected).  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_compat_test.dart (new)` · *בדיקה:* see step 13's EXHAUSTIVE hop_graph_compat_test (every compat edge crossesSystem==false); edge set == compatibleProductsFor(sku).where(!crossesSystem). · *תלוי:* [4]

**6. variant edges into hop_graph**  
Populate EdgeKind.variant from allVariantFamilies(): clique per family, real products, restrict to divePoolBySku.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_variant_test.dart (new)` · *בדיקה:* family members pairwise variant-adjacent; no-family product zero variant edges. · *תלוי:* [4]

**7. kit edges into hop_graph (FILTERED through crossesSystem)**  
PATCHED by P0.5: populate EdgeKind.kit from assembleKit over kSmartProducts co-membership; apply the IDENTICAL crossesSystem filter (step 13) so co-membership can't straddle systems. Restrict to divePoolBySku.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_kit_test.dart (new)` · *בדיקה:* recipe with >=2 resolved lines yields a kit-edge; kit edges have zero crossesSystem==true (asserted in step 13's test). · *תלוי:* [4]

**8. category edges into hop_graph (the <=4 fallback rail, raw-categoryHe for 100% coverage)**  
PATCHED (R2 major step 39/8/54 isolate): populate EdgeKind.category by shared categoryHe WITHIN one WaterSystem; use the RAW-categoryHe edge everywhere for isolation-prevention (NOT finderGroupFor, which returns null outside the ~6 groups) so every product with a category has >=1 edge BY CONSTRUCTION before superHub assignment.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_category_test.dart (new)` · *בדיקה:* two same-categoryHe supply skus adjacent; supply/drainage pair NOT connected; the REAL isolate set (enumerate every sku where compat==kit==variant=={}) all gain a category edge; union of present EdgeKinds=={compat,variant,kit,category}. · *תלוי:* [4]


### P0.5 hardening — feasible proof + compat gate (LOAD-BEARING)

**9. publicize collapseKeyOf() + divePoolBySku fold key (UNBLOCKS every census)**  
In word_finder_engine.dart add PUBLIC `collapseKeyOf(p)=>_collapseKey(p)` after :252 (keep _collapseKey + its 4 internal callsites byte-identical) AND PUBLIC `reachCollapsedKeys(pool)` + confirm the public `divePoolBySku` getter. kReachUniverse (step 2) folds on collapseKeyOf, NOT _collapseKey. Change every '_collapseKey' citation in steps 2/census to collapseKeyOf.  
*קבצים:* `lib/features/word_finder/word_finder_engine.dart` · `test/features/word_finder/collapse_key_public_test.dart (new)` · *בדיקה:* distinctCardCount(pool)==reachCollapsedKeys(pool).length for sampled pools; two size/colour variants share collapseKeyOf; divePoolBySku round-trips; grep-guard _collapseKey keeps its original internal callsites; the test compiling across the file boundary IS the proof. · *תלוי:* [2]

**10. crossesSystem(a,b) extracted from gapAdviceHe.only(), reusing the EXISTING productSystems()**  
NEW pure `crossesSystem(a,b)` in related_info.dart. Lift the inline only() predicate (:393) to top-level `_onlySystem`; rewrite gapAdviceHe:394-396 to call it (byte-identical). crossesSystem uses productSystems() (install_engine.dart:359 — EXISTS, NOT vaporware), NOT raw endSystems, returning (_onlySystem(sa,supply)&&_onlySystem(sb,drainage))||(reverse). Add install_engine import; if a cycle, copy the category-set logic to a shared helper both delegate to.  
*קבצים:* `lib/data/related_info.dart` · `test/data/crosses_system_test.dart (new)` · *בדיקה:* supply tap + drain trap -> true; two supply fittings -> false; both-system fixture paired with anything -> false; symmetric for 50 pairs; gapAdviceHe still returns the literal cross-system Hebrew string (refactor parity); import-cycle compile check. · *תלוי:* []

**11. kReachUniverse.length -> TOLERANCE BAND + superset content invariant (PATCHES step 2)**  
In dive_contract.dart add const kReachUpperBound alongside kReachLowerBound; pin the census as kReachLowerBound<=kReachUniverse.length<=kReachUpperBound (band, NOT equality). ADD content invariant: {collapseKeyOf(p) for hasSpec p} subset reachCollapsedKeys(kDivePool). Band bumped by the ingestion regen handshake (step 36). Pins MEANING not count, absorbing #56 ingestion drift.  
*קבצים:* `lib/features/card_keyboard/dive_contract.dart` · `test/features/card_keyboard/reach_universe_band_test.dart (new)` · *בדיקה:* kReachLowerBound>0 && kReachUpperBound>=kReachLowerBound; band holds on current catalog; hasSpec collapsed-set is a subset; OWNER-REVIEW comment cites #56; forcing length below lower bound RED-gates. · *תלוי:* [9,3]

**12. relatedPairs() oracle: single-system RELATED-pair predicate the <=4 proof asserts over**  
NEW pure `isRelatedPair(a,b)` + `relatedTargetsOf(src)` in hop_graph.dart. RELATED iff (i) !crossesSystem AND (ii) same weakly-connected component over the TAPPABLE rail adjacency (rankedNeighborsOf). Components computed ONCE via union-find, cached. relatedTargetsOf returns only in-component same-system targets.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/related_pairs_test.dart (new)` · *בדיקה:* symmetric; cross-system pair never related even via a fixture bridge (crossesSystem clause dominates); different-component supply skus not related; relatedTargetsOf(src) subset {!crossesSystem(src,q)}; hub relatedTargetsOf non-empty. · *תלוי:* [10,5,8]

**13. FILTER compat+kit edge-build through crossesSystem; EXHAUSTIVE hop_graph_compat_test (PATCHES steps 5/7)**  
At the EdgeKind.compat and EdgeKind.kit edge-build (steps 5/7) add edge p->q ONLY IF !crossesSystem(p,q). Do NOT trust _reallyMates (its drainage branch :176-177 connects by material family alone, smuggling a PVC supply<->drain cross-system edge). Filter at edge-build, not inside related_info (compatibleProductsFor byte-identical).  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_compat_test.dart` · *בדיקה:* EXHAUSTIVE (not sampling): enumerate EVERY compat edge, assert crossesSystem(src,dst)==false for ALL (zero tolerance, no allowlist); parity: compat set==compatibleProductsFor(sku).where(!crossesSystem); kit edges likewise zero crossing; RED self-test: a hand-built supply->drainage edge makes the exhaustive assertion fail. · *תלוי:* [10,5,7]

**14. mergedKeys memo cache keyed by collapsed-pool signature (per-card census affordable)**  
In card_engine.dart add a @visibleForTesting memo `mergedKeysMemoized(pool)` keyed on poolSig=pool.map(collapseKeyOf).toSet() (stable hash). Census-only behind kCensusMemoEnabled; production mergedKeys call sites byte-identical. Two raw pools collapsing to the same card-set share one computation.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/merged_keys_memo_test.dart (new)` · *בדיקה:* memoized==un-memoized mergedKeys (sequence-equality) for 20 pools; two pools with same collapsed set hit ONE cache entry (size grows by 1); deterministic; cache size <= distinct collapsed signatures. · *תלוי:* [9]

**15. STRICTLY-GREEDY single-path hidden-target census walker (deletes 'exhaustive'; wrong-target mutation)**  
NEW lib/test_harness/tests/greedy_census.dart: `greedyReach(targetSku,seed)` a SINGLE greedy walk to kMaxDiveTurns. Next chip chosen SOLELY by _AxisScore/distinctCardCount gain via mergedKeysMemoized — walker NEVER receives targetSku for selection. Target only picks WHICH branch (membership), never reorders chips. SUCCESS iff by kListThenPickTurn the <=12 distinct-label cut contains targetSku. DELETE every 'exhaustive BFS for EACH card' wording (contradictory with greedy).  
*קבצים:* `lib/test_harness/tests/greedy_census.dart (new)` · `test/features/card_keyboard/greedy_census_test.dart (new)` · *בדיקה:* grep-guard: chip-selection never references targetSku in its ranking expr; MUTATION: greedyReach(t1,seed).chipSequence==greedyReach(t2,seed).chipSequence for 50 (target,wrong-target) pairs (target-blind); a reachable card succeeds within 5 turns; an injected fabricated-unreachable card returns success==false. · *תלוי:* [9,14,3]

**16. single-source directed depth-4 BFS replacing the |U|^2 all-pairs census (PATCHES the <=4 proof)**  
NEW pure `reachWithin4(src)` in hop_graph.dart: ONE directed BFS from src over rankedNeighborsOf, frontier-limited to depth 4. The proof runs it ONCE PER NODE (~10^3 BFS, O(V·E)) asserting for every src relatedTargetsOf(src) subset reachWithin4(src) (union-of-unreachable-related-pairs EMPTY). DELETE the |U|^2 all-pairs framing (timeout). Equivalent: (a,b)<=4 iff b in reachWithin4(a), but O(V·E) not O(V^2·E).  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_reach_test.dart` · *בדיקה:* for src in divePoolBySku.keys: relatedTargetsOf(src).difference(reachWithin4(src)).isEmpty; over4Allowlist+kHopPairOverride EMPTY; reachWithin4 never contains a cross-system sku; structural: exactly divePoolBySku.length BFS calls (NOT |U|^2); WALL-CLOCK budget under kReachProofBudgetMs via Stopwatch; RED self-test deleting one superHub<->superHub edge. · *תלוי:* [9,12]

**17. split per-commit (seeded sample + structural self-tests + budget) vs nightly full sweep + load-retry**  
(A) PER-COMMIT verify_card_keyboard.sh: structural self-tests (single-source-not-|U|^2, target-blind mutation, exhaustive crossesSystem) + a DETERMINISTIC ~200-card seeded greedyReach sample + wall-clock budget + the kReachUniverse band. (B) NIGHTLY monster-nightly.yml (cron '0 3 * * *', modeled on protocol-enforce.yml job shape) runs FULL-|U| census + full single-source <=4 sweep at --concurrency=1. Wire verify_card_keyboard.sh into protocol-enforce.yml AFTER Gate 2 (:50). Install the load-failure-ONLY retry (step 37). NEVER add ENABLE_UNIFIED_FINDER/ENABLE_CARD_KEYBOARD to either workflow.  
*קבצים:* `app_flutter/scripts/verify_card_keyboard.sh` · `app_flutter/.github/workflows/monster-nightly.yml (new)` · `app_flutter/.github/workflows/protocol-enforce.yml` · `test/features/card_keyboard/census_sample_seed_test.dart (new)` · *בדיקה:* seeded ~200-card subset DETERMINISTIC across 3 runs, all in kReachUniverse, completes under per-commit budget; verify_card_keyboard.sh exits 0 clean, prints sample-pass + structural + ms; injected >4 makes structural RED self-test exit non-zero; nightly YAML valid (actionlint), cron '0 3 * * *', no monster define; taskkill dart before; retry-wrap load failures only (grep 'Connection closed before test suite loaded', cap 2, never a real RED); never tail. · *תלוי:* [15,16,11,37]

**18. central gate reconciliation: rewrite the contradictory 'exhaustive |U|^2' wording to the feasible harness**  
Rewrite the central gate test clauses so plan text and executable harness agree: (1) kReachUniverse BAND not equality; (2) per-card <=6 via STRICTLY-GREEDY target-blind walker over SEEDED SAMPLE per-commit / full nightly, cap-at-12 + pairwise-distinct; (3) <=4 via SINGLE-SOURCE directed depth-4 BFS per node asserting union-of-unreachable-related-pairs empty — DELETE 'enumerates |U|^2 ordered pairs', REPLACE with 'issues exactly divePoolBySku.length single-source BFS calls'; (4) allowlists EMPTY; (5) every compat/kit edge crossesSystem==false (exhaustive). Self-test seam: const kInjectOver4Offender=bool.fromEnvironment('INJECT_OVER4') adds one fabricated >4/cross-system edge -> RED.  
*קבצים:* `test/unified_central_gate_test.dart (new)` · `test/unified_central_gate_selftest_test.dart (new)` · `app_flutter/scripts/verify_card_keyboard.sh` · *בדיקה:* central gate green on clean tree, prints PASS counts; with INJECT_OVER4=true the union-empty assertion fails -> non-zero; structural guard asserts divePoolBySku.length BFS calls (not |U|^2); define-leak guard non-zero if ENABLE_* injected into a fixture web-deploy.yml; taskkill dart before; retry-wrap load failures only. · *תלוי:* [13,15,16,11,17]


### P0.5 hardening — new-surface debounce

**19. Make _pushStep the SINGLE re-entrancy gate (move _busy off _onWordTap onto _pushStep)**  
RELOCATE the _busy guard from _onWordTap (:313-315) into the first line of _pushStep (:204), before setState. Update the _busy doc (:118-119) to say it guards EVERY step-push surface. Guard stays outside setState so a blocked re-entrant call mutates nothing. Covers text/voice/AI/_SeedTap which all route through _pushStep.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/push_step_reentrancy_test.dart (new)` · *בדיקה:* two synchronous _pushStep in one frame -> stack grows by EXACTLY 1; after a pump a third lands (per-frame gate); grep-guard `if (_busy) return;` is in _pushStep and NOT in _onWordTap; flag-OFF build()==SizedBox.shrink. · *תלוי:* []

**20. Gate the _ProductTap sheet-open + a _switchByChip one-shot guard**  
(1) Wrap _onWordTap's _ProductTap showLipskeyProductSheet open (:366-368) in the same _busy check (no two modal sheets on double-tap). (2) In lipskey_product_sheet.dart add sheet-local `bool _hopBusy=false` next to _chipOverride (:121); guard _switchByChip's body (:364-371) so a same-frame double carousel/pager tap can't race two _chipOverride writes (and, post step-66, two _hopHistory entries). _hopBusy independent of screen _busy. Flag-OFF byte-identical (second-call refusal only a glitch/test can trigger).  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/screens/lipskey_product_sheet.dart` · `test/features/card_keyboard/product_tap_and_switch_reentrancy_test.dart (new)` · *בדיקה:* two same-frame _ProductTap -> showLipskeyProductSheet at most once (find.byType(LipskeyProductSheet)==1); _switchByChip(qA) then (qB) same frame -> _current==qA only, one setState, third after pump lands; flag-OFF single normal tap switches exactly as baseline. · *תלוי:* []

**21. Per-surface same-frame concurrency contract test across word/text/voice/AI/rail**  
NEW behavioral contract test (no production code) exercising ALL FIVE live surfaces through the unified gate; each new-surface step adds its row, gated `if(surfaceExists)` so it stubs until the surface lands. Two activations in one frame per surface: assert stack (or _hopHistory for rail) grows by EXACTLY 1 and Navigator depth +<=1. A NEGATIVE control (an unguarded helper) produces depth +2 and is caught.  
*קבצים:* `test/features/card_keyboard/per_surface_concurrency_test.dart (new)` · *בדיקה:* for each {word,text,voice,ai,rail}: delta==1 and depth delta<=1; negative control caught; flag-OFF every case a no-op; taskkill dart before; retry-wrap load failures only. · *תלוי:* [19,20]


### P0.5 hardening — identity isolation

**22. Track prev uid in _onAuthEvent; clear identity cache on ANY uid transition (not only ->null)**  
In auth_state.dart _onAuthEvent (:492) after `final gen=++_gen;` capture `final prevUid=state.user?.uid;`; in the non-null branch after :500 add `if(prevUid!=null && prevUid!=user.uid){_clearIdentityCache();}`. Do NOT wipe when prevUid==null (cold sign-in) or prevUid==user.uid (claims re-emit). ->null logout stays signOut()'s job. The EXISTING two-store wipe (profile+persona) stays UNGATED (a real pre-existing employer-switch bug); monster-flag stores wiped via the flag-gated step 24/25 listeners.  
*קבצים:* `lib/state/auth_state.dart` · `test/state/auth_event_uid_switch_test.dart (new)` · *בדיקה:* emit A then B via STREAM -> onIdentityCleared fired once on A->B; cold A from signed-out -> not fired; A then A -> not fired; A then null -> not double-fired; stale-gen guard holds (slow A claims after B don't clobber B). · *תלוי:* []

**23. ref.listen(currentUidProvider) in CardKeyboardScreen -> _restart() the State-held dive stack**  
The dive stack (:116)/_diveVersion/_memoVerdict are plain State fields no provider can reach; cardKeyboardStackProvider (card_keyboard_state.dart:18) is an ORPHAN. In build() gated `if(_live||forceLiveForTest)` add `ref.listen<String?>(currentUidProvider,(p,n){if(p!=n)_restart();});`. _restart() (:226) clears stack + bumps _diveVersion (invalidates the memo). Fix the orphan provider's docstring to point at THIS listener. Re-instates teardown fix #10.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/card_keyboard/card_keyboard_state.dart` · `test/features/card_keyboard/card_keyboard_uid_isolation_test.dart (new)` · *בדיקה:* seed dive under A (stack==2), flip to B via stream, pump one frame -> stack.isEmpty, crumbs empty, verdict CardAskWords, _diveVersion advanced; null->A restarts (documented); flag-OFF no listener registered, uid flip no throw. · *תלוי:* [22]

**24. ref.listen(currentUidProvider) in LipskeyProductSheet -> clear _hopHistory/_chipOverride + POP the sheet**  
Near top of _LipskeyProductSheetState.build (:382), inside `if(flagOn||forceLive)`, add a listener: on uid change clear _chipOverride, clear _hopHistory (once step 66 lands; null-safe until then), and `if(canPop())pop()`. The sheet was opened in A's context; dismiss rather than mutate to B (B starts clean from the keyboard, step 23 restarted it). Flag-OFF no listener (byte-identical to today).  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `test/screens/lipskey_sheet_uid_isolation_test.dart (new)` · *בדיקה:* open under A, hop (_chipOverride!=null), flip to B, pump -> _chipOverride==null (and _hopHistory empty post-66) AND route popped (find==0); A->A no pop; flag-OFF sheet stays open unchanged. · *תלוי:* [20,22]

**25. E2E identity-isolation via the STREAM path (seed under A, flip via stream, assert empty post-flip)**  
NEW E2E test (no production code): pump CardKeyboardScreen (forceLiveForTest) under a fake AuthStateNotifier with a controllable authStateChanges stream; sign in A, seed a 2-tap dive, record a pick (cardPicks A), open the sheet + one hop (_hopHistory==1). Emit user B on the SAME stream (lands at _onAuthEvent, NOT signOut). Pump one frame. Assert stack.isEmpty, cardPicks for active scope has none of A's skus, sheet _hopHistory empty + route popped. NEGATIVE: disabling step-23's listener leaves stack non-empty (teeth).  
*קבצים:* `test/features/card_keyboard/identity_switch_stream_e2e_test.dart (new)` · *בדיקה:* after STREAM A->B in first post-flip frame: stack empty, picks clean, _hopHistory empty, route popped; onIdentityCleared recorded once for the A->B edge; parity: same holds via signOut; negative control fails with the listener disabled; flag-OFF inert no throw; taskkill dart before; retry-wrap load failures only. · *תלוי:* [22,23,24]


### P0.5 hardening — persistence

**26. uid-namespaced prefs key helper (single source; uid==null preserves today's global key)**  
NEW pure lib/state/prefs_scope.dart: scopedPrefsKey(base,uid)=uid==null?base:'$base::$uid' + isLegacyGlobalKey(key). The ONE namespacing primitive every store reuses. uid==null returns the bare base (zero-regression, flag-OFF byte-identical on disk). Pure String fn, no Flutter import.  
*קבצים:* `lib/state/prefs_scope.dart (new)` · `test/state/prefs_scope_test.dart (new)` · *בדיקה:* scopedPrefsKey('bs.recently-viewed.v1',null)==legacy exact; ('..','A')=='..::A'; distinct uids distinct keys; isLegacyGlobalKey distinguishes '::'-suffixed. · *תלוי:* []

**27. recently_viewed.dart — uid-scope the key + try/catch getStringList (PATCHES step 51)**  
RecentlyViewedNotifier({uid}); replace bare _key reads/writes (:24/:31) with scopedPrefsKey(_key,_uid); uid==null keeps legacy. recentlyViewedProvider becomes autoDispose family on ref.watch(currentUidProvider). try/catch the getStringList -> const []. Keep _userTouched + touch()/clear() idempotency. PATCHES step 51 (its card writer now writes the uid-scoped key automatically). Live :6261 reader unaffected on uid==null.  
*קבצים:* `lib/state/recently_viewed.dart` · `test/state/recently_viewed_identity_test.dart (new)` · *בדיקה:* uid==null writes legacy key exactly; touch('SKU-A') under A, flip to B -> B empty, not containing SKU-A, disk key '..::B'; a String-typed corrupt key -> [] no throw. · *תלוי:* [26]

**28. product_favorites.dart — uid-scope the key + try/catch (merge target for the migration)**  
ProductFavoritesNotifier({uid}); replace _key (:18/:25) with scopedPrefsKey; autoDispose family on currentUidProvider; try/catch getStringList -> []. Keep _userTouched + toggle() byte-identical. Must be uid-scoped BEFORE the migration (step 30) so it doesn't write A's configs into a global set B reads.  
*קבצים:* `lib/state/product_favorites.dart` · `test/state/product_favorites_identity_test.dart (new)` · *בדיקה:* uid==null writes legacy exactly; toggle under A then flip to B -> B empty, disk key '..::B'; corrupt key -> [] no throw; live favorite-star behavior re-asserted on uid==null. · *תלוי:* [26]

**29. saved_configs.dart — uid-scope + try/catch + add the missing _userTouched guard**  
SavedConfigsNotifier({uid}); replace _key (:19/:24) with scopedPrefsKey; autoDispose family; try/catch -> const {}. CRITICAL: saved_configs.dart:17 _load has NO _userTouched guard (unlike the others) — add the one-shot bool, set in toggle(), early-return in _load when true (lazy _load can't clobber a synchronous user toggle). keyFor + isSaved/toggle byte-identical on uid==null (live save-config star at catalog_screen.dart:5138 unaffected). No migration logic here.  
*קבצים:* `lib/state/saved_configs.dart` · `test/state/saved_configs_identity_test.dart (new)` · *בדיקה:* uid==null writes legacy exactly; save under A, flip to B -> absent for B, disk key '..::B'; corrupt key -> {} no throw; NEW guard: toggle() before async _load resolves -> late _load does NOT overwrite. · *תלוי:* [26]

**30. savedConfigs->favorites migration rebuilt SKU-CORRECT, ADDITIVE (v2 key), REVERSIBLE (REPLACES step 53)**  
DELETE the lossy savedConfigKeysToSkus ('A#ליפסקי'->'A' is a productKey, not a sku). NEW saved_configs_migration.dart: resolveSavedConfigKeys(legacyKeys,{productKeyBrandToSku}) splits on LAST '#', resolves (productKey,brand)->real sku via an injected catalog lookup, drops unresolvable pairs into a REPORTED `unresolved` set. ADDITIVE+REVERSIBLE: flag-ON reader merges resolved skus into NEW 'bs.product-favorites.v2::$uid'; v1 + saved-configs.v1 byte-UNTOUCHED (dual-store). One-shot marker 'bs.saved-configs.migrated.v2::$uid' gates the once-only merge, only when kCardKeyboard/kUnifiedFinder ON.  
*קבצים:* `lib/state/saved_configs_migration.dart (new)` · `lib/state/product_favorites.dart (flag-ON v2-key reader)` · `test/state/saved_configs_migration_test.dart (new)` · *בדיקה:* SKU-correct: 'P1#ליפסקי','P1#פולירול','BOGUS#x' -> skus={real-1,real-2}, unresolved={'BOGUS#x'}, every sku in divePoolBySku, no bare token leaks; ADDITIVE: v1 byte-identical while v2 populated; ONCE: marker present skips re-merge; REVERSIBLE: enable->migrate->disable -> flag-OFF reader returns v1 only, saved-configs.v1 byte-identical; flag-OFF no marker no v2 key. · *תלוי:* [28,29]

**31. wipe identity-coupled persisted stores on the LIVE auth-stream transition (flag-gated; PATCHES step 90)**  
In auth_state.dart, on the prev-uid!=new-uid transition (step 22) extend onIdentityCleared (:627) to ref.invalidate (respects autoDispose) recentlyViewedProvider, productFavoritesProvider, savedConfigsProvider, cardPicksProvider. GATE the card-keyboard-coupled wipes (cardPicks, v2 favorites) behind a featureFlags handle so a flag-OFF logout is byte-identical; the always-safe per-uid stores rebuild lazily anyway, the invalidate just forces it in the first post-transition frame. Re-instates teardown fix #10 for persisted stores.  
*קבצים:* `lib/state/auth_state.dart` · `test/state/auth_identity_wipe_test.dart (new)` · *בדיקה:* STREAM A->B: all four read empty for B, none has A's data; flag-OFF logout: card-coupled wipe NOT invoked, only pre-existing profile+persona reset; list-driven kIdentityCoupledStores guard FAILS if a store is registered but not invalidated; uses ref.invalidate not read().clear(). · *תלוי:* [22,27,28,29,30]

**32. ref.listen(currentUidProvider) in screen+sheet to clear State-held stack/_hopHistory (composition net)**  
Consolidate the State-field isolation (steps 23/24) with the persisted-store wipe (step 31) so a mid-dive employer switch resets the WHOLE identity-coupled surface. No new production code beyond confirming both listeners fire; gated behind _live/forceLive so flag-OFF registers nothing. uid==null->uid treated as a transition (fresh login starts clean).  
*קבצים:* `test/features/card_keyboard/card_identity_restart_test.dart (new)` · *בדיקה:* seed multi-step dive under A, flip to B via stream -> stack reset to opening, _memoVerdict cleared in first post-flip frame, open sheet popped, _hopHistory empty; flag-OFF listeners never registered; taskkill dart before; retry-wrap load failures. · *תלוי:* [23,24,31]

**33. P0.5 persistence single-truth sweep — flag-OFF on-disk + in-memory byte-identity + define-leak guard**  
Consolidation suite (no production code) proving the whole P0.5 persistence/identity layer is flag-OFF byte-identical to pre-P0.5 baseline (no v2 keys, no marker, no migration, no extra wipes, legacy keys byte-identical) and flag-ON behaves as specified. Re-run the live word_finder anchor. CI guard: NO monster dart-define (ENABLE_*/kReachUniverse) in REPO-ROOT firebase-hosting.yml/web-deploy.yml/firebase-deploy.yml/deploy.yml.  
*קבצים:* `test/state/p05_persistence_single_truth_test.dart (new)` · *בדיקה:* flags false + uid==null: stores behave exactly like baseline (only legacy keys, no '::', no v2 key, no marker, no eager invalidate); flags ON + uid + legacy present: v2 key sku-correct, legacy byte-identical; live anchor byte-identical; CI guard ZERO matches (injecting one into a fixture COPY fails red); taskkill dart before. · *תלוי:* [31,32]


### P0.5 hardening — ingestion handshake

**34. AI seed safety: try/catch the AI-chip handler + reuse promptSafeText (R2 majors on steps 60/61)**  
Pre-resolve two AI gaps before P5 builds the surface: (a) mandate that the AI-chip handler WRAPS resolveAiSeed in try/catch showing an honest inline error (never a no-op/unhandled Future) — unlike the absorbed ai_finder which catches and shows _failed; (b) resolveAiSeed must reuse aiFinderPrompt(text) (already funnels through promptSafeText) or call promptSafeText(text,maxLen:600), NO raw `text` interpolation. Doc-as-contract here; the wiring lands in P5 (steps 60/61).  
*קבצים:* `test/features/card_keyboard/ai_seed_safety_contract_test.dart (new)` · *בדיקה:* a throwing fake gateway through the handler yields an inline error not a dead-end; code-presence test asserts no raw `text` interpolation in ai_seed.dart and that promptSafeText is on the path. · *תלוי:* []

**35. 'where is my copper' end-to-end: material token -> productsOfMaterial; drop Hebrew \b fiction; fix מרפק sample (R2 major on steps 53/54)**  
Pre-resolve the discoverability major before P4 builds synonym_bridge: (a) in resolveQuery, when a normalized token EQUALS a kMaterials key, resolve via productsOfMaterial (NOT resolveWord — נחושת is not a name-token, so resolveWord returns empty and the no-dead-end fallback returns the WHOLE pool) and UNION; (b) DROP the unicode-\b claim for Hebrew (Dart RegExp \b is ASCII-only) — match whole Hebrew tokens by equality; (c) surface materialsInPool() as UNGATED opening keys; (d) seed kQuerySynonyms with everyday-noun aliases (מרפק->ברך, which appears ZERO times in the catalog); (e) gate the P4 E2E with a meta-test asserting every sample resolves to >=1 product BEFORE the convergence assertion.  
*קבצים:* `test/features/word_finder/copper_path_contract_test.dart (new)` · *בדיקה:* resolveQuery('copper')/('נחושת')/('медь') resolve to the copper SUBSET (NOT the whole pool); a material token routes through productsOfMaterial; no Dart \b on a Hebrew alias; 'מרפק' maps to ברך and resolves >=1; meta-test asserts every canonical E2E sample is non-empty. · *תלוי:* []

**36. scripts/regen_unified_finder_baselines.sh — the #56 regeneration handshake**  
NEW executable bash regen script (modeled on mutation_verify.sh + the --update-goldens idiom) recomputing every data-derived locked artifact: (1) the kReachLowerBound/kReachUpperBound band (via a tiny dart entrypoint calling reachUniverseSize); (2) flag-ON value goldens; (3) byte anchors + kit-binding snapshots. REPO_ROOT=$(git rev-parse --show-toplevel); cd app_flutter. Normal CI: recompute into temp and DIFF vs checked-in, failing on drift WITHOUT a regen commit; an ingestion PR runs --update.  
*קבצים:* `app_flutter/scripts/regen_unified_finder_baselines.sh (new, executable)` · `app_flutter/tool/dump_reach_band.dart (new)` · `test/features/card_keyboard/regen_handshake_test.dart (new)` · *בדיקה:* clean tree -> exit 0, recomputed band/goldens MATCH checked-in; simulate ingestion drift (env-gated count outside band) -> verify-mode non-zero; --update writes a new band and re-verify passes; script greps clean for monster defines; script is -x and runs from app_flutter; taskkill dart before; never tail. · *תלוי:* [11]

**37. load-failure-ONLY CI retry wrap for the heavy gate**  
The MEMORY-recorded retry-wrap DOES NOT EXIST (the real gate is a bare flutter test --concurrency=4 at protocol-enforce.yml:50). NEW scripts/test_with_load_retry.sh: runs flutter test, on non-zero greps STRICTLY for 'Connection closed before test suite loaded' AND asserts assertion-count parity (0 real failures), only then re-runs (hard cap 2). ANY real assertion failure is NEVER retried. Patch protocol-enforce.yml: wrap the heavy-census step in it, run heavy censuses in their OWN step at --concurrency=1 (less Defender-scan crash surface), keep the fast suite at --concurrency=4. Injection seam: const bool.fromEnvironment('FORCE_LOAD_CRASH'). taskkill dart before each invocation.  
*קבצים:* `app_flutter/scripts/test_with_load_retry.sh (new, executable)` · `app_flutter/.github/workflows/protocol-enforce.yml` · `test/features/card_keyboard/load_retry_selftest_test.dart (new)` · *בדיקה:* passing target -> exit 0, one attempt; FORCE_LOAD_CRASH -> first attempt emits the signature, retries, passes (attempt-count==2); a genuine assertion RED -> NOT retried (attempt-count==1, non-zero); grep matches ONLY the load signature + parity-checks failure count; show the protocol-enforce.yml diff (concurrency=1 census step + the wrap); taskkill dart before; never tail. · *תלוי:* []


### P1 data

**38. baseline goldens BEFORE any data edit (flag-OFF anchors that never move)**  
Capture immovable flag-OFF anchors: (i) golden of card_signals output on a fixed seed pool; (ii) a LIVE word_finder value-golden (narrowAxis().chips + colorOptions() + materialsInPool() same pool). Tagged 'flag-OFF — must never change'. No production change.  
*קבצים:* `test/features/card_keyboard/p1_baseline_golden_test.dart (new)` · `test/golden/word_finder_live_anchor.txt (new)` · *בדיקה:* records and re-reads the anchors; stable across runs; full card_keyboard + word_finder suites green. · *תלוי:* [8]

**39. canonicalSize EQUIVALENCE DICTIONARY (replaces the invented +/-1.5mm band)**  
NEW size_equiv.dart: canonicalSize(label) folding DN15==1/2"==15mm from kBspInchToMm cross-referenced with _kInchMm/_tokenize. EXCLUDES cross-dim x/×, cm, meters, angle (return null). No numeric band. SizeSignal NOT yet rewired (size golden stays byte-identical).  
*קבצים:* `lib/features/word_finder/size_equiv.dart (new)` · `test/features/word_finder/size_equiv_test.dart (new)` · *בדיקה:* canonicalSize('1/2"')==('DN15')==('15mm'); ('3/4"')==('DN20'); length/cross-dim/angle return null; idempotent; keys resolve through kBspInchToMm. · *תלוי:* [38]

**40. dims['חומר'] into materialOf (recovers ~64 copper + dims-only materials)**  
materialOf(): after the kMaterials text scan and BEFORE kCategoryMaterial fallback, consult p.dims?['חומר'] mapped through kMaterials. Precedence text>dims>category preserved.  
*קבצים:* `lib/features/word_finder/material_lexicon.dart` · `test/features/word_finder/material_lexicon_test.dart` · *בדיקה:* dims['חומר']=='נחושת' with no copper word -> 'נחושת'; a 'פלסטיק' dims product still null; text-matched UNCHANGED; seededFraction strictly increases (~64). · *תלוי:* [39]

**41. material demoted to a GATED CO-EQUAL axis**  
MaterialSignal participates scored by decisiveness; replace the binary seededFraction hide (card_signals.dart:208) with the decisions.dart kMaterialIsGatedCoAxis gate (offers chips when it can SPLIT the pool AND coverage clears a FLOOR, never forced first). Keep kHardSignals order as tie-break only.  
*קבצים:* `lib/features/card_keyboard/card_signals.dart` · `lib/features/card_keyboard/decisions.dart` · `test/features/card_keyboard/card_signals_test.dart` · *בדיקה:* material never a forced standalone first axis on a wide pool; appears where most decisive; below floor yields no chips; merge still ranks by integer expRem; p1 flag-OFF anchor unchanged. · *תלוי:* [40]

**42. kTrueColors allowlist + color exclusions as its COMPLEMENT (kills ~65 finish leaks)**  
NEW color_truth.dart: const kTrueColors + isTrueColor; exclusions are the COMPLEMENT (ניקל/נחושת/נירוסטה/זהב מוברש/כרום… are FINISH not colour). kLipskeyColors NOT touched. cardColorOptions(pool)=colorOptions(pool).where(isTrueColor).  
*קבצים:* `lib/features/word_finder/color_truth.dart (new)` · `test/features/word_finder/color_truth_test.dart (new)` · *בדיקה:* every kTrueColors member true; ניקל/נחושת/זהב מוברש/כרום false; cardColorOptions drops them (>0) keeps לבן/שחור; kLipskeyColors string-equality unchanged; ColorSignal rewiring deferred (colour golden byte-identical). · *תלוי:* [41]

**43. reconcile brass/stainless taxonomy (one mapping across lexicon vs verified-specs)**  
NEW material_taxonomy.dart: canonicalMaterial(raw) reconciling kMaterials buckets with VerifiedSpec.material strings; 'פליז'>'נחושת'; brass/stainless/steel each one bucket; verified-spec strings map into the same space. Single source for the material axis + compat-material display.  
*קבצים:* `lib/features/word_finder/material_taxonomy.dart (new)` · `test/features/word_finder/material_taxonomy_test.dart (new)` · *בדיקה:* canonicalMaterial('פליז')==('נחושת'); 'נירוסטה'/'stainless' one bucket; VerifiedSpec.material values resolve without throwing; materialOf∘canonicalMaterial idempotent, never reclassifies an existing hit. · *תלוי:* [42]

**44. kCategoryGroups (<=12 groups, 100%-by-construction, 'אחר' fallback)**  
NEW category_groups.dart: curated map from 60+ raw categoryHe into <=12 owner-facing groups with explicit 'אחר' catch-all; groupOf(p)=lookup ?? 'אחר'. Pure const + one function. Also guarantees the step-8 category-edge isolation coverage.  
*קבצים:* `lib/features/word_finder/category_groups.dart (new)` · `test/features/word_finder/category_groups_test.dart (new)` · *בדיקה:* distinct group count <=12; EVERY kDivePool product maps non-empty; union of group members == every sku (no orphan/double-count); unknown categoryHe lands in 'אחר'. · *תלוי:* [43]

**45. fresh flag-ON value-golden + cross-axis data invariants (after all P1 edits)**  
Record the evolvable flag-ON value-golden (cardColorOptions + materialsInPool(dims) + canonicalSize folds + groupOf). data_axis_invariants: no colour value is also a true material; every canonicalSize key reachable; every product has a group; seededFraction recovered. RE-RUN the step-38 flag-OFF anchor byte-identical.  
*קבצים:* `test/features/card_keyboard/p1_value_golden_test.dart (new)` · `test/features/card_keyboard/data_axis_invariants_test.dart (new)` · *בדיקה:* value-golden blessed; invariants green; CRITICALLY step-38 anchor re-runs UNCHANGED; full suites green. · *תלוי:* [44]


### P2 state

**46. remove infoGain from SignalChip ==/hashCode**  
card_engine.dart: drop infoGain from operator== (:88) and Object.hash (:93), keep the field (display tier). Removes the NaN/ULP hazard from a value type used in sets/goldens.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/card_engine_test.dart` · *בדיקה:* SignalChip(infoGain:1.0)==SignalChip(infoGain:2.0) when other fields match, hashCodes equal, Set dedups; mergedKeys ladder tests unchanged; p1 goldens unchanged. · *תלוי:* [45]

**47. recently-viewed DUAL-WRITE (keep catalog :4506; add flag-gated card writer; :4395 brandHistory untouched)**  
KEEP catalog_screen.dart:4506 .touch exactly (flag-OFF byte-identity); ADD a SECOND writer in the card product-resolution path gated behind kCardKeyboardFlag (read once, threaded). touch is idempotent. :4394-95 brandHistoryProvider is a different concern, NOT touched. Now writes the uid-scoped key (step 27).  
*קבצים:* `lib/screens/catalog_screen.dart (unchanged)` · `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/recent_dual_write_test.dart (new)` · *בדיקה:* flag OFF: catalog touches exactly as before, card path never mounted; flag ON: card resolve also touches, list identical (idempotent); grep brandHistoryProvider unchanged. · *תלוי:* [46,27]

**48. savedConfigs migration wiring uses the REVERSIBLE sku-correct dual-store (consumes step 30)**  
PATCHED: instead of v2's lossy savedConfigKeysToSkus, wire the flag-ON favorites reader to the reversible additive migration built in step 30 (NEW v2 key, marker-gated, once-only, never runs flag-OFF). The _userTouched guard now lives in saved_configs.dart (step 29).  
*קבצים:* `lib/state/product_favorites.dart (flag-ON v2-key reader)` · `test/state/saved_configs_migration_test.dart` · *בדיקה:* flag OFF: no marker, no migration, v1 byte-identical; flag ON + marker absent: sku-correct merge once + marker set; second launch no re-merge; user toggle before _load preserved. · *תלוי:* [47,30]

**49. P2 single-truth sweep + flag-OFF byte-identity + define-leak guard**  
One save-suite proving the whole P2 state layer flag-OFF byte-identical; wires the three guarded mutations + re-runs the step-38 anchor. CI guard: NO monster dart-define in the live deploy workflows.  
*קבצים:* `test/features/card_keyboard/p2_single_truth_test.dart (new)` · *בדיקה:* flags false: recentlyViewed/savedConfigs/productFavorites identical to baseline (no extra writes/marker/migration); SignalChip equality invisible OFF; step-38 anchor byte-identical; CI guard zero monster defines in the four workflows; full suites green. · *תלוי:* [48]


### P3 entry-surface

**50. Hoist P3/P4/P5 owner UX decisions into decisions.dart**  
const block: kOpeningSurfaceIsSingleMouth=true; kMaxScreen1Decisions=1; kCensusInputsAreCapabilityGated=true. Each with an OWNER-REVIEW comment. No widget/engine code.  
*קבצים:* `lib/features/card_keyboard/decisions.dart` · *בדיקה:* the three consts exist with the stated values, const; doc-presence regex asserts OWNER-REVIEW markers. · *תלוי:* [1]

**51. Pure input-capability census: liveOpeningInputs() excluding dead AI/voice**  
NEW opening_inputs.dart: enum OpeningInput{wordGrid,text,voice,ai}; pure liveOpeningInputs({aiAvailable,voiceAvailable}) always wordGrid+text, conditionally voice/ai. Data-only. Capability read at the CALL site (claudeGatewayProvider!=null; !VoiceService.isWebUnstable && available).  
*קבצים:* `lib/features/card_keyboard/opening_inputs.dart (new)` · *בדיקה:* (false,false)==[wordGrid,text]; (true,true) full 4; wordGrid+text in all 4 combos. · *תלוי:* [50]

**52. Single OpeningSurface widget: word grid + text + mic as INPUT METHODS (no mode buttons)**  
NEW opening_surface.dart: OpeningSurface({wordKeys,onQuery,onMic,showMic,onVoiceUnavailable}). RTL, LayoutBuilder 360/800: one TextField top, WordKeyboard(showUtilityRow:false), trailing mic IconButton. Three input methods one flow, NO segmented control/tab/mode pill. showMic threaded once.  
*קבצים:* `lib/features/card_keyboard/opening_surface.dart (new)` · `lib/features/card_keyboard/card_keyboard_screen.dart` · *בדיקה:* EXACTLY one WordKeyboard, one TextField, ZERO ToggleButtons/TabBar; mic iff showMic; 360px no overflow; flag-OFF screen still SizedBox.shrink. · *תלוי:* [51]

**53. Wire OpeningSurface into CardKeyboardScreen behind kUnifiedFinder; thread capability bools once**  
For CardAskWords render OpeningSurface. Compute capability bools ONCE at mount (late final _aiAvailable, _voiceAvailable). Thread _voiceAvailable->showMic. Self-gate = contains(kUnifiedFinderFlag)||contains(kCardKeyboardFlag). Default both false -> SizedBox.shrink. No child ref.watch.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/card_keyboard/card_keyboard_flag.dart` · *בדיקה:* forceLiveForTest + override claudeGatewayProvider->null: opening renders OpeningSurface, showMic==(!kIsWeb); flags unset -> OpeningSurface empty + SizedBox.shrink; guard: no ref.watch in any OpeningSurface child. · *תלוי:* [52]


### P4 text-voice

**54. synonym_bridge.dart: normalizeQuery() whole-token Hebrew equality + Latin word-boundary**  
PATCHED (R2 major via step 35): NEW synonym_bridge.dart: kQuerySynonyms (alias->canonical) whose canonical VALUES are the distinct kMaterials keys + catalog color/finish strings + everyday-noun aliases (מרפק->ברך). normalizeQuery replaces Latin tokens via word-boundary regex (so 'PP' never fires in 'PPR') but matches HEBREW tokens by WHOLE-TOKEN EQUALITY (Dart \b is ASCII-only — the unicode-\b claim is dropped). Query-time fold distinct from build-time kWordSynonyms.  
*קבצים:* `lib/features/word_finder/synonym_bridge.dart (new)` · *בדיקה:* kQuerySynonyms values superset kMaterials.keys; normalizeQuery('PPR')=='PPR'; normalizeQuery('copper PPR ברז')=='נחושת PPR ברז'; copper==פליז=='נחושת'; מרפק->ברך; idempotent; no Dart \b applied to a Hebrew alias. · *תלוי:* [45,35]

**55. resolveQuery(): material-token -> productsOfMaterial, no-dead-end fallback**  
PATCHED (R2 major via step 35): resolveQuery(raw,lexicon): normalize, tokenize; for each token — if it EQUALS a kMaterials key resolve via productsOfMaterial and UNION (NOT resolveWord, which is empty for נחושת and would dump the whole pool), else resolveWord(token); AND-intersect per-token sets; empty intersection -> UNION fallback (never dead-end); map skus via divePoolBySku preserving order. One funnel for text + mic.  
*קבצים:* `lib/features/word_finder/synonym_bridge.dart` · *בדיקה:* resolveQuery('ברז נחושת') subset resolveQuery('ברז') and non-empty; copper==פליז=='נחושת' resolve to the copper SUBSET (not whole pool); all-unknown -> UNION fallback non-empty; result skus all in divePoolBySku. · *תלוי:* [54,2]

**56. Wire OpeningSurface text field to resolveQuery (debounced, injected scheduler) through _pushStep**  
Fill OpeningSurface.onQuery: debounce via an INJECTED scheduler (default 250ms; tests inject 0). On settle push a NewbieStep (axisLabel:_kOpeningWordAxis, crumbWord:text, predicate skuSet.contains) via _pushStep (covered by the step-19 unified _busy gate). Live 'נמצאו N' count. Empty keeps the surface.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/card_keyboard/opening_surface.dart` · *בדיקה:* forceLiveForTest, 0-debounce: type 'נחושת' -> one step (word axis unanswered), verdict pool subset copper, count==resolveQuery length; fast 3-char burst resolves exactly once (composes with the step-21 text concurrency row); flag-OFF shrink. · *תלוי:* [55,53,19]

**57. Wire mic to VoiceService -> normalizeQuery -> same funnel; hide when unavailable**  
Fill OpeningSurface.onMic guarded on _voiceAvailable: VoiceService.instance.listen(onFinal->_handleQuery, onError honest snackbar, localeId:'he-IL'). onFinal flows through the SAME _handleQuery as text. Refine showMic with the async probe so an unavailable engine hides the mic from BOTH UI and census. _handleQuery routes through the step-19 gate.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/services/voice.dart` · *בדיקה:* fake VoiceService: available delivers 'ברז נחושת' -> identical stack to typing (parity); unavailable hides mic (find==0); web mic hidden; two onFinal back-to-back -> one step (step-21 voice row); flag-OFF unchanged. · *תלוי:* [56]

**58. STRICTLY-GREEDY <=6 census over LIVE inputs, target HIDDEN (uses the feasible harness)**  
PATCHED: NEW opening_census harness for each input in liveOpeningInputs(false,false) and each card in kReachUniverse, run greedyReach (step 15 — single-path, target-blind, mergedKeysMemoized) not an 'exhaustive BFS'. Reach iff within kMaxDiveTurns the <=12 pairwise-distinct cut contains the target. Per-commit on the seeded sample (step 17), full sweep nightly. Unreachable allowlist EMPTY.  
*קבצים:* `lib/test_harness/tests/opening_census.dart (new)` · `test/opening_census_test.dart (new)` · *בדיקה:* every sampled card reached <=kMaxDiveTurns, <=12 cut contains target with pairwise-distinct labels, unreachable allowlist EMPTY; target-blind (mutation: wrong target same chip sequence); executes within the per-commit budget. · *תלוי:* [51,55,56,15,16,17,3]

**59. Text/voice <=6 E2E samples + 1000-input fuzz + naive-mouth acceptance (samples pre-validated)**  
PATCHED (R2 major via step 35): opening_e2e_test drives the real screen for canonical samples through the text field, each converging <=kMaxDiveTurns. A META-TEST asserts every E2E sample resolves to >=1 product BEFORE the convergence assertion (kills the מרפק=zero-hits sample). 1000+ alias/case/whitespace fuzz: no throw, subset divePool, normalizeQuery idempotent. ~20-phrase naive corpus: turns<=budget, screen-1 decision-group count == kMaxScreen1Decisions==1.  
*קבצים:* `test/opening_e2e_test.dart (new)` · `test/opening_naive_acceptance_test.dart (new)` · *בדיקה:* meta-test green (every sample non-empty) THEN each sample <=kMaxDiveTurns to the intended sku; fuzz no-throw + bounded; naive turns<=budget, screen-1==1; flag-OFF re-green of word_finder + fuzzy_search suites. · *תלוי:* [58,50,54,35]


### P5 ai-surface

**60. AI-surface inventory + disposition**  
Doc-as-test enumerating the 3 AI surfaces; ai_finder ABSORBED as the AI input-method; describe_to_cart + ai_assistant stay separate (honest branding). No production edit.  
*קבצים:* `lib/test_harness/tests/ai_surface_inventory.dart (new)` · `test/ai_surface_inventory_test.dart (new)` · *בדיקה:* 3 surfaces listed, each a disposition enum, exactly one (ai_finder) ABSORBED. · *תלוי:* [50]

**61. resolveAiSeed(): literal-first, gateway-optional, promptSafeText, offline-honest**  
PATCHED (R2 major via step 34): NEW ai_seed.dart. AiSeed{literal,categoryHe}. (1) LITERAL FIRST — normalizeQuery then fuzzySearchProducts offline, no model call; (2) only if empty AND gateway!=null call gateway.ask with the closed-set category prompt via aiFinderPrompt/promptSafeText (NO raw text interpolation) -> real categoryHe -> productsInCategory; (3) gateway==null -> const []; ClaudeException RE-THROWN. Never invents a sku.  
*קבצים:* `lib/features/card_keyboard/ai_seed.dart (new)` · *בדיקה:* literal hit resolves OFFLINE (gateway.ask never called); literal-miss + null gateway -> [] no throw; literal-miss + fake gateway -> mapped category real products; throwing gateway propagates ClaudeException; every returned sku in divePoolBySku; code-presence: no raw `text` interpolation, promptSafeText on path. · *תלוי:* [54,2,34]

**62. Wire AI mouth into OpeningSurface as the 4th input method (try/catch handler, flag+capability gated)**  
PATCHED (R2 major via step 34): add a 'תאר לי' chip (rendered when _aiAvailable OR always for the offline literal path). On tap take the text value -> WRAP resolveAiSeed in try/catch showing an honest inline error (never a no-op) -> if non-empty push a NewbieStep via _pushStep (step-19 gate); if gateway==null AND literal empty show 'דורש חיבור' inline. _aiAvailable read once.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/card_keyboard/opening_surface.dart` · *בדיקה:* gateway null: literal-matching text seeds offline, non-matching shows 'דורש חיבור'; fake gateway: semantic phrase seeds the mapped category; a THROWING gateway -> inline error not a dead-end; two chip taps one frame -> one step (step-21 ai row); census (step 58) with aiAvailable:false confirms AI NOT counted; flag-OFF shrink. · *תלוי:* [61,53,19,34]

**63. P5 closure: AI-mouth flag-OFF byte-identity audit + ai_finder/claude_gateway regression**  
Closure audit (no production code): (a) flags OFF -> SizedBox.shrink, zero AI affordance; (b) ai_finder_screen + claude_functions suites pass UNCHANGED; (c) demo default build (gateway==null) degrades to offline-literal-only.  
*קבצים:* `test/opening_ai_closeout_test.dart (new)` · *בדיקה:* three asserts green; ai_finder_screen_test + claude_functions_test byte-green; analyze zero-new; taskkill dart before; retry-wrap load failures. · *תלוי:* [62,60]


### P6 tap-chips

**64. CardSeed pure abstraction with DISTINCT non-empty sentinels**  
NEW card_seed.dart: @immutable CardSeed{mouthId,displayLabel,emoji?,seedPredicate,seedAxisLabel}. seedAxisLabel pairwise-distinct across word/material/job/category AND distinct from _kOpeningWordAxis. Value-equality over scalar fields (predicate excluded). Predicate rebuilt from DATA at the call site.  
*קבצים:* `lib/features/card_keyboard/card_seed.dart (new)` · `test/features/card_keyboard/card_seed_test.dart (new)` · *בדיקה:* four sentinels pairwise-distinct and none==_kOpeningWordAxis; equality holds/differs per scalar field; a constructed predicate over kDivePool non-empty. · *תלוי:* [2]

**65. Word-mouth seed source (top-24 + 'עוד…') over kReachUniverse**  
NEW card_seed_sources.dart: wordSeedsFor(pool) one CardSeed per opening word, predicate = resolveWord(word) sku-set, collapsed take(kFirstWordCount=24), seedAxisLabel=wordSeedAxis.  
*קבצים:* `lib/features/card_keyboard/card_seed_sources.dart (new)` · *בדיקה:* collapsed length==24 when >=24 words; every predicate non-empty; full-set union covers resolveWord skus; no empty-predicate seed. · *תלוי:* [64]

**66. Material-mouth seed source (gate-exempt; copper folds brass; DROP empty)**  
materialSeedsFor(pool): one CardSeed per materialsInPool, predicate = MaterialSignal.matches; seedAxisLabel=materialSeedAxis; material GATE-EXEMPT (seeding doesn't mark the axis answered). Empty-predicate seeds DROPPED.  
*קבצים:* `lib/features/card_keyboard/card_seed_sources.dart` · *בדיקה:* 'נחושת' seed keeps copper+brass, rejects steel-only; material axis stays UNanswered after a material seed; no emitted seed empty over kDivePool. · *תלוי:* [64,41]

**67. Job/recipe-mouth seed source — predicate = union(brands[].sku, main); DROP empty**  
jobSeedsFor(): one CardSeed per kSmartProducts recipe; predicate sku-set = UNION of resolvable SmartBrand.sku + resolved main; empty union DROPPED; seedAxisLabel=jobSeedAxis. assembleKit resolves skus.  
*קבצים:* `lib/features/card_keyboard/card_seed_sources.dart` · *בדיקה:* every emitted seed non-empty; sku-set == union(resolved brands, resolved main), contains main, excludes unrelated; empty-union recipes produce zero seeds; count <= kSmartProducts.length. · *תלוי:* [64]

**68. Category/emoji-mouth seed source covering EVERY card (no orphan)**  
categorySeedsFor(): buckets by finderGroupFor + a fallback bucket so EVERY product lands in >=1 bucket (the step-8/44 raw-categoryHe coverage backs the fallback). One CardSeed per non-empty bucket; category gate-exempt.  
*קבצים:* `lib/features/card_keyboard/card_seed_sources.dart` · *בדיקה:* union of all category-seed predicates over kReachUniverse == 100% distinct cards (via divePoolBySku, not raw sku), ZERO orphan; every emitted bucket non-empty. · *תלוי:* [64,2]

**69. Screen wiring: tap-mouth chrome over WordKeyboard (input-method affordances, flag-gated byte-identical)**  
Seed-chrome row ABOVE WordKeyboard on the opening turn only (stack.isEmpty); tapping a seed pushes ONE seedStep via _onWordTap's _pushStep path (step-19 gate) with a typed _SeedTap. Chrome DISAPPEARS after a seed/word tap (not a persistent mode toggle). Guarded behind the mount-once _live bool, threaded. Flag-OFF byte-identical.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · *בדיקה:* flag-OFF SizedBox.shrink; flag-ON opening turn 4 seed affordances; tapping 'material' pushes one step, material axis stays UNanswered; chrome absent after a tap and OFF; existing screen golden unchanged OFF. · *תלוי:* [65,66,67,68]

**70. 'עוד…/פחות' word-mouth toggle (render-only, never seeds)**  
_wordsExpanded bool toggling collapsed top-24 vs full wordSeeds; ONLY changes which seeds render, never pushes a step. Flag-gated; OFF unchanged.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · *בדיקה:* 'עוד…' -> rendered word-seed count == full length; 'פחות' -> back to 24; neither changes stack. · *תלוי:* [65,69]

**71. STRICTLY-GREEDY no-typing browse census (<=kMaxDiveTurns, target HIDDEN)**  
PATCHED: NEW browse_census.dart browseReach() proves EVERY distinct card reachable in <=kMaxDiveTurns using ONLY category/emoji seeds + tap dives (no text), via greedyReach (step 15 — single-path target-blind memoized), NOT 'exhaustive BFS'. Reach iff a hidden walk lands the target in a ShowProducts cut by kListThenPickTurn and it survives. Per-commit seeded sample / nightly full (step 17).  
*קבצים:* `lib/features/card_keyboard/browse_census.dart (new)` · `test/features/card_keyboard/browse_census_test.dart (new)` · *בדיקה:* browseReach sampled reachedCount over the sample, unreachedAllowlist EMPTY; injected fabricated-unreachable card -> RED; guard: walk never receives the target as a selection input; nightly runs full kReachUniverse. · *תלוי:* [68,69,15,16,17,2,3]

**72. Seed-source determinism/purity fuzz + distinct-axis + flag-OFF byte-identity checkpoint**  
Property test: all four seed sources shuffle-stable, pure, zero empty-predicate seeds; every seedAxisLabel one of the four sentinels; material+category keep their axis UNanswered. Plus flag-OFF byte-identity vs pre-P6 baseline.  
*קבצים:* `test/features/card_keyboard/card_seeds_invariants_test.dart (new)` · *בדיקה:* shuffle 50 -> identical output incl order; flag-OFF screen render == baseline (SizedBox.shrink); full suite green; taskkill dart before; retry-wrap. · *תלוי:* [65,66,67,68,70,71]


### P7 merged-brain

**73. PoolSeed contract + seedPool() unified funnel (public kOpeningSeedAxis)**  
In card_engine.dart add PoolSeed + seedPool(pool,PoolSeed) applying a predicate and returning the narrowed pool; expose const kOpeningSeedAxis. seedPool preserves sku identity. PURE.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · *בדיקה:* seedPool keeps exactly the matching skus; kOpeningSeedAxis non-empty and distinct from every hard-axis name; seedPool(kDivePool, all-true)==kDivePool. · *תלוי:* [69,64]

**74. All seeders over the SAME pool (text/material/facet/sku/AI)**  
In card_seed_sources.dart add seedFromText/Material/FacetSubtype/Skus, each a PoolSeed over the SAME pool. Multi-word text = UNION of resolveWord results; all-unknown -> null. Reuse existing predicates, no new matching.  
*קבצים:* `lib/features/card_keyboard/card_seed_sources.dart` · *בדיקה:* seedFromText('ברז נחושת')==union of the two resolutions (non-empty); seedFromText('zzz')==null; seedFromSkus keeps exactly those; all four go through seedPool identically. · *תלוי:* [73]

**75. Pre-restructure golden: populate info-gain, order UNCHANGED**  
Populate SignalChip.infoGain = n - distinctCardCount(narrowed) WITHOUT changing layout/order; re-bless the flag-ON golden byte-identical to the post-P1 golden. Isolates 'numbers populated' from 'order changed'.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/merged_golden.txt` · *בדיקה:* every emitted chip infoGain>0; _mergedChips ORDER over a fixed pool byte-identical to pre-change golden. · *תלוי:* [45,46]

**76. Unify info-gain scoring across all 5 axes incl. material (behavior-preserving)**  
Extract _scoreAxis(src,pool) shared by every axis so material is not a special branch (it scores on the FULL pool with its carry-along predicate). Behavior byte-identical to step 75.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · *בדיקה:* golden identical to step 75; material scored via the SAME _scoreAxis (same denominator n=distinctCardCount(pool)). · *תלוי:* [75]

**77. Per-axis top-K-by-gain (golden changes ON PURPOSE) + <=6 re-confirm**  
Replace positional take with per-axis SCORED top-K. SIZE/ANGLE keep representativeTake (endpoints). Re-bless the new golden — the only step where merged-row order intentionally moves. The hard <=6 turn-gate (step 78) re-runs and still passes.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/merged_golden.txt` · *בדיקה:* new golden blessed + diff note; size/angle rows still include global min AND max; the <=6 turn-gate re-runs and passes. · *תלוי:* [76]

**78. Screen wiring: every mouth dives through seedPool / card_seed (free-text seam)**  
Route _onWordTap's _WordTap and the new _SeedTap through seedFromSkus / typed seed constructors so a free-text or tap entry pushes ONE seedStep through the SAME funnel (and the step-19 gate). Flag-gated; OFF unchanged.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · *בדיקה:* typing/tapping a seed pushes exactly ONE step; a word entry and the equivalent sku-seed yield the SAME narrowed verdict (parity); flag-OFF unchanged. · *תלוי:* [73,74]

**79. HARD <=6 turn-gate: list-then-pick, ShowProducts by turn 5 (enforcement only)**  
Enforcement using kMaxDiveTurns/kReachListCap (NOT a new declaration): the dive MUST reach a CardShowProducts whose list <=12 by turn <=5; assert <=kReachListCap entries AND pairwise-distinct labels.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · *בדיקה:* across canonical journeys a CardShowProducts(1<list<=12) appears by turn 5; labels pairwise-distinct AND <=12; a 13-item list goes RED. · *תלוי:* [77,3]

**80. STRICTLY-GREEDY merged-brain <=6 census: HIDDEN-target, target-survives-the-cut**  
PATCHED: card_brain_contract_test proves EVERY distinct card has a <=6 path via greedyReach (step 15 — single greedy walk, target-blind, mergedKeysMemoized) NOT 'exhaustive BFS'. Success iff a hidden walk produces a <=12 cut by turn<=5 containing the target. Count via collapseKeyOf (step 9), per-commit seeded sample / nightly full. offenders allowlist EMPTY.  
*קבצים:* `test/features/card_keyboard/card_brain_contract_test.dart (new)` · *בדיקה:* sampled reachedCount, offendersAllowlist EMPTY; guard: walk never receives the target as a selection input; injected always-unreachable fixture -> RED; denominator via collapseKeyOf == kReachUniverse unit. · *תלוי:* [78,79,9,15,16,17,2,3]

**81. Live-mouth gating of the <=6 census (exclude build-dead AI/voice)**  
browse_census + card_brain_contract restrict counted mouths to those LIVE in the demo build (text+word-grid+tap live; AI/voice excluded when capability absent via liveOpeningInputs).  
*קבצים:* `test/features/card_keyboard/card_brain_contract_test.dart` · `test/features/card_keyboard/browse_census_test.dart` · *בדיקה:* with AI/voice probed-absent the census still reaches the sample via live mouths alone; toggling the AI probe off doesn't change the verdict. · *תלוי:* [80,71,51]

**82. Merged-brain regression + analyze drift + flag-OFF checkpoint**  
Run full card_keyboard + word_finder suites + analyze; assert flag-OFF byte-identical to the step-38 anchor. No production mutation in P7.  
*קבצים:* `test/features/card_keyboard/` · *בדיקה:* all green + analyze zero-new; flag-OFF screen render == baseline; taskkill dart before; retry-wrap. · *תלוי:* [80,81]


### P8 hop-graph

**83. hop_graph adjacency from EdgeKind-tagged real edges (DIRECTED, product-nodes only, crossesSystem-filtered)**  
PATCHED: build directed rankedNeighborsOf by UNIONING the real tagged edges (compat/variant/kit/category) over node-set==kDivePool keys, NO virtual nodes. Edges crossing a WaterSystem boundary EXCLUDED from compat/kit via crossesSystem (step 13 — the EXISTING productSystems(), not the false _reallyMates assumption).  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_test.dart` · *בדיקה:* node-set==divePoolBySku.keys (HW- present); every edge EdgeKind-tagged; NO compat/kit edge crosses a single-system boundary (composes with step 13's exhaustive test); zero virtual nodes. · *תלוי:* [5,6,7,8,13]

**84. Diameter/isolation spike: measure CURRENT directed all-pairs BFS before hubs**  
Pure hopMetrics(): DIRECTED BFS measuring diameter, worstPair, isolatedCount on the RAW edge graph. Measurement, not assumption.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_test.dart` · *בדיקה:* hopMetrics returns {diameter,worstPair,isolatedCount}; printed as design input; internal consistency (isolatedCount<=nodes; worstPair distance==diameter); no <=4 claim yet. · *תלוי:* [83]

**85. 1-adjacent multi-superHub STAR backbone (every hub EXACTLY 1 from a superHub)**  
PATCHED (R2 major step 62 isolate): superHub selection + hub assignment so the construction is honestly <=4: per-WaterSystem real-product superHubs; every other product a hub-leaf at distance EXACTLY 1 from >=1 superHub via a real tagged edge; superHubs mutually 1-adjacent; out-degree <= kNeighborBudget. The step-8/68 raw-categoryHe catch-all guarantees every product has >=1 category edge BY CONSTRUCTION, so the real isolate set (compat==kit==variant=={} AND no category) is empty before superHub assignment. Backbone edges are REAL rankedNeighborsOf edges.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_test.dart` · *בדיקה:* every non-superHub has >=1 real edge to a superHub at distance EXACTLY 1; every superHub pair distance EXACTLY 1; out-degree <= kNeighborBudget; the REAL isolate set (enumerate every sku where compat==kit==variant=={}) is covered by a category edge; unreachableCount==0; RED self-test removing one hub->superHub edge. · *תלוי:* [84,8,1]

**86. forceLive test seam on LipskeyProductSheet**  
Add forceLive bool (mirroring forceLiveForTest) so the flag-gated hop UI can be exercised without seeding the runtime flag. Read the mount-once flag bool ONCE; forceLive ORs it. No production behaviour when false.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · *בדיקה:* forceLive=false -> no hop rail/history (byte-identical); forceLive=true -> the flag-gated region builds; flag read exactly once (no per-build child ref.watch). · *תלוי:* [83]

**87. Product-hop history stack (_hopHistory) behind flag; dual-path with _chipOverride**  
Add _hopHistory (List<sku>) driving the in-place switch + one-product back WHEN ON. Existing _chipOverride + _switchByChip remain the flag-OFF path UNTOUCHED (DUAL-PATH). _switchByChip carries the step-20 _hopBusy guard and is cleared by the step-24 uid listener. No deletion of _chipOverride.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · *בדיקה:* flag-OFF -> _chipOverride drives switching, _hopHistory inert, render byte-identical; flag-ON (forceLive) -> 2 hops then back returns; flag-OFF widget tree == pre-P8 baseline. · *תלוי:* [86,20,24]

**88. Route the connections carousel through in-place hop (no recursive sheet), flag-gated**  
When ON the carousel onTap calls in-place _switchByChip/_hopHistory instead of a recursive showLipskeyProductSheet. OFF keeps the recursive open byte-identical.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · *בדיקה:* flag-ON tap -> NO second sheet (Navigator depth unchanged), product switches in place; flag-OFF -> recursive sheet still opens; two same-frame carousel taps -> one switch (step-20 _hopBusy + step-21 rail row). · *תלוי:* [87]

**89. Always-visible 'קשור' rail = SUPERSET of proof-edges in an UNBOUNDED sub-rail**  
Flag-gated 'קשור' rail driven by rankedNeighborsOf(currentSku). MUST be a SUPERSET of the proof-edges; the backbone hub/superHub proof-edges render in a DEDICATED UNBOUNDED sub-rail (no top-K truncation) so the constructive <=4 path is always tappable. Flag-OFF rail absent.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · *בדיקה:* for sampled products every proof-edge appears as a tappable chip in the proof sub-rail (proofEdges subset railChips); sub-rail NOT length-capped; flag-OFF no rail. · *תלוי:* [87,85]

**90. 'חזרה' lands on the merged row + breadcrumb; opening a sheet does NOT clear the hop stack**  
Wire X/back to pop _hopHistory + render the hop-path breadcrumb; opening a sheet doesn't reset the stack. Flag-gated; OFF unchanged.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · *בדיקה:* after A>B>C, back -> B -> A (breadcrumb shrinks); opening a sheet mid-path preserves _hopHistory; flag-OFF no breadcrumb. · *תלוי:* [87,88]

**91. HONEST <=4 census: single-source directed depth-4 BFS over the TAPPABLE rail; allowlist EMPTY; no cross-WaterSystem**  
PATCHED: hop_reach_test proves <=4 via the single-source reachWithin4 per node (step 16) over the ACTUAL tappable rail edges (rankedNeighborsOf, what the UI renders), asserting relatedTargetsOf(src) subset reachWithin4(src) for every src (union-of-unreachable-related-pairs EMPTY) — NOT |U|^2 all-pairs. '<=4 to a RELATED product over the tagged graph', no cross-WaterSystem path. over4Allowlist + kHopPairOverride EMPTY.  
*קבצים:* `test/features/card_keyboard/hop_reach_test.dart` · *בדיקה:* for src in divePoolBySku.keys relatedTargetsOf(src).difference(reachWithin4(src)).isEmpty; over4Allowlist+kHopPairOverride EMPTY; every reached q !crossesSystem; structural: exactly divePoolBySku.length BFS calls; wall-clock budget; RED self-test deleting a superHub<->superHub edge. · *תלוי:* [85,89,16,12,2]

**92. Neighbor rail never empty (no dead-end product), incl. all hot-water skus**  
Guarantee rankedNeighborsOf(sku).length >= kMinNeighbors for EVERY product (fallback through superHub/variant-family/category when compat/kit sparse). Pure helper.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_graph_test.dart` · *בדיקה:* for EVERY sku (incl the 81 HW-) rankedNeighborsOf(sku).length >= kMinNeighbors (enumerate all, zero dead-ends). · *תלוי:* [85,89]

**93. Reconcile hopsBetween() onto the ONE canonical rail graph (no third graph)**  
Re-point any hopsBetween()/soft-suggestion path (and the P9 'מה מתחבר' rail) to BFS over the SAME rankedNeighborsOf adjacency as steps 89/91 — exactly ONE hop graph.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · *בדיקה:* hopsBetween(a,b) for sampled pairs AGREES with the step-91 reachWithin4 census; guard: only rankedNeighborsOf is the graph source. · *תלוי:* [91,92]

**94. Real EXECUTABLE .sh gate for the hop region: single-source <=4 + greedy <=6 + RED self-test + define-leak guard**  
PATCHED: scripts/verify_unified_finder.sh (BASH, modeled on mutation_verify.sh) EXECUTES flutter test on the single-source <=4 census (step 91) AND the greedy hidden-target <=6 censuses (steps 71/80/81), running heavy censuses at --concurrency=1 wrapped in the step-37 load-retry, fails on any over-4/over-6, and a SELF-TEST injects a fabricated >4 pair + a 13-item/turn-7 path asserting RED. Greps the live workflows for any monster dart-define.  
*קבצים:* `scripts/verify_unified_finder.sh (new, executable)` · `test/features/card_keyboard/hop_reach_test.dart` · `test/features/card_keyboard/card_brain_contract_test.dart` · *בדיקה:* exit 0 clean; injected >4 OR >6 -> non-zero; workflow-leak guard non-zero if a monster define added to a fixture copy; heavy censuses at concurrency=1 in the retry wrap; taskkill dart before; retry-wrap load failures only; never tail. · *תלוי:* [91,71,80,81,37]

**95. Flag-OFF byte-identity checkpoint for the entire hop region**  
Audit gates over steps 87-90: flag OFF -> no rail/breadcrumb/_hopHistory effect, byte-identical to the pre-P8 baseline; _chipOverride path exactly as before.  
*קבצים:* `test/screens/` · `test/features/card_keyboard/hop_graph_test.dart` · *בדיקה:* full word_finder + screens suites green + analyze zero-new; flag-OFF sheet widget tree == pre-P8 baseline; taskkill dart before; retry-wrap. · *תלוי:* [88,89,90,93,94]


### P9 hidden-signals

**96. softTilt() reconciled: bias via history/kit/compat SET-overlap (NOT anchorOf), live on the wide merge pool**  
PATCHED (R2 BLOCKER #7): card_soft.dart documents that during a merged-keys turn distinctCardCount>kShowProductsThreshold so anchorOf is ALWAYS null -> anchor-keyed softTilt is INERT. RECONCILE: softTilt(chip,{historySkus,kitSkus,compatSkus}) returns [1.0,1.6], 1.0 ONLY when none of the three sets overlap the chip's member skus — a DIFFERENT mechanism than anchorOf, LIVE on the wide pool the merge actually reaches. Keep card_soft's anchorOf/softSuggestionsFor for the resolution layer. softTilt does NOT call anchorOf.  
*קבצים:* `lib/features/card_keyboard/card_soft.dart` · `test/features/card_keyboard/card_soft_tilt_test.dart (new)` · *בדיקה:* softTilt(any,{},{},{})==1.0 (overlapless inert); on a WIDE pool (distinctCardCount>12) a chip overlapping seeded historySkus returns >1.0 and <=1.6 (non-inert where the merge runs); monotone; deterministic; grep-guard softTilt body references the three sets, never anchorOf. · *תלוי:* [2,77]

**97. kitSkusFor/compatSkusFor adapters + softAnchor near-converge guard (reuse verified engines)**  
In card_soft.dart add kitSkusFor(sku) (-> assembleKit skus) and compatSkusFor(sku) (-> the verified connectionsFor/install_engine neighbour set softSuggestionsFor already uses — REUSE). softAnchor(pool) returns the dominant sku ONLY when pool.length in 2..kNearConverge, else null.  
*קבצים:* `lib/features/card_keyboard/card_soft.dart` · `test/features/card_keyboard/card_soft_tilt_test.dart` · *בדיקה:* softAnchor(kDivePool)==null; over a 3-product pool returns a sku in that pool; kitSkusFor(smart-sku) non-empty, every sku in divePoolBySku; compatSkusFor(x)==the verified connectionsFor neighbour set (parity). · *תלוי:* [96]

**98. One soft module: card_engine imports card_soft.softTilt; build the tilted golden from a REAL seeded run (REPLACES the orphan soft_tilt.dart)**  
PATCHED (R2 BLOCKER #7): card_engine.mergedKeys multiplies each chip's baseWeight by card_soft.softTilt(chip,history,kit,compat) BEFORE the per-axis top-K, where the three sets arrive as NEW OPTIONAL params defaulting to const {} (existing callers + flag-OFF byte-identical). Tilt re-orders WITHIN an axis only. Build card_merged_tilted.json from a REAL seeded run (BUILDABLE now that softTilt is live on the wide pool). NO second soft_tilt.dart file — assert exactly one soft module imported.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/card_engine_golden_test.dart` · `test/golden/card_merged_48.json (unchanged)` · `test/golden/card_merged_tilted.json (new)` · *בדיקה:* mergedKeys with no soft params == step-77 golden (inert path); with seeded historySkus order matches card_merged_tilted.json AND the (axisId,value) SET equals the inert run (order-only); guard: card_engine imports card_soft and NO soft_tilt.dart exists; mutation_verify.sh on the multiply site goes RED on the tilted golden. · *תלוי:* [96,97]

**99. WordKey destination via the EXISTING axisGlyph seam (no colliding isDestination field) — REPLACES v2 step 70**  
PATCHED (R2 BLOCKER #6 reconcile): word_keys_model.dart already declares semanticLabel + axisGlyph (rendered by BsKey _content:204-213 / _semanticLabel:288). Do NOT add a SECOND bool isDestination. For a DESTINATION word-key set axisGlyph:Icons.north_east (same field/render path as the prediction-chip glyph fixed in step 119). card_engine emits the glyph only in the near-converge band; wide pool sets none. This supersedes v2 step 70's redundant field.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/card_keyboard/card_engine.dart` · `test/features/card_keyboard/word_key_destination_seam_test.dart (new)` · *בדיקה:* near-converge verdict -> >=1 WordKey with axisGlyph==Icons.north_east; wide pool -> zero; existing word_keyboard tests green (no new field/constructor break); grep-guard NO 'isDestination' symbol added to word_keys_model.dart; flag-OFF screen SizedBox.shrink. · *תלוי:* [119,98]

**100. Tag near-converge chips as DESTINATIONS (render-only) + thread through the screen**  
PATCHED: card_engine emits SignalChip.isDestination=true ONLY for chips whose softAnchor pool is in the near-converge band (render hint, NEVER routing). _keysFor maps it onto the WordKey axisGlyph seam (step 99), not a new button. A wide pool emits ZERO destination chips.  
*קבצים:* `lib/features/card_keyboard/card_engine.dart` · `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/card_destination_wiring_test.dart (new)` · *בדיקה:* mergedKeys over kDivePool (wide) yields no chip isDestination==true; a near-converge stack yields >=1; _keysFor threads the flag (near-converge verdict builds keys with the north_east axisGlyph); flag-OFF screen SizedBox.shrink. · *תלוי:* [97,98,99]

**101. Identity-scoped history seam -> engine (recentlyViewed via currentUidProvider), no cross-identity leak**  
NEW historySkusProvider in card_keyboard_state.dart: Provider.autoDispose<Set<String>> reading recentlyViewedProvider scoped by ref.watch(currentUidProvider); uid==null -> global list; uid change rebuilds empty. CardKeyboardScreen reads it ONCE and threads the Set to mergedKeys (step 98 param). Do NOT make recentlyViewedProvider itself a family (live :6261 reader untouched).  
*קבצים:* `lib/features/card_keyboard/card_keyboard_state.dart` · `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/card_history_identity_test.dart (new)` · *בדיקה:* empty recentlyViewed -> historySkusProvider=={} -> mergedKeys == inert golden; populate under A, flip to B -> B does NOT contain A's skus; uid==null returns the global list; flag-OFF screen never reads it. · *תלוי:* [98,1]

**102. Soft-suggestions rail in the card sheet (compat∪kit) over the P8 canonical graph — flag-OFF absent**  
In lipskey_product_sheet.dart add a 'מה מתחבר לזה' rail driven by rankedNeighborsOf(sku) (the P8 graph, NOT a fresh traversal) UNION kitSkusFor(sku). Tap -> _switchByChip (step-20 _hopBusy + step-24 uid listener). Whole rail behind kCardKeyboardFlag||kUnifiedFinder.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `test/features/card_keyboard/card_soft_rail_test.dart (new)` · *בדיקה:* flag ON -> >=kMinNeighbors rail chips, every chip-sku in rankedNeighborsOf∪kitSkusFor (no off-graph suggestion); tapping calls the in-place hop (no second sheet); flag-OFF rail absent. · *תלוי:* [96,97,89,87]

**103. hopsBetween() reconciled to the ONE canonical rail graph (directed) — no third graph**  
Implement hopsBetween(a,b) in hop_graph.dart as a DIRECTED BFS over the SAME adjacency the <=4 census uses (call into the shared adjacency, no separate map). hopsBetween did NOT exist in word_finder_engine (verified 0 matches) — a genuine new build here.  
*קבצים:* `lib/features/card_keyboard/hop_graph.dart` · `test/features/card_keyboard/hop_between_canonical_test.dart (new)` · *בדיקה:* for sampled related pairs hopsBetween(a,b)==BFS distance over the step-91 census adjacency; an unrelated cross-WaterSystem pair returns unreachable (null/inf), NOT a fabricated <=4; guard: no second adjacency Map constructed (references the shared kHopAdjacency symbol). · *תלוי:* [96,91,89]

**104. Soft-signal isolation + inert-in-merge regression net; flag-OFF == baseline**  
card_soft_invariants_test asserting the WHOLE P9 layer is order-only + identity-safe: softTilt re-orders only within an axis (never adds/removes a chip, never crosses axes); destinations render-only; history identity-scoped (the three sets passed in, never global -> no cross-identity leak in ordering). Run full suite + analyze; flag-OFF byte-identity to the step-38 baseline.  
*קבצים:* `test/features/card_keyboard/card_soft_invariants_test.dart (new)` · `test/features/card_keyboard/card_engine_golden_test.dart` · *בדיקה:* invariants green; analyze zero-new; flag-OFF mergedKeys == step-38/77 golden; PROPERTY: for 200 random pools the chip SET from mergedKeys(...softParams) == the set from mergedKeys(...emptyParams) (order-only); feeding A's then B's historySkus changes order but never surfaces A's skus as B's chips. · *תלוי:* [98,100,101,103]


### P10 terminus

**105. CardPick model + identity-scoped cardPicksProvider (autoDispose family on uid + logout-wipe)**  
NEW card_picks.dart: CardPick(sku,label) value-equality on sku; cardPicksProvider StateNotifier.autoDispose scoped by ref.watch(currentUidProvider); uid==null one shared bucket; addPick dedups, canCompleteLine==picks.length>=2. The logout/identity wipe is the FLAG-GATED ref.invalidate registered in step 31 (NOT an ungated read().clear()).  
*קבצים:* `lib/features/card_keyboard/card_picks.dart (new)` · `test/features/card_keyboard/card_picks_test.dart (new)` · *בדיקה:* addPick twice same sku -> length 1, order preserved; canCompleteLine false at 1, true at 2; picks under A absent after flip to B; step-31 wipe empties picks on the stream transition (flag-ON); uid==null one shared list. · *תלוי:* [2,31,101]

**106. planLineFromPicks adapter — RETURNS LinePlanResult{plan,unresolvedSkus}, depth 4, mutable accessories**  
NEW line_planner.dart: LinePlanResult{plan,unresolvedSkus,resolvedAnchors}. (1) resolve each pick.sku via kCompatCatalog; any sku NOT in kCompatCatalog -> unresolvedSkus (NEVER dropped; ~48% off-corpus). (2) buildInstallation(resolvedAnchors, maxDepthPerSegment:4, accessories:<MUTABLE Set>, autoCompliance:true). (3) Fold an anchor that ended in an InstallationGap into unresolvedSkus.  
*קבצים:* `lib/logic/line_planner.dart (new)` · `test/features/card_keyboard/line_planner_test.dart (new)` · *בדיקה:* a Polyroll/Huliot-only pick appears in unresolvedSkus and is ABSENT from plan.items; two compat anchors -> both in plan.items, unresolvedSkus empty; engine called with maxDepthPerSegment==4 (spy); accessories Set mutated by _autoAddCompliance (HW-CLIP/HW-SEALANT present). · *תלוי:* [105,2]

**107. Contract-test freezing buildInstallation's public signature**  
install_engine_signature_test pinning buildInstallation/buildTreeInstallation signatures (maxDepthPerSegment, tempC, accessories Set<String>, loop, autoCompliance; InstallationPlan items/gaps/quantities/zones). A future default/param change fails this test, protecting the depth-4 + mutable-accessories assumptions.  
*קבצים:* `test/install_engine_signature_test.dart (new)` · *בדיקה:* green; calls buildInstallation with maxDepthPerSegment:4, mutable accessories, autoCompliance:true; asserts InstallationPlan shape non-throwing; pins the depth-4 call shape not the legacy depth-6 default. · *תלוי:* [106]

**108. Temp + auto-compliance wired into the line (install_studio capability absorbed)**  
Thread lineMaxTempProvider into planLineFromPicks; surface lineComplianceChecklist in the line-result sheet. autoCompliance:true inserts PRV/expansion/ball-valve/TMTV via _autoAddCompliance — the studio's safety capability reachable WITHOUT opening the studio. Behind the unified flag.  
*קבצים:* `lib/logic/line_planner.dart` · `lib/screens/lipskey_product_sheet.dart` · `test/features/card_keyboard/line_planner_compliance_test.dart (new)` · *בדיקה:* a hot supply line (tempC:60) yields auto-added HW-PRV-34 + expansion vessel in plan.items, criticalOpen==0 (parity with the studio _assemble path, same SKUs); cold line adds none; flag-OFF line section absent. · *תלוי:* [106]

**109. 9->1 scope DECISION in decisions.dart: absorb tree-mode OR honestly rebrand — pick ONE, prove no capability lost**  
Resolve install-studio scope as a CONSTANT kInstallStudioDisposition (owner-signed, hoisted before P1; the BUILD of the chosen branch lands here). Option A (absorb): planLineFromPicks detects a manifold anchor (manifoldOutlets>0) and routes through buildTreeInstallation(maxDepthPerSegment:4, mutable accessories, autoCompliance:true). Option B (rebrand): decisions records 'one finder + FLAT line; studio = separate tree workbench' and the studio pill is KEPT at cut-over. Build exactly one branch.  
*קבצים:* `lib/features/card_keyboard/decisions.dart` · `lib/logic/line_planner.dart` · `test/features/card_keyboard/line_branch_scope_test.dart (new)` · *בדיקה:* if absorbTree: a manifold + 2 targets produces a tree plan (גזע + ענף א/ענף ב) with unresolvedSkus still reporting off-corpus; if rebrandFlat: studio pill remains routable post-cut-over (step 117 does NOT hide 'תכנון חיבור') and the const is the single source; either way NO capability silently vanishes. · *תלוי:* [108,1]

**110. Converge->card records the pick (addPick before opening the sheet)**  
In _onWordTap (_ProductTap) and _pushStep's CardResolve branch call addPick(CardPick(sku,label)) BEFORE showLipskeyProductSheet. Reads currentUidProvider once (threaded). The _ProductTap open carries the step-20 _busy gate. Additive; flag-OFF screen shrink so no pick is recorded off-flag.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/card_converge_records_pick_test.dart (new)` · *בדיקה:* forceLiveForTest, openSheetOnResolve:false: a ShowProducts product tap adds the sku; a second distinct product -> 2 picks; same product twice -> 1 (dedup); flag-OFF screen shrink, cardPicks empty. · *תלוי:* [105,109,20]

**111. Between-products rail + <=12 'פשוט בחר' exit, sourced from the canonical hop graph**  
_BetweenRail showing rankedNeighborsOf(currentSku) capped at 6 (the canonical P8 graph, REUSE step 102's rail), title 'בחר מתוך N'. ShowProducts terminus capped at <=12. Tap -> in-place hop (_hopHistory, step-20 _hopBusy). Behind the unified flag.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `test/features/card_keyboard/between_rail_test.dart (new)` · *בדיקה:* rail shows <=6 chips each in rankedNeighborsOf(currentSku); a ShowProducts verdict never renders >12 keys; tapping performs an in-place hop (Navigator depth unchanged, _hopHistory +1); two same-frame taps -> one hop (step-21 rail row); flag-OFF rail absent. · *תלוי:* [110,103,102]

**112. Add-to-line + Complete-line chip (>=2) -> planLineFromPicks -> BOM that SURFACES unresolvedSkus**  
Add 'הוסף לקו' (addPick) + _CompleteLineChip gated on canCompleteLine. On tap planLineFromPicks -> BOM: items+quantities, auto-compliance safety items, plan.gaps, AND a LOUD 'לא נמצאו במאגר ההתקנה: …' section listing unresolvedSkus + 'הוסף הכל לסל' for resolvable items only. The unresolved set MUST be visible.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `lib/state/smart_cart.dart` · `test/features/card_keyboard/card_line_bom_test.dart (new)` · *בדיקה:* 2 compat picks -> chip enabled -> BOM lists both + quantities>0 + (if hot) safety items, unresolved empty; 1 compat + 1 Polyroll-only -> BOM lists the compat item AND the unresolved section names the Polyroll sku; <2 picks -> chip disabled; 'הוסף הכל לסל' adds only resolvable skus. · *תלוי:* [106,110,111]

**113. Converge->line E2E + flag-OFF/identity regression; engine suites green**  
E2E: opening -> ShowProducts -> 2 product taps -> complete-line chip -> planLineFromPicks -> BOM with both. Plus flag-OFF the whole P10 surface shrink/absent; identity flip (stream path) wipes picks mid-flow (composes with step 25/31). Run install_engine/build_line_bom/auto_compliance suites.  
*קבצים:* `test/features/card_keyboard/card_converge_to_line_e2e_test.dart (new)` · `test/build_line_bom_test.dart` · `test/auto_compliance_test.dart` · *בדיקה:* E2E green end-to-end; flag-OFF byte-identity (shrink, no picks/rail); flipping currentUidProvider mid-flow via the stream empties cardPicks; install_engine_safety_test + build_line_bom_test + auto_compliance_test pass; analyze zero-new. · *תלוי:* [109,112,25]


### P11 cut-over

**114. Routing scaffold — kUnifiedFinder superset + _forcedOnFlags reconciliation + GATING TABLE + pill_routing**  
PATCHED (R2 major step 85): const kUnifiedFinderFlag + build-twin kEnableUnifiedFinderDemo. kUnifiedFinder is a derived SUPERSET (isOn(kUnifiedFinder) implies kCardKeyboard branches); NOT in _forcedOnFlags; ENABLE_UNIFIED_FINDER in NO live workflow. RECONCILE the existing kCardKeyboard-in-_forcedOnFlags (feature_flags.dart:73-75): add a GATING TABLE comment mapping all 5 gates (kCardKeyboardFlag runtime, kEnableCardKeyboardDemo build-const, kUnifiedFinderFlag runtime, kEnableUnifiedFinderDemo build-const, forceLiveForTest) to {build|runtime|test}×{what it enables}; either remove kCardKeyboard from _forcedOnFlags or document the superset getter ORs both consts. NEW pill_routing.dart: total map of the 9 tool-labels -> UnifiedRole. Inert scaffold.  
*קבצים:* `lib/features/card_keyboard/unified_finder_flag.dart (new)` · `lib/state/feature_flags.dart` · `lib/features/card_keyboard/pill_routing.dart (new)` · `test/unified_finder_flag_test.dart (new)` · `test/pill_routing_test.dart (new)` · *בדיקה:* default build -> isOn(kUnifiedFinder)==false, byte-identical; isOn(kUnifiedFinder)==true implies the card-keyboard predicate true; kUnifiedFinder NOT in _forcedOnFlags; the GATING TABLE comment maps all 5 flags; pill_routing total (9 labels -> exactly one role, no extra keys). · *תלוי:* [113,94,104,109]

**115. Entry surface — UnifiedFinderEntry routed from catalog body when ON, byte-identical OFF**  
NEW UnifiedFinderEntry = CardKeyboardScreen spine + the unified text input. In _CatalogBody.build: when isOn(kUnifiedFinder) route מאתר/מאתר חכם/מקלדת חכמה to UnifiedFinderEntry; OFF keeps the existing per-pill routing (:2452-2473) byte-identical. Independently revertable.  
*קבצים:* `lib/features/card_keyboard/unified_finder_entry.dart (new)` · `lib/screens/catalog_screen.dart` · `test/unified_entry_routing_test.dart (new)` · *בדיקה:* flag OFF -> 'מאתר חכם' still returns WordFinderHome (byte-identical to :2457); flag ON -> UnifiedFinderEntry; the single input resolves 'נחושת' to a seeded dive (parity with _WordTap); existing catalog widget tests green OFF. · *תלוי:* [114]

**116. Completeness 9->1 — absorb _SearchBar/barcode/AiFinder-fallback; seed-path or honestly drop smart-tree/variants**  
When ON the unified input also carries: (1) the barcode scan button (reuse openBarcodeScanner — a scanned SKU opens the card directly); (2) an AI tail-escape AiFinderScreen.route(initialQuery:q) when the local dive is empty, NOT a separate pill. smart-tree + variants get a SEED PATH into the unified dive via card_seed; if a clean seed can't be built, DROP them from the '9 absorbed' count in decisions.dart (honest) and keep their pills. Voice already routes to the same input. No mode-button.  
*קבצים:* `lib/features/card_keyboard/unified_finder_entry.dart` · `lib/features/card_keyboard/decisions.dart` · `test/unified_completeness_test.dart (new)` · *בדיקה:* ON -> a scanned known SKU opens the product card; an empty-result query surfaces the AI tail-escape; smart-tree/variants seed a non-empty dive OR a decisions const lists them 'kept separate, not counted' (count matches reality); the input has no 'search by X' toggle. · *תלוי:* [115]

**117. Pill re-home — PURE render-time hide (NO persisted write); reset catalogSectionProvider; KEEP studio iff rebrandFlat; smart_home byte-identity**  
PATCHED (R2 major step 88): when ON route per pill_routing — קטגוריות/עץ-חכם/וריאנטים -> a LensSelectorRow shown AFTER a result; מועדפים/חיפושים-אחרונים -> shortcut chips; תכנון-חיבור -> in-sheet rails IF absorbTree else the studio pill KEPT. Hide absorbed pills with a PURE render-time filter gated on isOn(kUnifiedFinder) that writes NOTHING to prefs (do NOT use the persisted hiddenCatalogSections, whose write is permanent and survives a flip-back). Reset catalogSectionProvider to 'בית' on flag flip. The 8 smart_home tools UNTOUCHED.  
*קבצים:* `lib/screens/catalog_screen.dart` · `lib/features/card_keyboard/pill_routing.dart` · `test/smart_home_byte_identity_test.dart (new)` · `test/pill_rehome_test.dart (new)` · *בדיקה:* smart_home_byte_identity: same 8 home tools (count+labels+order) ON and OFF; pill_rehome: ON -> those pills re-home to a post-result LensSelectorRow, 'תכנון חיבור' hidden iff absorbTree; ROLLBACK: enable->hide->disable -> all 9 pills render AND bs.hidden-catalog-sections.v1 byte-identical (nothing persisted); OFF -> all 9 pills exactly as today. · *תלוי:* [116,109,111]

**118. Central REAL .sh gate: single-source <=4 + kReachUniverse BAND + greedy <=6 + RED self-test + workflow-define guard (PATCHED to the feasible harness)**  
PATCHED: scripts/verify_card_keyboard.sh (BASH, executable, modeled on mutation_verify.sh) runs flutter test test/unified_central_gate_test.dart (the step-18 reconciled harness) and exits non-zero on failure. It asserts: (1) kReachUniverse.length in the BAND (step 11, NOT equality); (2) per-card <=6 via the STRICTLY-GREEDY target-blind walker over the SEEDED SAMPLE per-commit / full nightly; (3) <=4 via SINGLE-SOURCE directed depth-4 BFS per node asserting union-of-unreachable-related-pairs empty (NOT |U|^2); (4) all allowlists EMPTY; (5) every compat/kit edge crossesSystem==false. SELF-TEST via INJECT_OVER4 -> RED. Workflow-define-leak guard greps the live workflows. Wired into protocol-enforce.yml after Gate 2, heavy censuses at concurrency=1 in the step-37 retry; runnable locally.  
*קבצים:* `scripts/verify_card_keyboard.sh (new, executable)` · `test/unified_central_gate_test.dart` · `test/unified_central_gate_selftest_test.dart` · `app_flutter/.github/workflows/protocol-enforce.yml` · *בדיקה:* exits 0 clean, prints PASS counts (band, sample <=6, single-source <=4, exhaustive crossesSystem); INJECT_OVER4 -> RED; structural guard asserts divePoolBySku.length BFS calls (NOT |U|^2); the band fails the gate if length forced below the lower bound; workflow-guard non-zero if ENABLE_* injected into a fixture web-deploy.yml; analyze zero-new; taskkill dart before; retry-wrap load failures only; never tail. · *תלוי:* [117,18,11,91,103,113]


### P12 a11y-contract

**119. Fix the ROOT #41 destination chip: render Icons.north_east in _PredictionChip (kills the colour-only WCAG 1.4.1 fail)**  
PATCHED (R2 BLOCKER #6): the DESTINATION branch of _PredictionChip (bs_keyboard.dart:884-918) renders Row([Flexible(label)]) only — the doc :818-819 promised a glyph that does not exist. Add Icon(Icons.north_east, size:m.fontSize*0.9, color:BsTokens.brand) as the FIRST child, then SizedBox(width:spaceHair), then Flexible(label) — reusing the BsKey._content:206-213 axisGlyph idiom. Word-chip branch UNTOUCHED. destinationChips empty by default (production byte-identical).  
*קבצים:* `lib/widgets/smart_input/keyboard/bs_keyboard.dart` · `test/widgets/smart_input/prediction_chip_destination_test.dart (new)` · *בדיקה:* pump with predictions=['ברז'] + destinationChips={'ברז'}: find.byIcon(Icons.north_east) finds EXACTLY one (STRUCTURE, not colour); with destinationChips={} zero and the chip subtree structurally identical to a word chip; Semantics label still '(ניווט)' vs '(חיפוש)'. · *תלוי:* []

**120. P12 phase root: a11y_contract.dart constants + empty-allowlist a11y gate scaffold**  
NEW a11y_contract.dart: const kMinTapTargetDip=48.0; kLiveRegionThrottleMs=400; kA11yPumpWidthDip=360.0; kA11yWaiverList=<String>{} EMPTY (any surface that can't meet the contract is tracked in a SEPARATELY-named debt list the gate ignores, mirroring kReachAllowlist). OWNER-REVIEW docstring. No widget/engine code.  
*קבצים:* `lib/features/card_keyboard/a11y_contract.dart (new)` · `test/features/card_keyboard/a11y_contract_test.dart (new)` · *בדיקה:* kMinTapTargetDip>=48; kLiveRegionThrottleMs>0; kA11yPumpWidthDip==360; kA11yWaiverList.isEmpty (gate FAILS if widened); all const; flag-OFF byte-identity trivial. · *תלוי:* []

**121. 48dp tap targets decoupled from the 30px visual cell (every tappable on a 360px pump)**  
PATCHED (R2 BLOCKER #8): KbCellMetrics sets cellHeight:30 on mobile (:491/495) -> 30px hit region < WCAG 2.5.5. DECOUPLE hit area from the visual cell: wrap the tappable of BsKey/_PredictionChip/_ToolTile in MaterialTapTargetSize.padded (ambient Theme scoped to the keyboard subtree) or a SizedBox(minHeight:kMinTapTargetDip)/MergeSemantics so hit-region>=48 while the painted cell stays 30. Behind kUnifiedFinder||kCardKeyboard.  
*קבצים:* `lib/widgets/smart_input/keyboard/bs_keyboard.dart` · `lib/widgets/smart_input/keyboard/bs_key.dart` · `test/widgets/smart_input/tap_target_size_test.dart (new)` · *בדיקה:* pump at 360, mobile metrics: for EVERY tappable getSize(hitRegion)>=Size(48,48); the PAINTED cell stays 30 (Container minHeight still m.cellHeight); flag-OFF hit region==30 (byte-identical). · *תלוי:* [120]

**122. RTL OrderedTraversalPolicy + logical focus order; most-decisive chip lands RTL-FIRST**  
PATCHED (R2 BLOCKER #8 + RTL major): app-wide ZERO FocusTraversalGroup; WordKeyboard hard-pins Directionality.ltr so AT reaches the LEAST-decisive chip first. Wrap the unified-finder body in FocusTraversalGroup(OrderedTraversalPolicy()) and assign NumericFocusOrder: text field -> mic -> merged chips (most-decisive axis FIRST via card_engine row index 0) -> hop-rail. Keep LTR Directionality for visual key-order stability but OVERRIDE traversal so the decisive chip is focus-FIRST regardless of pixel position. Behind the unified flag.  
*קבצים:* `lib/features/card_keyboard/opening_surface.dart` · `lib/features/card_keyboard/card_keyboard_screen.dart` · `lib/features/word_finder/word_keyboard.dart` · `test/features/card_keyboard/focus_order_rtl_test.dart (new)` · *בדיקה:* Directionality.rtl ambient: traversal from the text field visits [text,mic,chip(best-axis-first),…,railChip]; the FIRST merged chip focused is the best-axis chip (row index 0), NOT leftmost-pixel; flag-OFF no FocusTraversalGroup in the unified subtree. · *תלוי:* [120,99]

**123. Screen-reader announces axis+label per merged chip (reuse the EXISTING semanticLabel seam)**  
PATCHED (R2 BLOCKER #8): the seam EXISTS (WordKey.semanticLabel -> BsKey._semanticLabel:288, Semantics excludeSemantics:139). Confirm _keysFor sets WordKey.semanticLabel='${chip.axisName}: ${chip.displayLabel}' for EVERY merged chip (audit the card-keyboard path the teardown flagged). A DESTINATION chip (step 99) announces 'ניווט אל: ${label}'. Pure additive; null semanticLabel on non-chip keys announces the raw label as today.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/chip_semantics_test.dart (new)` · *בדיקה:* a merged verdict renders keys whose Semantics label == 'גודל: 1/2"' with the child Text excluded (single not doubled); a destination chip announces 'ניווט אל: …'; a plain key announces its raw label; flag-OFF shrink. · *תלוי:* [99]

**124. Throttle the per-keystroke liveRegion onto a debounced status node**  
PATCHED (R2 BLOCKER #8): liveRegion:true sits on the STATIC header (card_keyboard_screen.dart:424-429) and re-announces on EVERY verdict/keystroke. MOVE liveRegion OFF the header (keep header:true, liveRegion:FALSE — a heading announced on focus); add a SEPARATE off-screen Semantics(liveRegion:true) status node whose SETTLED summary ('נמצאו N · בחר ציר') updates ONCE per settled verdict via a Timer(kLiveRegionThrottleMs). Flag-gated; flag-OFF header keeps today's liveRegion:true exactly.  
*קבצים:* `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/features/card_keyboard/live_region_throttle_test.dart (new)` · *בדיקה:* fire 5 verdict changes within kLiveRegionThrottleMs -> the liveRegion status node updates EXACTLY once (coalesced), text is the settled summary with the remaining count; the header is header:true liveRegion:false; flag-OFF header liveRegion:true exactly as :429. · *תלוי:* [120]

**125. Hop-rail operable by screen-reader: _RelatedCard button role + label; 12-item ShowProducts list individually labelled+navigable**  
PATCHED (R2 BLOCKER #8): _RelatedCard (lipskey_product_sheet.dart:1018-1069) is a bare GestureDetector with NO button role. Wrap in Semantics(button:true, label:'${nameHe} · מק"ט ${sku}', onTapHint:'מעבר למוצר') + a 48dp hit area (step 121). For the 12-item ShowProducts list set each product key's WordKey.semanticLabel to name+sku so the 12 are individually announced+navigable, inside the step-122 FocusTraversalGroup. Flag-gated; flag-OFF _RelatedCard stays the bare GestureDetector.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `lib/features/card_keyboard/card_keyboard_screen.dart` · `test/screens/hop_rail_a11y_test.dart (new)` · `test/features/card_keyboard/show_products_a11y_test.dart (new)` · *בדיקה:* each _RelatedCard exposes Semantics button:true with a label containing the sku, getSize(hitRegion)>=48; flag-OFF no button role; a 12-item ShowProducts renders 12 keys each with a distinct (name+sku) label, all reachable by sequential focus (12 pairwise-distinct labels, composes with step 79). · *תלוי:* [121,122,123]

**126. Modal FocusScope trap on the in-sheet product modal**  
PATCHED (R2 BLOCKER #8): the in-sheet modal traps no focus so switch-access tabs into the catalog behind it. Wrap the sheet body (when a modal route) in FocusScope(canRequestFocus:true) + Semantics(scopesRoute:true, explicitChildNodes:true) so traversal cannot escape to the background catalog while open. Behind the unified flag; flag-OFF the sheet opens exactly as today.  
*קבצים:* `lib/screens/lipskey_product_sheet.dart` · `test/screens/sheet_focus_trap_test.dart (new)` · *בדיקה:* open the sheet over a catalog body (forceLive); Tab x N -> focus NEVER lands on a background catalog widget (every focused node within the sheet subtree); closing restores focus to the opener; flag-OFF no FocusScope wrapper inserted. · *תלוי:* [122]

**127. softTilt/card_soft reconcile capstone: no-orphaned-soft-layer + identity-safe soft-layer invariants**  
Consolidate the P9 softTilt reconcile (steps 96-98) under a single capstone: assert exactly ONE soft module (card_soft.dart) is imported by card_engine and NO soft_tilt.dart exists; the tilt is order-only and identity-safe (the three sets passed in, never global). This is the R2 BLOCKER #7 'no orphaned soft layer' gate, placed in P12 so it co-runs with the a11y gate as a single contract sweep.  
*קבצים:* `test/features/card_keyboard/card_soft_no_orphan_test.dart (new)` · *בדיקה:* grep-guard: card_engine imports card_soft, NO file soft_tilt.dart in lib/features/card_keyboard; PROPERTY (re-asserts step 104): chip SET from mergedKeys(...softParams)==from mergedKeys(...emptyParams) for 200 pools; A's then B's historySkus never surface A's skus as B's chips. · *תלוי:* [98,104]

**128. Cold-start comprehensibility + off-corpus a11y + naming coherence (doc-as-test)**  
PATCHED (R2 remaining majors): (1) COLD-START — cold_start_contract_test asserts screen-1 presents exactly kMaxScreen1Decisions==1 interactive decision group (no segmented control), and the most-decisive affordance is RTL-FIRST in reading order (reconciled with the LTR key-order pin via step 122 traversal). (2) OFF-CORPUS — the 'לא נמצאו במאגר ההתקנה' BOM section carries a Semantics header so AT is told some picks are unwired. (3) NAMING COHERENCE — assert the a11y seam is ONE name (axisGlyph/semanticLabel on WordKey), NOT axisGlyph+isDestination, and 'destination' terminology is consistent between _PredictionChip and the word-key.  
*קבצים:* `test/features/card_keyboard/cold_start_contract_test.dart (new)` · `test/features/card_keyboard/off_corpus_a11y_test.dart (new)` · `test/features/card_keyboard/naming_coherence_test.dart (new)` · *בדיקה:* cold_start (rtl): screen-1 decision-group count==1, zero ToggleButtons/TabBar, leading-edge focusable is the text field then the most-decisive chip; off_corpus: the unresolved section renders a Semantics header announcing the off-corpus count (never a silent partial); naming: WordKey exposes axisGlyph+semanticLabel and NOT isDestination, Icons.north_east used by BOTH _PredictionChip and the chip->WordKey mapping. · *תלוי:* [99,122,125]

**129. P12 a11y gate: Semantics-tree golden per surface + central .sh assertion, allowlist-EMPTY, wired into CI**  
PATCHED (R2 BLOCKER #8): a11y_contract_suite + a gate hook in scripts/verify_unified_finder.sh (step 94). Per surface (OpeningSurface, merged-chip keyboard, ShowProducts list, in-sheet hop-rail): (a) a Semantics-tree golden (button roles + labels) the gate diffs; (b) every tappable getSize>=48 at 360px (step 121); (c) a FocusTraversalGroup with OrderedTraversalPolicy and the decisive chip focus-first (step 122); (d) the liveRegion status node throttled (step 124); (e) kA11yWaiverList.isEmpty (step 120). SELF-TEST strips a button role from a fixture -> RED. taskkill dart before; retry-wrap load failures.  
*קבצים:* `test/features/card_keyboard/a11y_contract_suite_test.dart (new)` · `test/features/card_keyboard/a11y_contract_selftest_test.dart (new)` · `scripts/verify_unified_finder.sh` · `test/golden/a11y_semantics_tree.txt (new)` · *בדיקה:* verify_unified_finder.sh exits 0 clean with the a11y suite green; SELF-TEST stripping a button role / shrinking a hit region below 48 / emptying the FocusTraversalGroup -> non-zero (the gate CAN fail); kA11yWaiverList.isEmpty asserted; Semantics-tree golden stable across two runs; analyze zero-new. · *תלוי:* [121,122,123,124,125,126]
