/* @legacy index.html:11832-... (renderWorker). Section labels verbatim
 * from the task-group headers at :8099-8102. Phase 0 skeleton — names
 * only. No state, no actions. Worker picker + summary blocks come in
 * later phases. */

type Section = { id: string; emoji: string; title: string };

const SECTIONS: Section[] = [
  { id: 'current',   emoji: '🔨', title: 'המשימה הנוכחית שלך' },
  { id: 'queue',     emoji: '⏳', title: 'הבאות בתור' },
  { id: 'submitted', emoji: '📋', title: 'שהגשת' },
];

export function WorkerView() {
  return (
    <section class="dash" aria-label="לוח עובד">
      <header class="dash__head">
        <span class="dash__emoji" aria-hidden="true">🦺</span>
        <div>
          <h2 class="dash__title">עובד</h2>
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
