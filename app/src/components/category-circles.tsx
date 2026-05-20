import {
  currentCircles,
  currentParentId,
  categoryPath,
  drillInto,
  goUp,
} from '../store/app-store';
import { categoryById } from '../data/categories';

export function CategoryCircles() {
  const isRoot = categoryPath.value.length === 0;
  const parentId = currentParentId.value;
  const parent = parentId ? categoryById(parentId) : undefined;
  const circles = currentCircles.value;

  return (
    <div class="cats">
      <div class="cats__row" role="list">
        {!isRoot && (
          <button
            type="button"
            class="cat cat--back"
            onClick={goUp}
            aria-label="חזרה"
          >
            <span class="cat__bubble cat__bubble--back" aria-hidden="true">
              <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                <path d="M7 12h13M13 6l-6 6 6 6" />
              </svg>
            </span>
            <span class="cat__name">חזור</span>
          </button>
        )}

        {parent && (
          <button
            type="button"
            class="cat cat--current"
            onClick={goUp}
            aria-label={`${parent.name} (פתוח)`}
            aria-current="page"
          >
            <span class="cat__bubble cat__bubble--current" aria-hidden="true">{parent.emoji}</span>
            <span class="cat__name">{parent.name}</span>
          </button>
        )}

        {circles.map((cat) => (
          <button
            key={cat.id}
            type="button"
            class="cat"
            role="listitem"
            onClick={() => drillInto(cat.id)}
            aria-label={cat.name}
          >
            <span class="cat__bubble" aria-hidden="true">{cat.emoji}</span>
            <span class="cat__name">{cat.name}</span>
          </button>
        ))}
      </div>
    </div>
  );
}
