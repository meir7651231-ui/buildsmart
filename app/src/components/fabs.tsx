import { menuOpen, toggleMenu, openSearch } from '../store/app-store';

export function Fabs() {
  const open = menuOpen.value;
  return (
    <>
      <button
        type="button"
        class={`fab fab--menu${open ? ' is-open' : ''}`}
        onClick={toggleMenu}
        aria-label={open ? 'סגור תפריט' : 'פתח תפריט'}
        aria-expanded={open}
      >
        {open ? (
          <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round">
            <line x1="6" y1="6" x2="18" y2="18" />
            <line x1="18" y1="6" x2="6" y2="18" />
          </svg>
        ) : (
          <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
            <line x1="4" y1="7" x2="20" y2="7" />
            <line x1="4" y1="12" x2="20" y2="12" />
            <line x1="4" y1="17" x2="20" y2="17" />
          </svg>
        )}
      </button>

      <button
        type="button"
        class="fab fab--search"
        onClick={openSearch}
        aria-label="חיפוש"
      >
        <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
          <circle cx="11" cy="11" r="7" />
          <line x1="20" y1="20" x2="16.5" y2="16.5" />
        </svg>
      </button>
    </>
  );
}
