import { regressionStatus, regressionResults } from '../store/regression-store';
import { testButtons } from './tests/buttons';
import { testTabs } from './tests/tabs';
import { testProducts } from './tests/products';
import { testDsync } from './tests/dsync';
import { testDupes } from './tests/dupes';
import type { TestResult } from './types';

const yieldToUi = () => new Promise<void>((r) => setTimeout(r, 0));

export async function runRegression(): Promise<void> {
  if (regressionStatus.value === 'running') return;

  regressionStatus.value = 'running';
  regressionResults.value = [];

  /* Yield so the UI can paint the "running" state */
  await new Promise<void>((r) => setTimeout(r, 60));

  const results: TestResult[] = [];

  try {
    results.push(...testDsync());
    await yieldToUi();

    results.push(...testButtons());
    await yieldToUi();

    results.push(...testTabs());
    await yieldToUi();

    results.push(...testProducts());
    await yieldToUi();

    results.push(...testDupes());
  } catch (e) {
    results.push({
      id: 'runner:crash',
      category: 'dsync',
      label: 'הריצה קרסה',
      checks: [
        {
          name: 'הריצה הסתיימה בלי לקרוס',
          pass: false,
          detail: e instanceof Error ? e.message : String(e),
        },
      ],
    });
  }

  regressionResults.value = results;
  regressionStatus.value = 'done';
}
