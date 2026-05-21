/* @legacy index.html:6806 (renderSettings — 10 section groups)
 * Names only for now: legacy reading order is preserved (account first,
 * reset last). No actions wired — each row just closes the menu.
 *
 * Rendering note: the parent `<ul class="dial">` uses
 * `flex-direction: column-reverse`, so the LAST <li> in the JSX ends up
 * at the TOP of the visual stack. We reverse the data order here so the
 * stack reads top→bottom in legacy order.
 */
import {
  closeMenu,
  setSettingsGroup,
  pushSettingsPath,
  type SettingsGroupId,
} from '../../store/app-store';
import {
  appSettings,
  setTheme,
  setTextSize,
  toggleReduceMotion,
  toggleNotif,
  setLang,
  setUnits,
  setCurrency,
  setDefaultHaul,
  toggleExpress,
  toggleHighContrast,
  resetSettings,
} from '../../store/app-settings';
import { showToast } from '../../store/toast-store';

export type SettingsRowId = SettingsGroupId | 'reset';

type Row = {
  id: SettingsRowId;
  label: string;
  icon: preact.JSX.Element;
};

export const SETTINGS_ROWS: Row[] = [
  {
    id: 'account',
    label: 'חשבון',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21a8 8 0 0116 0" />
      </svg>
    ),
  },
  {
    id: 'notifications',
    label: 'התראות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 8a6 6 0 1112 0c0 7 3 7 3 9H3c0-2 3-2 3-9z" />
        <path d="M10 21a2 2 0 004 0" />
      </svg>
    ),
  },
  {
    id: 'display',
    label: 'תצוגה',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41" />
      </svg>
    ),
  },
  {
    id: 'accessibility',
    label: 'נגישות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="4" r="2" />
        <path d="M5 9h14M9 9l1 5-2 7M15 9l-1 5 2 7" />
      </svg>
    ),
  },
  {
    id: 'security',
    label: 'אבטחה והרשאות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 3l8 3v6c0 5-4 8-8 9-4-1-8-4-8-9V6l8-3z" />
      </svg>
    ),
  },
  {
    id: 'support',
    label: 'שירות ותמיכה',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M4 13a8 8 0 0116 0v3a2 2 0 01-2 2h-1v-5h3M4 13v3a2 2 0 002 2h1v-5H4" />
      </svg>
    ),
  },
  {
    id: 'delivery',
    label: 'משלוח ותשלום',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 7h11v9H3zM14 10h4l3 3v3h-7" />
        <circle cx="7" cy="18" r="1.6" />
        <circle cx="17" cy="18" r="1.6" />
      </svg>
    ),
  },
  {
    id: 'region',
    label: 'אזור ושפה',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18" />
      </svg>
    ),
  },
  {
    id: 'about',
    label: 'מידע',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M12 8h.01M11 12h1v5h1" />
      </svg>
    ),
  },
  {
    id: 'reset',
    label: 'איפוס לברירת מחדל',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 12a9 9 0 109-9" />
        <path d="M3 3v6h6" />
      </svg>
    ),
  },
];

/* Recursive node — every entry in the settings tree below the 10
 * group rows is a Node. Leaves have no `children`; branches have a
 * `children: Node[]` array whose own entries may again be branches. */
export type Node = { label: string; children?: Node[] };

/* @legacy SETTINGS tree, sourced verbatim from the legacy prototype:
 *   level 2 — `renderSettings()` at index.html:6817-6875
 *   level 3 — `SETTINGS_LABELS` at index.html:6750-6757 (select options),
 *             `openSecurityHub()` at index.html:21752-21762 (10 tiles),
 *             `openServiceHub()`  at index.html:22081-22090 (8 tiles)
 *   level 4 — `secRBAC()`   roleNames at index.html:21812-21813
 *             `secSession()` timeouts at index.html:21922
 *             `secEncryption()` rows  at index.html:21952-21957
 *             `secPrivacy()` rows     at index.html:22018-22023
 *             `svcQtyCalc()` mode tabs at index.html:22289-22293
 *             `svcOnboarding()` tour titles at index.html:22374-22381
 * `reset` is excluded — it's an action with no sub-rows. */
export const SETTINGS_SUB: Record<SettingsGroupId, Node[]> = {
  account: [
    { label: 'שם הקבלן' },
    { label: 'טלפון' },
    { label: 'סוג עוסק' },
    { label: 'תחום מקצועי' },
  ],
  notifications: [
    { label: 'עדכוני משלוחים' },
    { label: 'מבצעים והטבות' },
    { label: 'התראות תקציב' },
    { label: 'עדכוני הזמנות' },
  ],
  display: [
    {
      label: 'ערכת נושא',
      children: [{ label: 'בהיר' }, { label: 'כהה' }],
    },
    {
      label: 'גודל טקסט',
      children: [{ label: 'קטן' }, { label: 'בינוני' }, { label: 'גדול' }],
    },
    { label: 'הפחתת אנימציות' },
  ],
  accessibility: [
    { label: 'מצב ניגודיות גבוהה (לשמש)' },
  ],
  security: [
    {
      label: 'מרכז האבטחה',
      children: [
        { label: 'אימות דו-שלבי' },
        {
          label: 'הרשאות גישה',
          children: [
            { label: 'קבלן' },
            { label: 'מנהל מערכת' },
            { label: 'ספק / חנות' },
            { label: 'שליח' },
            { label: 'עובד' },
          ],
        },
        { label: 'כניסה ביומטרית' },
        { label: 'יומן ביקורת' },
        { label: 'הרשאת מיקום' },
        {
          label: 'נעילת הפעלה',
          children: [
            { label: '5 דק׳' },
            { label: '15 דק׳' },
            { label: '30 דק׳' },
            { label: '60 דק׳' },
          ],
        },
        {
          label: 'הצפנת נתונים',
          children: [
            { label: 'תקשורת מוצפנת (HTTPS/TLS)' },
            { label: 'נתונים מקומיים מוגנים' },
            { label: 'סיסמאות מאוחסנות כ-Hash' },
            { label: 'גיבוי מוצפן בענן' },
          ],
        },
        { label: 'היסטוריית כניסות' },
        { label: 'ניהול מכשירים' },
        {
          label: 'בקרת פרטיות',
          children: [
            { label: 'שיתוף נתוני שימוש' },
            { label: 'שירותי מיקום' },
            { label: 'התאמת תוכן שיווקי' },
            { label: 'שליחת דוחות תקלה' },
          ],
        },
      ],
    },
  ],
  support: [
    {
      label: 'מרכז השירות',
      children: [
        { label: 'מוקד תמיכה' },
        { label: 'צ׳אטבוט' },
        { label: 'דיווח על באג' },
        { label: 'המרת מידות' },
        {
          label: 'מחשבון כמויות',
          children: [
            { label: 'אריחים' },
            { label: 'צבע' },
            { label: 'בטון' },
          ],
        },
        { label: 'סנכרון יומן' },
        { label: 'לוח דרושים' },
        {
          label: 'סיור היכרות',
          children: [
            { label: 'מסך הבית' },
            { label: 'הזמנה' },
            { label: 'תקציב' },
            { label: 'משימות ואתר' },
            { label: 'מועדון BuildSmart' },
            { label: 'מוכנים!' },
          ],
        },
      ],
    },
  ],
  delivery: [
    {
      label: 'סוג הובלה מועדף',
      children: [{ label: 'משלוח קטן' }, { label: 'טנדר' }, { label: 'משאית' }],
    },
    { label: 'ברירת מחדל — משלוח אקספרס' },
    { label: 'אמצעי תשלום' },
  ],
  region: [
    {
      label: 'שפה',
      children: [{ label: 'עברית' }, { label: 'العربية' }, { label: 'English' }],
    },
    {
      label: 'יחידות מידה',
      children: [{ label: 'מטרי (מ׳, ק״ג)' }, { label: 'אימפריאלי' }],
    },
    {
      label: 'מטבע',
      children: [{ label: '₪ שקל' }, { label: '$ דולר' }],
    },
  ],
  about: [
    { label: 'גרסה' },
    { label: 'תנאי שימוש' },
    { label: 'מדיניות פרטיות' },
    { label: 'יצירת קשר' },
  ],
};

/* Walk SETTINGS_SUB[group] following `path` labels in order. Returns
 * the list of anchor Nodes (one per drill step) and the current list
 * of items to render above the anchors. Stops walking if a label can't
 * be found or hits a node without children. */
export function walkSettings(
  group: SettingsGroupId,
  path: string[],
): { anchors: Node[]; current: Node[] } {
  const anchors: Node[] = [];
  let current: Node[] = SETTINGS_SUB[group];
  for (const label of path) {
    const node = current.find((n) => n.label === label);
    if (!node || !node.children || node.children.length === 0) break;
    anchors.push(node);
    current = node.children;
  }
  return { anchors, current };
}

export function SettingsSubmenu() {
  const rows = [...SETTINGS_ROWS].reverse();
  const handleClick = (id: SettingsRowId) => {
    if (id === 'reset') {
      resetSettings();
      closeMenu();
      return;
    }
    setSettingsGroup(id);
  };
  return (
    <>
      {rows.map((row, i) => (
        <li
          key={row.id}
          role="none"
          class={`dial__item dial__item--sub${row.id === 'reset' ? ' dial__item--danger' : ''}`}
          style={{ animationDelay: `${i * 22}ms` }}
        >
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={() => handleClick(row.id)}
            aria-label={row.label}
          >
            <span class="dial__circle">{row.icon}</span>
            <span class="dial__label">{row.label}</span>
          </button>
        </li>
      ))}
    </>
  );
}

/* Leaf bindings — pure name → behaviour map. The key is the full path
 * joined by '>', e.g. 'display>גודל טקסט>בינוני'. A leaf with a binding
 * runs `action()` on tap (the dial stays open so the user sees the
 * effect) and shows `is-on` styling when `isActive()` returns true.
 * Leaves without a binding fall back to the legacy behaviour (close
 * the menu on tap). */
type Binding = {
  action: () => void;
  isActive?: () => boolean;
};

export const LEAF_BINDINGS: Record<string, Binding> = {
  /* === display === */
  'display>ערכת נושא>בהיר': {
    action: () => setTheme('light'),
    isActive: () => appSettings.value.display.theme === 'light',
  },
  'display>ערכת נושא>כהה': {
    action: () => setTheme('dark'),
    isActive: () => appSettings.value.display.theme === 'dark',
  },
  'display>גודל טקסט>קטן': {
    action: () => setTextSize('small'),
    isActive: () => appSettings.value.display.textSize === 'small',
  },
  'display>גודל טקסט>בינוני': {
    action: () => setTextSize('medium'),
    isActive: () => appSettings.value.display.textSize === 'medium',
  },
  'display>גודל טקסט>גדול': {
    action: () => setTextSize('large'),
    isActive: () => appSettings.value.display.textSize === 'large',
  },
  'display>הפחתת אנימציות': {
    action: () => toggleReduceMotion(),
    isActive: () => appSettings.value.display.reduceMotion,
  },

  /* === notifications — four straight on/off toggles === */
  'notifications>עדכוני משלוחים': {
    action: () => toggleNotif('shipments'),
    isActive: () => appSettings.value.notif.shipments,
  },
  'notifications>מבצעים והטבות': {
    action: () => toggleNotif('deals'),
    isActive: () => appSettings.value.notif.deals,
  },
  'notifications>התראות תקציב': {
    action: () => toggleNotif('budget'),
    isActive: () => appSettings.value.notif.budget,
  },
  'notifications>עדכוני הזמנות': {
    action: () => toggleNotif('orders'),
    isActive: () => appSettings.value.notif.orders,
  },

  /* === accessibility — single toggle === */
  'accessibility>מצב ניגודיות גבוהה (לשמש)': {
    action: () => toggleHighContrast(),
    isActive: () => appSettings.value.accessibility.highContrast,
  },

  /* === region === */
  'region>שפה>עברית': {
    action: () => setLang('he'),
    isActive: () => appSettings.value.region.lang === 'he',
  },
  'region>שפה>العربية': {
    action: () => setLang('ar'),
    isActive: () => appSettings.value.region.lang === 'ar',
  },
  'region>שפה>English': {
    action: () => setLang('en'),
    isActive: () => appSettings.value.region.lang === 'en',
  },
  'region>יחידות מידה>מטרי (מ׳, ק״ג)': {
    action: () => setUnits('metric'),
    isActive: () => appSettings.value.region.units === 'metric',
  },
  'region>יחידות מידה>אימפריאלי': {
    action: () => setUnits('imperial'),
    isActive: () => appSettings.value.region.units === 'imperial',
  },
  'region>מטבע>₪ שקל': {
    action: () => setCurrency('ils'),
    isActive: () => appSettings.value.region.currency === 'ils',
  },
  'region>מטבע>$ דולר': {
    action: () => setCurrency('usd'),
    isActive: () => appSettings.value.region.currency === 'usd',
  },

  /* === delivery — select + toggle (payment-method leaf needs a screen, not wired yet) === */
  'delivery>סוג הובלה מועדף>משלוח קטן': {
    action: () => setDefaultHaul('small'),
    isActive: () => appSettings.value.delivery.defaultHaul === 'small',
  },
  'delivery>סוג הובלה מועדף>טנדר': {
    action: () => setDefaultHaul('van'),
    isActive: () => appSettings.value.delivery.defaultHaul === 'van',
  },
  'delivery>סוג הובלה מועדף>משאית': {
    action: () => setDefaultHaul('truck'),
    isActive: () => appSettings.value.delivery.defaultHaul === 'truck',
  },
  'delivery>ברירת מחדל — משלוח אקספרס': {
    action: () => toggleExpress(),
    isActive: () => appSettings.value.delivery.express,
  },

  /* === about — @legacy index.html:6870-6876 (setLink calls) === */
  'about>גרסה': {
    action: () => showToast('BuildSmart 1.0 · אב-טיפוס'),
  },
  'about>תנאי שימוש': {
    action: () => showToast('תנאי השימוש — יוצגו בגרסה המלאה'),
  },
  'about>מדיניות פרטיות': {
    action: () => showToast('מדיניות הפרטיות — תוצג בגרסה המלאה'),
  },
  'about>יצירת קשר': {
    action: () => showToast('תמיכה — support@buildsmart.demo'),
  },
};

function leafKey(group: SettingsGroupId, path: string[], label: string): string {
  return [group, ...path, label].join('>');
}

/* Unified renderer for any depth below the group anchor. Given a list
 * of Nodes (the current `current` from walkSettings) and the path
 * already drilled, it renders each node as a dial row.
 *
 * Branches push another label onto the settings path. Leaves with a
 * matching LEAF_BINDINGS entry run the bound action and keep the menu
 * open; leaves without one close the menu. Active bindings get
 * `dial__item--leaf-on` so the current selection is visually marked. */
export function SettingsTreeSubmenu({
  group,
  nodes,
  pathPrefix,
}: {
  group: SettingsGroupId;
  nodes: Node[];
  pathPrefix: string[];
}) {
  const parent = SETTINGS_ROWS.find((r) => r.id === group);
  if (!parent) return null;
  const reversed = [...nodes].reverse();
  const handleClick = (node: Node) => {
    if (node.children && node.children.length > 0) {
      pushSettingsPath(node.label);
      return;
    }
    const binding = LEAF_BINDINGS[leafKey(group, pathPrefix, node.label)];
    if (binding) {
      binding.action();
      return;
    }
    closeMenu();
  };
  return (
    <>
      {reversed.map((node, i) => {
        const binding = LEAF_BINDINGS[leafKey(group, pathPrefix, node.label)];
        const on = binding?.isActive?.() ?? false;
        return (
          <li
            key={node.label}
            role="none"
            class={`dial__item dial__item--sub${on ? ' dial__item--leaf-on' : ''}`}
            style={{ animationDelay: `${i * 20}ms` }}
          >
            <button
              type="button"
              class="dial__btn"
              role="menuitem"
              onClick={() => handleClick(node)}
              aria-label={node.label}
              aria-pressed={binding ? on : undefined}
            >
              <span class={`dial__circle${on ? ' dial__circle--on' : ''}`}>{parent.icon}</span>
              <span class="dial__label">{node.label}</span>
            </button>
          </li>
        );
      })}
    </>
  );
}
