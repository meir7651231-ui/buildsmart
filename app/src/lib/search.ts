import { searchIndex, type SearchHit, type SearchKind } from '../data/search-index';

const KIND_ORDER: Record<SearchKind, number> = {
  screen: 0,
  cat: 1,
  prod: 2,
};

function normalize(s: string): string {
  return s.toLocaleLowerCase('he');
}

/**
 * Substring search with prefix-first ordering. Returns up to `limit` hits.
 */
export function searchExact(query: string, limit = 40): SearchHit[] {
  const q = normalize(query.trim());
  if (!q) return [];

  const prefix: Array<{ hit: SearchHit; score: number }> = [];
  const contains: Array<{ hit: SearchHit; score: number }> = [];

  for (const hit of searchIndex()) {
    let bestPos = -1;
    for (const kw of hit.keywords) {
      const pos = normalize(kw).indexOf(q);
      if (pos >= 0 && (bestPos < 0 || pos < bestPos)) bestPos = pos;
    }
    if (bestPos < 0) continue;
    const bucket = bestPos === 0 ? prefix : contains;
    bucket.push({ hit, score: bestPos * 100 + KIND_ORDER[hit.kind] });
  }

  prefix.sort((a, b) => a.score - b.score);
  contains.sort((a, b) => a.score - b.score);

  return [...prefix, ...contains].slice(0, limit).map((x) => x.hit);
}

/* Damerau-style Levenshtein for short Hebrew strings */
function editDistance(a: string, b: string): number {
  if (a === b) return 0;
  const m = a.length;
  const n = b.length;
  if (!m) return n;
  if (!n) return m;
  let prev = new Array<number>(n + 1);
  let cur = new Array<number>(n + 1);
  for (let j = 0; j <= n; j++) prev[j] = j;
  for (let i = 1; i <= m; i++) {
    cur[0] = i;
    for (let j = 1; j <= n; j++) {
      const cost = a[i - 1] === b[j - 1] ? 0 : 1;
      cur[j] = Math.min(prev[j]! + 1, cur[j - 1]! + 1, prev[j - 1]! + cost);
    }
    [prev, cur] = [cur, prev];
  }
  return prev[n]!;
}

/**
 * Fuzzy fallback. Only runs when `searchExact` returned nothing AND the
 * query is at least 2 characters. Tolerance is roughly 1 edit per 3 chars.
 */
export function searchFuzzy(query: string, limit = 6): SearchHit[] {
  const q = normalize(query.trim());
  if (q.length < 2) return [];
  const tolerance = Math.floor(q.length / 3) + 1;

  const scored: Array<{ hit: SearchHit; dist: number }> = [];
  for (const hit of searchIndex()) {
    let bestDist = Infinity;
    for (const kw of hit.keywords) {
      const norm = normalize(kw);
      const window = Math.min(norm.length, q.length + tolerance);
      for (let start = 0; start + q.length - tolerance <= norm.length; start++) {
        const slice = norm.slice(start, start + window);
        const d = editDistance(q, slice);
        if (d < bestDist) bestDist = d;
        if (bestDist <= tolerance) break;
      }
      if (bestDist <= tolerance) break;
    }
    if (bestDist <= tolerance) {
      scored.push({ hit, dist: bestDist + KIND_ORDER[hit.kind] * 0.1 });
    }
  }
  scored.sort((a, b) => a.dist - b.dist);
  return scored.slice(0, limit).map((s) => s.hit);
}
