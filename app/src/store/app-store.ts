import { signal, computed } from '@preact/signals';
import {
  childrenOf,
  type CatalogCategory,
  productsForPath,
  type CatalogProduct,
} from '../data/catalog';

export type Category = CatalogCategory;
export type Product = CatalogProduct;

/* ===== Navigation: category drill-down ===== */
export const categoryPath = signal<string[]>([]);

export const currentCircles = computed<Category[]>(() => {
  const path = categoryPath.value;
  const parent = path.length === 0 ? null : path[path.length - 1]!;
  return childrenOf(parent);
});

export const currentParentId = computed<string | null>(() => {
  const path = categoryPath.value;
  return path.length === 0 ? null : path[path.length - 1]!;
});

export const currentProducts = computed<Product[]>(() =>
  productsForPath(categoryPath.value),
);

export function drillInto(categoryId: string): void {
  categoryPath.value = [...categoryPath.value, categoryId];
}

export function goUp(): void {
  const path = categoryPath.value;
  if (path.length === 0) return;
  categoryPath.value = path.slice(0, -1);
}

export function resetCategory(): void {
  categoryPath.value = [];
}

/* ===== Overlays ===== */
export const menuOpen = signal(false);
export const searchOpen = signal(false);
export const openedProductId = signal<string | null>(null);

/* Which top-level menu tab is "drilled into". null = show all five FABs. */
export type MenuTab = 'home' | 'catalog' | 'projects' | 'cart' | 'settings';
export const menuActiveTab = signal<MenuTab | null>(null);

/* Within settings, which sub-group is drilled into. null = the 10-row list. */
export type SettingsGroupId =
  | 'account'
  | 'notifications'
  | 'display'
  | 'accessibility'
  | 'security'
  | 'support'
  | 'delivery'
  | 'region'
  | 'about';
export const menuActiveSettingsGroup = signal<SettingsGroupId | null>(null);

/* Within a settings sub-group, which row was drilled into (level 3).
 * Stored as the row's Hebrew label so we don't need a synthetic id table. */
export const menuActiveSubRow = signal<string | null>(null);

export function setMenuTab(t: MenuTab | null): void {
  menuActiveTab.value = t;
  if (t === null) {
    menuActiveSettingsGroup.value = null;
    menuActiveSubRow.value = null;
  }
}

export function setSettingsGroup(g: SettingsGroupId | null): void {
  menuActiveSettingsGroup.value = g;
  menuActiveSubRow.value = null;
}

export function setSubRow(label: string | null): void {
  menuActiveSubRow.value = label;
}

export function toggleMenu(): void {
  menuOpen.value = !menuOpen.value;
  if (!menuOpen.value) {
    menuActiveTab.value = null;
    menuActiveSettingsGroup.value = null;
    menuActiveSubRow.value = null;
  }
}
export function closeMenu(): void {
  menuOpen.value = false;
  menuActiveTab.value = null;
  menuActiveSettingsGroup.value = null;
  menuActiveSubRow.value = null;
}
export function openSearch(): void {
  searchOpen.value = true;
}
export function closeSearch(): void {
  searchOpen.value = false;
}
export function toggleSearch(): void {
  searchOpen.value = !searchOpen.value;
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

export function qtyOf(productId: string): number {
  return cart.value.find((l) => l.productId === productId)?.qty ?? 0;
}

export function setQty(productId: string, qty: number): void {
  const clamped = Math.max(0, qty);
  const existing = cart.value.find((l) => l.productId === productId);
  if (clamped === 0) {
    if (existing) cart.value = cart.value.filter((l) => l.productId !== productId);
    return;
  }
  if (existing) {
    cart.value = cart.value.map((l) =>
      l.productId === productId ? { ...l, qty: clamped } : l,
    );
  } else {
    cart.value = [...cart.value, { productId, qty: clamped }];
  }
}

export function incQty(productId: string): void {
  setQty(productId, qtyOf(productId) + 1);
}
export function decQty(productId: string): void {
  setQty(productId, qtyOf(productId) - 1);
}

/* ===== Notifications ===== */
export const notificationCount = signal(0);
