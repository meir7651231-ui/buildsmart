/* @legacy index.html:5383-5403 (bottom tabbar — בית / קטלוג / הפרויקטים / רכש / הגדרות)
 * The five items here mirror the legacy tabbar verbatim. R2/R3: every
 * tab destination is a dial level (never a page-swap). Tabs without a
 * built-out destination just closeMenu() for now. */
import {
  menuOpen,
  closeMenu,
  menuActiveTab,
  setMenuTab,
  menuActiveSettingsGroup,
  setSettingsGroup,
  menuActiveSettingsPath,
  popSettingsPathTo,
  settingsLevel,
  exitAdvancedSettings,
  type MenuTab,
} from '../store/app-store';
import {
  ProfileSubmenu,
  ProjectsSubmenu,
  SettingsSubmenu,
  SettingsTreeSubmenu,
  SETTINGS_ROWS,
  walkSettings,
} from './menu/submenu-settings';

type Tab = {
  id: MenuTab;
  label: string;
  icon: preact.JSX.Element;
};

const TABS: Tab[] = [
  {
    id: 'home',
    label: 'בית',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 11l9-8 9 8v9a2 2 0 01-2 2H5a2 2 0 01-2-2v-9z" />
      </svg>
    ),
  },
  {
    id: 'catalog',
    label: 'קטלוג',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round">
        <circle cx="11" cy="11" r="7" />
        <path d="M21 21l-4.5-4.5" />
      </svg>
    ),
  },
  {
    id: 'projects',
    label: 'הפרויקטים',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 21h18M5 21V7l7-4 7 4v14" />
      </svg>
    ),
  },
  {
    id: 'cart',
    label: 'רכש',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 6h15l-1.5 9h-12L6 6zM6 6L5 2H2" />
        <circle cx="9" cy="20" r="1.4" fill="currentColor" stroke="none" />
        <circle cx="17" cy="20" r="1.4" fill="currentColor" stroke="none" />
      </svg>
    ),
  },
  {
    id: 'settings',
    label: 'הגדרות',
    icon: (
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="3" />
        <path d="M19.4 15a1.65 1.65 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.65 1.65 0 00-1.8-.3 1.65 1.65 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.65 1.65 0 00-1-1.5 1.65 1.65 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.65 1.65 0 00.3-1.8 1.65 1.65 0 00-1.5-1H3a2 2 0 010-4h.1a1.65 1.65 0 001.5-1 1.65 1.65 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.65 1.65 0 001.8.3H9a1.65 1.65 0 001-1.5V3a2 2 0 014 0v.1a1.65 1.65 0 001 1.5 1.65 1.65 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.65 1.65 0 00-.3 1.8V9a1.65 1.65 0 001.5 1H21a2 2 0 010 4h-.1a1.65 1.65 0 00-1.5 1z" />
      </svg>
    ),
  },
];

/* The tab "הגדרות" opens a dial whose first level is the legacy
 * profile/identity sections (placeholder) + "הגדרות מתקדמות" which
 * drills into the 10 settings categories. The tab "הפרויקטים" opens
 * a dial of the 3 project names. */
const TAB_HAS_SUBMENU: Record<MenuTab, boolean> = {
  home: false,
  catalog: false,
  projects: true,
  cart: false,
  settings: true,
};

export function MenuSpeedDial() {
  if (!menuOpen.value) return null;

  const active = menuActiveTab.value;
  const activeDef = active ? TABS.find((t) => t.id === active) ?? null : null;

  const handleTabClick = (id: MenuTab) => {
    if (TAB_HAS_SUBMENU[id]) {
      setMenuTab(id);
      return;
    }
    /* Tabs without a built dial just close the menu. No page swap. */
    closeMenu();
  };

  return (
    <>
      <button
        type="button"
        class="dial__backdrop"
        aria-label="סגור תפריט"
        onClick={closeMenu}
      />
      <ul class="dial" role="menu" aria-label="תפריט ראשי">
        {!activeDef &&
          TABS.map((tab, i) => (
            <li
              key={tab.id}
              role="none"
              class="dial__item"
              style={{ animationDelay: `${i * 28}ms` }}
            >
              <button
                type="button"
                class="dial__btn"
                role="menuitem"
                onClick={() => handleTabClick(tab.id)}
                aria-label={tab.label}
              >
                <span class="dial__circle">{tab.icon}</span>
                <span class="dial__label">{tab.label}</span>
              </button>
            </li>
          ))}

        {activeDef && (
          <>
            <li role="none" class="dial__item dial__item--active">
              <button
                type="button"
                class="dial__btn"
                role="menuitem"
                onClick={() => setMenuTab(null)}
                aria-label={`חזרה מ-${activeDef.label}`}
                aria-expanded="true"
              >
                <span class="dial__circle dial__circle--active">{activeDef.icon}</span>
                <span class="dial__label dial__label--active">{activeDef.label}</span>
              </button>
            </li>
            {active === 'settings' && <SettingsLevel />}
            {active === 'projects' && <ProjectsSubmenu />}
          </>
        )}
      </ul>
    </>
  );
}

/* When the settings tab is active, walk the SETTINGS_SUB tree to the
 * depth given by `menuActiveSettingsPath` and render:
 *   1. the group anchor (always shown when group is set)
 *   2. one anchor per path step (the labels already drilled into)
 *   3. the current list of nodes as tappable rows above them
 * All anchors are rendered before the items so that the column-reverse
 * dial places anchors at the bottom and items rise above. The deepest
 * anchor sits closest to the rising items.
 *
 * Tapping an anchor pops the path back to that level (anchors[0] pops
 * everything to return to the group's L2 view). Tapping the group
 * anchor clears the group entirely (back to the 10-row level). */
function SettingsLevel() {
  /* Level 1 of the settings tab = ProfileSubmenu (8 sections + a
   * "הגדרות מתקדמות" row that enters advanced mode). */
  if (settingsLevel.value === 'profile') return <ProfileSubmenu />;

  /* Advanced mode = the 10 settings categories. An anchor at the bottom
   * lets the user pop back to the profile level. */
  const group = menuActiveSettingsGroup.value;
  if (!group) {
    return (
      <>
        <li role="none" class="dial__item dial__item--active">
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={exitAdvancedSettings}
            aria-label="חזרה מ-הגדרות מתקדמות"
            aria-expanded="true"
          >
            <span class="dial__circle dial__circle--active">{ADVANCED_BACK_ICON}</span>
            <span class="dial__label dial__label--active">הגדרות מתקדמות</span>
          </button>
        </li>
        <SettingsSubmenu />
      </>
    );
  }
  const groupDef = SETTINGS_ROWS.find((r) => r.id === group);
  if (!groupDef) return <SettingsSubmenu />;
  const path = menuActiveSettingsPath.value;
  const { anchors, current } = walkSettings(group, path);

  return (
    <>
      <li role="none" class="dial__item dial__item--active">
        <button
          type="button"
          class="dial__btn"
          role="menuitem"
          onClick={exitAdvancedSettings}
          aria-label="חזרה מ-הגדרות מתקדמות"
          aria-expanded="true"
        >
          <span class="dial__circle dial__circle--active">{ADVANCED_BACK_ICON}</span>
          <span class="dial__label dial__label--active">הגדרות מתקדמות</span>
        </button>
      </li>
      <li role="none" class="dial__item dial__item--active">
        <button
          type="button"
          class="dial__btn"
          role="menuitem"
          onClick={() => setSettingsGroup(null)}
          aria-label={`חזרה מ-${groupDef.label}`}
          aria-expanded="true"
        >
          <span class="dial__circle dial__circle--active">{groupDef.icon}</span>
          <span class="dial__label dial__label--active">{groupDef.label}</span>
        </button>
      </li>
      {anchors.map((anchor, i) => (
        <li key={anchor.label} role="none" class="dial__item dial__item--active">
          <button
            type="button"
            class="dial__btn"
            role="menuitem"
            onClick={() => popSettingsPathTo(i)}
            aria-label={`חזרה מ-${anchor.label}`}
            aria-expanded="true"
          >
            <span class="dial__circle dial__circle--active">{groupDef.icon}</span>
            <span class="dial__label dial__label--active">{anchor.label}</span>
          </button>
        </li>
      ))}
      <SettingsTreeSubmenu group={group} nodes={current} pathPrefix={path} />
    </>
  );
}

const ADVANCED_BACK_ICON = (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
    <circle cx="12" cy="12" r="3" />
    <path d="M19.4 15a1.65 1.65 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.65 1.65 0 00-1.8-.3 1.65 1.65 0 00-1 1.5V21a2 2 0 01-4 0v-.1a1.65 1.65 0 00-1-1.5 1.65 1.65 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.65 1.65 0 00.3-1.8 1.65 1.65 0 00-1.5-1H3a2 2 0 010-4h.1a1.65 1.65 0 001.5-1 1.65 1.65 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.65 1.65 0 001.8.3H9a1.65 1.65 0 001-1.5V3a2 2 0 014 0v.1a1.65 1.65 0 001 1.5 1.65 1.65 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.65 1.65 0 00-.3 1.8V9a1.65 1.65 0 001.5 1H21a2 2 0 010 4h-.1a1.65 1.65 0 00-1.5 1z" />
  </svg>
);
