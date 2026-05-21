/* @legacy index.html:7455-7484 (renderProjects). Placeholder — shows
 * only the verbatim project names from the prototype. Full site cards
 * (cart count, tree progress, budget, status) come in a later cut. */
import { PROJECTS } from '../data/projects';

export function SitesView() {
  return (
    <section class="sites" aria-label="הפרויקטים שלי">
      <header class="sites__head">
        <h2 class="sites__title">הפרויקטים שלי</h2>
        <p class="sites__sub">בבנייה — לעת עתה שמות בלבד מהאב-טיפוס</p>
      </header>
      <ul class="sites__list">
        {PROJECTS.map((p) => (
          <li key={p.id} class="sites__row">
            <span class="sites__name">{p.name}</span>
            <span class="sites__addr">{p.addr}</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
