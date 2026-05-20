import { searchFilters } from '../../store/search-store';

type Opt = {
  key: 'hasImage' | 'hasPrice';
  label: string;
  icon: preact.JSX.Element;
};

const OPTIONS: Opt[] = [
  {
    key: 'hasImage',
    label: 'עם תמונה',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="5" width="18" height="14" rx="2" />
        <circle cx="9" cy="11" r="2" />
        <path d="M21 19l-6-6-7 6" />
      </svg>
    ),
  },
  {
    key: 'hasPrice',
    label: 'עם מחיר מוצג',
    icon: (
      <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 1v22M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6" />
      </svg>
    ),
  },
];

export function FiltersSubmenu() {
  const f = searchFilters.value;
  return (
    <div class="ssub">
      {OPTIONS.map((o) => {
        const on = f[o.key];
        return (
          <button
            key={o.key}
            type="button"
            class={`ssub__row${on ? ' is-on' : ''}`}
            onClick={() =>
              (searchFilters.value = { ...searchFilters.value, [o.key]: !on })
            }
          >
            <span class="ssub__icon">{o.icon}</span>
            <span class="ssub__label">{o.label}</span>
            <span class={`ssub__check${on ? ' is-on' : ''}`} aria-hidden="true">
              {on ? '✓' : ''}
            </span>
          </button>
        );
      })}
    </div>
  );
}
