import { signal, computed } from '@preact/signals';
import { childrenOf, type Category } from '../data/categories';
import { productsForPath, type Product } from '../data/products';

/* ===== Navigation: category drill-down ===== */
export const categoryPath = signal<string[]>([]);

export const currentCircles = computed<Category[]>(() => {
  const path = categoryPath.value;
  const parent = path.length === 0 ? null : path[path.length - 1]!;
  return childrenOf(parent);
});

export const currentProducts = computed<Product[]>(() =>
  productsForPath(categoryPath.value, categoryPath.value.length === 0),
);

export function drillInto(categoryId: string): void {
  const next = [...categoryPath.value, categoryId];
  if (childrenOf(categoryId).length === 0) {
    return;
  }
  categoryPath.value = next;
}

export function jumpTo(index: number): void {
  categoryPath.value = categoryPath.value.slice(0, index);
}

export function resetCategory(): void {
  categoryPath.value = [];
}

/* ===== Overlays ===== */
export const menuOpen = signal(false);
export const searchOpen = signal(false);
export const openedProductId = signal<string | null>(null);

export function openMenu(): void {
  menuOpen.value = true;
}
export function closeMenu(): void {
  menuOpen.value = false;
}
export function openSearch(): void {
  searchOpen.value = true;
}
export function closeSearch(): void {
  searchOpen.value = false;
}
export function openProduct(id: string): void {
  openedProductId.value = id;
}
export function closeProduct(): void {
  openedProductId.value = null;
}

/* ===== Cart ===== */
export type CartLine = { productId: string; qty: number };

export const cart = signal<CartLine[]>([]);

export const cartCount = computed(() =>
  cart.value.reduce((sum, line) => sum + line.qty, 0),
);

export function addToCart(productId: string, qty: number): void {
  const existing = cart.value.find((l) => l.productId === productId);
  if (existing) {
    cart.value = cart.value.map((l) =>
      l.productId === productId ? { ...l, qty: l.qty + qty } : l,
    );
  } else {
    cart.value = [...cart.value, { productId, qty }];
  }
}

export function removeFromCart(productId: string): void {
  cart.value = cart.value.filter((l) => l.productId !== productId);
}

/* ===== Notifications (placeholder) ===== */
export const notificationCount = signal(0);
