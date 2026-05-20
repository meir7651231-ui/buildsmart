export function AppBar() {
  return (
    <header class="appbar">
      <div class="appbar__brand">
        <div class="appbar__logo" aria-hidden="true">BS</div>
        <h1 class="appbar__title">
          Build<span>Smart</span>
        </h1>
      </div>
      <nav class="appbar__actions">
        <button type="button" class="iconbtn" aria-label="התראות">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 16v-5a6 6 0 1 0-12 0v5l-2 2h16l-2-2zM10 20a2 2 0 0 0 4 0" stroke-linecap="round" stroke-linejoin="round" />
          </svg>
        </button>
        <button type="button" class="iconbtn" aria-label="עגלה">
          <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M3 3h2l2 13h11l2-9H6" stroke-linecap="round" stroke-linejoin="round" />
            <circle cx="9" cy="20" r="1.5" />
            <circle cx="17" cy="20" r="1.5" />
          </svg>
        </button>
      </nav>
    </header>
  );
}
