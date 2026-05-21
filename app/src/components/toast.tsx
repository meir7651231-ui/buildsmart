import { toastMsg } from '../store/toast-store';

export function Toast() {
  const msg = toastMsg.value;
  if (!msg) return null;
  return (
    <div class="toast" role="status" aria-live="polite" aria-atomic="true">
      {msg}
    </div>
  );
}
