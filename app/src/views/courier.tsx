/* @legacy index.html:17991-18045 (renderCourierHome) + :4291 (screen-courier).
 * Phase 0 skeleton — verbatim section names only. No state, no actions. */

type Section = { id: string; emoji: string; title: string };

const SECTIONS: Section[] = [
  { id: 'vehicle',   emoji: '🛻', title: 'הרכב שלי היום' },
  { id: 'pickup',    emoji: '📦', title: 'משלוחים ממתינים לאיסוף' },
  { id: 'active',    emoji: '🚚', title: 'משלוחים פעילים' },
  { id: 'portal',    emoji: '🧰', title: 'פורטל השליח' },
];

export function CourierView() {
  return (
    <section class="dash" aria-label="לוח שליח">
      <header class="dash__head">
        <span class="dash__emoji" aria-hidden="true">🛵</span>
        <div>
          <h2 class="dash__title">שליח</h2>
          <p class="dash__sub">בבנייה — לעת עתה כותרות sections בלבד</p>
        </div>
      </header>
      <ul class="dash__sections">
        {SECTIONS.map((s) => (
          <li key={s.id} class="dash__section">
            <span class="dash__section-ic" aria-hidden="true">{s.emoji}</span>
            <span class="dash__section-t">{s.title}</span>
            <span class="dash__section-tag">בבנייה</span>
          </li>
        ))}
      </ul>
    </section>
  );
}
