/* tabs — per-persona render audit. Legacy (index.html lines 15884-15947)
 * tests that each role's tab render function exists, runs without crash
 * and produces content. Our personas are the moral equivalent of the
 * legacy's role tabs.
 */
import { render } from 'preact';
import { HomeView } from '../../views/home';
import { ManagerView } from '../../views/manager';
import { StoreView } from '../../views/store';
import { CourierView } from '../../views/courier';
import { WorkerView } from '../../views/worker';
import type { TestResult } from '../types';

type TabSpec = {
  id: string;
  label: string;
  ref: () => preact.JSX.Element;
};

const TABS: TabSpec[] = [
  { id: 'home', label: 'קבלן · קטלוג', ref: HomeView },
  { id: 'manager', label: 'מנהל · לוח-בקרה', ref: ManagerView },
  { id: 'store', label: 'חנות', ref: StoreView },
  { id: 'courier', label: 'שליח', ref: CourierView },
  { id: 'worker', label: 'עובד', ref: WorkerView },
];

function tryRender(Tab: () => preact.JSX.Element): { pass: boolean; detail: string } {
  const container = document.createElement('div');
  container.style.cssText =
    'position:absolute;visibility:hidden;pointer-events:none;width:390px;height:844px;';
  document.body.appendChild(container);
  try {
    render(<Tab />, container);
    const html = container.innerHTML;
    if (html.length === 0) return { pass: false, detail: 'מחזיר HTML ריק' };
    return { pass: true, detail: '' };
  } catch (e) {
    return { pass: false, detail: e instanceof Error ? e.message : String(e) };
  } finally {
    try {
      render(null, container);
    } catch {
      /* ignore */
    }
    container.remove();
  }
}

export function testTabs(): TestResult[] {
  return TABS.map((t) => {
    const r = tryRender(t.ref);
    return {
      id: `tab:${t.id}`,
      category: 'tabs' as const,
      label: t.label,
      checks: [
        {
          name: `${t.label} מתרנדר בלי קריסה`,
          pass: r.pass,
          detail: r.detail,
        },
      ],
    };
  });
}
