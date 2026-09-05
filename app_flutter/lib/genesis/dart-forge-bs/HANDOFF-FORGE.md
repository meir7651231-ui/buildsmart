# HANDOFF-FORGE — ספריית-האטומים המעוצבת (Pure→Flutter)

> **לסשן שעובד על בנייה-חכמה (buildsmart):** יש ספריית-UI חדשה של **353 ווידג'טים
> פיקסל-נאמנים** ל-Pure HTML, מחוללים ממנוע `ds-forge`. **הרכב מסכים מהם — אל תבנה UI מאפס.**

## מה זה
- **353 אטומי-Dart** (`StatelessWidget`) ב-17 משפחות, נאמנים למקור-ה-HTML (ביקורת-פיקסל: 353/353
  מרונדרים · ממוצע-דיף אמיתי ~1.75% · אפס-קריסות).
- כל אטום **לובש עיצוב מהחריץ בלבד** (`DsSeam`) — אפס צבע-קבוע (חוק-5/6). מתאים לכל ערכת-נושא/וורטיקל.
- מקור-האמת: `machtzev/ds-forge.mjs` בריפו **genesis** (`-ai-chat-server`). האטומים כאן **מחוללים** —
  אל תערוך ידנית.

## מיקום וענף
- קוד: `app_flutter/lib/genesis/dart-forge-bs/<משפחה>/<אטום>.dart`
- ענף: `claude/mah-kora-0by8kw` (מסונכרן; אומת `flutter test` + ביקורת-פיקסל).
- רשימה מכונתית: `dart-forge-bs/forge-manifest.json`.

## איך משתמשים

**1. שם-המחלקה** = `Forge` + PascalCase של שם-הקובץ:
`gold_button.dart` → `ForgeGoldButton` · `summary_stat_strip.dart` → `ForgeSummaryStatStrip`

**2. ייבוא** דרך ה-barrel של המשפחה (מייצא את כל אטומיה):
```dart
import 'package:buildsmart/genesis/dart-forge-bs/action/action.dart';
```

**3. שימוש ישיר** — עובד מהקופסה עם ערכת-ברירת-המחדל (dark · `DsPure`):
```dart
const ForgeGoldButton()
```

**4. החלפת-עיצוב** (theme/skin/fonts) לתת-עץ שלם — עוטפים ב-`PureScope`
(‏`PureScope`+`DsSeam` מ-`dart-ui-bs/ds/ds_seam.dart` · `DsPure` מ-`dart-ui-bs/ds/ds_pure.dart`):
```dart
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_seam.dart';
import 'package:buildsmart/genesis/dart-ui-bs/ds/ds_pure.dart';

PureScope(
  theme: DsPure.theme,   // או ערכת-אקצנט/וורטיקל משלך
  skin:  DsPure.skin,
  fonts: DsPure.fonts,
  child: const ForgeGoldButton(),
)
```
בלי `PureScope` האטום נופל לברירות `DsPure` (דורמנטי · הפיך). `DsSeam.of/skinOf/fontsOf(context)`
הם ה-API שכל אטום קורא.

## חובה
- **פונטים ב-pubspec:** `Fraunces` · `Frank Ruhl Libre` · `Space Grotesk` · `Heebo` · `JetBrains Mono`
  (בלעדיהם הטקסט לא נאמן).
- **אל תערוך** קבצי `dart-forge-bs` — הם מחוללים. תיקון = במנוע `machtzev/ds-forge.mjs` (genesis) → regen → mirror.
- **גילוי מהיר** של כל המחלקות:
  ```bash
  grep -rh "class Forge" app_flutter/lib/genesis/dart-forge-bs | sort
  ```
- **מקרא-דיף בקטלוג:** 🟢 <2% · 🟡 <4% · 🔴 ≥4% (ה-🔴 הם כמעט-כולם תאי-`N_atoms` מרוכבים
  שמרכזים אטומים רבים יחד — צבירת-דיף, לא שגיאה; וכן אנימציה/blur שנאמנים ב-GPU האמיתי).

## עיקרון-הרכבה
הרכב מסכים מהאטומים (חוק-7: טעינה-לצד + דגל-הפיך), **לא לשכתב אותם**. אטום חסר/וריאנט חדש —
מוסיפים ל-Pure HTML במקור ומחוללים מחדש, לא כותבים Dart ביד.

---

## קטלוג מלא (353 אטומים)

### action — כפתורים · טוגלים · FAB · סגמנטים · שורות-מתג  `import .../dart-forge-bs/action/action.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge18Atoms` | 18_atoms.dart | 🔴 7.0% |
| `ForgeActionButton` | action_button.dart | 🟢 1.2% |
| `ForgeAddTradeButton` | add_trade_button.dart | 🟢 1.2% |
| `ForgeAnimatedToggle` | animated_toggle.dart | 🟢 1.3% |
| `ForgeCardBtn` | card_btn.dart | 🟢 1.7% |
| `ForgeCartFabButton` | cart_fab_button.dart | 🟡 2.2% |
| `ForgeChatSettingsSwitchRow` | chat_settings_switch_row.dart | 🟡 2.0% |
| `ForgeCircleCloseButton` | circle_close_button.dart | 🟢 0.0% |
| `ForgeCircleFab` | circle_fab.dart | 🟢 1.7% |
| `ForgeCourierFormsPillButton` | courier_forms_pill_button.dart | 🟢 1.3% |
| `ForgeCourierSettingsSwitchRow` | courier_settings_switch_row.dart | 🟢 1.6% |
| `ForgeDsToggleTile` | ds_toggle_tile.dart | 🟢 1.9% |
| `ForgeFabAction` | fab_action.dart | 🟡 2.3% |
| `ForgeFabMenu` | fab_menu.dart | 🟡 2.0% |
| `ForgeFilledCtaButton` | filled_cta_button.dart | 🟢 1.3% |
| `ForgeGalleryAllBtn` | gallery_all_btn.dart | 🟢 0.4% |
| `ForgeGlassButton` | glass_button.dart | 🟢 1.2% |
| `ForgeGoldButton` | gold_button.dart | 🟢 1.8% |
| `ForgeGradButton` | grad_button.dart | 🟢 1.2% |
| `ForgeGradientPulseButton` | gradient_pulse_button.dart | 🟢 1.2% |
| `ForgeLinkBtn` | link_btn.dart | 🟢 1.4% |
| `ForgeMagneticButton` | magnetic_button.dart | 🟢 1.3% |
| `ForgeMiniQtyBtn` | mini_qty_btn.dart | 🟢 1.2% |
| `ForgeNeonButton` | neon_button.dart | 🟢 1.3% |
| `ForgeNotifSettingsSwitchRow` | notif_settings_switch_row.dart | 🟡 3.7% |
| `ForgeOutlinedActionButton` | outlined_action_button.dart | 🟢 1.3% |
| `ForgePillButton` | pill_button.dart | 🟢 1.0% |
| `ForgePillCtaButton` | pill_cta_button.dart | 🟢 1.0% |
| `ForgePortalTileButton` | portal_tile_button.dart | 🟢 1.8% |
| `ForgePremiumToggle` | premium_toggle.dart | 🟡 3.4% |
| `ForgePrimaryBtn` | primary_btn.dart | 🟢 1.9% |
| `ForgeQuickActionButton` | quick_action_button.dart | 🟢 1.0% |
| `ForgeRippleButton` | ripple_button.dart | 🟢 1.1% |
| `ForgeSaveDraftButton` | save_draft_button.dart | 🟢 0.9% |
| `ForgeSegmentedPillToggle` | segmented_pill_toggle.dart | 🟢 0.5% |
| `ForgeSegmentedSwitch` | segmented_switch.dart | 🟢 0.5% |
| `ForgeSendReportButton` | send_report_button.dart | 🟢 1.4% |
| `ForgeSettingsSwitchRow` | settings_switch_row.dart | 🟢 2.0% |
| `ForgeSheetAdvanceButton` | sheet_advance_button.dart | 🟢 1.7% |
| `ForgeShutterButton` | shutter_button.dart | 🟢 0.2% |
| `ForgeSiteHubCardBtn` | site_hub_card_btn.dart | 🟢 1.8% |
| `ForgeSoftButton` | soft_button.dart | 🟢 0.9% |
| `ForgeStepBtn` | step_btn.dart | 🟢 0.3% |
| `ForgeStoreStepBtn` | store_step_btn.dart | 🟢 0.4% |
| `ForgeSubmitButton` | submit_button.dart | 🟢 1.1% |
| `ForgeSwitchRow` | switch_row.dart | 🟡 2.3% |
| `ForgeTradeBuilderAccessoryRuleEditorPillButton` | trade_builder_accessory_rule_editor_pill_button.dart | 🟢 1.6% |
| `ForgeUnitSegmentToggle` | unit_segment_toggle.dart | 🟢 0.5% |
| `ForgeWorkerFormsPillButton` | worker_forms_pill_button.dart | 🟢 0.9% |

### card — כרטיסים · flip · סטטיסטיקה · מדיה · profile  `import .../dart-forge-bs/card/card.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge11Atoms` | 11_atoms.dart | 🔴 4.6% |
| `Forge6Atoms` | 6_atoms.dart | 🔴 5.1% |
| `Forge9Atoms` | 9_atoms.dart | 🔴 5.2% |
| `ForgeAccordionPanel` | accordion_panel.dart | 🟢 1.6% |
| `ForgeAccordionSectionCard` | accordion_section_card.dart | 🟢 1.1% |
| `ForgeContactTile` | contact_tile.dart | 🟢 1.1% |
| `ForgeDsRecordCard` | ds_record_card.dart | 🟢 1.5% |
| `ForgeFlatCard` | flat_card.dart | 🟢 0.4% |
| `ForgeFlipCard` | flip_card.dart | 🟢 0.4% |
| `ForgeGlassCard` | glass_card.dart | 🟢 0.4% |
| `ForgeGradientHeroCard` | gradient_hero_card.dart | 🟢 0.4% |
| `ForgeGridHubCard` | grid_hub_card.dart | 🟢 1.0% |
| `ForgeHeroCard` | hero_card.dart | 🟢 1.1% |
| `ForgeHubTile` | hub_tile.dart | 🟡 2.2% |
| `ForgeKpiBox` | kpi_box.dart | 🟢 1.3% |
| `ForgeLiveStatusDot` | live_status_dot.dart | 🟢 0.5% |
| `ForgeLiveStatusPill` | live_status_pill.dart | 🟢 0.9% |
| `ForgeMetricTile` | metric_tile.dart | 🟡 2.1% |
| `ForgeOutlinedCardSection` | outlined_card_section.dart | 🟢 1.4% |
| `ForgePriceEstimatePanel` | price_estimate_panel.dart | 🟢 0.7% |
| `ForgeProductCard` | product_card.dart | 🟢 1.5% |
| `ForgeProfileCard` | profile_card.dart | 🟢 1.3% |
| `ForgePulsingStatus` | pulsing_status.dart | 🟢 1.0% |
| `ForgeRevealCard` | reveal_card.dart | 🟢 0.3% |
| `ForgeSectionCard` | section_card.dart | 🟢 0.5% |
| `ForgeSpotlightCard` | spotlight_card.dart | 🟢 1.0% |
| `ForgeStatTile` | stat_tile.dart | 🟢 1.2% |
| `ForgeStatusDot` | status_dot.dart | 🟢 1.2% |
| `ForgeStripPanelFrame` | strip_panel_frame.dart | 🟢 1.6% |
| `ForgeSummaryStatStrip` | summary_stat_strip.dart | 🔴 6.2% |
| `ForgeTrendCard` | trend_card.dart | 🟢 1.4% |

### chat — בועות-צ׳אט · מחוונים · שורת-קלט  `import .../dart-forge-bs/chat/chat.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `ForgeBubbleStates` | bubble_states.dart | 🟢 1.2% |
| `ForgeComposer` | composer.dart | 🟡 3.1% |
| `ForgeDeliveryTicks` | delivery_ticks.dart | 🟢 1.3% |
| `ForgeMessageThread` | message_thread.dart | 🟢 1.4% |
| `ForgeQuickReply` | quick_reply.dart | 🟡 2.1% |
| `ForgeTypingIndicator` | typing_indicator.dart | 🟢 1.8% |

### composite — טפסים · אשפים · בוררים · שורות-מפוצלות (מרכבים)  `import .../dart-forge-bs/composite/composite.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge6RowAtoms` | 6_row_atoms.dart | 🔴 6.5% |
| `Forge8Assemblies` | 8_assemblies.dart | 🔴 5.9% |
| `ForgeCartSummaryCard` | cart_summary_card.dart | 🟢 1.9% |
| `ForgeFilterBar` | filter_bar.dart | 🟢 1.8% |
| `ForgeFilterToolbar` | filter_toolbar.dart | 🟢 1.3% |
| `ForgeFormCard` | form_card.dart | 🟢 1.5% |
| `ForgeQuickAddForm` | quick_add_form.dart | 🔴 4.5% |
| `ForgeReplyComposer` | reply_composer.dart | 🟡 2.1% |
| `ForgeRequestComposer` | request_composer.dart | 🟢 1.2% |
| `ForgeSettingsGroup` | settings_group.dart | 🟡 2.6% |
| `ForgeSignInForm` | sign_in_form.dart | 🟢 1.7% |
| `ForgeSplitControl` | split_control.dart | 🟡 3.3% |
| `ForgeStatClusterCard` | stat_cluster_card.dart | 🟡 2.8% |
| `ForgeStripGroupCard` | strip_group_card.dart | 🟡 2.8% |
| `ForgeSummaryCard` | summary_card.dart | 🟢 1.4% |
| `ForgeSummaryStatStrip` | summary_stat_strip.dart | 🟡 2.5% |
| `ForgeWizardHeader` | wizard_header.dart | 🟢 1.4% |
| `ForgeWizardStep` | wizard_step.dart | 🟢 1.7% |

### dataviz — גרפים · טבעות · מדים · בארים · sparkline  `import .../dart-forge-bs/dataviz/dataviz.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge5Atoms` | 5_atoms.dart | 🔴 5.3% |
| `Forge6Atoms` | 6_atoms.dart | 🔴 5.8% |
| `Forge7Atoms` | 7_atoms.dart | 🔴 4.9% |
| `Forge9Atoms` | 9_atoms.dart | 🔴 5.8% |
| `ForgeAreaChart` | area_chart.dart | 🟢 1.2% |
| `ForgeBarChart` | bar_chart.dart | 🟢 0.6% |
| `ForgeChartLegend` | chart_legend.dart | 🟢 1.0% |
| `ForgeDonutChart` | donut_chart.dart | 🟢 1.8% |
| `ForgeHeatGrid` | heat_grid.dart | 🟢 1.5% |
| `ForgeIntensityStrip` | intensity_strip.dart | 🟢 0.4% |
| `ForgeLegendRow` | legend_row.dart | 🟢 1.6% |
| `ForgeLineSpark` | line_spark.dart | 🟢 1.0% |
| `ForgeLinearProgress` | linear_progress.dart | 🟡 2.2% |
| `ForgePieChart` | pie_chart.dart | 🟢 0.2% |
| `ForgeProgressRing` | progress_ring.dart | 🟢 0.3% |
| `ForgeRadialGauge` | radial_gauge.dart | 🟡 3.6% |
| `ForgeRatingBars` | rating_bars.dart | 🟢 1.4% |
| `ForgeSegmentedMeter` | segmented_meter.dart | 🟡 3.4% |
| `ForgeSparkArea` | spark_area.dart | 🟢 1.6% |
| `ForgeStackedBarGroup` | stacked_bar_group.dart | 🟢 0.8% |
| `ForgeStatBlock` | stat_block.dart | 🟢 1.5% |
| `ForgeStepAreaChart` | step_area_chart.dart | 🟢 1.1% |
| `ForgeTrendChart` | trend_chart.dart | 🟡 2.2% |
| `ForgeWaveformBars` | waveform_bars.dart | 🟢 1.3% |

### feedback — מודלים · toast · sheets · skeleton · empty · progress  `import .../dart-forge-bs/feedback/feedback.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge10Atoms` | 10_atoms.dart | 🔴 6.1% |
| `Forge4Atoms` | 4_atoms.dart | 🔴 5.7% |
| `Forge5Atoms` | 5_atoms.dart | 🔴 5.0% |
| `Forge6Atoms` | 6_atoms.dart | 🔴 5.1% |
| `ForgeAlertBanner` | alert_banner.dart | 🟡 2.8% |
| `ForgeAnimatedEmpty` | animated_empty.dart | 🟢 1.0% |
| `ForgeConfirmDialog` | confirm_dialog.dart | 🟢 1.6% |
| `ForgeConsentDialog` | consent_dialog.dart | 🟢 1.4% |
| `ForgeDotsLoader` | dots_loader.dart | 🟡 2.6% |
| `ForgeDraftBadge` | draft_badge.dart | 🟡 2.5% |
| `ForgeEmptyHint` | empty_hint.dart | 🟡 3.0% |
| `ForgeEmptyState` | empty_state.dart | 🟢 0.9% |
| `ForgeLinearProgress` | linear_progress.dart | 🟡 2.6% |
| `ForgeModalDialog` | modal_dialog.dart | 🔴 4.9% |
| `ForgeNotifyBadge` | notify_badge.dart | 🟢 1.3% |
| `ForgeOrbitSpinner` | orbit_spinner.dart | 🟢 0.3% |
| `ForgeProgressRing` | progress_ring.dart | 🟢 1.3% |
| `ForgeRuleInspectDialog` | rule_inspect_dialog.dart | 🟢 1.3% |
| `ForgeSearchEmptyState` | search_empty_state.dart | 🟢 0.9% |
| `ForgeShimmerSkeleton` | shimmer_skeleton.dart | 🟢 0.0% |
| `ForgeSkeletonCard` | skeleton_card.dart | 🟢 0.0% |
| `ForgeSlideSheet` | slide_sheet.dart | 🟢 0.8% |
| `ForgeSnackToast` | snack_toast.dart | 🟢 0.8% |
| `ForgeStoryRing` | story_ring.dart | 🟢 0.0% |
| `ForgeTooltipBubble` | tooltip_bubble.dart | 🟡 2.1% |
| `ForgeZoomHint` | zoom_hint.dart | 🟡 2.5% |

### header — כותרות-עמוד · hero · sticky · brand · sections  `import .../dart-forge-bs/header/header.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge6Atoms` | 6_atoms.dart | 🔴 6.0% |
| `ForgeBrandHeader` | brand_header.dart | 🟢 1.7% |
| `ForgeBrandListRow` | brand_list_row.dart | 🟢 0.8% |
| `ForgeCenteredPageHeader` | centered_page_header.dart | 🟡 2.1% |
| `ForgeDateChip` | date_chip.dart | 🟢 1.2% |
| `ForgeDateHeader` | date_header.dart | 🟢 0.9% |
| `ForgeDatePills` | date_pills.dart | 🟡 2.5% |
| `ForgeDetailHeader` | detail_header.dart | 🟡 2.3% |
| `ForgeDsDateField` | ds_date_field.dart | 🟢 0.9% |
| `ForgeEmojiSectionTitle` | emoji_section_title.dart | 🟢 0.8% |
| `ForgeGradientHeroCard` | gradient_hero_card.dart | 🟡 2.3% |
| `ForgeHeroHeader` | hero_header.dart | 🟡 3.8% |
| `ForgeLensGroupHeader` | lens_group_header.dart | 🟢 1.4% |
| `ForgeModalHeader` | modal_header.dart | 🟢 0.9% |
| `ForgePageHeader` | page_header.dart | 🔴 4.1% |
| `ForgeProfileCard` | profile_card.dart | 🟢 1.1% |
| `ForgeProfileHeaderRow` | profile_header_row.dart | 🟡 2.4% |
| `ForgeProfileRow` | profile_row.dart | 🟢 1.4% |
| `ForgeSectionHeader` | section_header.dart | 🟢 1.7% |
| `ForgeSectionTitle` | section_title.dart | 🟢 1.0% |
| `ForgeSheetHeader` | sheet_header.dart | 🟢 0.6% |
| `ForgeSmartProjectHero` | smart_project_hero.dart | 🟡 3.1% |
| `ForgeStepProgressHeader` | step_progress_header.dart | 🟡 2.1% |
| `ForgeStickyHeader` | sticky_header.dart | 🟢 1.4% |
| `ForgeStoreSupplierHeader` | store_supplier_header.dart | 🟢 1.3% |
| `ForgeTitledSection` | titled_section.dart | 🟢 1.4% |
| `ForgeWizardHeader` | wizard_header.dart | 🟡 2.0% |

### input — שדות · פיקרים · dial-pad · טווח · חיפוש · pin  `import .../dart-forge-bs/input/input.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge4Atoms` | 4_atoms.dart | 🟡 3.4% |
| `ForgeDsDateField` | ds_date_field.dart | 🟢 1.2% |
| `ForgeDsEnumField` | ds_enum_field.dart | 🟢 0.9% |
| `ForgeDsField` | ds_field.dart | 🟢 0.7% |
| `ForgeDsNumberField` | ds_number_field.dart | 🟢 0.6% |
| `ForgeDsSearch` | ds_search.dart | 🟢 0.4% |
| `ForgeDualRange` | dual_range.dart | 🟡 2.8% |
| `ForgeField` | field.dart | 🟢 0.5% |
| `ForgeFieldLabel` | field_label.dart | 🟡 2.9% |
| `ForgeFieldRow` | field_row.dart | 🟢 0.9% |
| `ForgeGlowField` | glow_field.dart | 🔴 8.0% |
| `ForgeGlowSlider` | glow_slider.dart | 🟢 1.6% |
| `ForgeInputBar` | input_bar.dart | 🟢 0.4% |
| `ForgeLabeledField` | labeled_field.dart | 🟢 1.0% |
| `ForgeNumberStepper` | number_stepper.dart | 🟢 0.3% |
| `ForgeOtpInput` | otp_input.dart | 🟡 2.4% |
| `ForgePickerOption` | picker_option.dart | 🟡 3.9% |
| `ForgePickerOptionChip` | picker_option_chip.dart | 🟡 2.5% |
| `ForgePickerOptionsPanel` | picker_options_panel.dart | 🟡 2.7% |
| `ForgePinPad` | pin_pad.dart | 🟡 3.5% |
| `ForgePremiumField` | premium_field.dart | 🟡 2.4% |
| `ForgeQtyStepperBox` | qty_stepper_box.dart | 🟢 0.2% |
| `ForgeSearchField` | search_field.dart | 🟡 3.4% |
| `ForgeSegPicker` | seg_picker.dart | 🟢 0.7% |
| `ForgeSmartQtyStepper` | smart_qty_stepper.dart | 🟢 1.1% |
| `ForgeTagInput` | tag_input.dart | 🟢 0.6% |
| `ForgeWheelPicker` | wheel_picker.dart | 🟢 0.6% |

### list — שורות-רשימה · swipe · manage · פריטים  `import .../dart-forge-bs/list/list.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge2Atoms` | 2_atoms.dart | 🟡 3.6% |
| `Forge4Atoms` | 4_atoms.dart | 🔴 4.8% |
| `Forge5Atoms` | 5_atoms.dart | 🔴 4.7% |
| `Forge6Atoms` | 6_atoms.dart | 🔴 4.7% |
| `Forge7Atoms` | 7_atoms.dart | 🔴 4.5% |
| `Forge8Atoms` | 8_atoms.dart | 🔴 4.8% |
| `ForgeActionRow` | action_row.dart | 🟢 1.4% |
| `ForgeCheckRow` | check_row.dart | 🟢 1.1% |
| `ForgeKvRow` | kv_row.dart | 🟢 1.2% |
| `ForgeLinkRow` | link_row.dart | 🟢 1.2% |
| `ForgeManageRow` | manage_row.dart | 🟡 3.8% |
| `ForgeNotifRow` | notif_row.dart | 🟢 1.0% |
| `ForgeNumberRow` | number_row.dart | 🟢 1.1% |
| `ForgeProfileRow` | profile_row.dart | 🟢 1.2% |
| `ForgeSwipeRow` | swipe_row.dart | 🟡 3.6% |
| `ForgeSwitchRow` | switch_row.dart | 🟢 2.0% |

### media — אווטארים · חבילות · גלריות · thumb · pager  `import .../dart-forge-bs/media/media.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge12Atoms` | 12_atoms.dart | 🔴 7.5% |
| `ForgeAvatar` | avatar.dart | 🟢 0.3% |
| `ForgeAvatarFallback` | avatar_fallback.dart | 🟢 0.4% |
| `ForgeAvatarGroup` | avatar_group.dart | 🟢 0.3% |
| `ForgeAvatarRing` | avatar_ring.dart | 🟢 1.4% |
| `ForgeAvatarStack` | avatar_stack.dart | 🟢 1.0% |
| `ForgeAvatarStatus` | avatar_status.dart | 🟢 0.4% |
| `ForgeBrandMark` | brand_mark.dart | 🟢 1.1% |
| `ForgeCoverBanner` | cover_banner.dart | 🟢 1.0% |
| `ForgeFacePileGroup` | face_pile_group.dart | 🟢 1.5% |
| `ForgeGalleryAllBtn` | gallery_all_btn.dart | 🟢 0.4% |
| `ForgeGalleryGrid` | gallery_grid.dart | 🟢 0.3% |
| `ForgeGalleryMosaic` | gallery_mosaic.dart | 🔴 4.5% |
| `ForgeHeroCoverMark` | hero_cover_mark.dart | 🟢 0.6% |
| `ForgeImageFacePager` | image_face_pager.dart | 🟢 0.7% |
| `ForgeImageTile` | image_tile.dart | 🟢 0.7% |
| `ForgeLogoMark` | logo_mark.dart | 🟢 1.6% |
| `ForgeMediaPlaceholder` | media_placeholder.dart | 🟢 0.7% |
| `ForgeMediaThumb` | media_thumb.dart | 🟢 0.0% |
| `ForgeProfileAvatar` | profile_avatar.dart | 🟢 0.1% |
| `ForgeProfileCover` | profile_cover.dart | 🟢 1.2% |
| `ForgeProofThumb` | proof_thumb.dart | 🟢 0.0% |
| `ForgeStoryReel` | story_reel.dart | 🟢 0.4% |
| `ForgeStoryRing` | story_ring.dart | 🟢 0.3% |
| `ForgeThumbPlaceholder` | thumb_placeholder.dart | 🟢 0.9% |
| `ForgeThumbStrip` | thumb_strip.dart | 🟢 0.8% |
| `ForgeThumbnail` | thumbnail.dart | 🟢 0.0% |

### motion — אנימציות · gradient · glow · particle · confetti (חלקן דורמנטיות בטסט)  `import .../dart-forge-bs/motion/motion.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `ForgeAuroraField` | aurora_field.dart | 🟢 0.6% |
| `ForgeConfettiBurst` | confetti_burst.dart | 🟢 0.5% |
| `ForgeGenerativeCanvas` | generative_canvas.dart | 🟢 0.2% |
| `ForgeGlowPulse` | glow_pulse.dart | 🟡 2.7% |
| `ForgeGradientSweep` | gradient_sweep.dart | 🔴 25.0% |
| `ForgeParallaxTilt` | parallax_tilt.dart | 🟡 2.8% |
| `ForgeParticleField` | particle_field.dart | 🟢 0.3% |
| `ForgeTypeWriter` | type_writer.dart | 🟢 0.3% |

### nav — ניווט-תחתון · rail · fab-menu · tabs · tiles  `import .../dart-forge-bs/nav/nav.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `ForgeActionChipRail` | action_chip_rail.dart | 🟡 2.3% |
| `ForgeAnimatedTabs` | animated_tabs.dart | 🟢 1.5% |
| `ForgeBreadcrumbTrail` | breadcrumb_trail.dart | 🟢 0.9% |
| `ForgeDsNavTile` | ds_nav_tile.dart | 🟢 0.4% |
| `ForgeFabMenu` | fab_menu.dart | 🟢 1.4% |
| `ForgeHomeShellMenuRow` | home_shell_menu_row.dart | 🟢 0.9% |
| `ForgeHopBreadcrumb` | hop_breadcrumb.dart | 🟢 0.9% |
| `ForgeImageFacePager` | image_face_pager.dart | 🟡 3.2% |
| `ForgeMenuRow` | menu_row.dart | 🟢 0.8% |
| `ForgeSegmentedPillToggle` | segmented_pill_toggle.dart | 🟢 0.4% |
| `ForgeStockTab` | stock_tab.dart | 🟢 0.7% |
| `ForgeWorkerNav` | worker_nav.dart | 🟢 1.8% |

### selection — צ׳יפים · דירוג-כוכבים · tag-input · facets · toggles  `import .../dart-forge-bs/selection/selection.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge14Atoms` | 14_atoms.dart | 🔴 6.1% |
| `Forge4Atoms` | 4_atoms.dart | 🟡 3.6% |
| `Forge5Atoms` | 5_atoms.dart | 🟡 2.7% |
| `Forge6Atoms` | 6_atoms.dart | 🟡 2.9% |
| `ForgeAnimatedToggle` | animated_toggle.dart | 🟡 2.7% |
| `ForgeCheckPop` | check_pop.dart | 🟢 1.0% |
| `ForgeCheckRow` | check_row.dart | 🟢 0.7% |
| `ForgeDropSelect` | drop_select.dart | 🟢 0.4% |
| `ForgeDsChip` | ds_chip.dart | 🟡 3.5% |
| `ForgeFacetChip` | facet_chip.dart | 🔴 4.6% |
| `ForgeMustChip` | must_chip.dart | 🟢 1.1% |
| `ForgePendingCheckRow` | pending_check_row.dart | 🟢 0.8% |
| `ForgePickerOption` | picker_option.dart | 🟢 1.0% |
| `ForgePickerOptionsPanel` | picker_options_panel.dart | 🟢 1.1% |
| `ForgePresetChip` | preset_chip.dart | 🟢 1.0% |
| `ForgeRatingBars` | rating_bars.dart | 🟢 0.4% |
| `ForgeRegressionPanelCheckRow` | regression_panel_check_row.dart | 🟢 0.5% |
| `ForgeSegPicker` | seg_picker.dart | 🟢 0.7% |
| `ForgeSegmentedPillToggle` | segmented_pill_toggle.dart | 🟢 0.2% |
| `ForgeSettingsSwitchRow` | settings_switch_row.dart | 🟢 1.7% |
| `ForgeStarRating` | star_rating.dart | 🟢 1.4% |
| `ForgeSwitchRow` | switch_row.dart | 🟢 1.6% |
| `ForgeTagDetailRow` | tag_detail_row.dart | 🟢 0.9% |
| `ForgeTagInput` | tag_input.dart | 🟡 2.2% |
| `ForgeTintedTag` | tinted_tag.dart | 🟢 0.7% |
| `ForgeUnitSegmentToggle` | unit_segment_toggle.dart | 🟢 0.4% |

### spatial — מרקרים · מפות-מיקום · ריווח  `import .../dart-forge-bs/spatial/spatial.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `ForgeDataTable` | data_table.dart | 🟡 3.1% |
| `ForgeMapSurface` | map_surface.dart | 🟢 1.5% |
| `ForgeMarkerStates` | marker_states.dart | 🔴 4.8% |
| `ForgeMinimap` | minimap.dart | 🟢 0.9% |
| `ForgeSortHeaderStates` | sort_header_states.dart | 🟡 3.1% |
| `ForgeTreeGrid` | tree_grid.dart | 🟢 2.0% |

### status — תגי-סטטוס · מונים · meter · pills · badges  `import .../dart-forge-bs/status/status.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge4Atoms` | 4_atoms.dart | 🔴 4.8% |
| `Forge5Atoms` | 5_atoms.dart | 🔴 6.3% |
| `Forge6Atoms` | 6_atoms.dart | 🔴 4.7% |
| `Forge9Atoms` | 9_atoms.dart | 🔴 5.7% |
| `ForgeCountBadge` | count_badge.dart | 🟢 0.7% |
| `ForgeDraftBadge` | draft_badge.dart | 🟡 2.3% |
| `ForgeHierarchyChipPill` | hierarchy_chip_pill.dart | 🟢 1.6% |
| `ForgeIntelPill` | intel_pill.dart | 🟢 1.0% |
| `ForgeLinearProgress` | linear_progress.dart | 🟡 3.1% |
| `ForgeLiveStatusDot` | live_status_dot.dart | 🟢 0.6% |
| `ForgeLiveStatusPill` | live_status_pill.dart | 🟢 0.9% |
| `ForgeMeter` | meter.dart | 🟡 3.9% |
| `ForgeNotifyBadge` | notify_badge.dart | 🟢 2.0% |
| `ForgeProgressRing` | progress_ring.dart | 🟢 0.5% |
| `ForgeProgressStatRow` | progress_stat_row.dart | 🟡 2.5% |
| `ForgePulsingStatus` | pulsing_status.dart | 🟢 1.1% |
| `ForgeRadialGauge` | radial_gauge.dart | 🟢 0.8% |
| `ForgeScoreBandChip` | score_band_chip.dart | 🟡 2.7% |
| `ForgeSectionPill` | section_pill.dart | 🟢 1.1% |
| `ForgeSeverityChip` | severity_chip.dart | 🟡 2.1% |
| `ForgeStagePill` | stage_pill.dart | 🔴 4.6% |
| `ForgeStatTile` | stat_tile.dart | 🟢 1.2% |
| `ForgeStatusChip` | status_chip.dart | 🔴 8.5% |
| `ForgeStatusDot` | status_dot.dart | 🟢 1.3% |
| `ForgeStatusDotChip` | status_dot_chip.dart | 🟢 1.9% |
| `ForgeTintedBadgeRow` | tinted_badge_row.dart | 🟡 3.7% |
| `ForgeTrendIndicator` | trend_indicator.dart | 🟢 1.5% |

### temporal — שעונים · countdown · ticker · זמן-יחסי  `import .../dart-forge-bs/temporal/temporal.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `ForgeCountdownTimer` | countdown_timer.dart | 🔴 4.6% |
| `ForgeLiveClockRelativeTime` | live_clock_relative_time.dart | 🔴 6.3% |
| `ForgeMetaTicker` | meta_ticker.dart | 🔴 5.1% |
| `ForgeMiniCalendar` | mini_calendar.dart | 🟢 1.0% |
| `ForgeRangePicker` | range_picker.dart | 🟢 0.3% |
| `ForgeTimeSlot` | time_slot.dart | 🟢 0.0% |
| `ForgeWeekStripDateCellTheater` | week_strip_date_cell_theater.dart | 🟡 2.7% |

### text — סולם-טיפוגרפי · ציטוט · הדגשה · gradient · truncate · listים  `import .../dart-forge-bs/text/text.dart`

| מחלקה | קובץ | דיף |
|---|---|---|
| `Forge7Atoms` | 7_atoms.dart | 🔴 4.7% |
| `ForgeBulletList` | bullet_list.dart | 🟡 3.1% |
| `ForgeCodeBlock` | code_block.dart | 🟡 2.6% |
| `ForgeEmphasisText` | emphasis_text.dart | 🔴 6.3% |
| `ForgeEyebrow` | eyebrow.dart | 🟢 1.9% |
| `ForgeGradientText` | gradient_text.dart | 🔴 5.5% |
| `ForgeLinkRow` | link_row.dart | 🔴 4.3% |
| `ForgeMarquee` | marquee.dart | 🔴 4.3% |
| `ForgeNumberedList` | numbered_list.dart | 🟡 2.7% |
| `ForgeOverline` | overline.dart | 🟢 1.6% |
| `ForgePullQuote` | pull_quote.dart | 🔴 7.2% |
| `ForgeSectionLabel` | section_label.dart | 🟢 1.4% |
| `ForgeTruncClamp` | trunc_clamp.dart | 🔴 4.8% |
| `ForgeTruncOne` | trunc_one.dart | 🔴 4.3% |
| `ForgeTypeScale` | type_scale.dart | 🔴 4.4% |
| `ForgeVoicePair` | voice_pair.dart | 🔴 6.6% |
