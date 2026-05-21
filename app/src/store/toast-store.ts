import { signal } from '@preact/signals';

export const toastMsg = signal<string | null>(null);

let _timer: ReturnType<typeof setTimeout> | null = null;

export function showToast(msg: string, durationMs = 3200): void {
  if (_timer) clearTimeout(_timer);
  toastMsg.value = msg;
  _timer = setTimeout(() => {
    toastMsg.value = null;
    _timer = null;
  }, durationMs);
}
