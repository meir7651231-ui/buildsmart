import { menuOpen, closeMenu, cartCount } from '../store/app-store';

type Tool = {
  id: string;
  label: string;
  helper: string;
  icon: preact.JSX.Element;
  badge?: number;
};

function buildTools(): Tool[] {
  return [
    {
      id: 'cart',
      label: 'עגלת רכש',
      helper: 'פריטים שמוכנים להזמנה',
      badge: cartCount.value,
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <path d="M6 6h15l-1.5 9h-12L6 6zM6 6L5 2H2" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      ),
    },
    {
      id: 'projects',
      label: 'הפרויקטים שלי',
      helper: 'תקציב, משימות וצוות',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <path d="M3 21h18M5 21V7l7-4 7 4v14" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      ),
    },
    {
      id: 'orders',
      label: 'הזמנות',
      helper: 'מעקב משלוחים והיסטוריה',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <path d="M3 7h18M5 7v12a2 2 0 002 2h10a2 2 0 002-2V7M9 11h6" stroke-linecap="round" />
        </svg>
      ),
    },
    {
      id: 'notifications',
      label: 'התראות',
      helper: 'עדכוני משלוח ואיומים',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <path d="M18 16v-5a6 6 0 10-12 0v5l-2 2h16l-2-2zM10 20a2 2 0 004 0" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      ),
    },
    {
      id: 'profile',
      label: 'הפרופיל',
      helper: 'דרגה, הישגים ופרטים',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <circle cx="12" cy="8" r="4" />
          <path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6" stroke-linecap="round" />
        </svg>
      ),
    },
    {
      id: 'settings',
      label: 'הגדרות',
      helper: 'שפה, התראות, מצב כהה',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <circle cx="12" cy="12" r="3" />
          <path d="M19.4 15a1.65 1.65 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.65 1.65 0 00-1.8-.3 1.65 1.65 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.65 1.65 0 00-1-1.5 1.65 1.65 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.65 1.65 0 00.3-1.8 1.65 1.65 0 00-1.5-1H3a2 2 0 010-4h.1a1.65 1.65 0 001.5-1 1.65 1.65 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.65 1.65 0 001.8.3H9a1.65 1.65 0 001-1.5V3a2 2 0 014 0v.1a1.65 1.65 0 001 1.5 1.65 1.65 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.65 1.65 0 00-.3 1.8V9a1.65 1.65 0 001.5 1H21a2 2 0 010 4h-.1a1.65 1.65 0 00-1.5 1z" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      ),
    },
    {
      id: 'signout',
      label: 'התנתקות',
      helper: 'יציאה מהחשבון',
      icon: (
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9">
          <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4M16 17l5-5-5-5M21 12H9" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      ),
    },
  ];
}

export function MenuDrawer() {
  if (!menuOpen.value) return null;
  const tools = buildTools();

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label="תפריט ראשי">
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={closeMenu} />
      <div class="sheet__panel">
        <div class="sheet__handle" aria-hidden="true" />
        <header class="sheet__head">
          <h2 class="sheet__title">תפריט</h2>
          <button type="button" class="sheet__close" onClick={closeMenu} aria-label="סגור">
            <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
              <line x1="6" y1="6" x2="18" y2="18" />
              <line x1="18" y1="6" x2="6" y2="18" />
            </svg>
          </button>
        </header>

        <ul class="sheet__list">
          {tools.map((tool) => (
            <li key={tool.id}>
              <button type="button" class="tool" onClick={closeMenu}>
                <span class="tool__icon">{tool.icon}</span>
                <span class="tool__text">
                  <span class="tool__label">{tool.label}</span>
                  <span class="tool__helper">{tool.helper}</span>
                </span>
                {tool.badge ? <span class="tool__badge">{tool.badge}</span> : null}
                <span class="tool__chev" aria-hidden="true">‹</span>
              </button>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
