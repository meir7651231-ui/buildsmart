import { searchFilters } from '../../store/search-store';

export function FiltersMode() {
  const f = searchFilters.value;
  const set = (next: Partial<typeof f>) => {
    searchFilters.value = { ...searchFilters.value, ...next };
  };
  return (
    <div class="opts">
      <h3 class="opts__title">פילטרים</h3>
      <label class="opts__row">
        <input
          type="checkbox"
          checked={f.hasImage}
          onChange={(e) => set({ hasImage: (e.target as HTMLInputElement).checked })}
        />
        <span>רק מוצרים עם תמונה</span>
      </label>
      <label class="opts__row">
        <input
          type="checkbox"
          checked={f.hasPrice}
          onChange={(e) => set({ hasPrice: (e.target as HTMLInputElement).checked })}
        />
        <span>רק מוצרים עם מחיר מוצג</span>
      </label>
      <button
        type="button"
        class="opts__reset"
        onClick={() => (searchFilters.value = { hasPrice: false, hasImage: false })}
      >
        איפוס פילטרים
      </button>
    </div>
  );
}
