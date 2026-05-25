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

/* @legacy index.html:4260-4263 (admTab buttons of screen-store).
 *
 * s-home children: 3 shStat tiles from renderStoreHome @ :17128-17132:
 *   🔧 בהכנה  ·  📦 מוכן לאיסוף  ·  💰 מחזור פעיל
 *
 * s-portal children: 8 portal items from renderStorePortal @ :20762-20769
 *   (each has ic + t args used verbatim).
 *
 * s-orders / s-stock stay as leaves — the legacy filter chips and
 * summary tiles have labels but no verbatim emoji per sub-item. */
const STORE_SECTIONS: Section[] = [
  {
    id: 's-home',
    emoji: '🏠',
    title: 'בית',
    children: [
      { id: 'sh-prep',    emoji: '🔧', title: 'בהכנה' },
      { id: 'sh-ready',   emoji: '📦', title: 'מוכן לאיסוף' },
      { id: 'sh-revenue', emoji: '💰', title: 'מחזור פעיל' },
    ],
  },
  {
    id: 's-orders',
    emoji: '📥',
    title: 'הזמנות',
    /* @legacy soChip filters @ :17310-17313 (verbatim labels) + emoji
     * sourced from store shStat @17128-17132 (same module): */
    children: [
      { id: 'so-new',   emoji: '📥', title: 'לאישור' },
      { id: 'so-prep',  emoji: '🔧', title: 'בהכנה' },
      { id: 'so-ready', emoji: '📦', title: 'מוכנות' },
    ],
  },
  {
    id: 's-stock',
    emoji: '📦',
    title: 'מלאי',
    /* @legacy md-pmeta status labels @ :17914 — both verbatim:
     *   '✅ זמין במלאי' / '❌ אזל — מוסתר מהקבלן'. */
    children: [
      { id: 'ss-in',  emoji: '✅', title: 'זמין במלאי' },
      { id: 'ss-out', emoji: '❌', title: 'אזל' },
    ],
  },
  {
    id: 's-portal',
    emoji: '🧰',
    title: 'פורטל',
    children: [
      { id: 'sp-ratings',  emoji: '⭐',  title: 'דירוג ספקים' },
      { id: 'sp-sla',      emoji: '⏱️', title: 'מעקב SLA' },
      { id: 'sp-zones',    emoji: '🗺️', title: 'אזורי הפצה' },
      { id: 'sp-bulk',     emoji: '📉', title: 'הנחות כמות' },
      { id: 'sp-barcode',  emoji: '🏷️', title: 'הפקת ברקודים' },
      { id: 'sp-fleet',    emoji: '🚛', title: 'ניהול צי רכב' },
      { id: 'sp-chat',     emoji: '💬', title: 'צ׳אט עם קבלן' },
      { id: 'sp-autostk',  emoji: '🔄', title: 'עדכון מלאי' },
    ],
  },
];

/* @legacy index.html:17991-18043 (renderCourierHome). Section titles
 * verbatim; emoji per section:
 *   🛵 = HAUL_TYPES[0].ic (vehicle picker, @11951)
 *   📦 = chStat 'לאיסוף' ic (@18033)
 *   🚚 = chStat 'בדרך' ic (@18034) / empty-state ic (@7762)
 *   🧰 = fin-hub-ic for "פורטל השליח" (@18039)
 *
 * vehicle children: 3 HAUL_TYPES @ :11951-11953 (ic + name).
 * portal children: 6 items in openCourierPortal @ :20787-20792 (ic + t).
 * pickup / active stay as leaves — no verbatim emoji per sub-item. */
const COURIER_SECTIONS: Section[] = [
  {
    id: 'vehicle',
    emoji: '🛵',
    title: 'הרכב שלי היום',
    children: [
      { id: 'haul-small', emoji: '🛵', title: 'משלוח קטן' },
      { id: 'haul-van',   emoji: '🚐', title: 'טנדר' },
      { id: 'haul-truck', emoji: '🚛', title: 'משאית' },
    ],
  },
  { id: 'pickup', emoji: '📦', title: 'משלוחים ממתינים לאיסוף' },
  {
    id: 'active',
    emoji: '🚚',
    title: 'משלוחים פעילים',
    /* @legacy ch-btn labels in renderCourierList @ :18112-18114 — verbatim
     * action buttons per stage (each emoji + label is one literal string): */
    children: [
      { id: 'ca-pickup',    emoji: '📦', title: 'אספתי מהחנות' },
      { id: 'ca-transit',   emoji: '🚚', title: 'יצאתי לדרך' },
      { id: 'ca-delivered', emoji: '✅', title: 'נמסר ללקוח' },
    ],
  },
  {
    id: 'portal',
    emoji: '🧰',
    title: 'פורטל השליח',
    children: [
      { id: 'cp-nav',    emoji: '🧭', title: 'ניווט למשלוח' },
      { id: 'cp-fleet',  emoji: '🚛', title: 'צי רכב' },
      { id: 'cp-sla',    emoji: '⏱️', title: 'מעקב SLA' },
      { id: 'cp-zones',  emoji: '🗺️', title: 'אזורי הפצה' },
      { id: 'cp-pod',    emoji: '📸', title: 'אישור מסירה' },
      { id: 'cp-chat',   emoji: '💬', title: 'צ׳אט עם חנות' },
    ],
  },
];

/* @legacy index.html:8099-8102 — renderWorker task-group headers,
 * verbatim incl. the emoji prefix. Each group drills into the
 * specific statuses that legacy filters into it (see :8096-8098):
 *   current   = active OR rejected
 *   queue     = pending
 *   submitted = review OR done
 * Statuses come from `taskStatusInfo` @8048-8054 — ic + label verbatim. */
const ST_PENDING  = { id: 'st-pending',  emoji: '⏳', title: 'ממתינה' };
const ST_ACTIVE   = { id: 'st-active',   emoji: '🔨', title: 'בביצוע' };
const ST_REVIEW   = { id: 'st-review',   emoji: '📸', title: 'ממתין לאישור' };
const ST_DONE     = { id: 'st-done',     emoji: '✅', title: 'אושר ✓' };
const ST_REJECTED = { id: 'st-rejected', emoji: '↩️', title: 'נדחה — לתקן' };

const WORKER_SECTIONS: Section[] = [
  { id: 'current',   emoji: '🔨', title: 'המשימה הנוכחית שלך', children: [ST_ACTIVE, ST_REJECTED] },
  { id: 'queue',     emoji: '⏳', title: 'הבאות בתור',         children: [ST_PENDING] },
  { id: 'submitted', emoji: '📋', title: 'שהגשת',               children: [ST_REVIEW, ST_DONE] },
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
  {
    id: 'm-orders',
    emoji: '🚚',
    title: 'הזמנות',
    /* @legacy ORDER_FLOW @ index.html:16943 + ORDER_STAGE labels @ :12041-12048.
     * Emoji sourced from related legacy contexts:
     *   📥 from store admTab "📥 הזמנות" @4261 (intake)
     *   🔧 from store shStat 'בהכנה' @17129
     *   📦 from store shStat 'מוכן לאיסוף' @17130 / courier chStat 'לאיסוף' @18033
     *   🚛 from HAUL_TYPES truck @11953 (vehicle taken)
     *   🚚 from courier chStat 'בדרך' @18034
     *   ✅ from courier chStat 'נמסרו' @18035 */
    children: [
      { id: 'mo-new',       emoji: '📥', title: 'התקבלה' },
      { id: 'mo-preparing', emoji: '🔧', title: 'בהכנה' },
      { id: 'mo-ready',     emoji: '📦', title: 'מוכן לאיסוף' },
      { id: 'mo-pickup',    emoji: '🚛', title: 'נאסף' },
      { id: 'mo-transit',   emoji: '🚚', title: 'בדרך לאתר' },
      { id: 'mo-delivered', emoji: '✅', title: 'נמסר ✓' },
    ],
  },
  {
    id: 'm-customers',
    emoji: '👥',
    title: 'לקוחות',
    /* @legacy mc-pill labels @ :16608 + msd-tag @ :16617.
     * 🟢 קבלן פעיל verbatim @ :16617. ⚠️ ניצול אשראי גבוה verbatim @ :16617. */
    children: [
      { id: 'mc-live', emoji: '🟢', title: 'פעיל' },
      { id: 'mc-low',  emoji: '⚠️', title: 'אשראי גבוה' },
    ],
  },
  {
    id: 'm-manage',
    emoji: '🛠️',
    title: 'ניהול',
    /* @legacy index.html:16653-16745 — mmSection(key, ic, title, ...)
     * calls of renderMgrManage. emoji + title verbatim from each. */
    children: [
      { id: 'mm-trees',    emoji: '🌳', title: 'עץ המוצרים' },
      { id: 'mm-brands',   emoji: '🏷️', title: 'מותגים ומחירים' },
      { id: 'mm-cats',     emoji: '🗂️', title: 'קטגוריות' },
      { id: 'mm-settings', emoji: '⚙️', title: 'הגדרות אפליקציה' },
    ],
  },
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
