import { searchSort, type SortMode } from '../../store/search-store';

type Opt = {
  id: SortMode;
  label: string;
  icon: preact.JSX.Element;
};

const SORTS: Opt[] = [
  {
    id: 'default',
    label: 'ברירת מחדל',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
        <path d="M4 6h16M4 12h12M4 18h8" />
      </svg>
    ),
  },
  {
    id: 'name_asc',
    label: 'שם א→ת',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M4 6h10M4 12h7M4 18h4" />
        <path d="M16 5l4 14M14 14h8" />
      </svg>
    ),
  },
  {
    id: 'name_desc',
    label: 'שם ת→א',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M4 18h10M4 12h7M4 6h4" />
        <path d="M16 19l4-14M14 10h8" />
      </svg>
    ),
  },
  {
    id: 'price_asc',
    label: 'מחיר ↑',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 19V5M5 12l7-7 7 7" />
      </svg>
    ),
  },
  {
    id: 'price_desc',
    label: 'מחיר ↓',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 5v14M5 12l7 7 7-7" />
      </svg>
    ),
  },
];

export function SortSubmenu() {
  const active = searchSort.value;
  return (
    <div class="ssub">
      {SORTS.map((o) => {
        const on = active === o.id;
        return (
          <button
            key={o.id}
            type="button"
            class={`ssub__row${on ? ' is-on' : ''}`}
            onClick={() => (searchSort.value = o.id)}
          >
            <span class="ssub__icon">{o.icon}</span>
            <span class="ssub__label">{o.label}</span>
          </button>
        );
      })}
    </div>
  );
}
