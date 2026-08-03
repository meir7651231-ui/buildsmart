# _NotifList

- **screen:** `notifications_screen`
- **role:** section

## עצם · object (11)

> registry 8 · mapped 8/8 · **unregistered 3**

- **text** "🔕" · — לא-רשום
- **cfgText** "התראות מושתקות" · `notifications_screen.snooze_title` ✅
- **text** "🌙" · — לא-רשום
- **cfgText** "שעות שקט פעילות" · `notifications_screen.quiet_title` ✅
- **cfgText** "מושתק בשעות השקט" · `notifications_screen.quiet_sub` ✅
- **text** "🔔" · — לא-רשום
- **cfgText** "אין התראות" · `notifications_screen.empty_title` ✅
- **cfgText** "כשיהיו עדכונים — הם יופיעו כאן" · `notifications_screen.empty_sub` ✅
- **cfgText** "התראה נמחקה" · `notifications_screen.deleted_toast` ✅
- **cfgText** "סמן כנקרא" · `notifications_screen.mark_read` ✅
- **cfgText** "מחק" · `notifications_screen.menu_delete` ✅

## חיבורים · connections (17)

- **reads** · `watch` → `notifSectionProvider`
- **reads** · `watch` → `notifDismissedIdsProvider`
- **reads** · `watch` → `notifSearchQueryProvider`
- **reads** · `watch` → `notifExpandedGroupsProvider`
- **reads** · `watch` → `notifSettingsProvider`
- **writes** · `state=` → `notifExpandedGroupsProvider`
- **reads** · `read` → `notifExpandedGroupsProvider`
- **reads** · `read` → `notifDismissedIdsProvider`
- **reads** · `watch` → `notifReadIdsProvider`
- **reads** · `watch` → `notifFollowedIdsProvider`
- **action** · `showMenu` → `showMenu`
- **writes** · `add` → `notifReadIdsProvider`
- **writes** · `add` → `notifDismissedIdsProvider`
- **reads** · `read` → `notifFollowedIdsProvider`
- **writes** · `state=` → `storeSectionProvider`
- **writes** · `state=` → `mainTabProvider`
- **action** · `showNotifActionSheet` → `showNotifActionSheet`

## התנהגות · behaviour (5)

- **onTap** → _verb_ `ref.read(notifExpandedGroupsProvider.notifier).state = Set<String>.from(ref.r…` → write → notifExpandedGroupsProvider
- **onTap** → _verb_ `ref.read(notifReadIdsProvider.notifier).add(notif.id)` → write → notifReadIdsProvider
- **onTap** → _verb_ `showNotifActionSheet(context, notif.type, notif.preview)` → open → showNotifActionSheet
- **onTap** → _verb_ `ref.read(storeSectionProvider.notifier).state = StoreSection.orders` → write → storeSectionProvider
- **onTap** → _verb_ `ref.read(mainTabProvider.notifier).state = 3` → write → mainTabProvider

## floor · external functions (2)

- `add`
- `confirmDestructive`

## חוזה-רכיב · contract + gaps

- **extractable:** `embeds-shared`
- **props:** —
- **untangle:**
  - SingleChildScrollView = shared component → separate atom
- **gaps:** 3 unregistered — "🔕" · "🌙" · "🔔"
