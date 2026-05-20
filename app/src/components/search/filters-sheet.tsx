import { searchFilters } from '../../store/search-store';

type Props = { onClose: () => void };

export function FiltersSheet({ onClose }: Props) {
  const f = searchFilters.value;
  const set = (next: Partial<typeof f>) => {
    searchFilters.value = { ...searchFilters.value, ...next };
  };

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label="פילטרים">
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={onClose} />
      <div class="sheet__panel sheet__panel--filters">
        <div class="sheet__handle" aria-hidden="true" />
        <h2 class="sheet__title">פילטרים</h2>

        <label class="filter-row">
          <input
            type="checkbox"
            checked={f.hasImage}
            onChange={(e) => set({ hasImage: (e.target as HTMLInputElement).checked })}
          />
          <span>רק מוצרים עם תמונה</span>
        </label>

        <label class="filter-row">
          <input
            type="checkbox"
            checked={f.hasPrice}
            onChange={(e) => set({ hasPrice: (e.target as HTMLInputElement).checked })}
          />
          <span>רק מוצרים עם מחיר מוצג</span>
        </label>

        <button
          type="button"
          class="psheet__cta"
          onClick={() => {
            searchFilters.value = { hasPrice: false, hasImage: false };
            onClose();
          }}
        >
          איפוס פילטרים
        </button>
        <button type="button" class="vmic__close" onClick={onClose}>
          סגור
        </button>
      </div>
    </div>
  );
}
