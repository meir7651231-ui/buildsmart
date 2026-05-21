/* @legacy index.html:4260-4263 (admTab buttons for screen-store).
 * Phase 0 skeleton — verbatim section names only. No state, no actions. */

type Section = { id: string; emoji: string; title: string };

const SECTIONS: Section[] = [
  { id: 's-home',    emoji: '🏠', title: 'בית' },
  { id: 's-orders',  emoji: '📥', title: 'הזמנות' },
  { id: 's-stock',   emoji: '📦', title: 'מלאי' },
  { id: 's-portal',  emoji: '🧰', title: 'פורטל' },
];

export function StoreView() {
  return (
    <section class="dash" aria-label="לוח חנות ספק">
      <header class="dash__head">
        <span class="dash__emoji" aria-hidden="true">🏪</span>
        <div>
          <h2 class="dash__title">חנות ספק</h2>
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
