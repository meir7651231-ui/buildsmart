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
class ManagedScreen {
  const ManagedScreen(this.id, this.emoji, this.labelHe,
      {this.sections = const []});

  final String id;
  final String emoji;
  final String labelHe;
  final List<ManagedSection> sections;

  bool get isSectionBuilt => sections.isNotEmpty;
}

/// The managed screens (level-1), in default order. Home first (fully
/// section-built — verbatim from `kHomeSectionMeta`). The rest carry screen-level
/// order/hide now; their sections arrive gradually (slice-5).
const List<ManagedScreen> kManagedScreens = [
  ManagedScreen('home', '🏠', 'מסך הבית', sections: [
    ManagedSection('categories', '🗂️', 'מחלקות'),
    ManagedSection('products', '🌳', 'עץ חכם — אינסטלציה'),
    ManagedSection('workPath', '🛁', 'מסלול עבודה חכם'),
    ManagedSection('promise', '⚡', 'כלים מהירים'),
    ManagedSection('reorderHistory', '🔁', 'הזמנות אחרונות לאתר'),
  ]),
  ManagedScreen('contractor', '👷', 'לוח קבלן'),
  ManagedScreen('manager', '👔', 'לוח מנהל'),
  ManagedScreen('store', '🏪', 'חנות ספק'),
];
