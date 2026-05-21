/* @legacy index.html:6806 (renderSettings — 10 section groups)
 * Names only for now: legacy reading order is preserved (account first,
 * reset last). No actions wired — each row just closes the menu.
 *
 * Rendering note: the parent `<ul class="dial">` uses
 * `flex-direction: column-reverse`, so the LAST <li> in the JSX ends up
 * at the TOP of the visual stack. We reverse the data order here so the
 * stack reads top→bottom in legacy order.
 */
import { closeMenu } from '../../store/app-store';

export type SettingsRowId =
  | 'account'
  | 'notifications'
  | 'display'
  | 'accessibility'
  | 'security'
  | 'support'
  | 'delivery'
  | 'region'
  | 'about'
  | 'reset';

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

export function SettingsSubmenu() {
  const rows = [...SETTINGS_ROWS].reverse();
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
            onClick={closeMenu}
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
