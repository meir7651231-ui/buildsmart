import {
  bsOpen,
  activePersona,
  bsDrillPersona,
  drillIntoPersona,
  popBsDrill,
  type Persona,
} from '../../store/bs-store';
import { showToast } from '../../store/toast-store';

type Tile = { id: Persona; label: string; emoji: string };

/* @legacy index.html:4088-4113 (role-drawer "מי אתה?") — labels are
 * the verbatim <b> text of each role-pick-btn. L1 of the BS dial. */
const TILES: Tile[] = [
  { id: 'contractor', label: 'קבלן',         emoji: '👷' },
  { id: 'manager',    label: 'מנהל המערכת',  emoji: '👔' },
  { id: 'store',      label: 'חנות ספק',     emoji: '🏪' },
  { id: 'courier',    label: 'שליח',         emoji: '🛵' },
  { id: 'worker',     label: 'עובד',         emoji: '🦺' },
];

type Section = { id: string; emoji: string; title: string };

/* @legacy index.html:4260-4263 (admTab buttons of screen-store). L2 of
 * the BS dial when drilled into "חנות ספק". Each leaf taps a toast for
 * Phase 0; deeper functionality wired in later phases. */
const STORE_SECTIONS: Section[] = [
  { id: 's-home',    emoji: '🏠', title: 'בית' },
  { id: 's-orders',  emoji: '📥', title: 'הזמנות' },
  { id: 's-stock',   emoji: '📦', title: 'מלאי' },
  { id: 's-portal',  emoji: '🧰', title: 'פורטל' },
];

/* Other personas have no sub-sections yet — drill is a no-op (toast). */
const PERSONA_SECTIONS: Partial<Record<Persona, Section[]>> = {
  store: STORE_SECTIONS,
};

export function BsDial() {
  if (!bsOpen.value) return null;
  const drilled = bsDrillPersona.value;

  /* L1 — 5 personas. Tap drills into that persona's sub-sections. */
  if (drilled === null) {
    const current = activePersona.value;
    return (
      <ul class="bsdial" role="menu" aria-label="בחירת משתמש">
        {TILES.map((t, i) => (
          <li
            key={t.id}
            class="bsdial__item"
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <button
              type="button"
              role="menuitem"
              class={`bsdial__btn${t.id === current ? ' is-active' : ''}`}
              onClick={() => drillIntoPersona(t.id)}
              aria-label={t.label}
              aria-current={t.id === current ? 'true' : undefined}
            >
              <span class="bsdial__circle" aria-hidden="true">{t.emoji}</span>
              <span class="bsdial__label">{t.label}</span>
            </button>
          </li>
        ))}
      </ul>
    );
  }

  /* L2 — drilled persona's sub-sections. Top row is a back anchor. */
  const tile = TILES.find((t) => t.id === drilled)!;
  const sections = PERSONA_SECTIONS[drilled];
  return (
    <ul class="bsdial" role="menu" aria-label={tile.label}>
      <li class="bsdial__item bsdial__item--active">
        <button
          type="button"
          role="menuitem"
          class="bsdial__btn is-active"
          onClick={popBsDrill}
          aria-label={`חזרה מ-${tile.label}`}
          aria-expanded="true"
        >
          <span class="bsdial__circle" aria-hidden="true">{tile.emoji}</span>
          <span class="bsdial__label">{tile.label}</span>
        </button>
      </li>
      {sections?.map((s, i) => (
        <li
          key={s.id}
          class="bsdial__item"
          style={{ animationDelay: `${i * 30}ms` }}
        >
          <button
            type="button"
            role="menuitem"
            class="bsdial__btn"
            onClick={() => showToast(`${s.title} — בבנייה`)}
            aria-label={s.title}
          >
            <span class="bsdial__circle" aria-hidden="true">{s.emoji}</span>
            <span class="bsdial__label">{s.title}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
