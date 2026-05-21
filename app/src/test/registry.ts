/* Mirror of the legacy BUTTON_REGISTRY adapted to what we've built so far.
 * Add new entries as new interactive functions ship.
 */
import {
  toggleMenu,
  closeMenu,
  toggleSearch,
  openSearch,
  closeSearch,
  openProduct,
  closeProduct,
  drillInto,
  goUp,
  resetCategory,
  setQty,
  incQty,
  decQty,
  qtyOf,
} from '../store/app-store';
import { toggleBs, closeBs, setPersona } from '../store/bs-store';
import {
  setActiveTool,
  resetSearch,
  recordRecent,
  clearRecent,
} from '../store/search-store';

export type ButtonEntry = {
  fn: string;
  area: string;
  does: string;
  ref: unknown;
};

export const BUTTON_REGISTRY: ButtonEntry[] = [
  /* Identity / BS */
  { fn: 'toggleBs',    area: 'זהות',   does: 'פותח/סוגר BS dial',           ref: toggleBs },
  { fn: 'closeBs',     area: 'זהות',   does: 'סוגר BS dial',                ref: closeBs },
  { fn: 'setPersona',  area: 'זהות',   does: 'מחליף persona פעיל',          ref: setPersona },

  /* Menu FAB */
  { fn: 'toggleMenu',  area: 'תפריט',  does: 'פותח/סוגר את תפריט הראשי',    ref: toggleMenu },
  { fn: 'closeMenu',   area: 'תפריט',  does: 'סוגר את התפריט',              ref: closeMenu },

  /* Search FAB + tools */
  { fn: 'toggleSearch', area: 'חיפוש', does: 'פותח/סוגר את החיפוש',         ref: toggleSearch },
  { fn: 'openSearch',   area: 'חיפוש', does: 'פותח את החיפוש',              ref: openSearch },
  { fn: 'closeSearch',  area: 'חיפוש', does: 'סוגר את החיפוש',              ref: closeSearch },
  { fn: 'setActiveTool',area: 'חיפוש', does: 'בוחר כלי חיפוש (קולי/ברקוד/פילטר/מיון)', ref: setActiveTool },
  { fn: 'resetSearch',  area: 'חיפוש', does: 'מאפס את מצב החיפוש',          ref: resetSearch },
  { fn: 'recordRecent', area: 'חיפוש', does: 'שומר חיפוש אחרון',            ref: recordRecent },
  { fn: 'clearRecent',  area: 'חיפוש', does: 'מנקה היסטוריית חיפושים',      ref: clearRecent },

  /* Categories / catalog drill-down */
  { fn: 'drillInto',     area: 'קטלוג', does: 'נכנס לתת-קטגוריה',           ref: drillInto },
  { fn: 'goUp',          area: 'קטלוג', does: 'יוצא לקטגוריית-על',          ref: goUp },
  { fn: 'resetCategory', area: 'קטלוג', does: 'מאפס נתיב הקטגוריות לשורש',  ref: resetCategory },

  /* Product sheet */
  { fn: 'openProduct',  area: 'מוצר',  does: 'פותח כרטיס מוצר',             ref: openProduct },
  { fn: 'closeProduct', area: 'מוצר',  does: 'סוגר כרטיס מוצר',             ref: closeProduct },

  /* Cart */
  { fn: 'incQty', area: 'עגלה', does: 'מגדיל כמות של פריט בעגלה',         ref: incQty },
  { fn: 'decQty', area: 'עגלה', does: 'מקטין כמות של פריט בעגלה',         ref: decQty },
  { fn: 'setQty', area: 'עגלה', does: 'מגדיר כמות של פריט בעגלה',         ref: setQty },
  { fn: 'qtyOf',  area: 'עגלה', does: 'שולף כמות של פריט בעגלה',          ref: qtyOf },
];
