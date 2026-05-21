/* Test category names mirror the legacy regression suite at
 * index.html lines 15273–15279: buttons / tabs / products / dsync / dupes.
 * Behavior contracts (testButton_*) will fill in as we port more flows.
 */
export type TestCategory = 'buttons' | 'tabs' | 'products' | 'behavior' | 'dsync' | 'dupes';

export type TestCheck = {
  name: string;
  pass: boolean;
  expected?: string;
  got?: string;
  detail?: string;
};

export type TestResult = {
  id: string;
  category: TestCategory;
  label: string;
  area?: string;
  checks: TestCheck[];
};

export type RegressionStatus = 'idle' | 'running' | 'done';

export type CategorySummary = {
  category: TestCategory;
  total: number;
  passed: number;
};
