import { contractorName, cartCount } from '../store/app-store';
import { toggleBs, bsOpen } from '../store/bs-store';

export function FloatingHeader() {
  const count = cartCount.value;
  const bsActive = bsOpen.value;

  return (
    <>
      <button
        type="button"
        class={`float float--logo${bsActive ? ' is-open' : ''}`}
        aria-label="BuildSmart"
        aria-expanded={bsActive}
        onClick={toggleBs}
      >
        BS
      </button>

      <div class="float float--name" role="status" aria-live="polite">
        {contractorName.value}
      </div>

      <button type="button" class="float float--cart" aria-label="עגלת רכש">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
          <path d="M6 6h15l-1.6 9h-12L6 6z" />
          <path d="M6 6L5 2H2" />
          <circle cx="9" cy="20" r="1.6" fill="currentColor" stroke="none" />
          <circle cx="17" cy="20" r="1.6" fill="currentColor" stroke="none" />
        </svg>
        {count > 0 && <span class="float__badge">{count}</span>}
      </button>
    </>
  );
}
