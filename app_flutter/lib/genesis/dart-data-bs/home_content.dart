// 📦 דאטה-תוכן · מסך-הבית של הקבלן — כל התוכן שהיה צרוב ב-widgets (חוק "אטום נקי").
// מוצא: buildsmart app_flutter/lib/screens/smart_home_screen.dart (origin/main 28.8) —
// חולץ verbatim מ-_WorkPath · _QuickTools · _SmartTreeRow · 4 ההירואים · _OrderCard.
// המנגנונים (dart-ui-bs/) מקבלים את זה כ-props; שינוי-תוכן = עריכת-שורה כאן, אפס-קוד.

const homeSectionTitles = {
  'workPath': 'מסלול עבודה חכם',
  'quickTools': 'כלים מהירים',
  'smartTree': '🌳 עץ חכם — אינסטלציה',
  'departments': 'מחלקות',
  'recentOrders': 'הזמנות אחרונות לאתר',
  'favorites': 'מועדפים',
};

const workPathContent = (
  termPrefix: 'smart_home_screen.workpath',
  badge: '🛁 חדש — מאפס עד גמר',
  title: 'גמר אמבטיה — מלווה אותך שלב-שלב',
  sub: '4 שלבים בסדר הנכון. כל שלב: עץ מוצרים + חלון "סדר הרכבה".',
);

/// gate: מזהה-שער ארגוני (המנגנון לא מכיר מודולים — הקופסה מפרשת).
const quickToolsContent = [
  (emoji: '📐', title: 'סרוק תוכנית עבודה', sub: 'צלם שרטוט אינסטלציה — נזהה מה צריך להזמין', action: 'scanPlan', gate: 'rawShellOff'),
  (emoji: '📦', title: 'המלאי שלי', sub: 'מה כבר יש לך — במחסן ובאתר', action: 'stock', gate: 'site.stock'),
  (emoji: '📋', title: 'משימות העבודה', sub: 'חלק משימות לעובדים ועקוב אחרי הביצוע', action: 'siteHub', gate: 'site'),
];

const homeHeroes = [
  (id: 'installStudio', glyph: '', title: 'תכנון חיבור', sub: 'בחר מה לחבר — נכין רשימת קנייה תקנית ונבדוק את החיבור', gate: 'compat'),
  (id: 'superFinder', glyph: '🕸️', title: 'מאתר-על', sub: 'גלגל-חיפוש-על — בחר מאיזה ציר להתחיל', gate: 'kAxisDive'),
  (id: 'catalogConfig', glyph: '🎛️', title: 'קטלוג מגדיר', sub: 'כרטיס-הגדרה לכל מוצר — תמונה + גלגלים', gate: ''),
  (id: 'internalCard', glyph: '🃏', title: 'כרטיס פנימי', sub: 'כל המנוע במקום אחד — 13 סקציות', gate: 'kInternalCard'),
];

const orderCardTerms = (itemsSuffix: 'פריטים', addToCart: 'הוסף לסל', addedToCart: 'נוסף לסל', priceBySupplier: 'מחיר לפי ספק');
const emptyStateTerms = (
  noOrders: 'עדיין אין הזמנות — לאחר הראשונה היא תופיע כאן.',
  noFavorites: 'עדיין אין מועדפים — סמן ☆ על מוצר והוא יופיע כאן.',
);
