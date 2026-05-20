import { categoryPath, currentCircles, drillInto, jumpTo, resetCategory } from '../store/app-store';
import { categoryById } from '../data/categories';

export function CategoryCircles() {
  const circles = currentCircles.value;
  const path = categoryPath.value;
  const isRoot = path.length === 0;

  return (
    <div class="cats">
      {!isRoot && (
        <div class="cats__crumbs" role="navigation" aria-label="ניווט קטגוריות">
          <button type="button" class="crumb crumb--home" onClick={resetCategory}>
            <span aria-hidden="true">⌂</span>
            <span class="crumb__label">הכל</span>
          </button>
          {path.map((id, i) => {
            const isLast = i === path.length - 1;
            const cat = categoryById(id);
            return (
              <button
                key={id}
                type="button"
                class={`crumb${isLast ? ' is-current' : ''}`}
                onClick={() => !isLast && jumpTo(i + 1)}
                aria-current={isLast ? 'page' : undefined}
              >
                <span class="crumb__sep" aria-hidden="true">/</span>
                <span class="crumb__label">{cat?.name ?? id}</span>
              </button>
            );
          })}
        </div>
      )}

      <div class="cats__row" role="list">
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
