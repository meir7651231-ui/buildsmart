import { signal, computed } from '@preact/signals';
import { searchExact, searchFuzzy } from '../lib/search';
import type { SearchHit, SearchKind } from '../data/search-index';

const RECENT_KEY = 'bs.search.recent.v1';
const MAX_RECENT = 8;

export type SearchScope = 'all' | 'prod' | 'cat' | 'screen';

export type SortMode = 'default' | 'name_asc' | 'name_desc' | 'price_asc' | 'price_desc';

export const searchQuery = signal('');
export const searchScope = signal<SearchScope>('all');
export const searchSort = signal<SortMode>('default');

export type ToolKind = 'voice' | 'barcode' | 'filters' | 'sort' | 'catalog';
export const activeTool = signal<ToolKind | null>(null);

export function setActiveTool(t: ToolKind | null): void {
  activeTool.value = t;
}

/* Filters — minimal MVP: price range + in-cart-only */
export type SearchFilters = {
  hasPrice: boolean;
  hasImage: boolean;
};
export const searchFilters = signal<SearchFilters>({ hasPrice: false, hasImage: false });

function loadRecent(): string[] {
  try {
    const raw = localStorage.getItem(RECENT_KEY);
    if (!raw) return [];
    const arr = JSON.parse(raw);
    if (!Array.isArray(arr)) return [];
    return arr.filter((x) => typeof x === 'string').slice(0, MAX_RECENT);
  } catch {
    return [];
  }
}

export const recentSearches = signal<string[]>(loadRecent());

export function recordRecent(q: string): void {
  const trimmed = q.trim();
  if (!trimmed) return;
  const next = [trimmed, ...recentSearches.value.filter((r) => r !== trimmed)].slice(0, MAX_RECENT);
  recentSearches.value = next;
  try {
    localStorage.setItem(RECENT_KEY, JSON.stringify(next));
  } catch {
    /* storage unavailable — keep in-memory */
  }
}

export function clearRecent(): void {
  recentSearches.value = [];
  try {
    localStorage.removeItem(RECENT_KEY);
  } catch {
    /* ignore */
  }
}

function applyScope(hits: SearchHit[]): SearchHit[] {
  const scope = searchScope.value;
  if (scope === 'all') return hits;
  return hits.filter((h) => (h.kind as SearchKind) === scope);
}

function applyFilters(hits: SearchHit[]): SearchHit[] {
  const f = searchFilters.value;
  if (!f.hasPrice && !f.hasImage) return hits;
  return hits.filter((h) => {
    if (h.kind !== 'prod') return false;
    if (f.hasImage && !h.image) return false;
    return true;
  });
}

export const exactResults = computed<SearchHit[]>(() => {
  const q = searchQuery.value;
  if (!q.trim()) return [];
  return applyFilters(applyScope(searchExact(q, 60)));
});

export const fuzzyResults = computed<SearchHit[]>(() => {
  const q = searchQuery.value;
  if (!q.trim() || exactResults.value.length > 0) return [];
  return applyFilters(applyScope(searchFuzzy(q)));
});

export const hasResults = computed(
  () => exactResults.value.length > 0 || fuzzyResults.value.length > 0,
);

export function resetSearch(): void {
  searchQuery.value = '';
  searchScope.value = 'all';
  searchSort.value = 'default';
  searchFilters.value = { hasPrice: false, hasImage: false };
  activeTool.value = null;
}
