import { searchScope, type SearchScope } from '../../store/search-store';

const CHIPS: Array<{ id: SearchScope; label: string }> = [
  { id: 'all', label: 'הכל' },
  { id: 'prod', label: 'מוצרים' },
  { id: 'cat', label: 'קטגוריות' },
  { id: 'screen', label: 'מסכים' },
];

export function ScopeChips() {
  const active = searchScope.value;
  return (
    <div class="scope-chips" role="tablist" aria-label="היקף חיפוש">
      {CHIPS.map((c) => (
        <button
          key={c.id}
          type="button"
          role="tab"
          aria-selected={c.id === active}
          class={`scope-chip${c.id === active ? ' is-active' : ''}`}
          onClick={() => (searchScope.value = c.id)}
        >
          {c.label}
        </button>
      ))}
    </div>
  );
}
