// 📜 קובץ-ראשי · screens__home_shell — פירוק שלד-הבית (בנייה-חכמה) לאטומים-נקיים.
// מוצא קדוש: scratchpad/all-screens/screens__home_shell.dart (1,885 שורות) — לא נגענו.
// מפת-המכונה: screens-seed/machine/screens__home_shell.json · תוכן:
// new/dart-data-bs/screens__home_shell_content.dart
//
// ── שימוש באטומי-מדף קיימים (הכרעה-5: צורכים, לא משכפלים) ──
// נבדק מול המדף (new/dart-ui-bs/): PillButton · StatTile · BareStat · EmptyStateCard ·
// PlaceholderRow · HeroCard · TitledSection · QuickToolsList · WorkPathCard · OrderCard,
// ומול תיקיות-המסכים הקיימות (store / manager_dashboard / chat_settings).
// נצרך-מהמדף (בקופסה, לא באטומים — חוק-1):
//   SheetScaffold (screens__store_screen/sheet_scaffold.dart) — הכרום של _NewChatSheet
//     (ידית 36×4 + כותרת גליף+18/w700 + subtitle 13 + children) זהה-מנגנון; ה-Divider
//     שאחרי ה-subtitle נכנס כילד-ראשון ב-children. גם כרום _ProfileCard (ידית+padding)
//     קרוב, אך שם הכותרת = ProfileHeaderRow (אווטאר+שם+סגירה) ⇒ הקופסה מרכיבה ידית
//     ידנית או SheetScaffold עם children בלבד — הכרעת-קופסה, לא אטום חדש.
//   BottomNavCell — נצרך במקור מ-widget חיצוני (widgets/), אינו מוגדר במסך; תא-הטאב
//     נשאר אטום-המקור, _BottomNav = קופסה שמרכיבה אותו עם BadgedIcon + HelpTarget.
// לא-שוכפל אך נרשם עוגן-הבדל (אטום חדש הוצדק):
//   MenuRow ≠ PlaceholderRow (מדף: ListTile+trailing-badge; כאן Row חשוף ל-PopupMenuItem)
//     ≠ SheetTile-חנות (ListTile+onTap; כאן ההקשה של הפריט-העוטף).
//   DirectoryRow ≠ SheetTile (גליף 24 מול 22, chevron-trailing, subtitle, onTap-nullable)
//     ≠ ContactTile (שם אווטאר-עיגול-צבוע).
//   StatusDotChip ≠ LiveStatusPill-מנהל (שם לא-לחיץ, נקודה=צבע-טקסט, בלי Semantics).
//   BadgedIcon ≠ CountBadge-מנהל (גלולה עצמאית) ≠ תג-CartFabButton (מלבני-ממוסגר).
//   FilledCtaButton ≠ PillButton-מדף (Material/InkWell גלולה 14/w800 + מצב-מנוטרל;
//     כאן FilledButton רוחב-מלא 16/w800 רדיוס-כרטיס).
//
// ── האטומים שנחצבו כאן (13 קבצים, כולם 🧼 אפס-עברית/דאטה בגוף) ──
// help_freeze_overlay · cart_chat_bubble · cart_fab_button · badged_icon · menu_row ·
// name_chip · status_dot_chip · pulsing_status · directory_row · profile_header_row ·
// icon_detail_row · filled_cta_button (+ קובץ-הערות זה).
//
// ── דדופ פנים-מסך שנפתר בפירוק ──
// 4 כפתורי-ה-⋮ (_CatalogMenuButton/_ChatsMenuButton/_NotificationsMenuButton/
// _StoreMenuButton) = מנגנון אחד: PopupMenuButton(אייקון more_vert, לבן, מתחת,
// רדיוס-10) + MenuRow פר-פריט; ההבדל = רשימת-הפריטים (catalogMenuItems/chatsMenuItems+
// muteAllRow/notifMenuItems/storeMenuItems ב-content) + ה-dispatch = חיווט-קופסה.
// שני ענפי _NewChatSheet (רשימה קבועה / ספרייה חיה) = DirectoryRow אחד; ההבדל =
// מקור-השורות (newChatContactTypes מול directoryProvider+roleBadges) ו-subtitle/onTap.
//
// ── התרת-סבך: קריאות-provider שהפכו ל-props/callbacks (מה הקופסה תזרים) ──
// HomeShell (קופסת-השלד): mainTabProvider (IndexedStack + ניווט-טאב) · helpModeProvider
//   (מונט HelpFreezeOverlay; onExit ⇒ כתיבת-false; onScrimTap ⇒ SnackBar מ-content) ·
//   smartCartProvider listen (פרומפט "לאן לשלוח" חד-פעמי: shipToPromptedProvider +
//   saveShipToPrompted + openShipToSheet) · promptRoleRequestProvider listen + תפיסת-
//   latch-על-מונט (FIX #5) ⇒ showRoleRequestSheet · listenTabScreenView (intel) ·
//   maybeShowConsentModal (kIntelLive) · keyboardOverlayOpenProvider (מונט המקלדת-הצפה /
//   FAB-המקלדת: FloatingActionButton רגיל + tooltip מ-content — לא נחצב, שורת-Flutter
//   יחידה) · resetAllDials + איפוסי-קטלוג (homeDepartment/catalogSystemFilter/
//   catalogTreePath/catalogSection=homeSectionId) בלחיצת-טאב.
// _GlobalSearchOverlay = קופסה דקה: keyboardDiveQueryProvider>=2 ⇒ Material(רקע-ערכה) +
//   GlobalSearchResultsView; אחרת SizedBox.shrink. אין בה UI-עצמי ⇒ לא אטום.
// CartFab (קופסה): smartCartProvider ⇒ fold-כמויות ⇒ CartFabButton.countLabel;
//   cartBubbleDismissedProvider + listen-התכווצות ⇒ אילו CartChatBubble מוצגים (שני
//   האחרונים פחות שנסגרו); openCart (resetAllDials + maybePop אם popFirst +
//   storeSection=cart + tab=3) ⇒ onPressed; cartLineDisplay(line) + תבניות-content ⇒
//   emoji/name/attrs/priceLabel/qtyLabel; openCartLineProductSheet ⇒ onTap-הבועה.
// _HomeAppBar (קופסה): userProfileProvider.select(registered,name) ⇒ NameChip.label
//   (השם-הפרטי הראשון); showProfileCard/showRolePicker ⇒ onTaps; tabHeaderHiddenProvider
//   + modOn(search) ⇒ כפתור-החיפוש; updatesSubTabProvider + modOn(chat) ⇒ איזה תפריט-⋮;
//   catalogSectionProvider==smartTreeSectionId ⇒ PulsingStatus (reducedMotion מ-
//   catalogSettingsProvider; bsSuccess(context) ⇒ color) או שורת-הגרסה (Text רגיל,
//   versionChromeTpl + kVersionLabel/kBuild = זהות-הצבה, חוק-6); helpModeProvider ⇒
//   מצב-הנורה + toggle; showIntroTour ⇒ long-press; openCameraSheet ⇒ המצלמה;
//   כל ה-HelpTarget-ים (appBarHelp) = עטיפות-קופסה.
// _BottomNav (קופסה): notifUnreadCountProvider ⇒ BadgedIcon.badgeLabel (תקרת 9+ =
//   unreadBadgeOverflowLabel, פורמט בקופסה); orgTerm(nav.*) ⇒ תוויות; onTap(i) מהשלד.
// תפריטי-⋮ (קופסאות): modOn(ai)/modOn(chat) שערי-רשימה+dispatch; allChatsMuted/
//   toggleMuteAllChats/markAllNotifsRead/dismissAllNotifs/confirmDestructive/showToast ·
//   ניווטי-Route (AIHubScreen/CatalogSettingsScreen/ChatsArchiveScreen/
//   NotifSettingsScreen/StoreSettingsScreen) · storeSectionProvider-כתיבות · CfgText
//   פר-cfgId ⇒ MenuRow.labelSlot.
// _NewChatSheet (קופסה): useFirebaseBackend ⇒ איזה ענף; directoryProvider.when
//   (loading⇒spinner, error/ריק⇒hint-מ-content, data⇒DirectoryRow-ים ב-ListView תחום
//   50% גובה); currentUidProvider ⇒ onTap-nullable; chatEngineProvider.createOrGetThread
//   + openChatThread / openNewChatWith ⇒ ההקשות; CfgText-ים ⇒ סלוטים.
// _ProfileCard (קופסה): userProfileProvider ⇒ name/initial (דין-אורח: guestName +
//   fallbackIcon=person) + רשימת-IconDetailRow (רק שדות-מלאים: work_outline/
//   place_outlined/badge_outlined/alternate_email); Navigator.pop/push(ProfileScreen) ⇒
//   onClose/onPressed; CfgVisible+CfgText editCta ⇒ עטיפה+labelSlot; Directionality-RTL
//   + ידית-sheet = כרום-קופסה.
// _RoleStatusChip (קופסה): kUserSystem-שער; roleChipStateProvider ⇒ בחירת-תווית
//   (roleStatusLabels) + שלישיית-צבעים (פיגמנטים: dot/fg/bg פר-מצב — orange F39C12/
//   9C6A08/FDF1DD · yellow EAC10C/8A7500/FBF6D6 · green 27AE60/1B7A43/DDF3E6 · red
//   E74C3C/A3271A/FBE3E0); semanticsTpl ⇒ semanticsLabel; _onTap (authState.isRealUser
//   ⇒ WelcomeScreen / reloadRole + showRolePicker או showRoleRequestSheet) ⇒ onTap.
//
// ── שערים (תמיד בקופסה; האטומים עיוורים להם — חוק-5) ──
// kUserSystem · kIntelLive · kGlobalSearch+modOn(search) · kKeyboardToolStrip+!kKbGlobal ·
// kHideUnderConstruction · modOn(ai) · modOn(chat) · useFirebaseBackend.
// זהות/הצבה (חוק-6, לעולם לא אטום): AppBrand.name · kVersionLabel/kBuild · heroTags.
//
// ── קומפוזרים שנשארים קופסאות (לא נחצבו לאטום) ──
// HomeShell · _GlobalSearchOverlay · CartFab · _HomeAppBar · _BottomNav ·
// _CatalogMenuButton · _ChatsMenuButton · _NotificationsMenuButton · _StoreMenuButton ·
// _NewChatSheet · _ProfileCard · _RoleStatusChip (המיפוי) + openNewChatSheet/
// showProfileCard (פותחני-sheet). מועמד-לוגיקה טהור למחצבה: _roleBadge (מיוצג כדאטה —
// roleBadges + roleBadgeFallback ב-content).
