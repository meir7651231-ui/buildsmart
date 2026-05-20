import { menuOpen, toggleMenu, searchOpen, toggleSearch } from '../store/app-store';

export function Fabs() {
  const menuIsOpen = menuOpen.value;
  const searchIsOpen = searchOpen.value;
  return (
    <>
      <button
        type="button"
        class={`fab fab--menu${menuIsOpen ? ' is-open' : ''}`}
        onClick={toggleMenu}
        aria-label={menuIsOpen ? 'סגור תפריט' : 'פתח תפריט'}
        aria-expanded={menuIsOpen}
      >
        {menuIsOpen ? (
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
        class={`fab fab--search${searchIsOpen ? ' is-search-open' : ''}`}
        onClick={toggleSearch}
        aria-label={searchIsOpen ? 'סגור חיפוש' : 'חיפוש'}
        aria-expanded={searchIsOpen}
      >
        <svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round">
          <circle cx="11" cy="11" r="7" />
          <line x1="20" y1="20" x2="16.5" y2="16.5" />
        </svg>
      </button>
    </>
  );
}
