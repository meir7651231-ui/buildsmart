import {
  regressionStatus,
  regressionFilter,
  filteredResults,
  filteredSummary,
  summaryByCategory,
} from '../../store/regression-store';
import { runRegression } from '../../test/runner';
import type { TestCategory } from '../../test/types';

const FILTERS: Array<{ id: 'all' | TestCategory; label: string }> = [
  { id: 'all', label: 'הכל' },
  { id: 'buttons', label: 'כפתורים' },
  { id: 'tabs', label: 'טאבים' },
  { id: 'products', label: 'מוצרים' },
  { id: 'behavior', label: 'התנהגות' },
  { id: 'dsync', label: 'סנכרון' },
  { id: 'dupes', label: 'זהויות' },
];

const CATEGORY_HE: Record<TestCategory, string> = {
  buttons: 'כפתורים',
  tabs: 'טאבים',
  products: 'מוצרים',
  behavior: 'התנהגות',
  dsync: 'סנכרון',
  dupes: 'זהויות',
};

export function RegressionPanel() {
  const status = regressionStatus.value;
  const summary = filteredSummary.value;
  const byCat = summaryByCategory.value;
  const filter = regressionFilter.value;
  const results = filteredResults.value;

  return (
    <section class="reg" aria-label="מרכז בדיקות רגרסיה">
      <header class="reg__head">
        <h3 class="reg__title">🔬 מרכז בדיקות רגרסיה</h3>
        <p class="reg__sub">
          בודק את כל הפעולות, נתוני הקטלוג, ה-views והאינווריאנטים של המערכת
        </p>
      </header>

      <button
        type="button"
        class="reg__run"
        onClick={runRegression}
        disabled={status === 'running'}
      >
        {status === 'running'
          ? '⏳ מריץ את הבדיקות... רגע'
          : status === 'done'
            ? '↻ הרץ שוב'
            : '▶ הרץ בדיקת רגרסיה מלאה'}
      </button>

      {status === 'done' && (
        <>
          <div class={`reg__summary${summary.failed === 0 ? ' is-ok' : ' is-bad'}`}>
            <span class="reg__summary-big">
              {summary.failed === 0
                ? '✅ כל הבדיקות עברו'
                : `❌ נמצאו ${summary.failed} כשלים`}
            </span>
            <span class="reg__summary-line">
              {byCat
                .map((c) => `${CATEGORY_HE[c.category]}: ${c.passed}/${c.total}`)
                .join(' · ')}
            </span>
          </div>

          <div class="reg__filters" role="tablist" aria-label="פילטרים">
            {FILTERS.map((f) => (
              <button
                key={f.id}
                type="button"
                role="tab"
                aria-selected={filter === f.id}
                class={`reg__filter${filter === f.id ? ' is-on' : ''}`}
                onClick={() => (regressionFilter.value = f.id)}
              >
                {f.label}
              </button>
            ))}
          </div>

          <ul class="reg__list">
            {results.map((result) => {
              const total = result.checks.length;
              const failed = result.checks.filter((c) => !c.pass).length;
              const ok = failed === 0;
              return (
                <li key={result.id} class={`reg__card${ok ? ' is-ok' : ' is-bad'}`}>
                  <header class="reg__card-h">
                    <span class="reg__card-mark" aria-hidden="true">
                      {ok ? '✓' : '✗'}
                    </span>
                    <span class="reg__card-nm">{result.label}</span>
                    {result.area && <span class="reg__card-area">{result.area}</span>}
                    <span class="reg__card-score">
                      {total - failed}/{total}
                    </span>
                  </header>
                  <ul class="reg__checks">
                    {result.checks.map((check, i) => (
                      <li
                        key={i}
                        class={`reg__check${check.pass ? ' is-p' : ' is-f'}`}
                      >
                        <span class="reg__check-ic" aria-hidden="true">
                          {check.pass ? '✓' : '✗'}
                        </span>
                        <span class="reg__check-nm">{check.name}</span>
                        {check.detail && (
                          <span class="reg__check-dt">{check.detail}</span>
                        )}
                        {!check.pass && check.expected !== undefined && (
                          <span class="reg__check-dt">
                            ציפיתי: {check.expected} · קיבלתי: {check.got}
                          </span>
                        )}
                      </li>
                    ))}
                  </ul>
                </li>
              );
            })}
          </ul>
        </>
      )}
    </section>
  );
}
