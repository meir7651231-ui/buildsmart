import { menuOpen, closeMenu } from '../store/app-store';

type Tool = {
  id: string;
  label: string;
  icon: preact.JSX.Element;
};

const TOOLS: Tool[] = [
  {
    id: 'projects',
    label: 'פרויקטים',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 21h18M5 21V7l7-4 7 4v14" />
      </svg>
    ),
  },
  {
    id: 'orders',
    label: 'הזמנות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
        <path d="M3 7h18M5 7v12a2 2 0 002 2h10a2 2 0 002-2V7M9 11h6" />
      </svg>
    ),
  },
  {
    id: 'notifications',
    label: 'התראות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M18 16v-5a6 6 0 10-12 0v5l-2 2h16l-2-2zM10 20a2 2 0 004 0" />
      </svg>
    ),
  },
  {
    id: 'profile',
    label: 'פרופיל',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
        <circle cx="12" cy="8" r="4" />
        <path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6" />
      </svg>
    ),
  },
  {
    id: 'settings',
    label: 'הגדרות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="3" />
        <path d="M19.4 15a1.65 1.65 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.65 1.65 0 00-1.8-.3 1.65 1.65 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.65 1.65 0 00-1-1.5 1.65 1.65 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.65 1.65 0 00.3-1.8 1.65 1.65 0 00-1.5-1H3a2 2 0 010-4h.1a1.65 1.65 0 001.5-1 1.65 1.65 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.65 1.65 0 001.8.3H9a1.65 1.65 0 001-1.5V3a2 2 0 014 0v.1a1.65 1.65 0 001 1.5 1.65 1.65 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.65 1.65 0 00-.3 1.8V9a1.65 1.65 0 001.5 1H21a2 2 0 010 4h-.1a1.65 1.65 0 00-1.5 1z" />
      </svg>
    ),
  },
  {
    id: 'signout',
    label: 'התנתקות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" />
      </svg>
    ),
  },
];

export function MenuSpeedDial() {
  if (!menuOpen.value) return null;

  return (
    <>
      <button
        type="button"
        class="dial__backdrop"
        aria-label="סגור תפריט"
        onClick={closeMenu}
      />
      <ul class="dial" role="menu" aria-label="תפריט ראשי">
        {TOOLS.map((tool, i) => (
          <li
            key={tool.id}
            role="none"
            class="dial__item"
            style={{ animationDelay: `${i * 28}ms` }}
          >
            <button type="button" class="dial__btn" role="menuitem" onClick={closeMenu}>
              <span class="dial__circle">{tool.icon}</span>
              <span class="dial__label">{tool.label}</span>
            </button>
          </li>
        ))}
      </ul>
    </>
  );
}
