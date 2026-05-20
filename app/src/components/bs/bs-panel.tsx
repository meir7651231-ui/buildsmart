import {
  bsOpen,
  closeBs,
  bsActiveTool,
  setBsTool,
  theme,
  setTheme,
  language,
  setLanguage,
  type BsToolKind,
  type ThemeMode,
  type Language,
} from '../../store/bs-store';
import { resetCategory } from '../../store/app-store';

type Tool = {
  id: BsToolKind;
  label: string;
  helper: string;
  icon: preact.JSX.Element;
  navigates: boolean;
};

const TOOLS: Tool[] = [
  {
    id: 'home',
    label: 'דף הבית',
    helper: 'איפוס למסך הראשי',
    navigates: false,
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 11l9-8 9 8M5 10v10h14V10" />
      </svg>
    ),
  },
  {
    id: 'theme',
    label: 'מצב כהה',
    helper: 'בהיר · כהה · אוטומטי',
    navigates: true,
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 12.8A9 9 0 1111.2 3 7 7 0 0021 12.8z" />
      </svg>
    ),
  },
  {
    id: 'language',
    label: 'שפה',
    helper: 'עברית · English · العربية',
    navigates: true,
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M3 12h18M12 3a14 14 0 010 18M12 3a14 14 0 000 18" />
      </svg>
    ),
  },
  {
    id: 'help',
    label: 'עזרה',
    helper: 'מדריך וקיצורים',
    navigates: false,
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M9.5 9a2.5 2.5 0 014.83.9c0 1.7-2.5 2.6-2.5 4.1M12 17.5h.01" />
      </svg>
    ),
  },
];

export function BsPanel() {
  const open = bsOpen.value;
  const tool = bsActiveTool.value;
  const activeTool = tool ? TOOLS.find((t) => t.id === tool) : null;

  const handleClose = () => {
    closeBs();
    setBsTool(null);
  };

  const handleMainTap = (t: Tool) => {
    if (t.navigates) {
      setBsTool(t.id);
      return;
    }
    if (t.id === 'home') resetCategory();
    handleClose();
  };

  return (
    <div class={`bspanel${open ? ' is-open' : ''}`} aria-hidden={!open}>
      <button
        type="button"
        class="bspanel__scrim"
        aria-label="סגור"
        onClick={handleClose}
        tabIndex={open ? 0 : -1}
      />
      <aside
        class="bspanel__drawer"
        role="dialog"
        aria-modal="true"
        aria-label="הגדרות BuildSmart"
      >
        <header class="bspanel__head">
          {activeTool ? (
            <button
              type="button"
              class="bspanel__back"
              onClick={() => setBsTool(null)}
              aria-label="חזרה"
            >
              <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M7 12h13M13 6l-6 6 6 6" />
              </svg>
            </button>
          ) : (
            <div class="bspanel__brand">
              <span class="bspanel__brand-mark">BS</span>
              <span class="bspanel__brand-name">BuildSmart</span>
            </div>
          )}
          <div class="bspanel__title">
            {activeTool ? activeTool.label : 'מה תרצה לעשות?'}
          </div>
        </header>

        <div class="bspanel__body">
          {!activeTool && <MainList onTap={handleMainTap} />}
          {tool === 'theme' && <ThemeList />}
          {tool === 'language' && <LanguageList />}
        </div>

        <footer class="bspanel__foot">
          <span>גרסה 0.1 · BuildSmart</span>
        </footer>
      </aside>
    </div>
  );
}

function MainList({ onTap }: { onTap: (t: Tool) => void }) {
  return (
    <ul class="bslist" role="menu">
      {TOOLS.map((t) => (
        <li key={t.id}>
          <button
            type="button"
            class="bsrow"
            role="menuitem"
            onClick={() => onTap(t)}
          >
            <span class="bsrow__icon">{t.icon}</span>
            <span class="bsrow__text">
              <span class="bsrow__label">{t.label}</span>
              <span class="bsrow__helper">{t.helper}</span>
            </span>
            <span class="bsrow__chev" aria-hidden="true">‹</span>
          </button>
        </li>
      ))}
    </ul>
  );
}

const THEME_OPTS: Array<{ id: ThemeMode; label: string; helper: string; icon: preact.JSX.Element }> = [
  {
    id: 'light',
    label: 'בהיר',
    helper: 'תצוגה רגילה ביום',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="4" />
        <path d="M12 3v2M12 19v2M5 12H3M21 12h-2M6 6l1.5 1.5M16.5 16.5L18 18M6 18l1.5-1.5M16.5 7.5L18 6" />
      </svg>
    ),
  },
  {
    id: 'dark',
    label: 'כהה',
    helper: 'נוח יותר בלילה',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 12.8A9 9 0 1111.2 3 7 7 0 0021 12.8z" />
      </svg>
    ),
  },
  {
    id: 'auto',
    label: 'אוטומטי',
    helper: 'לפי הגדרות המכשיר',
    icon: (
      <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="9" />
        <path d="M12 3v18" />
        <path d="M12 3a9 9 0 010 18z" fill="currentColor" opacity="0.35" />
      </svg>
    ),
  },
];

function ThemeList() {
  const current = theme.value;
  return (
    <ul class="bslist" role="radiogroup" aria-label="מצב כהה">
      {THEME_OPTS.map((o) => {
        const on = current === o.id;
        return (
          <li key={o.id}>
            <button
              type="button"
              role="radio"
              aria-checked={on}
              class={`bsrow${on ? ' is-on' : ''}`}
              onClick={() => setTheme(o.id)}
            >
              <span class="bsrow__icon">{o.icon}</span>
              <span class="bsrow__text">
                <span class="bsrow__label">{o.label}</span>
                <span class="bsrow__helper">{o.helper}</span>
              </span>
              {on && (
                <span class="bsrow__check" aria-hidden="true">
                  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M5 12l5 5L20 7" />
                  </svg>
                </span>
              )}
            </button>
          </li>
        );
      })}
    </ul>
  );
}

const LANG_OPTS: Array<{ id: Language; label: string; helper: string }> = [
  { id: 'he', label: 'עברית', helper: 'ברירת מחדל' },
  { id: 'en', label: 'English', helper: 'English (US)' },
  { id: 'ar', label: 'العربية', helper: 'Arabic' },
];

function LanguageList() {
  const current = language.value;
  return (
    <ul class="bslist" role="radiogroup" aria-label="שפה">
      {LANG_OPTS.map((o) => {
        const on = current === o.id;
        return (
          <li key={o.id}>
            <button
              type="button"
              role="radio"
              aria-checked={on}
              class={`bsrow${on ? ' is-on' : ''}`}
              onClick={() => setLanguage(o.id)}
            >
              <span class="bsrow__icon bsrow__icon--text" aria-hidden="true">
                {o.id === 'he' ? 'אב' : o.id === 'en' ? 'Aa' : 'ا'}
              </span>
              <span class="bsrow__text">
                <span class="bsrow__label">{o.label}</span>
                <span class="bsrow__helper">{o.helper}</span>
              </span>
              {on && (
                <span class="bsrow__check" aria-hidden="true">
                  <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M5 12l5 5L20 7" />
                  </svg>
                </span>
              )}
            </button>
          </li>
        );
      })}
    </ul>
  );
}
