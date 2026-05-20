import { contractorName, cartCount } from '../store/app-store';

export function AppBar() {
  const count = cartCount.value;
  return (
    <header class="appbar">
      <button type="button" class="appbar__cart" aria-label="עגלת רכש">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
          <path d="M6 6h15l-1.6 9h-12L6 6z" />
          <path d="M6 6L5 2H2" />
          <circle cx="9" cy="20" r="1.6" fill="currentColor" stroke="none" />
          <circle cx="17" cy="20" r="1.6" fill="currentColor" stroke="none" />
        </svg>
        {count > 0 && <span class="appbar__cart-badge">{count}</span>}
      </button>

      <div class="appbar__brand">
        <div class="appbar__logo" aria-hidden="true">BS</div>
        <span class="appbar__name">{contractorName.value}</span>
      </div>

      <span class="appbar__spacer" aria-hidden="true" />
    </header>
  );
}
