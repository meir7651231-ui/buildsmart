// 🧪 חולל ע"י מחולל-הלוחות (board-gen) — שער-ההצצה למסכי-הגנסיס. אל תערוך ידנית.
// חוק-7 (החלפה-הפיכה): הדגל כבוי כברירת-מחדל ⇒ collection-if מעלים הכול — זהות-ביט.
// הדלקה: flutter run --dart-define=GENESIS_SCREENS=true
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/widgets/toast.dart' show bsNavigatorKey;
import '../dart-gen-bs/gen_business.dart';
import '../dart-gen-bs/gen_entry.dart';
import '../dart-gen-bs/gen_shipping.dart';
import '../dart-gen-bs/gen_team.dart';
import 'screens__ai_hub_screen_board.dart';
import 'screens__budget_screen_board.dart';
import 'screens__camera_sheet_board.dart';
import 'features__catalog_config__catalog_config_screen_board.dart';
import 'features__catalog_config__wheel_picker_board.dart';
import 'screens__catalog_screen_board.dart';
import 'screens__catalog_settings_screen_board.dart';
import 'screens__chat_settings_screen_board.dart';
import 'screens__chats_screen_board.dart';
import 'screens__consent_modal_board.dart';
import 'screens__contractor_hr_sheet_board.dart';
import 'screens__contractor_material_requests_sheet_board.dart';
import 'screens__contractor_tools_sheets_board.dart';
import 'screens__courier_attendance_screen_board.dart';
import 'screens__courier_certs_screen_board.dart';
import 'screens__courier_dashboard_screen_board.dart';
import 'screens__courier_forms_screen_board.dart';
import 'screens__courier_portal_tab_board.dart';
import 'screens__courier_profile_screen_board.dart';
import 'screens__courier_reports_tab_board.dart';
import 'screens__courier_settings_screen_board.dart';
import 'screens__defects_sheet_board.dart';
import 'screens__docs_readiness_gate_board.dart';
import 'screens__finance_hub_sheets_board.dart';
import 'screens__finder_screen_board.dart';
import 'features__fittings__intel__build_plan_screen_board.dart';
import 'screens__home_shell_board.dart';
import 'screens__install_studio_screen_board.dart';
import 'screens__intel__intel_tab_board.dart';
import 'screens__legal_screen_board.dart';
import 'screens__lipskey_brand_screen_board.dart';
import 'screens__lipskey_product_sheet_board.dart';
import 'screens__lipskey_products_screen_board.dart';
import 'screens__manager_copilot_screen_board.dart';
import 'screens__manager_dashboard_screen_board.dart';
import 'screens__manager_profile_screen_board.dart';
import 'screens__manager_role_assign_sheet_board.dart';
import 'screens__notif_settings_screen_board.dart';
import 'screens__notifications_screen_board.dart';
import 'screens__persona_picking_sheet_board.dart';
import 'screens__persona_portal_board.dart';
import 'screens__profile_screen_board.dart';
import 'screens__projects_screen_board.dart';
import 'screens__regression_panel_screen_board.dart';
import 'screens__rewards_hub_screen_board.dart';
import 'screens__role_requests_inbox_screen_board.dart';
import 'screens__site_hub_screen_board.dart';
import 'screens__smart_home_screen_board.dart';
import 'screens__smart_project_screen_board.dart';
import 'screens__stock_screen_board.dart';
import 'screens__store_dashboard_screen_board.dart';
import 'screens__store_profile_screen_board.dart';
import 'screens__store_screen_board.dart';
import 'screens__store_settings_screen_board.dart';
import 'screens__studio__panes__find_replace_pane_board.dart';
import 'screens__studio__panes__theme_pane_board.dart';
import 'screens__studio__studio_top_bar_board.dart';
import 'screens__suppliers_screen_board.dart';
import 'screens__tasks_screen_board.dart';
import 'screens__trade_builder__accessory_rule_editor_board.dart';
import 'screens__trade_builder__attribute_schema_editor_board.dart';
import 'screens__trade_builder__category_tree_editor_board.dart';
import 'screens__trade_builder__connection_rule_studio_board.dart';
import 'screens__trade_builder__product_authoring_screen_board.dart';
import 'screens__trade_builder__trade_builder_home_board.dart';
import 'screens__trade_builder__trade_define_step_board.dart';
import 'screens__trade_builder__trade_publish_sheet_board.dart';
import 'screens__worker_app_screen_board.dart';
import 'screens__worker_attendance_screen_board.dart';
import 'screens__worker_employer_stock_sheet_board.dart';
import 'screens__worker_equipment_checklist_sheet_board.dart';
import 'screens__worker_forms_screen_board.dart';
import 'screens__worker_notifs_sheet_board.dart';
import 'screens__worker_profile_screen_board.dart';
import 'screens__worker_report_drilldowns_board.dart';
import 'screens__worker_reports_tab_board.dart';
import 'screens__worker_safety_screen_board.dart';
import 'screens__worker_settings_screen_board.dart';
import 'screens__worker_task_detail_sheet_board.dart';

const bool kGenesisScreens = bool.fromEnvironment('GENESIS_SCREENS');

/// מצב מחצב-בלבד (GENESIS_ONLY): האפליקציה כולה = הגלריה — רק מה שהמנועים בנו,
/// בלי האפליקציה-המקורית בכלל. הכרעת-בעלים 29.8 "אני רוצה לראות רק מה שהוא בנה".
const bool kGenesisOnly = bool.fromEnvironment('GENESIS_ONLY');

/// שורש עצמאי לגלריה — ProviderScope משלו (הלוחות הם ConsumerWidgets) + RTL.
class GenesisApp extends StatelessWidget {
  const GenesisApp({super.key});

  @override
  Widget build(BuildContext context) => ProviderScope(
        child: MaterialApp(
          title: 'המחצב — מסכי-הגנסיס',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF223047)),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
          home: const _GenEntryHost(),
        ),
      );
}

/// 🧬 מארח-הכניסה (הכרעה 18): מסך-הכניסה שהמחולל יצר לעצמו + כפתור-צף אל הגלריה.
class _GenEntryHost extends StatelessWidget {
  const _GenEntryHost();

  @override
  Widget build(BuildContext context) => Stack(children: [
        const GenEntryScreen(),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton.small(
                heroTag: 'genesis-enter',
                tooltip: 'כל המסכים',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GenesisGallery()),
                ),
                child: const Text('🧪', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ]);
}


/// כפתור-כניסה צף (🧪) — נטען-לצד מעל-הניווט; קיים רק כשהדגל דלוק.
class GenesisEntryButton extends StatelessWidget {
  const GenesisEntryButton({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 96),
            child: FloatingActionButton.small(
              heroTag: 'genesis-gallery',
              tooltip: 'מסכי-הגנסיס (תצוגה-לצד)',
              onPressed: () => bsNavigatorKey.currentState?.push(
                MaterialPageRoute(builder: (_) => const GenesisGallery()),
              ),
              child: const Text('🧪', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      );
}

class _GEntry {
  const _GEntry(this.name, this.subtitle, this.build);
  final String name;
  final String subtitle;
  final Widget Function() build;
}

/// הגלריה: 🧬 מסכי-המחולל (בקשה⇒מסך) בראש, ואחריהם המסכים-המורכבים-מהמקור.
class GenesisGallery extends StatelessWidget {
  const GenesisGallery({super.key});

  static final List<_GEntry> _screens = [
    _GEntry('🧬 פרופיל עסק', 'נוצר מהמחולל — חיווט-מלא', () => const GenBusinessScreen()),
    _GEntry('🧬 המחולל', 'נוצר מהמחולל — חיווט-מלא', () => const GenEntryScreen()),
    _GEntry('🧬 הגדרות משלוחים', 'נוצר מהמחולל — חיווט-מלא', () => const GenShippingScreen()),
    _GEntry('🧬 ניהול צוות', 'נוצר מהמחולל — חיווט-מלא', () => const GenTeamScreen()),
    _GEntry('ai hub screen', 'מחווט: 0 · ממתין-לחיווט: 1', () => const AiHubScreenBoard()),
    _GEntry('budget screen', 'מחווט: 2 · ממתין-לחיווט: 5', () => const BudgetScreenBoard()),
    _GEntry('camera sheet', 'מחווט: 1 · ממתין-לחיווט: 6', () => const CameraSheetBoard()),
    _GEntry('catalog config · catalog config screen', 'מחווט: 1 · ממתין-לחיווט: 1', () => const CatalogConfigCatalogConfigScreenBoard()),
    _GEntry('catalog config · wheel picker', 'מחווט: 0 · ממתין-לחיווט: 0', () => const CatalogConfigWheelPickerBoard()),
    _GEntry('catalog screen', 'מחווט: 4 · ממתין-לחיווט: 23', () => const CatalogScreenBoard()),
    _GEntry('catalog settings screen', 'מחווט: 2 · ממתין-לחיווט: 0', () => const CatalogSettingsScreenBoard()),
    _GEntry('chat settings screen', 'מחווט: 0 · ממתין-לחיווט: 3', () => const ChatSettingsScreenBoard()),
    _GEntry('chats screen', 'מחווט: 1 · ממתין-לחיווט: 9', () => const ChatsScreenBoard()),
    _GEntry('consent modal', 'מחווט: 1 · ממתין-לחיווט: 2', () => const ConsentModalBoard()),
    _GEntry('contractor hr sheet', 'מחווט: 1 · ממתין-לחיווט: 7', () => const ContractorHrSheetBoard()),
    _GEntry('contractor material requests sheet', 'מחווט: 0 · ממתין-לחיווט: 1', () => const ContractorMaterialRequestsSheetBoard()),
    _GEntry('contractor tools sheets', 'מחווט: 1 · ממתין-לחיווט: 0', () => const ContractorToolsSheetsBoard()),
    _GEntry('courier attendance screen', 'מחווט: 1 · ממתין-לחיווט: 4', () => const CourierAttendanceScreenBoard()),
    _GEntry('courier certs screen', 'מחווט: 0 · ממתין-לחיווט: 1', () => const CourierCertsScreenBoard()),
    _GEntry('courier dashboard screen', 'מחווט: 1 · ממתין-לחיווט: 6', () => const CourierDashboardScreenBoard()),
    _GEntry('courier forms screen', 'מחווט: 1 · ממתין-לחיווט: 14', () => const CourierFormsScreenBoard()),
    _GEntry('courier portal tab', 'מחווט: 0 · ממתין-לחיווט: 3', () => const CourierPortalTabBoard()),
    _GEntry('courier profile screen', 'מחווט: 4 · ממתין-לחיווט: 1', () => const CourierProfileScreenBoard()),
    _GEntry('courier reports tab', 'מחווט: 0 · ממתין-לחיווט: 3', () => const CourierReportsTabBoard()),
    _GEntry('courier settings screen', 'מחווט: 2 · ממתין-לחיווט: 0', () => const CourierSettingsScreenBoard()),
    _GEntry('defects sheet', 'מחווט: 0 · ממתין-לחיווט: 3', () => const DefectsSheetBoard()),
    _GEntry('docs readiness gate', 'מחווט: 1 · ממתין-לחיווט: 1', () => const DocsReadinessGateBoard()),
    _GEntry('finance hub sheets', 'מחווט: 1 · ממתין-לחיווט: 26', () => const FinanceHubSheetsBoard()),
    _GEntry('finder screen', 'מחווט: 0 · ממתין-לחיווט: 1', () => const FinderScreenBoard()),
    _GEntry('fittings · intel · build plan screen', 'מחווט: 0 · ממתין-לחיווט: 4', () => const FittingsIntelBuildPlanScreenBoard()),
    _GEntry('home shell', 'מחווט: 1 · ממתין-לחיווט: 1', () => const HomeShellBoard()),
    _GEntry('install studio screen', 'מחווט: 1 · ממתין-לחיווט: 2', () => const InstallStudioScreenBoard()),
    _GEntry('intel · intel tab', 'מחווט: 0 · ממתין-לחיווט: 0', () => const IntelIntelTabBoard()),
    _GEntry('legal screen', 'מחווט: 0 · ממתין-לחיווט: 0', () => const LegalScreenBoard()),
    _GEntry('lipskey brand screen', 'מחווט: 2 · ממתין-לחיווט: 5', () => const LipskeyBrandScreenBoard()),
    _GEntry('lipskey product sheet', 'מחווט: 2 · ממתין-לחיווט: 3', () => const LipskeyProductSheetBoard()),
    _GEntry('lipskey products screen', 'מחווט: 1 · ממתין-לחיווט: 10', () => const LipskeyProductsScreenBoard()),
    _GEntry('manager copilot screen', 'מחווט: 2 · ממתין-לחיווט: 1', () => const ManagerCopilotScreenBoard()),
    _GEntry('manager dashboard screen', 'מחווט: 3 · ממתין-לחיווט: 13', () => const ManagerDashboardScreenBoard()),
    _GEntry('manager profile screen', 'מחווט: 0 · ממתין-לחיווט: 1', () => const ManagerProfileScreenBoard()),
    _GEntry('manager role assign sheet', 'מחווט: 1 · ממתין-לחיווט: 3', () => const ManagerRoleAssignSheetBoard()),
    _GEntry('notif settings screen', 'מחווט: 0 · ממתין-לחיווט: 1', () => const NotifSettingsScreenBoard()),
    _GEntry('notifications screen', 'מחווט: 1 · ממתין-לחיווט: 2', () => const NotificationsScreenBoard()),
    _GEntry('persona picking sheet', 'מחווט: 0 · ממתין-לחיווט: 2', () => const PersonaPickingSheetBoard()),
    _GEntry('persona portal', 'מחווט: 0 · ממתין-לחיווט: 1', () => const PersonaPortalBoard()),
    _GEntry('profile screen', 'מחווט: 2 · ממתין-לחיווט: 3', () => const ProfileScreenBoard()),
    _GEntry('projects screen', 'מחווט: 1 · ממתין-לחיווט: 0', () => const ProjectsScreenBoard()),
    _GEntry('regression panel screen', 'מחווט: 0 · ממתין-לחיווט: 11', () => const RegressionPanelScreenBoard()),
    _GEntry('rewards hub screen', 'מחווט: 2 · ממתין-לחיווט: 2', () => const RewardsHubScreenBoard()),
    _GEntry('role requests inbox screen', 'מחווט: 1 · ממתין-לחיווט: 0', () => const RoleRequestsInboxScreenBoard()),
    _GEntry('site hub screen', 'מחווט: 0 · ממתין-לחיווט: 12', () => const SiteHubScreenBoard()),
    _GEntry('smart home screen', 'מחווט: 0 · ממתין-לחיווט: 4', () => const SmartHomeScreenBoard()),
    _GEntry('smart project screen', 'מחווט: 3 · ממתין-לחיווט: 1', () => const SmartProjectScreenBoard()),
    _GEntry('stock screen', 'מחווט: 3 · ממתין-לחיווט: 3', () => const StockScreenBoard()),
    _GEntry('store dashboard screen', 'מחווט: 1 · ממתין-לחיווט: 6', () => const StoreDashboardScreenBoard()),
    _GEntry('store profile screen', 'מחווט: 1 · ממתין-לחיווט: 0', () => const StoreProfileScreenBoard()),
    _GEntry('store screen', 'מחווט: 2 · ממתין-לחיווט: 18', () => const StoreScreenBoard()),
    _GEntry('store settings screen', 'מחווט: 4 · ממתין-לחיווט: 8', () => const StoreSettingsScreenBoard()),
    _GEntry('studio · panes · find replace pane', 'מחווט: 1 · ממתין-לחיווט: 1', () => const StudioPanesFindReplacePaneBoard()),
    _GEntry('studio · panes · theme pane', 'מחווט: 1 · ממתין-לחיווט: 2', () => const StudioPanesThemePaneBoard()),
    _GEntry('studio · studio top bar', 'מחווט: 0 · ממתין-לחיווט: 1', () => const StudioStudioTopBarBoard()),
    _GEntry('suppliers screen', 'מחווט: 1 · ממתין-לחיווט: 1', () => const SuppliersScreenBoard()),
    _GEntry('tasks screen', 'מחווט: 1 · ממתין-לחיווט: 7', () => const TasksScreenBoard()),
    _GEntry('trade builder · accessory rule editor', 'מחווט: 0 · ממתין-לחיווט: 9', () => const TradeBuilderAccessoryRuleEditorBoard()),
    _GEntry('trade builder · attribute schema editor', 'מחווט: 1 · ממתין-לחיווט: 3', () => const TradeBuilderAttributeSchemaEditorBoard()),
    _GEntry('trade builder · category tree editor', 'מחווט: 1 · ממתין-לחיווט: 5', () => const TradeBuilderCategoryTreeEditorBoard()),
    _GEntry('trade builder · connection rule studio', 'מחווט: 4 · ממתין-לחיווט: 4', () => const TradeBuilderConnectionRuleStudioBoard()),
    _GEntry('trade builder · product authoring screen', 'מחווט: 1 · ממתין-לחיווט: 6', () => const TradeBuilderProductAuthoringScreenBoard()),
    _GEntry('trade builder · trade builder home', 'מחווט: 1 · ממתין-לחיווט: 1', () => const TradeBuilderTradeBuilderHomeBoard()),
    _GEntry('trade builder · trade define step', 'מחווט: 1 · ממתין-לחיווט: 4', () => const TradeBuilderTradeDefineStepBoard()),
    _GEntry('trade builder · trade publish sheet', 'מחווט: 0 · ממתין-לחיווט: 3', () => const TradeBuilderTradePublishSheetBoard()),
    _GEntry('worker app screen', 'מחווט: 2 · ממתין-לחיווט: 15', () => const WorkerAppScreenBoard()),
    _GEntry('worker attendance screen', 'מחווט: 0 · ממתין-לחיווט: 6', () => const WorkerAttendanceScreenBoard()),
    _GEntry('worker employer stock sheet', 'מחווט: 5 · ממתין-לחיווט: 2', () => const WorkerEmployerStockSheetBoard()),
    _GEntry('worker equipment checklist sheet', 'מחווט: 2 · ממתין-לחיווט: 1', () => const WorkerEquipmentChecklistSheetBoard()),
    _GEntry('worker forms screen', 'מחווט: 1 · ממתין-לחיווט: 14', () => const WorkerFormsScreenBoard()),
    _GEntry('worker notifs sheet', 'מחווט: 0 · ממתין-לחיווט: 2', () => const WorkerNotifsSheetBoard()),
    _GEntry('worker profile screen', 'מחווט: 0 · ממתין-לחיווט: 4', () => const WorkerProfileScreenBoard()),
    _GEntry('worker report drilldowns', 'מחווט: 1 · ממתין-לחיווט: 1', () => const WorkerReportDrilldownsBoard()),
    _GEntry('worker reports tab', 'מחווט: 0 · ממתין-לחיווט: 4', () => const WorkerReportsTabBoard()),
    _GEntry('worker safety screen', 'מחווט: 1 · ממתין-לחיווט: 1', () => const WorkerSafetyScreenBoard()),
    _GEntry('worker settings screen', 'מחווט: 2 · ממתין-לחיווט: 3', () => const WorkerSettingsScreenBoard()),
    _GEntry('worker task detail sheet', 'מחווט: 1 · ממתין-לחיווט: 1', () => const WorkerTaskDetailSheetBoard()),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('🧪 מסכי-הגנסיס — תצוגה-לצד')),
        body: ListView.separated(
          itemCount: _screens.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = _screens[i];
            return ListTile(
              title: Text(e.name),
              subtitle: Text(e.subtitle),
              trailing: const Icon(Icons.chevron_left),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => e.build()),
              ),
            );
          },
        ),
      );
}
