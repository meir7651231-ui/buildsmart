// 🖥️ מרשם-המסכים — the screens the wizard's "ניהול מסכים" manages (screen-
// management directive · slice-2), each with its ordered sections. Home is fully
// section-built (its 5 REAL sections; ids == HomeSection.name so the slice-5
// migration is a clean map). Contractor / manager / store are declared as screens
// (level-1 order/hide of a whole screen) but NOT yet section-built — their level-2
// shows a slice-5 placeholder rather than inventing sections ("אין המצאות").

/// The [screenSectionsProvider] key for the screen-LIST level (ordering / hiding
/// whole screens), deliberately distinct from any real screen id.
const String kScreensRootKey = '__screens__';

/// One manageable section within a screen (a level-2 row).
class ManagedSection {
  const ManagedSection(this.id, this.emoji, this.labelHe);

  final String id;
  final String emoji;
  final String labelHe;
}

/// One manageable screen (a level-1 row). [sections] empty ⇒ not yet
/// section-built (level-2 is a placeholder until slice-5 structures it).
/// [keyboardTools] are the screen's per-screen keyboard tiles (ids == the tool
/// LABEL, the keyboard's own identity) — edited FROM the screen editor (slice-4),
/// never from the keyboard itself (a tool must not edit itself).
class ManagedScreen {
  const ManagedScreen(this.id, this.emoji, this.labelHe,
      {this.sections = const [], this.keyboardTools = const []});

  final String id;
  final String emoji;
  final String labelHe;
  final List<ManagedSection> sections;
  final List<ManagedSection> keyboardTools;

  bool get isSectionBuilt => sections.isNotEmpty;
  bool get hasKeyboard => keyboardTools.isNotEmpty;
}

/// The [screenSectionsProvider] key for a screen's KEYBOARD-tool layout (order /
/// hide of the per-screen keyboard tiles), distinct from the section layout.
String keyboardLayoutKey(String screenId) => 'kbd:$screenId';

/// The managed screens (level-1), in default order. Home first (fully
/// section-built — verbatim from `kHomeSectionMeta`). The rest carry screen-level
/// order/hide now; their sections arrive gradually (slice-5).
// NOTE (slice-5): the 👷 קבלן persona has NO separate board — picking it CLEARS
// the persona and lands on HomeShell → SmartHomeBody (role_picker_sheet.dart), so
// the contractor's board literally IS the home screen (already section-built ·
// slice-3). There is therefore no distinct 'contractor' screen to manage — the
// 'home' entry below IS the contractor's board (label reflects both).
const List<ManagedScreen> kManagedScreens = [
  ManagedScreen('home', '🏠', 'מסך הבית (לוח הקבלן)', sections: [
    ManagedSection('categories', '🗂️', 'מחלקות'),
    ManagedSection('products', '🌳', 'עץ חכם — אינסטלציה'),
    ManagedSection('workPath', '🛁', 'מסלול עבודה חכם'),
    ManagedSection('promise', '⚡', 'כלים מהירים'),
    ManagedSection('reorderHistory', '🔁', 'הזמנות אחרונות לאתר'),
  ], keyboardTools: [
    // The 8 HOME keyboard tiles (kbHomeNodes) — ids == the tile LABEL.
    ManagedSection('מחלקות', '🗂️', 'מחלקות'),
    ManagedSection('עץ חכם', '🌳', 'עץ חכם'),
    ManagedSection('מסלול', '🛣️', 'מסלול'),
    ManagedSection('מהירים', '⚡', 'מהירים'),
    ManagedSection('הזמנות', '📦', 'הזמנות'),
    ManagedSection('מאתר', '🔎', 'מאתר'),
    ManagedSection('חיבור', '🔌', 'חיבור'),
    ManagedSection('מועדפים', '⭐', 'מועדפים'),
  ]),
  // 👔 לוח מנהל — live section editor (slice-5b): ids == ManagerDashSection.name.
  // 'studio' is compile-dev-only (excluded here); 'attention' is opt-in (rendered
  // only when the company enables manager.attention) but stays orderable/hideable.
  ManagedScreen('manager', '👔', 'לוח מנהל', sections: [
    ManagedSection('copilot', '🤖', 'קו-פיילוט'),
    ManagedSection('studioEntry', '🎨', 'כניסת סטודיו'),
    ManagedSection('attention', '🔔', 'דורש טיפול'),
    ManagedSection('kpis', '📊', 'כרטיסי מדדים'),
    ManagedSection('pipeline', '📈', 'צינור ההזמנות'),
  ]),
  ManagedScreen('store', '🏪', 'חנות ספק'),
];
