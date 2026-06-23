# Pillar #2 — Domain / Vertical Builder · build-steps 31–50 (phase 3)

> Source plan: `knowledge/studio-plan/02-domain-vertical-builder.md`. Branch `claude/whats-happening-LyY9G`.
> Global slice: **steps 31–50** of the 100-step BuildSmart-Studio decomposition (exactly 20 here).
> Stack: Flutter 3.29 / Dart 3.7 / Riverpod · RTL/Hebrew/a11y · gated default-OFF · server-ready · 100-gate protocol · governance #84.
> **Keystone (the zero-reg pivot):** step 38 — the generated plumbing seed is asserted byte-equal to the live consts. Nothing trade-agnostic ships until it is green.
> **Scale to 10Ks (indexed search, Firestore sharding, list virtualization) is OUT — deferred to Pillar-5 steps.**
>
> Per-step gate baseline (every step, in addition to its named gate): `flutter analyze` 0 errors · `flutter test` (incl. `knowledge_protocol_test`) green · `WIRING.md` updated for any new wired symbol. Each step is independently shippable behind a default-OFF flag → demo/live build stays byte-identical.
> Line format: `N. <action> · <file / file:line seam> · <gate/test> · <zero-reg note>`

---

### Schema + flags + store (31–34) — pure additive, no read-path touched

31. Add three default-OFF flags + flag-helper consts · new `lib/state/trade_builder_flags.dart` (`kTradeBuilderFlag`,`kTradeStudioFlag`,`kTradeImportFlag`) via `feature_flags.dart:36` `FeatureFlagsNotifier` · `feature_flags_test` extended (all three default OFF, not in `_forcedOnFlags`) · no consumer reads a flag yet → zero call-sites changed.

32. Define trade/category/attribute/product/accessory/fixture schema · new `lib/domain/trade_schema.dart` (`Trade`,`TradeCategory`,`AttributeDef`,`AttributeValue`,`AttributeKind`,`TradeProduct`,`AccessoryRule`,`SmartFixture`,`InstallStage`) · new `trade_schema_test` (toJson/fromJson roundtrip, stable string ids) · pure new file, imported nowhere live.

33. Define connection schema (authored matrix, replaces closed enum) · new `lib/domain/connection_schema.dart` (`ConnectorType`,`SystemDef`,`ProductConnectorSpec`,`ProductEnd`,`CompatibilityRule`,`SizeMatch`,`CompletionRule`,`RuleSeverity`) · `connection_schema_test` (JSON roundtrip; severity≡`CheckSeverity` mapping) · `lipskey_verified_connections.dart:24` `EndType`/`:41` `WaterSystem` left untouched (they become seed types in 37).

34. Add authored-trade store (deltas only, SharedPreferences) · new `lib/state/trades_store.dart` `StateNotifier<TradesDoc>` (key `bs.trades.v1`) mirroring `catalog_settings.dart:8` `_kStorageKey`/`_load`/`_persist` idiom · **G-roundtrip** new `trades_store_roundtrip_test` (mirror `persistence_roundtrip_test`) · starts empty → no published trade → live app unaffected.

### Generated plumbing seed = the zero-reg keystone (35–38)

35. Add adapter `TradeProduct.toLegacy()`→`LipskeyCatalogProduct` (1:1; `attributes`→`dims`) · new `lib/domain/trade_product_adapter.dart` against `lipskey_catalog.dart:4` `LipskeyCatalogProduct` · `trade_product_adapter_test` (`==` + render-field identity on sampled `kCatalogProducts`) · adapter is the only screen-facing type → screens still see `LipskeyCatalogProduct`.

36. Write generator: consts → plumbing `Trade` doc + categories/products/fixtures · new `scripts/gen_plumbing_seed.dart` reading `polyroll_catalog.dart:1513` `kCatalogProducts`, `catalog_tree.dart:36` `kCatalogTree`, `catalog.dart:5` `kCatalogCats`, `smart_tree.dart:153` `kSmartProducts`, `brands.dart:25` `kBrands` · generator runs clean (emits committed file in 37) · script only; no lib import yet.

37. Commit generated seed incl. `CompatibilityRule`s derived from 891 specs · new `lib/domain/seeds/plumbing_trade_seed.dart` (emitted from `lipskey_verified_connections.dart:77` `VerifiedSpec` mating pairs; `EndType`→`ConnectorType`, `WaterSystem`→`SystemDef`) · file compiles; analyze clean · authored store still empty → plumbing supplied by baked seed, app byte-identical.

38. **KEYSTONE — assert seed ≡ live consts byte/semantics-identical** · new `test/trade_seed_equivalence_test.dart` covering `kCatalogProducts`/`kCatalogTree`/`kCatalogCats`/`kSmartProducts` + every `kVerifiedSpecs` mating answer · **G-seed (hard gate to proceed)** alongside `catalog_regression_test`+`phaseb_seeds_test` staying green · red = plumbing regression; no later step lands until green.

### Trade-agnostic resolver (39–41) — pure logic, proven against old engine

39. Build pure trade-agnostic engine (no UI) · new `lib/domain/connection_resolver.dart` `canConnect(a,b,ruleSet)`/`completion(line)`/`systemCoherence(line)` over `CompatibilityRule`/`CompletionRule` · unit `connection_resolver_unit_test` (SizeMatch exactSame/anyToAny/tableLookup) · pure functions, called nowhere live yet.

40. **G-resolver parity** — run resolver on seeded matrix vs old answers · new `test/connection_resolver_parity_test.dart` feeding `compat_50_samples_test` + `full_compliance_audit_test` fixtures through resolver, asserting equality with `lipskey_verified_connections.dart` results · **G-resolver (gate)**; old `compat_*`/`full_compliance_audit_test` untouched & green · resolver proven equal before any screen calls it.

41. Wrap engine connect/compliance behind flag, plumbing branch kept · `install_engine.dart:151` `lineComplianceChecklist` + `:90` `connectionMethodLabel` delegate to resolver only when `tradeId!='plumbing'` & `kTradeStudioFlag` ON · `install_engine_*` (b5/b6/b8/b10/b11/b13/safety/hardening) all stay green · `'plumbing'` keeps hand-coded branch verbatim → OFF path = today.

### Repository tradeId seam + active-trade (42–43) — default reproduces today

42. Add `tradeId` param to repo reads, default `'plumbing'` = seed · `catalog_repository.dart:36` interface (`allProducts`/`catalogCategories`/`smartTreeCats` + new `categoryTree`) + impl `catalog_local.dart:44` `LocalCatalogRepository` filtering seed by trade · `repositories_test`+`catalog_regression_test` green (plumbing seed≡`kCatalogProducts`) · default arg → existing callers unchanged.

43. Add `activeTradeProvider` (defaults `'plumbing'`; switcher hidden when count==1) · new provider in `lib/state/trades_store.dart` consumed via `catalogRepositoryProvider` (`catalog_local.dart:103`) · `active_trade_provider_test` (default plumbing; switcher hidden at count==1) · single published trade → no switcher UI → zero visible change.

### Hebrew no-code authoring screens (44–47) — gated manager tab, RTL/a11y

44. Add gated manager entry + trade list + define-step (Trade draft) · new `lib/screens/trade_builder/trade_builder_home.dart` + `trade_define_step.dart`; entry in `manager_dashboard_screen.dart` ("🏗️ בונה ענפים", `kTradeBuilderFlag`) writing via `tradesEditProvider` over `trades_store.dart` · **G-authoring** widget test (RTL directionality + semantics + `textScaler` clamp 1.35) · tab hidden when flag OFF → `manager_dashboard_screen_test` unchanged.

45. Add category-tree + attribute-schema editors · new `lib/screens/trade_builder/category_tree_editor.dart` (RTL reorder add/rename/move/delete `TradeCategory`) + `attribute_schema_editor.dart` (`AttributeDef` kind/values/"ציר וריאנט?"/unit — authored replacement for `variant_families.dart:9` `AttrKind`) · widget tests RTL+a11y; live name-decompose preview · writes only via `tradesEditProvider`; const files untouched.

46. Add product + accessory authoring editors · new `lib/screens/trade_builder/product_authoring_screen.dart` (edit `attributes` vs schema; non-virtualized list, ≤10K — Pillar-5 owns scale) + `accessory_rule_editor.dart` (`AccessoryRule` name/why/must/price/linkSku) · widget tests RTL+a11y · authored deltas only → live catalog reads seed unchanged.

47. Add connection-rule studio + publish sheet · new `lib/screens/trade_builder/connection_rule_studio.dart` (`ConnectorType`/`SystemDef` + A×B matrix + `CompletionRule` + live test-bench calling `connection_resolver.dart`) + `trade_publish_sheet.dart` (validation: every category≥1 product, every variant axis has values, no orphan compat rule → flips `published`) · widget tests RTL+a11y + publish-validation blocks bad trade · draft never affects live app.

### Bulk import contract (48) — mapping/validation only, at-scale = Pillar 5

48. Add import template-export + column-map + dry-run + gated commit · UI in `product_authoring_screen.dart` + new `scripts/` template generator from `AttributeDef`s · **G-import** new `bulk_import_test` (template→map→dry-run→commit on synthetic CSV; required/enum/sku-unique; **no write on error**) behind `kTradeImportFlag` · 10K-row pipeline/Firestore batches/indexed search explicitly deferred to Pillar 5.

### Gated install-studio + brand refactor + electrician acceptance (49–50)

49. Abstract install-studio baked physics + brand if-ladders at named seams (gated) · `install_studio_screen.dart:37` system colors→`SystemDef.color`, `:100` picker→`smartFixtures`, `:137` compliance labels→`CompletionRule.whyHe`, `:439` temp pills→envelope, `:558` `canConnect`→`connection_resolver`, `:2438` kit, `:2319` slope→optional `TradePhysicsConfig`; `related_info.dart:53/54/446/449/500/527/624/645` + `lipskey_catalog.dart:50` if-ladders→`BrandProfile` (`brands.dart:4`) · **G-flag-off** golden/snapshot diff vs current (all `kTrade*` OFF) green · OFF/`'plumbing'`→identical constants; `if` ladders deleted only after G-seed green.

50. **G-newtrade acceptance — author "חשמלאי" end-to-end, catalog+studio function** · new `test/trade_newtrade_acceptance_test.dart` (in-test author 2 categories, 1 variant axis, 2 products, 1 compat rule → publish → assert catalog list + install-studio connect for electrician) + sync `WIRING.md`/`02-domain-vertical-builder.md` · **G-newtrade (acceptance)** with full suite green; per-trade rollout default-OFF until owner approval (governance #84) · the literal "תוסיף חשמלאי בעצמי" proof; plumbing path unchanged throughout.
