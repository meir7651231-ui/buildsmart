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
  editingLeafKey,
  startEditingLeaf,
  stopEditingLeaf,
  enterAdvancedSettings,
  enterProfile,
  profilePath,
  pushProfilePath,
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
  toggleTwoFA,
  toggleBiometric,
  toggleLocationPerm,
  setSessionTimeout,
  toggleSecPrivacy,
  type SessionTimeout,
} from '../../store/app-settings';
import {
  userProfile,
  setProfileField,
  type ProfileKey,
} from '../../store/user-profile';
import { showToast } from '../../store/toast-store';
import { PROJECTS } from '../../data/projects';
import {
  identityStats,
  identityAchievements,
  currentRank,
  nextRank,
  formatIls,
} from '../../data/identity';

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
  /* R9 — present for text-input leaves. When set, tapping the leaf
   * opens an inline input row instead of running `action`. `action` is
   * still required and is invoked on save (Enter or blur). */
  input?: {
    get: () => string;
    set: (v: string) => void;
    label: string;
  };
};

/* @legacy index.html:6818-6821 (menu row labels) vs :6946-6950 (edit-dialog labels).
 * They differ for `phone` only — menu row says 'טלפון', edit toast says 'מספר טלפון'. */
function profileBinding(key: ProfileKey, rowLabel: string, toastLabel: string): Binding {
  return {
    action: () => {
      /* never called — renderer detects `input` and opens edit mode. */
    },
    isActive: () => userProfile.value[key].length > 0,
    input: {
      get: () => userProfile.value[key],
      set: (v: string) => {
        setProfileField(key, v);
        showToast(`${toastLabel} עודכן`);
      },
      label: rowLabel,
    },
  };
}

export const LEAF_BINDINGS: Record<string, Binding> = {
  /* === account — R9 inline edit. @legacy index.html:6818-6821 + :6946-6950 === */
  'account>שם הקבלן': profileBinding('name', 'שם הקבלן', 'שם הקבלן'),
  'account>טלפון': profileBinding('phone', 'טלפון', 'מספר טלפון'),
  'account>סוג עוסק': profileBinding('business', 'סוג עוסק', 'סוג עוסק'),
  'account>תחום מקצועי': profileBinding('trade', 'תחום מקצועי', 'תחום מקצועי'),

  /* === delivery>אמצעי תשלום — R9 inline edit === */
  'delivery>אמצעי תשלום': profileBinding('payment', 'אמצעי תשלום', 'אמצעי תשלום'),

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

  /* === security — @legacy index.html:21753-21762 (hub items) === */

  /* L3 — simple toggles */
  'security>מרכז האבטחה>אימות דו-שלבי': {
    action: () => toggleTwoFA(),
    isActive: () => appSettings.value.security.twoFA,
  },
  'security>מרכז האבטחה>כניסה ביומטרית': {
    action: () => toggleBiometric(),
    isActive: () => appSettings.value.security.biometric,
  },
  'security>מרכז האבטחה>הרשאת מיקום': {
    action: () => toggleLocationPerm(),
    isActive: () => appSettings.value.security.locationPerm,
  },

  /* L3 — info toasts (read-only screens in legacy) */
  'security>מרכז האבטחה>יומן ביקורת': {
    action: () => showToast('יומן הביקורת יוצג בגרסה המלאה'),
  },
  'security>מרכז האבטחה>היסטוריית כניסות': {
    action: () => showToast('היסטוריית הכניסות תוצג בגרסה המלאה'),
  },
  'security>מרכז האבטחה>ניהול מכשירים': {
    action: () => showToast('ניהול המכשירים יהיה זמין בגרסה המלאה'),
  },

  /* L4 — session timeout select — @legacy index.html:21927 (setSessionTimeout) */
  'security>מרכז האבטחה>נעילת הפעלה>5 דק׳': {
    action: () => setSessionTimeout(5 as SessionTimeout),
    isActive: () => appSettings.value.security.sessionTimeout === 5,
  },
  'security>מרכז האבטחה>נעילת הפעלה>15 דק׳': {
    action: () => setSessionTimeout(15 as SessionTimeout),
    isActive: () => appSettings.value.security.sessionTimeout === 15,
  },
  'security>מרכז האבטחה>נעילת הפעלה>30 דק׳': {
    action: () => setSessionTimeout(30 as SessionTimeout),
    isActive: () => appSettings.value.security.sessionTimeout === 30,
  },
  'security>מרכז האבטחה>נעילת הפעלה>60 דק׳': {
    action: () => setSessionTimeout(60 as SessionTimeout),
    isActive: () => appSettings.value.security.sessionTimeout === 60,
  },

  /* L4 — RBAC roles info toasts — @legacy index.html:21675 (RBAC_MATRIX) */
  'security>מרכז האבטחה>הרשאות גישה>קבלן': {
    action: () => showToast('קבלן: הזמנות · תקציב · קטלוג · משימות · הטבות'),
  },
  'security>מרכז האבטחה>הרשאות גישה>מנהל מערכת': {
    action: () => showToast('מנהל מערכת: ניהול מלא — הזמנות · קטלוג · משתמשים · דוחות'),
  },
  'security>מרכז האבטחה>הרשאות גישה>ספק / חנות': {
    action: () => showToast('ספק / חנות: מילוי הזמנות · מלאי · קטלוג'),
  },
  'security>מרכז האבטחה>הרשאות גישה>שליח': {
    action: () => showToast('שליח: עדכוני משלוח · אישור מסירה'),
  },
  'security>מרכז האבטחה>הרשאות גישה>עובד': {
    action: () => showToast('עובד: משימות · סיום משימות'),
  },

  /* L4 — encryption indicators (read-only) — @legacy index.html:21953-21967 */
  'security>מרכז האבטחה>הצפנת נתונים>תקשורת מוצפנת (HTTPS/TLS)': {
    action: () => showToast('✓ תקשורת מוצפנת פעילה — HTTPS/TLS'),
  },
  'security>מרכז האבטחה>הצפנת נתונים>נתונים מקומיים מוגנים': {
    action: () => showToast('✓ נתונים מקומיים מוגנים'),
  },
  'security>מרכז האבטחה>הצפנת נתונים>סיסמאות מאוחסנות כ-Hash': {
    action: () => showToast('✓ סיסמאות מוגנות — מאוחסנות כ-Hash'),
  },
  'security>מרכז האבטחה>הצפנת נתונים>גיבוי מוצפן בענן': {
    action: () => showToast('גיבוי מוצפן — דורש שרת בגרסה המלאה'),
  },

  /* L4 — privacy toggles — @legacy index.html:22016 (privacySettings) */
  'security>מרכז האבטחה>בקרת פרטיות>שיתוף נתוני שימוש': {
    action: () => toggleSecPrivacy('analytics'),
    isActive: () => appSettings.value.security.privacy.analytics,
  },
  'security>מרכז האבטחה>בקרת פרטיות>שירותי מיקום': {
    action: () => toggleSecPrivacy('location'),
    isActive: () => appSettings.value.security.privacy.location,
  },
  'security>מרכז האבטחה>בקרת פרטיות>התאמת תוכן שיווקי': {
    action: () => toggleSecPrivacy('marketing'),
    isActive: () => appSettings.value.security.privacy.marketing,
  },
  'security>מרכז האבטחה>בקרת פרטיות>שליחת דוחות תקלה': {
    action: () => toggleSecPrivacy('crashReports'),
    isActive: () => appSettings.value.security.privacy.crashReports,
  },

  /* === support — @legacy index.html:22075 (openServiceHub, 8 tiles) === */

  /* L3 — info toasts (full features require server) */
  'support>מרכז השירות>מוקד תמיכה': {
    action: () => showToast('🎧 מוקד תמיכה — פתיחת פנייה בגרסה המלאה'),
  },
  'support>מרכז השירות>צ׳אטבוט': {
    action: () => showToast('🤖 צ׳אטבוט — מענה מיידי בגרסה המלאה'),
  },
  'support>מרכז השירות>דיווח על באג': {
    action: () => showToast('📳 דיווח על באג — זמין בגרסה המלאה'),
  },
  'support>מרכז השירות>המרת מידות': {
    action: () => showToast('📏 המרת מידות — מטרי ↔ אימפריאלי בגרסה המלאה'),
  },
  'support>מרכז השירות>סנכרון יומן': {
    action: () => showToast('📅 סנכרון Google Calendar — זמין בגרסה המלאה'),
  },
  'support>מרכז השירות>לוח דרושים': {
    action: () => showToast('📋 לוח דרושים — פרסום משרות בגרסה המלאה'),
  },

  /* L4 — quantity calculator modes — @legacy index.html:22290 (svcQtyCalc tabs) */
  'support>מרכז השירות>מחשבון כמויות>אריחים': {
    action: () => showToast('🧮 מחשבון אריחים — זמין בגרסה המלאה'),
  },
  'support>מרכז השירות>מחשבון כמויות>צבע': {
    action: () => showToast('🧮 מחשבון צבע — זמין בגרסה המלאה'),
  },
  'support>מרכז השירות>מחשבון כמויות>בטון': {
    action: () => showToast('🧮 מחשבון בטון — זמין בגרסה המלאה'),
  },

  /* L4 — onboarding tour steps — @legacy index.html:22375 (TOUR_STEPS[].d) */
  'support>מרכז השירות>סיור היכרות>מסך הבית': {
    action: () => showToast('🏠 כאן מתחילים — חיפוש מהיר, קטגוריות, וכלי ה-AI החכמים.'),
  },
  'support>מרכז השירות>סיור היכרות>הזמנה': {
    action: () => showToast('🛒 בוחרים מוצרים, מוסיפים לסל, ומאשרים — הכל מגיע ישר לאתר.'),
  },
  'support>מרכז השירות>סיור היכרות>תקציב': {
    action: () => showToast('💰 מרכז הפיננסים עוקב אחרי כל שקל — תקציב, חריגות ודוחות.'),
  },
  'support>מרכז השירות>סיור היכרות>משימות ואתר': {
    action: () => showToast('📋 ניהול אתר הבנייה — גאנט, ליקויים, נוכחות ובטיחות.'),
  },
  'support>מרכז השירות>סיור היכרות>מועדון BuildSmart': {
    action: () => showToast('🎮 צוברים BuildCoins על כל פעולה — וממשים בהטבות.'),
  },
  'support>מרכז השירות>סיור היכרות>מוכנים!': {
    action: () => showToast('🎉 זהו — אתם מכירים את BuildSmart. בהצלחה בעבודה!'),
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
  const editingKey = editingLeafKey.value;
  const handleClick = (node: Node, key: string) => {
    if (node.children && node.children.length > 0) {
      pushSettingsPath(node.label);
      return;
    }
    const binding = LEAF_BINDINGS[key];
    if (binding?.input) {
      startEditingLeaf(key);
      return;
    }
    if (binding) {
      binding.action();
      return;
    }
    closeMenu();
  };
  return (
    <>
      {reversed.map((node, i) => {
        const key = leafKey(group, pathPrefix, node.label);
        const binding = LEAF_BINDINGS[key];
        const on = binding?.isActive?.() ?? false;
        const isEditing = binding?.input && editingKey === key;
        return (
          <li
            key={node.label}
            role="none"
            class={`dial__item dial__item--sub${on ? ' dial__item--leaf-on' : ''}`}
            style={{ animationDelay: `${i * 20}ms` }}
          >
            {isEditing ? (
              <LeafEditor binding={binding!} icon={parent.icon} />
            ) : (
              <button
                type="button"
                class="dial__btn"
                role="menuitem"
                onClick={() => handleClick(node, key)}
                aria-label={node.label}
                aria-pressed={binding && !binding.input ? on : undefined}
              >
                <span class={`dial__circle${on ? ' dial__circle--on' : ''}`}>{parent.icon}</span>
                <span class="dial__label">{node.label}</span>
              </button>
            )}
          </li>
        );
      })}
    </>
  );
}

/* R9 — inline edit row. Same circle + same pill shape as the leaf,
 * but the label pill is an <input>. Enter or blur saves; Esc cancels.
 *
 * The cancelled ref guards against the blur fired by the input being
 * unmounted right after Esc — otherwise Esc would still save the typed
 * value via onBlur. */
function LeafEditor({
  binding,
  icon,
}: {
  binding: Binding;
  icon: preact.JSX.Element;
}) {
  const { input } = binding;
  if (!input) return null;
  const state = { cancelled: false };
  const commit = (raw: string) => {
    if (state.cancelled) return;
    const trimmed = raw.trim();
    const prev = input.get();
    if (trimmed !== prev) input.set(trimmed);
    stopEditingLeaf();
  };
  return (
    <div class="dial__btn" role="presentation">
      <span class="dial__circle">{icon}</span>
      <input
        class="dial__input"
        type="text"
        autoFocus
        defaultValue={input.get()}
        placeholder={input.label}
        aria-label={input.label}
        dir="auto"
        onKeyDown={(e) => {
          if (e.key === 'Enter') commit((e.currentTarget as HTMLInputElement).value);
          else if (e.key === 'Escape') {
            state.cancelled = true;
            stopEditingLeaf();
          }
        }}
        onBlur={(e) => commit((e.currentTarget as HTMLInputElement).value)}
      />
    </div>
  );
}

/* === Settings tab — 3-level dial.
 * Level 1 (TOP)     : הגדרות-פרופיל · הגדרות מתקדמות
 * Level 2 (profile) : כרטיס קבלן · דרגות הקבלן
 * Level 3 (card)    : אתה במצב הדגמה · המספרים שלך · סך הרכש דרך BuildSmart
 * Level 3 (ranks)   : ההטבה שלך · הישגים · מועדון BuildSmart
 *
 * Labels verbatim from index.html:6545-6680 (refreshIdentity) except for
 * "הגדרות-פרופיל" (user-authored grouping label — not in legacy). */

const ICON_PROFILE = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="8" r="4" />
    <path d="M4 21a8 8 0 0116 0" />
  </svg>
);

const ICON_ADVANCED = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="12" r="3" />
    <path d="M19.4 15a1.65 1.65 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.65 1.65 0 00-1.8-.3 1.65 1.65 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.65 1.65 0 00-1-1.5 1.65 1.65 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.65 1.65 0 00.3-1.8 1.65 1.65 0 00-1.5-1H3a2 2 0 010-4h.1a1.65 1.65 0 001.5-1 1.65 1.65 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.65 1.65 0 001.8.3H9a1.65 1.65 0 001-1.5V3a2 2 0 014 0v.1a1.65 1.65 0 001 1.5 1.65 1.65 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.65 1.65 0 00-.3 1.8V9a1.65 1.65 0 001.5 1H21a2 2 0 010 4h-.1a1.65 1.65 0 00-1.5 1z" />
  </svg>
);

const ICON_CARD = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <rect x="3" y="5" width="18" height="14" rx="2" />
    <path d="M3 10h18" />
  </svg>
);

const ICON_RANKS = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <path d="M5 21V9l7-5 7 5v12M9 21v-6h6v6" />
  </svg>
);

export const PROFILE_TREE: Node[] = [
  {
    label: 'כרטיס קבלן',
    children: [
      { label: 'אתה במצב הדגמה' },
      {
        label: 'המספרים שלך',
        children: [
          { label: 'הזמנות' },
          { label: 'אתרים פעילים' },
          { label: 'עצי מוצרים' },
          { label: 'אביזרים שהעץ הציל' },
        ],
      },
      { label: 'סך הרכש דרך BuildSmart' },
    ],
  },
  {
    label: 'דרגות הקבלן',
    children: [
      { label: 'ההטבה שלך' },
      {
        label: 'הישגים',
        children: [
          { label: 'הזמנה ראשונה' },
          { label: '10 הזמנות' },
          { label: 'ריבוי אתרים' },
          { label: 'חובב עץ מוצרים' },
          { label: 'לא שוכח כלום' },
          { label: 'מחזור ₪10K' },
        ],
      },
      { label: 'מועדון BuildSmart' },
    ],
  },
];

/* @legacy index.html:6535-6543 (achievement ic) + 6604-6608 (statTile ic).
 * R4 keeps emoji in the circle (icon slot), label stays plain text. */
const PROFILE_LEAF_ICONS: Record<string, string> = {
  'כרטיס קבלן>המספרים שלך>הזמנות':              '📦',
  'כרטיס קבלן>המספרים שלך>אתרים פעילים':        '🏗️',
  'כרטיס קבלן>המספרים שלך>עצי מוצרים':          '🌳',
  'כרטיס קבלן>המספרים שלך>אביזרים שהעץ הציל':   '🧠',
  'דרגות הקבלן>הישגים>הזמנה ראשונה':            '🚀',
  'דרגות הקבלן>הישגים>10 הזמנות':                '📦',
  'דרגות הקבלן>הישגים>ריבוי אתרים':             '🏗️',
  'דרגות הקבלן>הישגים>חובב עץ מוצרים':           '🌳',
  'דרגות הקבלן>הישגים>לא שוכח כלום':             '🧠',
  'דרגות הקבלן>הישגים>מחזור ₪10K':               '💰',
};

/* Per-leaf behaviours. Key = full path joined by '>'. Each leaf shows
 * a toast with real data drawn from identityStats(). Achievements
 * leaves additionally expose isActive() so the dial circle tints
 * brand-green when the achievement is unlocked. */
type ProfileLeafBinding = {
  action: () => void;
  isActive?: () => boolean;
};

function achToast(idx: number): void {
  const s = identityStats();
  const a = identityAchievements(s)[idx]!;
  showToast(`${a.ic} ${a.on ? '✓ הושג — ' : '🔒 נעול — '}${a.desc}`);
}

const PROFILE_LEAVES: Record<string, ProfileLeafBinding> = {
  'כרטיס קבלן>אתה במצב הדגמה': {
    action: () =>
      showToast('אתה במצב הדגמה · הירשם כדי לשמור את הנתונים, האתרים וההזמנות שלך'),
  },
  'כרטיס קבלן>המספרים שלך>הזמנות': {
    action: () => showToast(`הזמנות: ${identityStats().orders}`),
  },
  'כרטיס קבלן>המספרים שלך>אתרים פעילים': {
    action: () => showToast(`אתרים פעילים: ${identityStats().sites}`),
  },
  'כרטיס קבלן>המספרים שלך>עצי מוצרים': {
    action: () => showToast(`עצי מוצרים: ${identityStats().trees}`),
  },
  'כרטיס קבלן>המספרים שלך>אביזרים שהעץ הציל': {
    action: () => showToast(`אביזרים שהעץ הציל: ${identityStats().autoSaved}`),
  },
  'כרטיס קבלן>סך הרכש דרך BuildSmart': {
    action: () => showToast(`סך הרכש: ${formatIls(identityStats().spent)}`),
  },
  'דרגות הקבלן>ההטבה שלך': {
    action: () => {
      const s = identityStats();
      const r = currentRank(s.orders);
      const n = nextRank(s.orders);
      const tail = n
        ? ` · ${n.min - s.orders} עד ${n.ic} ${n.name}`
        : ' · הדרגה הגבוהה ביותר';
      showToast(`${r.ic} ${r.name} — ${r.perk}${tail}`);
    },
  },
  'דרגות הקבלן>הישגים>הזמנה ראשונה':    { action: () => achToast(0), isActive: () => identityAchievements(identityStats())[0]!.on },
  'דרגות הקבלן>הישגים>10 הזמנות':        { action: () => achToast(1), isActive: () => identityAchievements(identityStats())[1]!.on },
  'דרגות הקבלן>הישגים>ריבוי אתרים':     { action: () => achToast(2), isActive: () => identityAchievements(identityStats())[2]!.on },
  'דרגות הקבלן>הישגים>חובב עץ מוצרים':   { action: () => achToast(3), isActive: () => identityAchievements(identityStats())[3]!.on },
  'דרגות הקבלן>הישגים>לא שוכח כלום':     { action: () => achToast(4), isActive: () => identityAchievements(identityStats())[4]!.on },
  'דרגות הקבלן>הישגים>מחזור ₪10K':       { action: () => achToast(5), isActive: () => identityAchievements(identityStats())[5]!.on },
  'דרגות הקבלן>מועדון BuildSmart': {
    action: () =>
      showToast('🎮 מועדון BuildSmart — BuildCoins, אתגרים, לוח מובילים והטבות'),
  },
};

/* Level 1 — two branches. Tap "הגדרות-פרופיל" → enter profile;
 * tap "הגדרות מתקדמות" → enter advanced (existing 10 categories). */
export function SettingsTopSubmenu() {
  const rows = [
    { id: 'advanced', label: 'הגדרות מתקדמות', icon: ICON_ADVANCED, onClick: enterAdvancedSettings },
    { id: 'profile',  label: 'הגדרות-פרופיל',  icon: ICON_PROFILE,  onClick: enterProfile },
  ];
  return (
    <>
      {rows.map((r, i) => (
        <li
          key={r.id}
          role="none"
          class="dial__item dial__item--sub"
          style={{ animationDelay: `${i * 22}ms` }}
        >
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={r.onClick}
            aria-label={r.label}
          >
            <span class="dial__circle">{r.icon}</span>
            <span class="dial__label">{r.label}</span>
          </button>
        </li>
      ))}
    </>
  );
}

/* Walks PROFILE_TREE following the active profilePath. Branch labels
 * push deeper; leaves show a placeholder toast. */
function walkProfile(path: string[]): { anchors: Node[]; current: Node[] } {
  const anchors: Node[] = [];
  let current: Node[] = PROFILE_TREE;
  for (const label of path) {
    const node = current.find((n) => n.label === label);
    if (!node || !node.children || node.children.length === 0) break;
    anchors.push(node);
    current = node.children;
  }
  return { anchors, current };
}

const PROFILE_BRANCH_ICON: Record<string, preact.JSX.Element> = {
  'כרטיס קבלן': ICON_CARD,
  'דרגות הקבלן': ICON_RANKS,
};

export function ProfileTreeSubmenu() {
  const path = profilePath.value;
  const { current } = walkProfile(path);
  /* Reverse so the topmost row in the visual stack reads first. */
  const reversed = [...current].reverse();
  /* Pick an icon: branch icon if drilled in, else default. */
  const branchIcon =
    path.length > 0
      ? PROFILE_BRANCH_ICON[path[0]!] ?? ICON_PROFILE
      : ICON_PROFILE;
  return (
    <>
      {reversed.map((node, i) => {
        const leafKey = [...path, node.label].join('>');
        const binding = PROFILE_LEAVES[leafKey];
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
              onClick={() => {
                if (node.children && node.children.length > 0) {
                  pushProfilePath(node.label);
                  return;
                }
                if (binding) {
                  binding.action();
                  return;
                }
                showToast(`${node.label} — בבנייה`);
              }}
              aria-label={node.label}
              aria-pressed={binding?.isActive ? on : undefined}
            >
              <span class={`dial__circle${on ? ' dial__circle--on' : ''}`}>
                {(() => {
                  /* Priority: leaf-specific emoji (stats/achievements) →
                   * top-level branch icon → ancestor's branch icon. */
                  const emoji = PROFILE_LEAF_ICONS[leafKey];
                  if (emoji) return <span class="dial__circle-emoji">{emoji}</span>;
                  if (path.length === 0) {
                    return PROFILE_BRANCH_ICON[node.label] ?? ICON_PROFILE;
                  }
                  return branchIcon;
                })()}
              </span>
              <span class="dial__label">{node.label}</span>
            </button>
          </li>
        );
      })}
    </>
  );
}

export const PROFILE_TOP_ICON = ICON_PROFILE;
export const ADVANCED_TOP_ICON = ICON_ADVANCED;

export function profileAnchorIcon(label: string): preact.JSX.Element {
  return PROFILE_BRANCH_ICON[label] ?? ICON_PROFILE;
}

/* === Projects dial. @legacy index.html:6447-6451 + 7455 (renderProjects).
 * Placeholder — 3 project names as dial leaves, toast on tap. */

const PROJECT_ICON = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <path d="M3 21h18M5 21V7l7-4 7 4v14" />
  </svg>
);

export function ProjectsSubmenu() {
  const reversed = [...PROJECTS].reverse();
  return (
    <>
      {reversed.map((p, i) => (
        <li
          key={p.id}
          role="none"
          class="dial__item dial__item--sub"
          style={{ animationDelay: `${i * 22}ms` }}
        >
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={() => showToast(`${p.name} — בבנייה`)}
            aria-label={p.name}
          >
            <span class="dial__circle">{PROJECT_ICON}</span>
            <span class="dial__label">{p.name}</span>
          </button>
        </li>
      ))}
    </>
  );
}
