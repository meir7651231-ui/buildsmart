import { signal, computed } from '@preact/signals';

export type Route = 'home' | 'catalog' | 'sites' | 'cart' | 'profile';

const ROUTES: Route[] = ['home', 'catalog', 'sites', 'cart', 'profile'];

function parseHash(): Route {
  const raw = window.location.hash.replace(/^#\/?/, '') as Route;
  return ROUTES.includes(raw) ? raw : 'home';
}

export const route = signal<Route>(parseHash());
export const cartCount = signal(0);
export const notificationCount = signal(0);

export const hasCart = computed(() => cartCount.value > 0);
export const hasNotifications = computed(() => notificationCount.value > 0);

window.addEventListener('hashchange', () => {
  route.value = parseHash();
});

export function navigate(next: Route): void {
  if (route.value === next) return;
  window.location.hash = `/${next}`;
}
