/* @legacy index.html:6447-6451 (PROJECTS array). Verbatim. */

export type Project = {
  id: string;
  name: string;
  addr: string;
  manager: string;
};

export const PROJECTS: Project[] = [
  { id: 'PRJ-1', name: 'מגדל הרצליה — קומה 4', addr: "רח' הנדיב 12, הרצליה", manager: 'יוסי כהן' },
  { id: 'PRJ-2', name: 'וילה כפר שמריהו',     addr: "רח' האלון 4, כפר שמריהו", manager: 'אבי מזרחי' },
  { id: 'PRJ-3', name: 'שיפוץ משרדים — רעננה', addr: 'אחוזה 88, רעננה',         manager: 'דנה לוי'   },
];

export const ACTIVE_PROJECT_ID = 'PRJ-1';
