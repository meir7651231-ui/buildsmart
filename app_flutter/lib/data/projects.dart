/// @legacy index.html:6447-6451 (PROJECTS array). Verbatim.
class Project {
  const Project({
    required this.id,
    required this.name,
    required this.addr,
    required this.manager,
  });

  final String id;
  final String name;
  final String addr;
  final String manager;
}

const List<Project> kProjects = [
  Project(
    id: 'PRJ-1',
    name: 'מגדל הרצליה — קומה 4',
    addr: "רח' הנדיב 12, הרצליה",
    manager: 'יוסי כהן',
  ),
  Project(
    id: 'PRJ-2',
    name: 'וילה כפר שמריהו',
    addr: "רח' האלון 4, כפר שמריהו",
    manager: 'אבי מזרחי',
  ),
  Project(
    id: 'PRJ-3',
    name: 'שיפוץ משרדים — רעננה',
    addr: 'אחוזה 88, רעננה',
    manager: 'דנה לוי',
  ),
];

const String kActiveProjectId = 'PRJ-1';
