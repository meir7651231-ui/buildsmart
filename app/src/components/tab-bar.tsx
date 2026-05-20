import { type Route, route, cartCount, navigate } from '../store/app-store';

type TabDef = {
  id: Route;
  label: string;
  icon: preact.JSX.Element;
};

const HomeIcon = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M3 11l9-8 9 8v9a2 2 0 01-2 2H5a2 2 0 01-2-2v-9z" stroke="currentColor" stroke-width="1.9" stroke-linejoin="round" />
  </svg>
);

const CatalogIcon = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="1.9" />
    <path d="M21 21l-4.5-4.5" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
  </svg>
);

const SitesIcon = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M3 21h18M5 21V7l7-4 7 4v14" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" />
  </svg>
);

const CartIcon = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <path d="M6 6h15l-1.5 9h-12L6 6zM6 6L5 2H2" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" />
    <circle cx="8" cy="20" r="1.4" fill="currentColor" />
    <circle cx="18" cy="20" r="1.4" fill="currentColor" />
  </svg>
);

const ProfileIcon = (
  <svg viewBox="0 0 24 24" fill="none" aria-hidden="true">
    <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.9" />
    <path d="M4 21c1.5-4 4.5-6 8-6s6.5 2 8 6" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" />
  </svg>
);

const TABS: TabDef[] = [
  { id: 'home', label: 'בית', icon: HomeIcon },
  { id: 'catalog', label: 'קטלוג', icon: CatalogIcon },
  { id: 'sites', label: 'פרויקטים', icon: SitesIcon },
  { id: 'cart', label: 'רכש', icon: CartIcon },
  { id: 'profile', label: 'הגדרות', icon: ProfileIcon },
];

export function TabBar() {
  const active = route.value;
  return (
    <nav class="tabbar" aria-label="ניווט ראשי">
      {TABS.map((tab) => {
        const isActive = tab.id === active;
        const showBadge = tab.id === 'cart' && cartCount.value > 0;
        return (
          <button
            key={tab.id}
            type="button"
            class={`tabbar__tab${isActive ? ' is-active' : ''}`}
            aria-current={isActive ? 'page' : undefined}
            onClick={() => navigate(tab.id)}
          >
            <span class="tabbar__icon">{tab.icon}</span>
            <span class="tabbar__label">{tab.label}</span>
            {showBadge && <span class="tabbar__badge">{cartCount.value}</span>}
          </button>
        );
      })}
    </nav>
  );
}
