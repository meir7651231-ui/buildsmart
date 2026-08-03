# CourierPortalTab

- **screen:** `courier_portal_tab`
- **role:** composer

## עצם · object (3)

> registry 2 · mapped 2/2 · **unregistered 1**

- **cfgText** "🧰 פורטל השליח" · `courier_portal_tab.t01` ✅
- **cfgText** "ניווט, צי רכב, צ׳אט ומעקב SLA" · `courier_portal_tab.t02` ✅
- **text** "—:—" · — לא-רשום

## חיבורים · connections (5)

- **reads** · `read` → `sysOrdersProvider`
- **action** · `push` → `ChatsScreen`
- **action** · `showPortalSheet` → `showPortalSheet`
- **action** · `showPodSheet` → `showPodSheet`
- **action** · `showModalBottomSheet` → `showModalBottomSheet`

## התנהגות · behaviour (1)

- **onTap** → _verb_ `showPodSheet(context, o.id)` → open → showPodSheet

## floor · external functions (1)

- `fMoney`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 1 unregistered — "—:—"
