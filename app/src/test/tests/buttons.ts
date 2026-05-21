/* buttons — function-exists audit + light behavior contracts.
 * Legacy reference: runButtonAudit() (lines 12958-12973) + testButton_*
 * / testTen_* / testCrit_* (~lines 13380-14250). Behaviour tests save
 * state before calling, assert the expected mutation, then restore
 * (legacy "save/restore" pattern).
 */
import { BUTTON_REGISTRY } from '../registry';
import type { TestResult, TestCheck } from '../types';
import {
  cart,
  categoryPath,
  menuOpen,
  searchOpen,
  toggleMenu,
  toggleSearch,
  drillInto,
  resetCategory,
  setQty,
  qtyOf,
  goUp,
} from '../../store/app-store';
import {
  bsOpen,
  toggleBs,
  activePersona,
  setPersona,
} from '../../store/bs-store';
import { childrenOf } from '../../data/catalog';

function existenceCheck(): TestResult[] {
  return BUTTON_REGISTRY.map((entry) => ({
    id: `button:${entry.fn}`,
    category: 'buttons' as const,
    label: entry.does,
    area: entry.area,
    checks: [
      {
        name: `${entry.fn} מוגדר וניתן להזעיק`,
        pass: typeof entry.ref === 'function',
        expected: 'function',
        got: typeof entry.ref,
      },
    ],
  }));
}

function behaviorCheck(): TestResult[] {
  const results: TestResult[] = [];

  /* toggleBs — flips bsOpen, twice restores */
  results.push(behaviorOne('toggleBs', 'מצב BS dial מתחלף', () => {
    const checks: TestCheck[] = [];
    const before = bsOpen.value;
    toggleBs();
    checks.push(verdict('מצב התהפך', bsOpen.value !== before, !before, bsOpen.value));
    toggleBs();
    checks.push(verdict('שתי קריאות חוזרות למצב המקורי', bsOpen.value === before, before, bsOpen.value));
    return checks;
  }));

  /* toggleMenu */
  results.push(behaviorOne('toggleMenu', 'מצב התפריט מתחלף', () => {
    const checks: TestCheck[] = [];
    const before = menuOpen.value;
    toggleMenu();
    checks.push(verdict('מצב התהפך', menuOpen.value !== before, !before, menuOpen.value));
    toggleMenu();
    checks.push(verdict('שתי קריאות חוזרות למצב המקורי', menuOpen.value === before, before, menuOpen.value));
    return checks;
  }));

  /* toggleSearch */
  results.push(behaviorOne('toggleSearch', 'מצב החיפוש מתחלף', () => {
    const checks: TestCheck[] = [];
    const before = searchOpen.value;
    toggleSearch();
    checks.push(verdict('מצב התהפך', searchOpen.value !== before, !before, searchOpen.value));
    toggleSearch();
    checks.push(verdict('שתי קריאות חוזרות למצב המקורי', searchOpen.value === before, before, searchOpen.value));
    return checks;
  }));

  /* setPersona — switch and restore */
  results.push(behaviorOne('setPersona', 'החלפת persona מעדכנת state', () => {
    const checks: TestCheck[] = [];
    const before = activePersona.value;
    const target = before === 'manager' ? 'contractor' : 'manager';
    setPersona(target);
    checks.push(verdict('activePersona מתעדכן', activePersona.value === target, target, activePersona.value));
    setPersona(before);
    checks.push(verdict('שחזור למצב המקורי', activePersona.value === before, before, activePersona.value));
    return checks;
  }));

  /* drillInto + resetCategory + goUp — navigate, then restore */
  results.push(behaviorOne('drillInto', 'כניסה לקטגוריה משרשרת את הנתיב', () => {
    const checks: TestCheck[] = [];
    const beforePath = [...categoryPath.value];
    const tops = childrenOf(null);
    if (tops.length === 0) {
      checks.push({ name: 'יש קטגוריות שורש', pass: false, detail: 'CATEGORIES.length === 0' });
      return checks;
    }
    resetCategory();
    drillInto(tops[0]!.id);
    checks.push(verdict('הנתיב גדל ב-1', categoryPath.value.length === 1, '1', String(categoryPath.value.length)));
    checks.push(verdict('הנתיב מכיל את הקטגוריה הנבחרת', categoryPath.value[0] === tops[0]!.id, tops[0]!.id, categoryPath.value[0] ?? ''));
    goUp();
    checks.push(verdict('goUp מקצר את הנתיב', categoryPath.value.length === 0, '0', String(categoryPath.value.length)));
    /* restore */
    for (const id of beforePath) drillInto(id);
    return checks;
  }));

  /* setQty / qtyOf — set, read, restore */
  results.push(behaviorOne('setQty', 'הגדרת כמות בעגלה משתקפת ב-qtyOf', () => {
    const checks: TestCheck[] = [];
    const beforeCart = cart.value.map((l) => ({ ...l }));
    const testId = '__regression_test_product__';
    setQty(testId, 3);
    checks.push(verdict('qtyOf מחזיר את הערך החדש', qtyOf(testId) === 3, '3', String(qtyOf(testId))));
    setQty(testId, 0);
    checks.push(verdict('הגדרת 0 מסירה את הפריט', qtyOf(testId) === 0, '0', String(qtyOf(testId))));
    /* restore: replace cart with the saved copy */
    cart.value = beforeCart;
    return checks;
  }));

  return results;
}

function behaviorOne(fn: string, label: string, run: () => TestCheck[]): TestResult {
  let checks: TestCheck[] = [];
  let crashed = false;
  try {
    checks = run();
  } catch (e) {
    crashed = true;
    checks.push({
      name: `${fn} רץ בלי לקרוס`,
      pass: false,
      detail: e instanceof Error ? e.message : String(e),
    });
  }
  if (!crashed) {
    checks.push({ name: `${fn} רץ בלי לקרוס`, pass: true });
  }
  return {
    id: `behavior:${fn}`,
    category: 'behavior' as const,
    label: `${fn} · ${label}`,
    area: 'התנהגות',
    checks,
  };
}

function verdict(name: string, pass: boolean, expected: unknown, got: unknown): TestCheck {
  return { name, pass, expected: String(expected), got: String(got) };
}

export function testButtons(): TestResult[] {
  return [...existenceCheck(), ...behaviorCheck()];
}
