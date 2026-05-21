import {
  bsOpen,
  activePersona,
  bsDrillPersona,
  bsDrillPath,
  drillIntoPersona,
  popBsDrill,
  pushBsDrill,
  popBsDrillPathTo,
  type Persona,
} from '../../store/bs-store';
import { showToast } from '../../store/toast-store';

type Tile = { id: Persona; label: string; emoji: string };

/* @legacy index.html:4088-4113 (role-drawer "מי אתה?") — labels are
 * the verbatim <b> text of each role-pick-btn. L1 of the BS dial. */
const TILES: Tile[] = [
  { id: 'contractor', label: 'קבלן',         emoji: '👷' },
  { id: 'manager',    label: 'מנהל המערכת',  emoji: '👔' },
  { id: 'store',      label: 'חנות ספק',     emoji: '🏪' },
  { id: 'courier',    label: 'שליח',         emoji: '🛵' },
  { id: 'worker',     label: 'עובד',         emoji: '🦺' },
];

/* Section can branch (children) or be a leaf (no children). */
type Section = {
  id: string;
  emoji: string;
  title: string;
  children?: Section[];
};

/* @legacy index.html:4260-4263 (admTab buttons of screen-store). */
const STORE_SECTIONS: Section[] = [
  { id: 's-home',    emoji: '🏠', title: 'בית' },
  { id: 's-orders',  emoji: '📥', title: 'הזמנות' },
  { id: 's-stock',   emoji: '📦', title: 'מלאי' },
  { id: 's-portal',  emoji: '🧰', title: 'פורטל' },
];

/* @legacy index.html:17991-18043 (renderCourierHome). Section titles
 * verbatim; emoji per section:
 *   🛵 = HAUL_TYPES[0].ic (vehicle picker, @11951)
 *   📦 = chStat 'לאיסוף' ic (@18033)
 *   🚚 = chStat 'בדרך' ic (@18034) / empty-state ic (@7762)
 *   🧰 = fin-hub-ic for "פורטל השליח" (@18039) */
const COURIER_SECTIONS: Section[] = [
  { id: 'vehicle', emoji: '🛵', title: 'הרכב שלי היום' },
  { id: 'pickup',  emoji: '📦', title: 'משלוחים ממתינים לאיסוף' },
  { id: 'active',  emoji: '🚚', title: 'משלוחים פעילים' },
  { id: 'portal',  emoji: '🧰', title: 'פורטל השליח' },
];

/* @legacy index.html:8099-8102 — renderWorker task-group headers,
 * verbatim incl. the emoji prefix:
 *   🔨 = task-group 'act' @8099
 *   ⏳ = task-group 'pend' @8101
 *   📋 = task-group 'done' @8102 */
const WORKER_SECTIONS: Section[] = [
  { id: 'current',   emoji: '🔨', title: 'המשימה הנוכחית שלך' },
  { id: 'queue',     emoji: '⏳', title: 'הבאות בתור' },
  { id: 'submitted', emoji: '📋', title: 'שהגשת' },
];

/* @legacy index.html:4213-4216 — admTab buttons of screen-manager,
 * verbatim incl. emoji prefix:
 *   📊 לוח בקרה   @4213
 *   🚚 הזמנות     @4214
 *   👥 לקוחות     @4215
 *   🛠️ ניהול     @4216
 *
 * @legacy index.html:12160-12164 — לוח בקרה metric tiles (mdMetric calls):
 *   🚚 הזמנות פתוחות
 *   📦 מוצרים בקטלוג
 *   🧰 אביזרים נלווים
 *   ✅ זמינים כעת
 *   🏪 חנויות פעילות
 * Both emoji + label are verbatim from each mdMetric() call. */
const MANAGER_SECTIONS: Section[] = [
  {
    id: 'm-products',
    emoji: '📊',
    title: 'לוח בקרה',
    children: [
      { id: 'md-open-orders',  emoji: '🚚', title: 'הזמנות פתוחות' },
      { id: 'md-catalog',      emoji: '📦', title: 'מוצרים בקטלוג' },
      { id: 'md-accessories',  emoji: '🧰', title: 'אביזרים נלווים' },
      { id: 'md-available',    emoji: '✅', title: 'זמינים כעת' },
      { id: 'md-stores',       emoji: '🏪', title: 'חנויות פעילות' },
    ],
  },
  { id: 'm-orders',    emoji: '🚚', title: 'הזמנות' },
  { id: 'm-customers', emoji: '👥', title: 'לקוחות' },
  { id: 'm-manage',    emoji: '🛠️', title: 'ניהול' },
];

/* Other personas have no sub-sections yet — drill shows back anchor only. */
const PERSONA_SECTIONS: Partial<Record<Persona, Section[]>> = {
  store: STORE_SECTIONS,
  courier: COURIER_SECTIONS,
  worker: WORKER_SECTIONS,
  manager: MANAGER_SECTIONS,
};

/* Walk the persona's section tree along the given path. Returns the
 * list of anchor sections (one per drill step) and the items at the
 * current depth. Stops on missing label or empty children. */
function walkBsDrill(
  persona: Persona,
  path: string[],
): { anchors: Section[]; current: Section[] } {
  const anchors: Section[] = [];
  let current: Section[] = PERSONA_SECTIONS[persona] ?? [];
  for (const label of path) {
    const node = current.find((s) => s.title === label);
    if (!node || !node.children || node.children.length === 0) break;
    anchors.push(node);
    current = node.children;
  }
  return { anchors, current };
}

export function BsDial() {
  if (!bsOpen.value) return null;
  const drilled = bsDrillPersona.value;

  /* L1 — 5 personas. Tap drills into that persona's sub-sections. */
  if (drilled === null) {
    const current = activePersona.value;
    return (
      <ul class="bsdial" role="menu" aria-label="בחירת משתמש">
        {TILES.map((t, i) => (
          <li
            key={t.id}
            class="bsdial__item"
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <button
              type="button"
              role="menuitem"
              class={`bsdial__btn${t.id === current ? ' is-active' : ''}`}
              onClick={() => drillIntoPersona(t.id)}
              aria-label={t.label}
              aria-current={t.id === current ? 'true' : undefined}
            >
              <span class="bsdial__circle" aria-hidden="true">{t.emoji}</span>
              <span class="bsdial__label">{t.label}</span>
            </button>
          </li>
        ))}
      </ul>
    );
  }

  /* L2+ — walk the persona's tree. Render persona anchor + one anchor
   * per drill step + the current items above them. */
  const tile = TILES.find((t) => t.id === drilled)!;
  const path = bsDrillPath.value;
  const { anchors, current } = walkBsDrill(drilled, path);

  return (
    <ul class="bsdial" role="menu" aria-label={tile.label}>
      <li class="bsdial__item bsdial__item--active">
        <button
          type="button"
          role="menuitem"
          class="bsdial__btn is-active"
          onClick={popBsDrill}
          aria-label={`חזרה מ-${tile.label}`}
          aria-expanded="true"
        >
          <span class="bsdial__circle" aria-hidden="true">{tile.emoji}</span>
          <span class="bsdial__label">{tile.label}</span>
        </button>
      </li>
      {anchors.map((anchor, i) => (
        <li
          key={anchor.id}
          class="bsdial__item bsdial__item--active"
        >
          <button
            type="button"
            role="menuitem"
            class="bsdial__btn is-active"
            onClick={() => popBsDrillPathTo(i)}
            aria-label={`חזרה מ-${anchor.title}`}
            aria-expanded="true"
          >
            <span class="bsdial__circle" aria-hidden="true">{anchor.emoji}</span>
            <span class="bsdial__label">{anchor.title}</span>
          </button>
        </li>
      ))}
      {current.map((s, i) => {
        const hasChildren = !!s.children && s.children.length > 0;
        return (
          <li
            key={s.id}
            class="bsdial__item"
            style={{ animationDelay: `${i * 30}ms` }}
          >
            <button
              type="button"
              role="menuitem"
              class="bsdial__btn"
              onClick={() =>
                hasChildren
                  ? pushBsDrill(s.title)
                  : showToast(`${s.title} — בבנייה`)
              }
              aria-label={s.title}
            >
              <span class="bsdial__circle" aria-hidden="true">{s.emoji}</span>
              <span class="bsdial__label">{s.title}</span>
            </button>
          </li>
        );
      })}
    </ul>
  );
}
