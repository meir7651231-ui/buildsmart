import {
  searchQuery,
  exactResults,
  fuzzyResults,
  recentSearches,
  recordRecent,
  clearRecent,
} from '../../store/search-store';
import type { SearchHit } from '../../data/search-index';
import {
  closeSearch,
  openProduct,
  drillInto,
  resetCategory,
  categoryPath,
} from '../../store/app-store';

function gotoHit(hit: SearchHit) {
  recordRecent(searchQuery.value);
  closeSearch();
  if (hit.target.type === 'prod') {
    openProduct(hit.target.productId);
    return;
  }
  if (hit.target.type === 'cat') {
    resetCategory();
    drillInto(hit.target.categoryId);
    return;
  }
  if (hit.target.type === 'screen') {
    if (hit.target.key === 'home') {
      categoryPath.value = [];
    }
  }
}

function kindBadge(kind: SearchHit['kind']): string {
  if (kind === 'prod') return 'מוצר';
  if (kind === 'cat') return 'קטגוריה';
  return 'מסך';
}

function Row({ hit }: { hit: SearchHit }) {
  return (
    <li>
      <button type="button" class="sresult" onClick={() => gotoHit(hit)}>
        <span class="sresult__icon" aria-hidden="true">
          {hit.image ? <img src={hit.image} alt="" loading="lazy" /> : hit.emoji}
        </span>
        <span class="sresult__text">
          <span class="sresult__label">{hit.label}</span>
          <span class="sresult__path">{hit.path}</span>
        </span>
        <span class={`sresult__kind sresult__kind--${hit.kind}`}>{kindBadge(hit.kind)}</span>
      </button>
    </li>
  );
}

export function ResultsList() {
  const q = searchQuery.value.trim();
  const exact = exactResults.value;
  const fuzzy = fuzzyResults.value;
  const recent = recentSearches.value;

  if (!q) {
    if (recent.length === 0) {
      return (
        <div class="sresults">
          <p class="sresults__hint">התחל להקליד כדי לחפש מוצרים, קטגוריות ומסכים.</p>
        </div>
      );
    }
    return (
      <div class="sresults">
        <header class="sresults__head">
          <span>חיפושים אחרונים</span>
          <button type="button" class="sresults__clear" onClick={clearRecent}>
            נקה
          </button>
        </header>
        <ul class="sresults__recent">
          {recent.map((r) => (
            <li key={r}>
              <button type="button" class="sresult-chip" onClick={() => (searchQuery.value = r)}>
                <span aria-hidden="true">🕓</span> {r}
              </button>
            </li>
          ))}
        </ul>
      </div>
    );
  }

  if (exact.length === 0 && fuzzy.length === 0) {
    return (
      <div class="sresults">
        <p class="sresults__empty">לא נמצאו תוצאות עבור "{q}".</p>
      </div>
    );
  }

  return (
    <div class="sresults">
      {exact.length > 0 && (
        <ul class="sresults__list">
          {exact.map((h) => (
            <Row key={h.id} hit={h} />
          ))}
        </ul>
      )}
      {exact.length === 0 && fuzzy.length > 0 && (
        <>
          <p class="sresults__fuzzy-hint">לא נמצאו תוצאות מדויקות — האם התכוונת ל:</p>
          <ul class="sresults__list">
            {fuzzy.map((h) => (
              <Row key={h.id} hit={h} />
            ))}
          </ul>
        </>
      )}
    </div>
  );
}
