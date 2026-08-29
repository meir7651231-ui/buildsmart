// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__catalog_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 22.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter/services.dart';
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/atoms/atom_flag.dart';
import 'package:buildsmart/atoms/atom_home_screen.dart';
import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/fuzzy_search.dart';
import 'package:buildsmart/data/line_score.dart';
import 'package:buildsmart/data/score_band.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/search_index.dart';
import 'package:buildsmart/data/sections.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/features/card_keyboard/card_keyboard_screen.dart';
import 'package:buildsmart/features/ring_dive/catalog_wheel_screen.dart';
import 'package:buildsmart/features/ring_dive/plain_dive_screen.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_flag.dart';
import 'package:buildsmart/features/ring_dive/ring_dive_screen.dart';
import 'package:buildsmart/features/word_finder/word_finder_home.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/smart_home_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/finder_screen.dart';
import 'package:buildsmart/screens/install_studio_screen.dart';
import 'package:buildsmart/screens/legal_screen.dart';
import 'package:buildsmart/state/card_detail_mode.dart';
import 'package:buildsmart/state/card_projects.dart';
import 'package:buildsmart/state/brand_history.dart';
import 'package:buildsmart/state/card_acc_state.dart';
import 'package:buildsmart/state/card_filter_state.dart';
import 'package:buildsmart/state/card_selection.dart';
import 'package:buildsmart/state/card_versions.dart';
import 'package:buildsmart/state/profession_mode.dart';
import 'package:buildsmart/state/project_mode.dart';
import 'package:buildsmart/state/default_brand_resolver.dart';
import 'package:buildsmart/state/display_temp.dart';
import 'package:buildsmart/state/cart_safety.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/hidden_catalog_sections.dart';
import 'package:buildsmart/state/intel/intel_bus.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/keyboard_job_context.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/product_favorites.dart';
import 'package:buildsmart/state/recent_searches.dart';
import 'package:buildsmart/state/recently_viewed.dart';
import 'package:buildsmart/state/saved_configs.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/stage_progress.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/smart_input/keyboard/bs_keyboard_field.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:buildsmart/screens/company_catalog_import_sheet.dart';
import '../dart-screens-bs/catalog_screen.g.dart';

class CatalogScreenBoard extends ConsumerWidget {
  const CatalogScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CatalogScreenComposed(
      onQtyChanged: () {} /* TODO-לוח */,
      onTap: () => showCompanyCatalogImportSheet(context),
      onToggle: () {} /* TODO-לוח */,
      activeMatch: null /* TODO-לוח: List<String>? */,
      axisChipItems: const [] /* TODO-לוח: List<AxisChipItem> */,
      child: const SizedBox.shrink() /* TODO-לוח: Widget */,
      count: 0 /* TODO-לוח: int */,
      emoji: '' /* TODO-לוח: String */,
      expanded: false /* TODO-לוח: bool */,
      facetRowItems: const [] /* TODO-לוח: List<FacetRowItem> */,
      icon: Icons.remove,
      isSelected: false /* TODO-לוח: bool */,
      label: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      options: const [] /* TODO-לוח: List<String> */,
      price: null /* TODO-לוח: int? */,
      qty: 0 /* TODO-לוח: int */,
      savedVersionChipItems: const [] /* TODO-לוח: List<SavedVersionChipItem> */,
      selected: null /* TODO-לוח: String? */,
      selected2: false /* TODO-לוח: bool */,
      text: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      why: '' /* TODO-לוח: String */,
      t: CatalogScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
