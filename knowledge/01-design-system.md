# מערכת-העיצוב — `<style>` (index.html 14–4019)

נלכד מקריאה מלאה. **חלק א׳ — יסודות (head + 14–480).**
המשך (481–4019: רכיבי-תוכן, כרטיס-מוצר, תקציב, עץ, Categories A–J) — בקריאה הבאה.

---

## טיפוגרפיה (head, שורה 13)
Google Fonts:
- **Heebo** (400/500/700/800/900) — כותרות, מותג, מספרים גדולים (תמיד weight 900).
- **Rubik** (400/500/600/700) — גוף הטקסט (`body` default).

meta מותג: `theme-color = #1f6f6b` (8) · PWA capable (9-10) · manifest (7) · `lang="he" dir="rtl"` (2).

## פלטת-צבעים — `:root` (15–28)
| token | ערך | תפקיד |
|---|---|---|
| `--ink` | `#16191d` | טקסט ראשי |
| `--bg` | `#f6f6f4` | רקע מסך |
| `--card` | `#ffffff` | כרטיסים |
| `--brand` | `#1f6f6b` | **מותג teal** — header, statusbar, primary, toggles |
| `--brand-dark` | `#155551` | teal כהה |
| `--amber` | `#f2a516` | **כתום-מבטא** — CTA, badges, cart-count |
| `--amber-deep` | `#d98a00` | כתום כהה (טקסט) |
| `--grey` | `#8b8d8f` | טקסט משני |
| `--line` | `#e9e6df` | גבולות/מפרידים |
| `--danger` | `#d6492f` | אדום שגיאה |
| `--ok` | `#1f8a4c` | ירוק הצלחה |
| `--shadow` | `0 14px 34px -20px rgba(22,25,29,.42)` | צל כרטיס |

- **Dark theme** (`:root[data-theme="dark"]`, 29–38): `--ink#f1f2f3 --bg#14171a --card#1e2226 --brand#3a9e99 --brand-dark#5fc3bd --line#2e3338`.
  > ⚠️ פער-מותג מתועד: האב-טיפוס **teal `#1f6f6b`**; ה-Flutter עבר ל-light + **orange**.
- **reduce-motion** (39): `:root[data-reduce-motion="1"] *` → `animation:none; transition:none`.
- reset (40): `*{margin:0;padding:0;box-sizing:border-box;tap-highlight:transparent}`.

## המסגרת (mockup של טלפון, 41–69)
- `body` (41–47): רקע radial-gradient כהה (`#1a1d22` + 2 הילות אפורות), ממורכז (flex center), `padding:30px 14px`, font Rubik.
- `.stage` (48): עמודה ממורכזת gap 18. `.tagline` (49–50): כיתוב אפור מתחת, `b` בכתום.
- **`.phone`** (52–55): `390×800`, `#0c0d0f`, radius 46, padding 13, צל עמוק + `inset ring #2a2c30`.
- **`.screen`** (56–59): רקע `--bg`, radius 34, `overflow:hidden`, flex-column.
- **`.notch`** (60–61): `140×26` שחור עליון מרכזי.
- **`.statusbar`** (63–69): גובה 42, רקע `--brand`, טקסט לבן, dots לבנים.

## שפת-הרכיבים (71–480)

### Header / appbar (71–92)
רקע `--brand`, טקסט לבן. `logo-mark` ריבוע לבן 32 + `brand-name` Heebo-900 (ה-`span` בכתום). `iconbtn` 37px רקע לבן-שקוף. `cart-count` badge כתום בפינה (border בצבע brand).

### פעמון + פאנל התראות (93–133)
`bell-badge` אדום. אנימציית **`bellring`** (נדנוד 0.8s). `notif-panel` נפתח דרך `max-height` transition (`.show`→380px). `np-item` עם `np-ic`; `.unread` מודגש ב-teil שקוף.

### Sheet: פירוט-התראה + סטטוס-משלוח (134–200)
`nd-*` (פירוט התראה: אייקון 54, כותרת, שורות). `ship-card` עם `ship-badge` **לפי סטטוס**: `st-pending` אפור · `st-processing` כתום · `st-shipped` teal · `st-delivered` ירוק. `ship-track` = שרשרת `ship-step` עם נקודות (done/now). `deliv-pill` = שתי גלולות לבנות-שקופות (יעד-משלוח + סטטוס; `.needs-site` באדום-בהיר + `.dp-alert`).

### מסך-זהות / פרופיל (201–419)
- `identity-pill` (201–208): גלולה מתחת ל-appbar.
- **`id-hero`** (213–264): כרטיס-קבלן — gradient כהה, `id-hero-glow` (radial לפי `--rank`), `id-hero-grain` (נקודות). `id-avatar` 62 + `id-avatar-ring` (צבע דרגה). `id-rankbar` עם track + fill **gradient teal→amber** + זוהר.
- `id-sec-h` כותרות-סקשן + `id-sec-c` count-chip.
- **`id-stat`** tiles (274–293): 50% רוחב, לחיצים. `id-spent` = כרטיס-gradient teal (סך הוצאה).
- `id-perk` (294–305): banner כתום (הטבה).
- **`id-badge`** achievements (306–324): grid 33%, `grayscale`→צבע כשמושג, `id-badge-tick` ירוק / `id-badge-lock`.
- **`id-ladder`** (325–343): שורות-דרגה; `.reached` / `.cur` (מסגרת teal).
- `id-register` (362–381): banner-gradient teal (הרשמה) + cta כתום.
- `rk-*` (393–419): sheet-פירוט-דרגה (אייקון 62, דרישה, הטבה כתומה, mini-ladder got/sel).

### הגדרות-מתקדמות (420–457)
`set-demo` (note כתום). `set-gtitle` כותרת-קבוצה. `set-group`/`set-row`. **`set-switch`** toggle 42×24 (`.on`=teal, הכפתור מחליק).

### Coming soon placeholder (459–480)
`cs-badge` כתום · `cs-ic` 96px gradient · `cs-title` Heebo-900 22 · `cs-desc` · `cs-tags`.

---

## חלק ב׳ — רכיבי-תוכן + מערכת-ה-sheets (481–1000)

### גוף + view (490–496)
`.body` גלילה אנכית (scrollbar מוסתר). `.view` מוסתר; `.active` מציג עם אנימציית **`fade`** (8px↑). `.pad` ריפוד 16.

### חיפוש · hero · קטגוריות · promise (498–545)
- `.search` — תיבה עם מסגרת **teal עבה 2.5px** + צל. `.hero` — כרטיס-gradient כהה (`ink→#2c3036`) עם 🏗️ watermark (opacity .14) + תג כתום.
- `.section-title` Heebo-800 + `.more` קישור teal. `.cat-grid` 4 עמודות; `.cat` tile.
- `.promise` שורה teal-מרוככת עם `.pi` אייקון.

### כרטיס-מוצר — carousel (547–617)
`.prow` גלילה אופקית. `.pcard` 165px: `.pthumb` (אמוג'י 36) + **`.smart-badge`** (teal "⚡חכם"), `.pcard-cat`, `.pprice` Heebo-900, `.pcard-qty`, **`.pcard-tree`** (כפתור-עץ כתום), `.addbtn` (teal +). `.pcard-arrow` פותח `.pcard-detail` (`ptree-note` + `ptree-btn`).

### פירוט-מוצר · אשראי · תקציב (618–907)
- `.pd-card` עם `.pd-specs` (שורות k/v); `.pd-row-act` לחיצה.
- `.credit-box` gradient כהה + בר כתום. **`.budget-box`** לבן; `.bg-bar i` בר **gradient teal→amber**; `.bg-edit-btn`.
- **budget-detail sheet** `bd-*`: `.bd-headline` (`.over`→אדום), `.bd-pct` 34px, `.bd-cat` ברים, `.bd-site`.
- `pd-store`/`pd-grand` (תשלום). `cd-*` (אשראי). **`ss-*`** (סטטוס-אתר: `.ss-state` on=ירוק/off=כתום, `.ss-tile` ברים, `.ss-link`).
- **stage/day cards**: `.stage-arrow` פותח; `.sd-step` עם `.sd-step-check` (✓ ירוק, done=קו-חוצה). `day-burst` → `.burst-chip` כתום (אנימציה מדורגת **`burstIn`**) + `dayFlash`.
- `.be-field` (inputs rtl). `.plist` (שורת-מוצר + `.add-mini`). `.chips` (פילטר; `.on`=ink).

### ⭐ מערכת-ה-overlay/sheet (917–928) — הליבה של כל ה-sheets
- **`.overlay`**: `inset:0`, רקע כהה-שקוף + **`backdrop-filter:blur(3px)`**, יושב מלמטה (`align-items:flex-end`). `.show`→flex.
- **`.sheet`**: רוחב מלא, radius 26 עליון, `max-height:90%`, אנימציית **`rise`** (מגיח מלמטה, cubic-bezier). **`.grip`** ידית 42×5.
- > כל ה-overlays ב-`02-shell-and-screens` (sitePicker · settings · tree · brand · variant · …) יורשים את התבנית הזו.

### דיאלוג פריט-חסר + Category-A UI (929–999)
- `md-*` (פריט-חסר): `.md-btn.proceed` כתום · `.md-btn.replace` teal · `.md-done`.
- **`ca-*`** (שרשרת-אספקה): `.ca-primary` (כפתור teal ראשי) · `.ca-rma-item` (checkbox) · `.ca-select` · `.ca-tool-grid` (השכרת כלים) · `.ca-card` (`.overdue`=כתום) · `.ca-pill` (danger/done) · **`.ca-sig-canvas`** (קנבס-חתימה) · `.ca-svc` (כפתורי-שירות).

---

## חלק ג׳ — Categories A–J + עץ-המוצרים (1001–1520)

האב-טיפוס מארגן את הפיצ'רים המתקדמים ל-**10 "קטגוריות" (A–J)**, כל אחת עם prefix-CSS
משלה. זו עמוד-השדרה של הפיצ'רים (תואם ל-hub/feature overlays ב-`02`). **אין Category D** (דילוג במקור).

| קט' | prefix | תחום | רכיבי-מפתח |
|---|---|---|---|
| **A** | `ca-` | שרשרת-אספקה | scan-frame · OCR (`ocr-row`) · XML preview (monospace ltr) · price-compare (`cmp-row .best`=ירוק) · RFQ (`rfq-quote`) · **MSDS** (`msds-risk` m/h/x) |
| **B** | `fin-` | פיננסים | `fin-hub-btn` (gradient teal) · grid/tile · rows (up=ירוק/dn=אדום) · callout · opt(.on) · sub(bar) · **appr** (ok/no) · **gauge** (ok/h/x) · thr · fx-calc |
| **C** | `sc-` | ניהול-אתר | **gantt** (track/fill/pct) · floor/apt/rooms · attendance(.in) · safety-today (gradient כתום) · dep(.ready) · photo-pair (before→after) |
| **E** | (שונים) | UX/נגישות | skeleton(`ux-shimmer`) · page-trans · pull-to-refresh · **undo bar**(`ux-undo`) · **high-contrast**(`html[data-contrast=high]`) · focus-visible · reduce-motion |
| **F** | `ux-`/`ca-pod` | פורטל ספק/שליח | chat (בועות `ux-msg` them/me) · stars · POD · barcode |
| **G** | `ai-` | AI/אוטומציה | did-you-mean · mic · transcript · alt(from→to) · 3way-compare · warn |
| **H** | `rw-` | gamification | coin-banner (gradient כתום) · **leaderboard**(`rw-lb` .me) · badges(.on) · referral-code · **VIP tiers** |
| **I** | `sec-` | אבטחה | status · 2FA-OTP · **roles+perms (RBAC)**(`sec-role`/`sec-perm`) · biometric · audit · timeout · encryption · privacy-toggles |
| **J** | `svc-` | שירות/הרחבה | bot-chips · calc-tabs · **guided tour**(`svc-tour-dots`) |

### session-lock + פנים-ה-sheet (1384–1428)
`#sessionLock` overlay-נעילה (blur 6). `.sheet-head` (h3 Heebo-900 + p). **`.eyebrow` + `.pulse`** (נקודת-teal פועמת — מסמן "הופעל"). `.site-opt` בורר-אתר (.on=teal) + `.site-add` input.

### ⭐ עץ-המוצרים — tree-root + diagram + accessory (1430–1519)
- **`.tree-root`** (1430): כרטיס כהה (ink) — `.rthumb` 58 · `.name` · `.meta` · `.price` כתום · `.root-check` (✓ הופך לכתום).
- `.branch-label` (1455) + `.ai` תג-teal ("מומלץ ע"י BuildSmart").
- **`.tdiagram`** (1462): דיאגרמת-שלבים gradient כהה — `.td-stage` (clickable; `.active`=כתום, `.final`=teal) + `.td-icon` 46 + `.td-label/.td-sub` + `.td-arrow/.td-line` (teal).
- **`.accessory`** (1511): כרטיס-אביזר — `.picked`=teal · `.must`=אדום · `.stage-dim/.stage-hit` (עמעום/הדגשה לפי שלב נבחר).

---

## חלק ד׳ — ספריית-הרכיבים התפעולית (1520–2038)

### אביזר · מוצר-עשיר · בוררים (1519–1617)
- accessory-detail: `.acc-arrow` פותח · `.acc-why` · `.acc-stock-note` (כתום) · **`.stock-pill`** (order=כתום "הזמן" / wh=ירוק "במחסן" / site=teal "באתר") · `.acc-size`/`.acc-info` chips · `.have-it`(.72).
- מוצר-עשיר: `.opt-btn` (אופציות teal) · `.grp-head` (must=אדום/maybe=כתום/tools=אפור) · `.tool-box` (.picked=כתום).
- **`.pick-opt`** (brand/variant picker): `.po-check` עיגול (✓ teal) + `.po-name/.po-tag/.po-price`.

### מלאי · back-bar (1619–1661)
`.stock-tab` (.on=teal) · `.stock-row` (+`.sr-move`) · `.stock-empty` · `.back-head` (חץ-עיגול + כותרת).

### ⭐ בקרות-ניווט (1664–1693)
- **`.view-switch`** — segmented control (project↔sites · cart↔orders); `.vs-btn` (`.on`=card לבן + צל).
- **`.cat-chips`** — grid 3-עמ׳; `.cat-chip` (`.on`=teal מלא).

### שורת-מוצר בקטלוג (1700–1747)
`.prod-row` (`.in-cart`=teal) — `.prod-check` (✓) · `.pn-title/.pn-price` · foot: `.pf-tree`(כתום) + `.pf-brand`(teal).

### ⭐ מערכת-משימות (1748–1856)
- `.task-loc` (dropdown מיקום) · `.role-switch/.role-btn` (מנהל/עובד) · `.worker-pick/.wp-btn`.
- **5 מצבי-משימה** (צבע אחיד ל-group/icon/pill/status): `rev`=ביקורת(כתום) · `act`=פעיל(teal) · `pend`=ממתין(אפור) · `done`(ירוק) · `rej`=נדחה(אדום).
- `.task-card` · task-detail `td-*`: `.td-photo/.td-upload` (העלאת-תמונה) · `.td-note` (textarea) · `.td-approve`(ירוק)/`.td-reject`(אדום). work-log `.log-day/.log-row`. `.ad-*` (admin hero).

### ⭐ qty-wheel · check · btn-system (1866–1912)
- **`.qty-wheel`** stepper: `.qw-btn` ‹ › + `.qw-val` (לחיצה=הקלדה). `.check` (✓ teal).
- `.sheet-foot` (תחתית-sheet קבועה) + `.foot-row .total` (22px).
- **`.btn` (CTA ראשי): `.btn-primary` teal · `.btn-amber` כתום** (לחיצה→שוקע 2px, inset-shadow).

### סל + checkout (1914–2038)
- `.site-strip` (banner כהה, יעד + `.switch` כתום) · `.cart-line` (`.auto`=מקווקו לפריט-עץ · `.cl-link` קישור-מוצר · `.cl-del`) · `.empty`.
- `.deliv-pick/.slot` (חלון-אספקה) · `.summary-box`/`.checkout-box` (מסגרת teal; `.row.grand` סה"כ).
- **`.store-group`** — קיבוץ-סל לפי **חנות-ספק** (`.sg-name` + `.sg-eta` + `.sg-foot.ship`). `.order-card`(.open=teal).

---

## חלק ה׳ — הזמנות · פרויקט-flow · סורק · onboarding (2039–2577)

### כרטיס-הזמנה + מעקב (2038–2102)
`.order-card` (`oc-*`): `.oc-badge` סטטוס (pending=כתום · processing=teal · shipped=כחול · delivered=ירוק) · `.oci-link` · `.oc-tot.grand`. **`.track-line`** (מעקב-משלוח: `.tstep` dot done=teal/active=כתום + `.fill`). `.eta-badge` כתום.

### כרטיסי-אתר + multi-project (2104–2159)
`.site-card` (`.current`=teal) — `.badge` (live=teal/soon=כתום) · `.sc-stat` · `.sc-progress` · `.sc-link`. `.add-project-btn` (מקווקו). `.pm-field` (טופס-פרויקט). `.cat-bar/.legend` (פילוח-תקציב).

### tabbar · toast · hint (2161–2187)
`.tabbar` 5 טאבים (`.on`=teal · `.tdot` כתום). `.toast` (ink, נקודה כתומה). `.hint` (teal מקווקו).

### ⭐ פרויקט-flow: stage-card (2189–2263)
- `.project-hero` (gradient teal + 🛁) + `.project-prog` (בר כתום).
- **`.stage-card`**: `.stage-num` (done=teal/current=כתום/locked) · `.stage-state` (s-done/s-now/s-lock) · `.stage-foot`: `.sf-tree`/`.sf-order`(ink)/`.sf-done`(teal)/`.sf-undo`/`.sf-locked` · `.dep-warn` (תלות-חסרה, אדום). `.proj-cost/.proj-done`.

### סדר-הרכבה + seg (2265–2306)
`.ao-step` (rail + `.ao-bullet` ממוספר, `.warn`=כתום, `.ao-line`) · `.ao-dep` · `.ao-items`. `.seg` (segmented control נוסף).

### ⭐ סורק-תוכניות (2308–2466)
- `.scan-hero` (gradient כהה + 📐) · `.upload-btn` (מקווקו). **`.scan-canvas`**: `.blueprint` + **`.scan-laser`** (אנימציית `laser`) + `.detect-dot` (pop) + `.scan-tint`. `.scan-status` (spinner) · `.scan-load`.
- `.detect-summary` (teal) · `.zone-card` (`.conf` high=ירוק/mid=כתום) · `.zi-tree-btn`. **השוואת-מחירים**: `.store-chip` (`.best`=ירוק + `.stick` ✓). `.ptype` (בורר-סוג-תוכנית).

### ⭐ Onboarding fullscreen (2467–2577)
- `.fullscreen` (z-100). splash/login רקע ink. `.login-bg` (הילת-teal). `.login-logo` 74 לבן + `.login-brand` 34 (span כתום). `.login-card` (radius עליון 28) · `.login-field` · `.login-or`.
- **splash** (`splashIn`). **`.reg-field` + `.reg-check`** (✓ ירוק שמגיח כש-`.valid`) + `.reg-confirm` (מחליק `.show`). `.welcome-hamburger`. **`.role-drawer`** (מגירה מימין + scrim).

---

## חלק ו׳ — onboarding(המשך) + Admin dashboards (2578–3116)

### Onboarding: profession · prep · role-picker (2577–2664)
- `#screen-profession`: `.prof-card` (כרטיס-מקצוע, אייקון 60) · `.onb-back` (`.onb-back-light`=לבן).
- `#screen-prep` (רשימת-העמסה): `.prep-group` (ok=ירוק/warn=כתום) · `.prep-row`+`.pr-tag` (wh/order/site) · `.prep-ask` (`.pa-opt`).
- **`.role-pick-btn`** (בורר-תפקיד במגירה).

### ⭐ מעטפת Admin (2666–2708) — משותפת ל-4 הפרסונות
`.admin-screen` · `.adm-top` (ink) · **`.adm-tabs/.adm-tab`** (`.on`=teal) · `.adm-pane`(`.on`=מוצג) · `.adm-row`(+`.ar-btn`) · `.adm-pill` (new=teal/prep=כתום/ready=ירוק/done=אפור).

### ⭐ Manager dashboard `md-*` (2709–2986)
- hero: `.md-hero` (gradient כהה + glow + grain) · `.md-live` (פועם `mdpulse`) · **`.md-rev`** (הכנסות 34px).
- **`.md-metric`** tiles (פס-צד tone-BRAND/OK/AMBER) · `.md-alert`(אדום)/`.md-ok`(ירוק).
- מוצרים: `.md-search` · `.md-chips` · `.md-prow` + **`.md-sw`** (toggle-זמינות ירוק).
- **`.md-pipe`** (צינור-הזמנות) · `.md-chart` (bar קטגוריות) · `.md-store` (+medal+stats) · drill `msd-*` · `.md-rd-*` (פילוח-הכנסות).

### ⭐ פאנל בדיקות-רגרסיה `reg-*` (2765–2812)
`#regTestPanel` — `.reg-run` (כחול #1f6feb) · `.reg-summary` (ok/bad) · `.reg-prod` (ok/bad) · `.reg-check` (p/f + פירוט-שגיאה). **QA מובנה במסך-המנהל.**

### Manager — Management/Orders tabs (2987–3106)
- `mm-*` (ניהול): `.mm-sec` (אקורדיון, `.open`=teal) · `.mm-acc` · `.mm-add-btn` · `.mm-set` (k/v).
- `mo-*` (הזמנות): `.mo-card` + **`.mo-track`** (mini: done=teal/now=כתום) · `.mo-adv` (קדם-סטטוס) · `.mo-d-track` (מלא).

### Store dashboard `sh-*` (3107–…) — נמשך
`.sh-hello/.sh-sub` · **`.sh-action`** (פעולה-ראשית gradient teal). המשך בקריאה הבאה.

---

## חלק ז׳ — Store/Courier/Worker dashboards + משלוחים + תעודה (3117–3654)

### Store dashboard `sh-*` (3107–3196)
- **`.sh-action`** (פעולה-ראשית; `.held`=כתום, מספר 38px) · `.sh-clear`(ירוק) · `.sh-stat` · `.sh-stock-alert`(אדום) · `.sh-qbtn`.
- **`.so-card`** (הזמנת-חנות; פס-צד stage-new=teal/preparing=כתום/ready=ירוק) · `.so-btn` · `.so-wait/.so-held/.so-fixed`.

### ⭐ מתכנן-משלוחים `ship-*` (3198–3308)
`.ship-plan` (`.many`=כתום) · `.ship-card`: `.ship-slots` (חלונות) · `.ship-hauls` (הובלה) · item-picker `.ship-pick`+`.ship-cat`/`.ship-bulk` · `.ship-qty-*` (כמות-לכל-משלוח). `.oc-ship-plan` (סיכום-בהזמנה). split: `.adm-pill.split.fresh`(פועם) · `.sp-split-h` · `.ch-split-note`.

### ⭐ Picking sheet `sp-*` (3349–3403)
`.sp-prog` · `.sp-line` (`.picked`=ירוק קו-חוצה / `.missing`=אדום) · `.sp-lb.pick`(✓)/`.sp-lb.miss` · `.sp-repl` (תחליף).

### Store login `sl-*` (3404–3449)
`#screen-store-login`(ink) · `.sl-store` (`.off`=עמום) · `.sl-dot`(on=ירוק).

### ⭐ Courier `ch-*` (3450–3531)
`.ch-action` (gradient teal, מספר 38) · `.ch-veh-btn` (בורר-רכב) · `.ch-stats` · **`.ch-card`** (פס-צד ready=teal/pickup=כתום/transit=כחול) · `.ch-btn` · `.ch-d-item`.

### ⭐ Worker `ww-*` (3532–3554)
`.ww-summary` (gradient כהה) · `.ww-prog` · `.ww-st`. `.tc-detail` (line-clamp 2).

### ⭐ תעודת-משלוח `dn-*` (3563–3625)
`#screen-delivery-note` · `.dn-bar` (ink + הדפסה כתום) · **`.dn-doc`** (מסמך-מודפס לבן): `.dn-head` (לוגו+מטא) · `.dn-parties` · **`.dn-table`** (טבלת-פריטים) · `.dn-totals.grand` · `.dn-sign` (חתימות) · `.dn-foot`. `.oc-dn-btn`.

### accessory stock-cycle (3638–3652)
`.asc-btn` (order=teal/wh=כתום/site=ירוק — מחזור-מצב-מלאי).

---

## חלק ח׳ — catalog spec-sheet + ניווט + print + misc (3654–4019)

### ⭐ כרטיס-מפרט-מוצר `cd-*` (3653–3922)
`.cd-card` · `.cd-ic-img`/`.prod-thumb-img` (**תמונות-אמת** object-fit) · `.cd-store` (בורר-חנות `.on`=teal + eta) · `.cd-name/.cd-sub/.cd-desc` · **`.cd-size`** (בורר-מידה `.on`=teal) · `.cd-specs/.cd-row` (zebra) · `.cd-sku` (monospace) · `.cd-price` · `.cd-note`.

### ⭐ ניווט-קטלוג מדורג (3678–3880)
- drill-down (`#catDrill`): `.drill-crumb` · **`.drill-chip`** (`.on`=teal — סינון-תכונה).
- catnav (מסך עצמאי): `.catnav-crumb` (breadcrumb) · **`.cn-row`** (קטגוריה/תכונה; `.cn-row-attr` קומפקטי · `.cn-row-acc` מקווקו) · `.catnav-attrgrid` (2-עמ׳) · `.cn-allbtn`.
- **`.catnav-bar`** (sticky): `.catnav-back` · `.catnav-search`+`.search-clear`(✕) · **`.catnav-suggest`/`.cns-item`** (הצעות: label+path+kind) · `.catnav-sort/.csm-item` (מיון) · `.cnm-btn` (toggle-מצב).

### print (3923–3940)
`@media print` + `@page A4` — מסתיר הכל חוץ מ-`#screen-delivery-note`; `.dn-table` page-break-aware. תעודה מודפסת נקייה.

### Manager — Customers `mc-*` (3941–3976)
`.mc-card` · `.mc-pill` (live=ירוק/low=אדום/off=אפור) · **`.mc-credit-bar`** (`.hot`=אדום) · `.mc-d-order` (היסטוריה).

### misc סופי (3977–4017)
`.trk-map/.trk-svg` (מפת-מעקב SVG) · `.help-card/.help-q/.help-a` (שו"ת) · `.adm-act-btn` (teal/amber) · `.deliv-track/.dt-step` (מעקב אופקי).

---
**🏁 סוף ה-CSS (שורה 4019). מערכת-העיצוב נלכדה במלואה (head + 14–4019).**

### תובנות-על (cross-cutting)
- **2 צבעי-מותג בלבד:** teal `#1f6f6b` (ראשי/מבנה) + amber `#f2a516` (מבטא/CTA). ירוק=הצלחה, אדום=סכנה, אפור=ניטרלי.
- **שפה עקבית:** כרטיס לבן + `--line` border + radius 12–18; `.btn-primary`(teal)/`.btn-amber` הם ה-CTA; כל ה-sheets יורשים `.overlay/.sheet/.grip`; כל בורר משתמש ב-`.on`=teal.
- **4 פרסונות חולקות מעטפת** `.admin-screen/.adm-*`, וכל אחת prefix: manager=`md/mm/mo/mc`, store=`sh/so`, courier=`ch`, worker=`ww`.
- **מצבי-סטטוס בצבע אחיד** לאורך כל האפליקציה (משימה/הזמנה/משלוח): כתום=בתהליך, teal=פעיל, ירוק=הושלם, אדום=בעיה, אפור=ממתין.
- **טיפוגרפיה:** Heebo-900 לכותרות/מספרים, Rubik לגוף.
