import { searchSort, type SortMode } from '../../store/search-store';

const SORTS: Array<{ id: SortMode; label: string }> = [
  { id: 'default', label: 'ברירת מחדל' },
  { id: 'name_asc', label: 'שם א→ת' },
  { id: 'name_desc', label: 'שם ת→א' },
  { id: 'price_asc', label: 'מחיר ↑' },
  { id: 'price_desc', label: 'מחיר ↓' },
];

export function SortPickerMode() {
  const active = searchSort.value;
  return (
    <div class="opts">
      <h3 class="opts__title">מיון</h3>
      <ul class="opts__list">
        {SORTS.map((s) => (
          <li key={s.id}>
            <button
              type="button"
              class={`opts__radio${active === s.id ? ' is-on' : ''}`}
              onClick={() => (searchSort.value = s.id)}
            >
              <span class="opts__radio-dot" aria-hidden="true" />
              <span>{s.label}</span>
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
