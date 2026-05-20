import { setActiveTool, type ToolKind } from '../../store/search-store';

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
];

export function ToolsDial() {
  return (
    <ul class="sdial" role="menu" aria-label="כלי חיפוש">
      {TOOLS.map((t, i) => (
        <li key={t.id} class="sdial__item" style={{ animationDelay: `${i * 30}ms` }}>
          <button
            type="button"
            class="sdial__btn"
            role="menuitem"
            onClick={() => setActiveTool(t.id)}
          >
            <span class="sdial__circle">{t.icon}</span>
            <span class="sdial__label">{t.label}</span>
          </button>
        </li>
      ))}
    </ul>
  );
}

export { TOOLS };
