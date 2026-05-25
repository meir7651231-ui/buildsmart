/// BS personas — verbatim from index.html role-pick-btn @:4088-4113.
/// Same 5-persona model as the Preact app (TILES in bs-dial.tsx).
class Persona {
  const Persona({
    required this.id,
    required this.emoji,
    required this.title,
  });

  final String id;
  final String emoji;
  final String title;
}

const List<Persona> kPersonas = [
  Persona(id: 'contractor', emoji: '👷', title: 'קבלן'),
  Persona(id: 'manager',    emoji: '👔', title: 'מנהל המערכת'),
  Persona(id: 'store',      emoji: '🏪', title: 'חנות ספק'),
  Persona(id: 'courier',    emoji: '🛵', title: 'שליח'),
  Persona(id: 'worker',     emoji: '🦺', title: 'עובד'),
];
