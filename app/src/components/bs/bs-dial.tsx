import {
  bsOpen,
  closeBs,
  activePersona,
  setPersona,
  type Persona,
} from '../../store/bs-store';

type Tile = { id: Persona; label: string; emoji: string };

const TILES: Tile[] = [
  { id: 'contractor', label: 'קבלן', emoji: '👷' },
  { id: 'manager', label: 'מנהל', emoji: '👔' },
  { id: 'store', label: 'חנות', emoji: '🏪' },
  { id: 'courier', label: 'שליח', emoji: '🛵' },
  { id: 'worker', label: 'עובד', emoji: '🦺' },
];

export function BsDial() {
  if (!bsOpen.value) return null;
  const current = activePersona.value;

  const pick = (id: Persona) => {
    setPersona(id);
    closeBs();
  };

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
            onClick={() => pick(t.id)}
            aria-current={t.id === current ? 'true' : undefined}
          >
            <span class="bsdial__circle" aria-hidden="true">
              {t.emoji}
            </span>
            <span class="bsdial__label">{t.label}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}
