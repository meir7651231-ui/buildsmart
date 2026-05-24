import { signal } from '@preact/signals';
import { showToast } from '../store/toast-store';

// ─── section state ────────────────────────────────────────────────────────────

type Section = 'all' | 'cart' | 'orders' | 'services';
const activeSection = signal<Section>('all');

// ─── sheet state ─────────────────────────────────────────────────────────────

type SheetId = 'moadim' | 'tizmon' | 'sicha' | null;
type ServiceIdx = number | null;
const openSheet = signal<SheetId>(null);
const openService = signal<ServiceIdx>(null);

// ─── data ─────────────────────────────────────────────────────────────────────

const allItems = [
  { emoji: '🛒', title: 'הסל שלי',         sub: '3 פריטים ממתינים לסיכום',       time: 'עכשיו', badge: 3 },
  { emoji: '📦', title: 'ההזמנות שלי',     sub: 'הזמנה #1234 · בדרך אליך',       time: 'אתמול', badge: 1 },
  { emoji: '🔧', title: 'השכרת כלים',      sub: '2 כלים מושכרים עד 30.5',         time: '21.5',  badge: 0 },
  { emoji: '💰', title: 'פקדונות',          sub: 'פיקדון פעיל · ₪350',             time: '21.5',  badge: 0 },
  { emoji: '↩️', title: 'החזרה חדשה',      sub: 'בקשה #567 ממתינה לאישור',        time: '20.5',  badge: 0 },
  { emoji: '📨', title: 'מכרז ספקים',      sub: '3 הצעות חדשות התקבלו',           time: '20.5',  badge: 3 },
  { emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות זמינים להורדה',       time: '19.5',  badge: 0 },
  { emoji: '📊', title: 'השוואת מחירים',   sub: '4 ספקים עדכנו מחירים',           time: '19.5',  badge: 2 },
];

const cartItems = [allItems[0]];

const orders = [
  { id: 'BS-1234', items: '12 פריטים', total: '₪5,420', stageLabel: 'בדרך 🚛',    time: '24.5, 14:00', color: '#4CAF50' },
  { id: 'BS-1221', items: '5 פריטים',  total: '₪1,890', stageLabel: 'מוכן 📦',    time: '24.5, 09:30', color: '#2196F3' },
  { id: 'BS-1198', items: '3 פריטים',  total: '₪630',   stageLabel: 'בהכנה 🔧',   time: '23.5',        color: '#FF9800' },
  { id: 'BS-1171', items: '8 פריטים',  total: '₪2,240', stageLabel: 'הסתיימה ✓',  time: '21.5',        color: '#888888' },
  { id: 'BS-1155', items: '2 פריטים',  total: '₪310',   stageLabel: 'הסתיימה ✓',  time: '19.5',        color: '#888888' },
];

const services = [
  { emoji: '🔧', title: 'השכרת כלים',     sub: '2 כלים פעילים' },
  { emoji: '💰', title: 'פקדונות',         sub: 'פיקדון ₪350' },
  { emoji: '↩️', title: 'החזרה חדשה',     sub: 'בקשה #567' },
  { emoji: '📨', title: 'מכרז ספקים',     sub: '3 הצעות חדשות' },
  { emoji: '🧪', title: 'גיליונות בטיחות', sub: '5 גיליונות' },
  { emoji: '📊', title: 'השוואת מחירים',  sub: '4 ספקים עודכנו' },
];

const serviceEmojiMap: Record<string, number> = {
  '🔧': 0, '💰': 1, '↩️': 2, '📨': 3, '🧪': 4, '📊': 5,
};

const serviceSheets = [
  [{ emoji: '🔨', label: 'מקדחה', sub: 'מושכרת עד 30.5' }, { emoji: '🪚', label: 'משור חשמלי', sub: 'מושכר עד 28.5' }, { emoji: '➕', label: 'הוסף כלי', sub: '' }],
  [{ emoji: '💳', label: 'פיקדון #123', sub: '₪350 · פעיל' }, { emoji: '↩️', label: 'בקשת החזר', sub: '' }],
  [{ emoji: '📋', label: 'בקשה #567', sub: 'ממתינה לאישור' }, { emoji: '📦', label: 'פריטים להחזרה', sub: '3 יחידות' }, { emoji: '🚛', label: 'תיאום איסוף', sub: '' }],
  [{ emoji: '🏪', label: 'ספק A', sub: '₪4,200 · הצעה חדשה' }, { emoji: '🏪', label: 'ספק B', sub: '₪3,980 · הצעה חדשה' }, { emoji: '🏪', label: 'ספק C', sub: '₪4,500 · הצעה חדשה' }],
  [{ emoji: '📄', label: 'ברזל 12mm', sub: 'עודכן 20.5' }, { emoji: '📄', label: 'צבע אפוקסי', sub: 'עודכן 18.5' }, { emoji: '📄', label: 'ממס ניקוי', sub: 'עודכן 15.5' }, { emoji: '📄', label: 'בטון יצוק', sub: 'עודכן 10.5' }],
  [{ emoji: '🏪', label: 'רוט', sub: 'ברזל 12mm · ₪4.20' }, { emoji: '🏪', label: 'מ.א. שלמה', sub: 'ברזל 12mm · ₪3.85' }, { emoji: '🏪', label: 'אחים כהן', sub: 'ברזל 12mm · ₪4.10' }, { emoji: '🏪', label: 'בני ברק מבנים', sub: 'ברזל 12mm · ₪3.95' }],
];

// ─── sub-components ───────────────────────────────────────────────────────────

function StoreRow({ emoji, title, sub, time, badge }: { emoji: string; title: string; sub: string; time: string; badge: number; onClick?: () => void }) {
  return (
    <button type="button" class="store-row" onClick={() => showToast(`${title} — בבנייה`)}>
      <span class="store-row__avatar">{emoji}</span>
      <span class="store-row__body">
        <span class="store-row__top">
          <span class="store-row__name">{title}</span>
          <span class="store-row__time" style={badge > 0 ? 'color:var(--brand)' : ''}>{time}</span>
        </span>
        <span class="store-row__bottom">
          <span class="store-row__sub">{sub}</span>
          {badge > 0 && <span class="store-row__badge">{badge}</span>}
        </span>
      </span>
    </button>
  );
}

function OrderRow({ order }: { order: typeof orders[0] }) {
  return (
    <button type="button" class="store-row" onClick={() => showToast(`הזמנה ${order.id} — בבנייה`)}>
      <span class="store-row__avatar">📦</span>
      <span class="store-row__body">
        <span class="store-row__top">
          <span class="store-row__name">{order.id}</span>
          <span class="store-row__time">{order.time}</span>
        </span>
        <span class="store-row__bottom">
          <span class="store-row__sub">{order.items} · {order.total}</span>
          <span class="store-row__pill" style={`color:${order.color};border-color:${order.color}40;background:${order.color}22`}>{order.stageLabel}</span>
        </span>
      </span>
    </button>
  );
}

function ServiceRow({ svc, idx }: { svc: typeof services[0]; idx: number }) {
  return (
    <button type="button" class="store-row" onClick={() => { openService.value = idx; }}>
      <span class="store-row__avatar">{svc.emoji}</span>
      <span class="store-row__body">
        <span class="store-row__top">
          <span class="store-row__name">{svc.title}</span>
        </span>
        <span class="store-row__bottom">
          <span class="store-row__sub">{svc.sub}</span>
        </span>
      </span>
    </button>
  );
}

// ─── sheets ───────────────────────────────────────────────────────────────────

function SheetWrap({ title, emoji, onClose, children }: { title: string; emoji: string; onClose: () => void; children: any }) {
  return (
    <div class="sheet" onClick={(e) => { if ((e.target as HTMLElement).classList.contains('sheet__backdrop')) onClose(); }}>
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={onClose} />
      <div class="sheet__panel">
        <div class="sheet__handle" />
        <p class="store-sheet__title">{emoji} {title}</p>
        {children}
      </div>
    </div>
  );
}

function MoadimSheet() {
  return (
    <SheetWrap title="מועדים" emoji="📅" onClose={() => { openSheet.value = null; }}>
      {[['📅','לוח שנה'],['🗓️','אירועים קרובים'],['🏗️','לוח עבודה'],['⏰','תזכורות']].map(([e, l]) => (
        <button type="button" class="store-sheet__row" onClick={() => { openSheet.value = null; showToast(`${l} — בבנייה`); }}>
          <span>{e}</span><span>{l}</span>
        </button>
      ))}
    </SheetWrap>
  );
}

function TizmonSheet() {
  return (
    <SheetWrap title="תזמון" emoji="📆" onClose={() => { openSheet.value = null; }}>
      {[['📆','תזמן פגישה'],['🚛','תזמן משלוח'],['👷','תזמן עובד'],['📋','תזמן ביקורת']].map(([e, l]) => (
        <button type="button" class="store-sheet__row" onClick={() => { openSheet.value = null; showToast(`${l} — בבנייה`); }}>
          <span>{e}</span><span>{l}</span>
        </button>
      ))}
    </SheetWrap>
  );
}

function SichaSheet() {
  const contacts = [['👷','הקבלן הראשי'],['🏪','ספק חומרי בנייה'],['🛵','השליח'],['👔','מנהל המערכת']];
  return (
    <SheetWrap title="שיחה חדשה" emoji="📞" onClose={() => { openSheet.value = null; }}>
      {contacts.map(([e, n]) => (
        <button type="button" class="store-sheet__row" onClick={() => { openSheet.value = null; showToast(`שיחה עם ${n} — בבנייה`); }}>
          <span class="store-sheet__avatar">{e}</span><span>{n}</span>
        </button>
      ))}
    </SheetWrap>
  );
}

function ServiceSheet({ idx }: { idx: number }) {
  const svc = services[idx];
  const rows = serviceSheets[idx];
  return (
    <SheetWrap title={svc.title} emoji={svc.emoji} onClose={() => { openService.value = null; }}>
      <p class="store-sheet__sub">{svc.sub}</p>
      <hr class="store-sheet__hr" />
      {rows.map((r) => (
        <button type="button" class="store-sheet__row" onClick={() => { openService.value = null; showToast(`${r.label} — בבנייה`); }}>
          <span>{r.emoji}</span>
          <span class="store-sheet__row-body">
            <span>{r.label}</span>
            {r.sub && <span class="store-sheet__row-sub">{r.sub}</span>}
          </span>
        </button>
      ))}
    </SheetWrap>
  );
}

// ─── main view ────────────────────────────────────────────────────────────────

export function StoreView() {
  const section = activeSection.value;
  const sheet = openSheet.value;
  const svcIdx = openService.value;

  const chips: { id: Section; label: string }[] = [
    { id: 'all',      label: 'הכל' },
    { id: 'cart',     label: '🛒 הסל' },
    { id: 'orders',   label: '📦 הזמנות' },
    { id: 'services', label: '🔧 שירותים' },
  ];

  return (
    <div class="store-view">

      {/* Search */}
      <div class="store-view__search-wrap">
        <input class="store-view__search" type="search" placeholder="חיפוש הזמנות ומוצרים..." dir="rtl" />
      </div>

      {/* Section chips */}
      <div class="store-view__chips">
        {chips.map((c) => (
          <button
            key={c.id}
            type="button"
            class={`store-chip ${section === c.id ? 'store-chip--active' : ''}`}
            onClick={() => { activeSection.value = c.id; }}
          >
            {c.label}
          </button>
        ))}
      </div>

      {/* Quick actions */}
      <div class="store-view__actions">
        {[
          { icon: '♡', label: 'מועדפים', action: () => showToast('מועדפים — בבנייה') },
          { icon: '📅', label: 'מועדים',  action: () => { openSheet.value = 'moadim'; } },
          { icon: '📆', label: 'תזמון',   action: () => { openSheet.value = 'tizmon'; } },
          { icon: '📞', label: 'שיחה',    action: () => { openSheet.value = 'sicha'; } },
        ].map((a) => (
          <button key={a.label} type="button" class="store-action" onClick={a.action}>
            <span class="store-action__circle">{a.icon}</span>
            <span class="store-action__label">{a.label}</span>
          </button>
        ))}
      </div>

      {/* List */}
      <div class="store-view__list">
        {section === 'services' ? (
          services.map((s, i) => <ServiceRow key={i} svc={s} idx={i} />)
        ) : section === 'orders' ? (
          orders.map((o, i) => <OrderRow key={i} order={o} />)
        ) : (
          (section === 'cart' ? cartItems : allItems).map((item, i) => {
            const svcIdx = serviceEmojiMap[item.emoji];
            return svcIdx !== undefined
              ? <ServiceRow key={i} svc={{ emoji: item.emoji, title: item.title, sub: item.sub }} idx={svcIdx} />
              : <StoreRow key={i} {...item} />;
          })
        )}
      </div>

      {/* Sheets */}
      {sheet === 'moadim'  && <MoadimSheet />}
      {sheet === 'tizmon'  && <TizmonSheet />}
      {sheet === 'sicha'   && <SichaSheet />}
      {svcIdx !== null     && <ServiceSheet idx={svcIdx} />}
    </div>
  );
}
