// 📦 דאטה-תוכן · screens__chat_settings_screen (הגדרות-שיחות, בנייה-חכמה) — ליטוש-ידני
// של פלט-המכונה (screen-lift): שמות-סמנטיים במקום תעתיק, אפס המצאת-תוכן — הכול verbatim
// מהמקור הקדוש scratchpad/all-screens/screens__chat_settings_screen.dart.
// כל מונח קיים בקטלוג terms-catalog.json — המפתח t_XXXXXXXX מוער ליד כל ערך (הכרעת
// "מונח-קיים ⇒ המפתח שלו"); הקופסה רשאית לצרוך דרך uiTerms[key] במקום הערך המקומי.
// מזהי-הסטודיו (chat_settings_screen.tNN של CfgText/CfgVisible) מוערים גם הם — חיווט-קופסה.

// ── שלד-המסך + דיאלוג-איפוס (ChatSettingsScreen, שורות 22–107) ──
const chatSettingsScreenContent = (
  appBarTitle: 'הגדרות שיחות', // t01 · t_a8cccd89
  resetTooltip: 'איפוס לברירת מחדל', // t_00367599
  resetDialogTitle: 'איפוס הגדרות?', // t02 · t_d5f40ad5
  resetDialogBody: 'כל הגדרות השיחות יוחזרו לברירת המחדל.', // t03 · t_c553d711
  resetCancel: 'ביטול', // t04 · t_a7c55a8d
  resetConfirm: 'אפס', // t05 · t_769b7b3c
  resetDoneToast: 'הגדרות אופסו', // t_9e2ee412
);

// ── באנר תשובות-מהירות (_QuickReplyBanner, שורות 112–241) ──
const quickReplyBannerContent = (
  leadingGlyph: '⚡',
  title: 'תשובות מהירות', // t08 · t_65aafdd0
  editLabel: 'ערוך', // t09 · t_16a64fd1
  editDialogTitle: 'תשובות מהירות', // t06 · t_65aafdd0
  editDialogBody:
      'התבניות קבועות בגרסה זו. הקש על תבנית כדי להעתיק אותה — ' // t_887287ee
      'עריכת תבניות מותאמות אישית תתווסף בהמשך.', // t_aea4fd3b
  editDialogDismiss: 'הבנתי', // t07 · t_5e9909a0
  copiedToast: 'התבנית הועתקה', // t_6a9029f1
  templates: [
    'בדרך אליך 🚗', // t_c7f7a33a
    'אאשר בקרוב ✅', // t_e8d7a7ef
    'קיבלתי, תודה 🙏', // t_dd2385ed
    'נחזור אליך 📞', // t_80531464
  ],
);

// ── 1. שיחות וחיווי (_PresenceSection, שורות 245–305) ──
const presenceSectionContent = (
  emoji: '💬',
  title: 'שיחות וחיווי', // t_2e0d651f
  readReceipts: 'אישורי קריאה', // t_93ea3479
  typingIndicator: 'חיווי הקלדה', // t_fb1d150d
  lockScreenPreview: 'תצוגה מקדימה בנעילה', // t_ccf7f8f1
  initialResponse: 'פתיחת שיחה (מענה ראשוני)', // t_0ea30460
  lastSeenLabel: 'זמן מקוון אחרון', // t_704959f8
  lastSeenEveryone: 'כולם', // t_cd0c93a3
  lastSeenContacts: 'אנשי קשר', // t_9f89ab55
  lastSeenNobody: 'אף אחד', // t_843f881d
);

// ── 2. התראות שיחה (_ChatNotifSection, שורות 309–348) ──
const chatNotifSectionContent = (
  emoji: '🔔',
  title: 'התראות שיחה', // t_cf6393ed
  callRing: 'צלצול שיחה נכנסת', // t_d120dec3
  messageAlert: 'התראת הודעה חדשה', // t_d6a79a62
  vibration: 'רטט', // t_73135519
  perContactRingtone: 'צלצול לפי איש קשר', // t_41fe83a7 · placeholder
  muteSpecificChat: 'השתקת שיחה ספציפית', // t_1dc7d762 · placeholder
);

// ── 3. מדיה ושמע (_MediaSection, שורות 353–403) ──
const mediaSectionContent = (
  emoji: '🎙️',
  title: 'מדיה ושמע', // t_1545c03a
  autoDownloadLabel: 'הורדה אוטומטית', // t_58c37cae
  downloadWifiOnly: 'WiFi בלבד', // t_be18e520
  downloadCellular: 'WiFi + סלולרי', // t_b41475e3
  downloadAlways: 'תמיד', // t_bf5734ac
  downloadNever: 'אף פעם', // t_d48c42c1
  imageQualityLabel: 'איכות תמונות נשלחות', // t_193a47f6
  qualityOriginal: 'מקורית', // t_246f12f8
  qualityHigh: 'גבוהה', // t_a0d916a3
  qualityMedium: 'בינונית', // t_cbad00fd
  compressVideo: 'דחיסת וידאו', // t_0f9d901d
  storageManagement: 'ניהול אחסון', // t_4197a50c · placeholder
);

// ── 4. פרטיות (_ChatPrivacySection, שורות 407–487) ──
const chatPrivacySectionContent = (
  emoji: '👥',
  title: 'פרטיות', // t_edb8ca33
  whoCanChatLabel: 'מי יכול לפתוח שיחה', // t_e257503c
  chatEveryone: 'כולם', // t_cd0c93a3
  chatContactsOnly: 'אנשי קשר בלבד', // t_d8835134
  chatSavedOnly: 'שמורים בלבד', // t_051dcbe5
  blockUsers: 'חסימת משתמשים', // t_fcaa0146 · placeholder
  profileDetails: 'פרטי הפרופיל (תמונה / ביוגרפיה)', // t_b0510062 · placeholder
  clearHistoryLabel: 'מחיקת היסטוריה', // t_c4c082da
  clearHistoryButton: 'מחק', // t_09b6bcca
  clearDialogTitle: 'מחיקת היסטוריית שיחות', // t10 · t_f3b3607f
  clearDialogBody: 'היסטוריית השיחות תימחק והשיחות ייפתחו ריקות.', // t11 · t_b794d6e6
  clearCancel: 'ביטול', // t12 · t_a7c55a8d
  clearConfirm: 'מחק', // t13 · t_09b6bcca
  clearedToast: 'ההיסטוריה נמחקה', // t_5085f51f
);

// ── 5. גיבוי וייצוא (_BackupSection, שורות 491–529) ──
const backupSectionContent = (
  emoji: '💾',
  title: 'גיבוי וייצוא', // t_9cb769c0
  cloudBackup: 'גיבוי לענן', // t_c706c0ae
  backupFreqLabel: 'תדירות גיבוי', // t_53dd5ffc
  freqDaily: 'יומי', // t_ef403757
  freqWeekly: 'שבועי', // t_50296d4c
  freqMonthly: 'חודשי', // t_3ec09dc0
  exportHistoryCsv: 'ייצוא היסטוריה (CSV)', // t_eb2c6734 · placeholder
  deleteCloudBackup: 'מחיקת גיבוי ענן', // t_4ce70953 · placeholder
);

// ── 6. שפה ותרגום (_LangSection, שורות 533–568) ──
const langSectionContent = (
  emoji: '🌐',
  title: 'שפה ותרגום', // t_442ea9ad
  uiLangLabel: 'שפת ממשק', // t_a5b55fb3
  langHebrew: 'עברית', // t_6e254acf
  langArabic: 'ערבית', // t_9045c88f
  langEnglish: 'אנגלית', // t_89242fc5
  autoTranslate: 'תרגום אוטומטי', // t_4dfba214
  keyboardLang: 'שפת מקלדת', // t_3e65fd70 · placeholder
);

// ── 7. שיחות עסקיות (_BusinessSection, שורות 573–650) ──
const businessSectionContent = (
  emoji: '🏪',
  title: 'שיחות עסקיות', // t_d6cde56d
  businessHours: 'שעות פעילות עסקית', // t_d83ff50a
  openTime: 'פתיחה', // t_1a1c4d24
  closeTime: 'סגירה', // t_b728721f
  afterHoursMsgLabel: 'הודעת מחוץ לשעות', // t_3bba17db
  afterHoursMsgHint: 'אנחנו סגורים, נחזור אליך בשעות הפעילות...', // t_843b5533
  catalogInChat: 'קטלוג מוצרים בשיחה', // t_ddee3261
  paymentInChat: 'תשלום מתוך שיחה', // t_f1d9afe1
);

// ── 8. בוט ואוטומציה (_BotSection, שורות 654–695) ──
const botSectionContent = (
  emoji: '🤖',
  title: 'בוט ואוטומציה', // t_78253c5d
  faqBot: 'בוט שאלות נפוצות', // t_80ba77d8
  chatRouting: 'ניתוב שיחות', // t_730ca1df · placeholder
  greeting: 'ברכת פתיחה', // t_7f706d3e
  greetingTextLabel: 'טקסט הברכה', // t_f5e29367
  greetingTextHint: 'שלום! איך אפשר לעזור?', // t_bc93bd3a
  afterHoursReply: 'תגובה מחוץ לשעות פעילות', // t_e06b7c47 · placeholder
);

// ── 9. ארכיון וניקיון (_ArchiveSection, שורות 699–751) ──
const archiveSectionContent = (
  emoji: '🗂️',
  title: 'ארכיון וניקיון', // t_f67cd54d
  autoArchive: 'ארכוב אוטומטי', // t_032ca4b1
  autoDeleteLabel: 'מחיקה אוטומטית', // t_af3406c5
  deleteOff: 'כבוי', // t_8edcd285
  delete30Days: '30 יום', // t_fa2a3649
  delete90Days: '90 יום', // t_40e6963a
  delete180Days: '180 יום', // t_3aaec64f
  spamFilter: 'סינון ספאם', // t_5db08c64
  backupBeforeDelete: 'גיבוי לפני מחיקה', // t_5b9645f2
);

// ── מנגנונים משותפים ──
const sectionTileContent = (
  // תת-כותרת סקציה-בבנייה (t14 · t_3a3cce3d) — הקופסה מזרימה כ-subtitleNote
  underConstructionSection: 'בבנייה — ההגדרות נשמרות אך עדיין אינן משפיעות',
);

const inertRowContent = (
  // תת-כותרת שורה-בבנייה — משותפת ל-SettingsSwitchRow (t15) ול-SettingsRadioGroupRow
  // (t16); אותו נוסח verbatim בשני המנגנונים · t_584cf3e1
  underConstructionRow: 'בבנייה — עדיין לא משפיע',
);

const placeholderRowContent = (
  underConstructionBadge: 'בבנייה', // t17 · t_a98f280f — ה-badge של אטום-המדף PlaceholderRow
  // תבנית-$: הקופסה מפרמטת ('<label> — בבנייה') ומעבירה טוסט מוכן · t_f862ee5a
  tapToastTemplate: r'$label — בבנייה',
);
