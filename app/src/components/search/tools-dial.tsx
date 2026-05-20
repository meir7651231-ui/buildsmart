import { toolsDialOpen, searchSort, type SortMode } from '../../store/search-store';
import { useState } from 'preact/hooks';

type ToolId = 'voice' | 'barcode' | 'filters' | 'sort' | 'recent';

type Tool = {
  id: ToolId;
  label: string;
  icon: preact.JSX.Element;
  onTap: () => void;
};

const SORTS: Array<{ id: SortMode; label: string }> = [
  { id: 'default', label: 'ברירת מחדל' },
  { id: 'name_asc', label: 'שם א→ת' },
  { id: 'name_desc', label: 'שם ת→א' },
  { id: 'price_asc', label: 'מחיר ↑' },
  { id: 'price_desc', label: 'מחיר ↓' },
];

type Props = {
  onVoice: () => void;
  onBarcode: () => void;
  onFilters: () => void;
  onRecent: () => void;
};

export function ToolsDial({ onVoice, onBarcode, onFilters, onRecent }: Props) {
  const [sortOpen, setSortOpen] = useState(false);

  if (!toolsDialOpen.value) return null;

  const tools: Tool[] = [
    {
      id: 'voice',
      label: 'קולי',
      icon: (
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
          <rect x="9" y="2" width="6" height="12" rx="3" />
          <path d="M5 11a7 7 0 0014 0M12 18v4M8 22h8" />
        </svg>
      ),
      onTap: onVoice,
    },
    {
      id: 'barcode',
      label: 'ברקוד',
      icon: (
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
          <path d="M3 5v14M7 5v14M11 5v14M15 5v14M19 5v14" />
        </svg>
      ),
      onTap: onBarcode,
    },
    {
      id: 'filters',
      label: 'פילטרים',
      icon: (
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
          <path d="M3 5h18M6 12h12M10 19h4" />
        </svg>
      ),
      onTap: onFilters,
    },
    {
      id: 'sort',
      label: 'מיון',
      icon: (
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
          <path d="M7 4v16M3 8l4-4 4 4M17 20V4M13 16l4 4 4-4" />
        </svg>
      ),
      onTap: () => setSortOpen((v) => !v),
    },
    {
      id: 'recent',
      label: 'אחרונים',
      icon: (
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="9" />
          <path d="M12 7v5l3 2" />
        </svg>
      ),
      onTap: onRecent,
    },
  ];

  return (
    <div class="sdial">
      {sortOpen && (
        <ul class="sdial__sort" role="menu" aria-label="מיון">
          {SORTS.map((s) => (
            <li key={s.id}>
              <button
                type="button"
                class={`sdial__sort-item${searchSort.value === s.id ? ' is-active' : ''}`}
                onClick={() => {
                  searchSort.value = s.id;
                  setSortOpen(false);
                }}
              >
                {s.label}
              </button>
            </li>
          ))}
        </ul>
      )}
      <ul class="sdial__list" role="menu" aria-label="כלי חיפוש">
        {tools.map((t, i) => (
          <li
            key={t.id}
            class="sdial__item"
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <button type="button" class="sdial__btn" onClick={t.onTap}>
              <span class="sdial__circle">{t.icon}</span>
              <span class="sdial__label">{t.label}</span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
