import { activeTool, setActiveTool, type ToolKind } from '../../store/search-store';

type Tool = {
  id: ToolKind;
  label: string;
  icon: preact.JSX.Element;
};

const TOOLS: Tool[] = [
  {
    id: 'voice',
    label: 'קולי',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <rect x="9" y="2" width="6" height="12" rx="3" />
        <path d="M5 11a7 7 0 0014 0M12 18v4M8 22h8" />
      </svg>
    ),
  },
  {
    id: 'barcode',
    label: 'ברקוד',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
        <path d="M3 5v14M7 5v14M11 5v14M15 5v14M19 5v14" />
      </svg>
    ),
  },
  {
    id: 'filters',
    label: 'פילטרים',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 5h18M6 12h12M10 19h4" />
      </svg>
    ),
  },
  {
    id: 'sort',
    label: 'מיון',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M7 4v16M3 8l4-4 4 4M17 20V4M13 16l4 4 4-4" />
      </svg>
    ),
  },
  /* Catalog moved here from the menu FAB — browsing the 11 top
   * categories is a search-side primary action. */
  {
    id: 'catalog',
    label: 'קטלוג',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="3" width="7" height="7" rx="1.5" />
        <rect x="14" y="3" width="7" height="7" rx="1.5" />
        <rect x="3" y="14" width="7" height="7" rx="1.5" />
        <rect x="14" y="14" width="7" height="7" rx="1.5" />
      </svg>
    ),
  },
];

export function ToolsRail() {
  const active = activeTool.value;
  const activeDef = active ? TOOLS.find((t) => t.id === active) : null;

  return (
    <div class="trail" role="menu" aria-label="כלי חיפוש">
      {!activeDef &&
        TOOLS.map((t, i) => (
          <button
            key={t.id}
            type="button"
            class="trail__btn"
            role="menuitem"
            style={{ animationDelay: `${i * 28}ms` }}
            onClick={() => setActiveTool(t.id)}
          >
            <span class="trail__circle">{t.icon}</span>
            <span class="trail__label">{t.label}</span>
          </button>
        ))}

      {activeDef && (
        <button
          type="button"
          class="trail__btn trail__btn--active"
          onClick={() => setActiveTool(null)}
          aria-label={`חזרה מ-${activeDef.label}`}
        >
          <span class="trail__circle trail__circle--active">{activeDef.icon}</span>
          <span class="trail__label">{activeDef.label}</span>
        </button>
      )}
    </div>
  );
}

export { TOOLS };
