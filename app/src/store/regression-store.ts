import { signal, computed } from '@preact/signals';
import type { TestResult, TestCategory, RegressionStatus, CategorySummary } from '../test/types';

export const regressionStatus = signal<RegressionStatus>('idle');
export const regressionResults = signal<TestResult[]>([]);
export const regressionFilter = signal<'all' | TestCategory>('all');

export const filteredResults = computed<TestResult[]>(() => {
  const f = regressionFilter.value;
  if (f === 'all') return regressionResults.value;
  return regressionResults.value.filter((r) => r.category === f);
});

export const filteredSummary = computed<{ total: number; passed: number; failed: number }>(() => {
  const total = filteredResults.value.length;
  const passed = filteredResults.value.filter((r) => r.checks.every((c) => c.pass)).length;
  return { total, passed, failed: total - passed };
});

export const summaryByCategory = computed<CategorySummary[]>(() => {
  const cats: TestCategory[] = ['buttons', 'tabs', 'products', 'behavior', 'dsync', 'dupes'];
  return cats.map((category) => {
    const items = regressionResults.value.filter((r) => r.category === category);
    return {
      category,
      total: items.length,
      passed: items.filter((r) => r.checks.every((c) => c.pass)).length,
    };
  });
});
