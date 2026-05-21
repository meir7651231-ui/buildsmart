import { signal, computed } from '@preact/signals';
import {
  childrenOf,
  type CatalogCategory,
  productsForPath,
  type CatalogProduct,
} from '../data/catalog';

export type Category = CatalogCategory;
export type Product = CatalogProduct;

/* ===== Settings tab — inner level. R3 says the menu→הגדרות destination
 * is a dial, not a page. Level 1 shows the legacy profile sections (8
 * placeholders + "הגדרות מתקדמות"); level 2 shows the 10 settings
 * categories (the existing tree). Drilling further follows
 * menuActiveSettingsGroup + menuActiveSettingsPath. */
export type SettingsLevelId = 'profile' | 'advanced';
export const settingsLevel = signal<SettingsLevelId>('profile');
export function enterAdvancedSettings(): void {
  settingsLevel.value = 'advanced';
}
export function exitAdvancedSettings(): void {
  settingsLevel.value = 'profile';
}

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

/* Path within a settings group's tree, by label. Empty = at the
 * group's sub-rows (level 2). Length N means N anchors drilled beyond
 * the group anchor. Stored by label so we don't need a synthetic id
 * table — labels are unique within their parent in the legacy tree. */
export const menuActiveSettingsPath = signal<string[]>([]);

/* Full leaf-key currently being edited inline (R9). null = no edit
 * active. Set when an editable leaf is tapped; cleared on save/cancel
 * or when menu/group changes. */
export const editingLeafKey = signal<string | null>(null);

export function setMenuTab(t: MenuTab | null): void {
  menuActiveTab.value = t;
  editingLeafKey.value = null;
  settingsLevel.value = 'profile';
  if (t === null) {
    menuActiveSettingsGroup.value = null;
    menuActiveSettingsPath.value = [];
  }
}

export function setSettingsGroup(g: SettingsGroupId | null): void {
  menuActiveSettingsGroup.value = g;
  menuActiveSettingsPath.value = [];
  editingLeafKey.value = null;
}

export function pushSettingsPath(label: string): void {
  menuActiveSettingsPath.value = [...menuActiveSettingsPath.value, label];
  editingLeafKey.value = null;
}

export function popSettingsPathTo(depth: number): void {
  const cur = menuActiveSettingsPath.value;
  if (depth >= cur.length) return;
  menuActiveSettingsPath.value = cur.slice(0, depth);
  editingLeafKey.value = null;
}

export function startEditingLeaf(key: string): void {
  editingLeafKey.value = key;
}
export function stopEditingLeaf(): void {
  editingLeafKey.value = null;
}

export function toggleMenu(): void {
  menuOpen.value = !menuOpen.value;
  if (!menuOpen.value) {
    menuActiveTab.value = null;
    menuActiveSettingsGroup.value = null;
    menuActiveSettingsPath.value = [];
    editingLeafKey.value = null;
    settingsLevel.value = 'profile';
  }
}
export function closeMenu(): void {
  menuOpen.value = false;
  menuActiveTab.value = null;
  menuActiveSettingsGroup.value = null;
  menuActiveSettingsPath.value = [];
  editingLeafKey.value = null;
  settingsLevel.value = 'profile';
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
