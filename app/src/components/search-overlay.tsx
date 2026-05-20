import { useState, useMemo } from 'preact/hooks';
import { searchOpen, closeSearch, openProduct } from '../store/app-store';
import { PRODUCTS } from '../data/catalog';

export function SearchOverlay() {
  if (!searchOpen.value) return null;
  return <SearchPanel />;
}

function SearchPanel() {
  const [query, setQuery] = useState('');

  const results = useMemo(() => {
    const q = query.trim();
    if (!q) return [];
    const norm = q.toLowerCase();
    return PRODUCTS.filter((p) => {
      if (p.name.toLowerCase().includes(norm)) return true;
      if (p.productType?.toLowerCase().includes(norm)) return true;
      if (p.series?.toLowerCase().includes(norm)) return true;
      return false;
    }).slice(0, 50);
  }, [query]);

  return (
    <div class="search" role="dialog" aria-modal="true" aria-label="חיפוש מוצרים">
      <header class="search__head">
        <button type="button" class="search__close" onClick={closeSearch} aria-label="סגור">
          <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
            <line x1="6" y1="6" x2="18" y2="18" />
            <line x1="18" y1="6" x2="6" y2="18" />
          </svg>
        </button>
        <label class="search__field">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true">
            <circle cx="11" cy="11" r="7" />
            <line x1="20" y1="20" x2="16.5" y2="16.5" />
          </svg>
          <input
            type="search"
            inputMode="search"
            autoFocus
            placeholder="חיפוש מוצר..."
            value={query}
            onInput={(e) => setQuery((e.target as HTMLInputElement).value)}
          />
        </label>
      </header>

      <div class="search__body">
        {!query.trim() && (
          <p class="search__hint">התחל להקליד כדי לחפש מבין כל המוצרים.</p>
        )}
        {query.trim() && results.length === 0 && (
          <p class="search__hint">לא נמצאו תוצאות עבור "{query}".</p>
        )}
        {results.length > 0 && (
          <ul class="search__results">
            {results.map((p) => (
              <li key={p.id}>
                <button
                  type="button"
                  class="search__result"
                  onClick={() => {
                    closeSearch();
                    openProduct(p.id);
                  }}
                >
                  <span class="search__emoji" aria-hidden="true">
                    {p.image ? (
                      <img src={p.image} alt="" loading="lazy" />
                    ) : (
                      p.emoji
                    )}
                  </span>
                  <span class="search__text">
                    <span class="search__name">{p.name}</span>
                    {p.productType && (
                      <span class="search__supplier">{p.productType}</span>
                    )}
                  </span>
                  {typeof p.price === 'number' && p.price > 0 && (
                    <span class="search__price">₪{p.price}</span>
                  )}
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
