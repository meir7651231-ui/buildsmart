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
  setSubRow,
  type SettingsGroupId,
} from '../../store/app-store';

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

/* @legacy index.html:6817-6875 — sub-rows per group, in legacy reading order.
 * Sources for the optional `children` (grandchildren shown at level 3):
 *   - select option labels:  SETTINGS_LABELS at index.html:6750-6757
 *   - security hub tiles:    openSecurityHub() at index.html:21752-21762
 *   - service hub tiles:     openServiceHub()  at index.html:22081-22090
 * `reset` is excluded — it's an action with no sub-rows. Rows without
 * `children` are leaves at level 2 and just close the menu when tapped. */
type SubRow = { label: string; children?: string[] };

export const SETTINGS_SUB: Record<SettingsGroupId, SubRow[]> = {
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
    { label: 'ערכת נושא', children: ['בהיר', 'כהה'] },
    { label: 'גודל טקסט', children: ['קטן', 'בינוני', 'גדול'] },
    { label: 'הפחתת אנימציות' },
  ],
  accessibility: [
    { label: 'מצב ניגודיות גבוהה (לשמש)' },
  ],
  security: [
    {
      label: 'מרכז האבטחה',
      children: [
        'אימות דו-שלבי',
        'הרשאות גישה',
        'כניסה ביומטרית',
        'יומן ביקורת',
        'הרשאת מיקום',
        'נעילת הפעלה',
        'הצפנת נתונים',
        'היסטוריית כניסות',
        'ניהול מכשירים',
        'בקרת פרטיות',
      ],
    },
  ],
  support: [
    {
      label: 'מרכז השירות',
      children: [
        'מוקד תמיכה',
        'צ׳אטבוט',
        'דיווח על באג',
        'המרת מידות',
        'מחשבון כמויות',
        'סנכרון יומן',
        'לוח דרושים',
        'סיור היכרות',
      ],
    },
  ],
  delivery: [
    { label: 'סוג הובלה מועדף', children: ['משלוח קטן', 'טנדר', 'משאית'] },
    { label: 'ברירת מחדל — משלוח אקספרס' },
    { label: 'אמצעי תשלום' },
  ],
  region: [
    { label: 'שפה', children: ['עברית', 'العربية', 'English'] },
    { label: 'יחידות מידה', children: ['מטרי (מ׳, ק״ג)', 'אימפריאלי'] },
    { label: 'מטבע', children: ['₪ שקל', '$ דולר'] },
  ],
  about: [
    { label: 'גרסה' },
    { label: 'תנאי שימוש' },
    { label: 'מדיניות פרטיות' },
    { label: 'יצירת קשר' },
  ],
};

export function findSubRow(group: SettingsGroupId, label: string): SubRow | undefined {
  return SETTINGS_SUB[group].find((r) => r.label === label);
}

export function SettingsSubmenu() {
  const rows = [...SETTINGS_ROWS].reverse();
  const handleClick = (id: SettingsRowId) => {
    if (id === 'reset') {
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

/* Level-3 (sub-sub) renderer — for a given group, lists its sub-rows.
 * Rows with `children` drill further (set the sub-row); leaf rows just
 * close the menu. Reuses the parent group's icon for visual cohesion. */
export function SettingsSubSubmenu({ group }: { group: SettingsGroupId }) {
  const parent = SETTINGS_ROWS.find((r) => r.id === group);
  if (!parent) return null;
  const rows = SETTINGS_SUB[group];
  const reversed = [...rows].reverse();
  const handleClick = (row: SubRow) => {
    if (row.children && row.children.length > 0) {
      setSubRow(row.label);
    } else {
      closeMenu();
    }
  };
  return (
    <>
      {reversed.map((row, i) => (
        <li
          key={row.label}
          role="none"
          class="dial__item dial__item--sub"
          style={{ animationDelay: `${i * 22}ms` }}
        >
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={() => handleClick(row)}
            aria-label={row.label}
          >
            <span class="dial__circle">{parent.icon}</span>
            <span class="dial__label">{row.label}</span>
          </button>
        </li>
      ))}
    </>
  );
}

/* Level-4 (leaf) renderer — given a (group, sub-row) pair, lists the
 * grandchildren. These are the deepest names: select options for the
 * setSelect rows, hub tile names for security/support. All taps close
 * the menu (names only — no actions wired). */
export function SettingsLeafSubmenu({
  group,
  subLabel,
}: {
  group: SettingsGroupId;
  subLabel: string;
}) {
  const parent = SETTINGS_ROWS.find((r) => r.id === group);
  const sub = findSubRow(group, subLabel);
  if (!parent || !sub || !sub.children) return null;
  const reversed = [...sub.children].reverse();
  return (
    <>
      {reversed.map((leaf, i) => (
        <li
          key={leaf}
          role="none"
          class="dial__item dial__item--sub"
          style={{ animationDelay: `${i * 20}ms` }}
        >
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={closeMenu}
            aria-label={leaf}
          >
            <span class="dial__circle">{parent.icon}</span>
            <span class="dial__label">{leaf}</span>
          </button>
        </li>
      ))}
    </>
  );
}
