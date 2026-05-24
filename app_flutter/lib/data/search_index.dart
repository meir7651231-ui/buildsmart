// App-wide search index — every navigable node in BuildSmart.
// Covers: bottom-nav tabs, BS personas + sub-trees, menu tabs + sub-trees,
// settings groups + all deep leaves, catalog categories, search tools.

enum SearchType {
  screen,
  persona,
  category,
  setting,
  action,
  menu,
}

class SearchEntry {
  const SearchEntry({
    required this.emoji,
    required this.title,
    required this.breadcrumb,
    required this.type,
  });

  final String emoji;
  final String title;
  final String breadcrumb;
  final SearchType type;

  bool matches(String query) {
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        breadcrumb.toLowerCase().contains(q);
  }

  String get typeLabel => switch (type) {
        SearchType.screen   => 'מסך',
        SearchType.persona  => 'BS',
        SearchType.category => 'קטגוריה',
        SearchType.setting  => 'הגדרה',
        SearchType.action   => 'פעולה',
        SearchType.menu     => 'תפריט',
      };
}

const List<SearchEntry> kSearchIndex = [
  // ── Bottom nav screens ─────────────────────────────────────────────────
  SearchEntry(emoji: '📋', title: 'קטלוג',  breadcrumb: '',  type: SearchType.screen),
  SearchEntry(emoji: '💬', title: 'שיחות',  breadcrumb: '',  type: SearchType.screen),
  SearchEntry(emoji: '🔔', title: 'התראות', breadcrumb: '',  type: SearchType.screen),
  SearchEntry(emoji: '🛒', title: 'חנות',   breadcrumb: '',  type: SearchType.screen),

  // ── Search tools ───────────────────────────────────────────────────────
  SearchEntry(emoji: '🎤', title: 'חיפוש קולי', breadcrumb: 'חיפוש', type: SearchType.action),
  SearchEntry(emoji: '📷', title: 'סורק ברקוד',  breadcrumb: 'חיפוש', type: SearchType.action),
  SearchEntry(emoji: '⚙️', title: 'פילטרים',     breadcrumb: 'חיפוש', type: SearchType.action),
  SearchEntry(emoji: '↕️', title: 'מיון',        breadcrumb: 'חיפוש', type: SearchType.action),
  SearchEntry(emoji: '▦',  title: 'קטלוג',       breadcrumb: 'חיפוש', type: SearchType.action),

  // ── Catalog categories (11 verbatim) ───────────────────────────────────
  SearchEntry(emoji: '🚰',  title: 'ברזים וכיורים',       breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🚽',  title: 'אסלות',               breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🚿',  title: 'מקלחות ואמבטיות',     breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '♨️', title: 'חימום מים',            breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🍽️', title: 'מטבח',                breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🕳️', title: 'ניקוז וצנרת',          breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🚾',  title: 'גופי תברואה',          breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🔗',  title: 'אביזרי קצה וחיבורים', breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🧱',  title: 'בנייה ומחיצות',        breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🎨',  title: 'גמר',                 breadcrumb: 'קטלוג', type: SearchType.category),
  SearchEntry(emoji: '🧰',  title: 'אביזרים נלווים',       breadcrumb: 'קטלוג', type: SearchType.category),

  // ── BS dial — personas (L1) ────────────────────────────────────────────
  SearchEntry(emoji: '👷', title: 'קבלן',         breadcrumb: 'BS', type: SearchType.persona),
  SearchEntry(emoji: '👔', title: 'מנהל המערכת',  breadcrumb: 'BS', type: SearchType.persona),
  SearchEntry(emoji: '🏪', title: 'חנות ספק',      breadcrumb: 'BS', type: SearchType.persona),
  SearchEntry(emoji: '🛵', title: 'שליח',          breadcrumb: 'BS', type: SearchType.persona),
  SearchEntry(emoji: '🦺', title: 'עובד',          breadcrumb: 'BS', type: SearchType.persona),

  // ── BS › מנהל המערכת ──────────────────────────────────────────────────
  SearchEntry(emoji: '📊', title: 'לוח בקרה',      breadcrumb: 'BS › מנהל המערכת',             type: SearchType.persona),
  SearchEntry(emoji: '🚚', title: 'הזמנות פתוחות', breadcrumb: 'BS › מנהל המערכת › לוח בקרה', type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'מוצרים בקטלוג', breadcrumb: 'BS › מנהל המערכת › לוח בקרה', type: SearchType.persona),
  SearchEntry(emoji: '🧰', title: 'אביזרים נלווים', breadcrumb: 'BS › מנהל המערכת › לוח בקרה', type: SearchType.persona),
  SearchEntry(emoji: '✅', title: 'זמינים כעת',    breadcrumb: 'BS › מנהל המערכת › לוח בקרה', type: SearchType.persona),
  SearchEntry(emoji: '🏪', title: 'חנויות פעילות', breadcrumb: 'BS › מנהל המערכת › לוח בקרה', type: SearchType.persona),
  SearchEntry(emoji: '🚚', title: 'הזמנות',        breadcrumb: 'BS › מנהל המערכת',             type: SearchType.persona),
  SearchEntry(emoji: '📥', title: 'התקבלה',        breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '🔧', title: 'בהכנה',          breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'מוכן לאיסוף',   breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '🚛', title: 'נאסף',           breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '🚚', title: 'בדרך לאתר',     breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '✅', title: 'נמסר ✓',        breadcrumb: 'BS › מנהל המערכת › הזמנות',    type: SearchType.persona),
  SearchEntry(emoji: '👥', title: 'לקוחות',        breadcrumb: 'BS › מנהל המערכת',             type: SearchType.persona),
  SearchEntry(emoji: '🟢', title: 'פעיל',          breadcrumb: 'BS › מנהל המערכת › לקוחות',    type: SearchType.persona),
  SearchEntry(emoji: '⚠️', title: 'אשראי גבוה',    breadcrumb: 'BS › מנהל המערכת › לקוחות',    type: SearchType.persona),
  SearchEntry(emoji: '🛠️', title: 'ניהול',         breadcrumb: 'BS › מנהל המערכת',             type: SearchType.persona),
  SearchEntry(emoji: '🌳', title: 'עץ המוצרים',    breadcrumb: 'BS › מנהל המערכת › ניהול',     type: SearchType.persona),
  SearchEntry(emoji: '🏷️', title: 'מותגים ומחירים', breadcrumb: 'BS › מנהל המערכת › ניהול',   type: SearchType.persona),
  SearchEntry(emoji: '🗂️', title: 'קטגוריות',     breadcrumb: 'BS › מנהל המערכת › ניהול',     type: SearchType.persona),
  SearchEntry(emoji: '⚙️', title: 'הגדרות אפליקציה', breadcrumb: 'BS › מנהל המערכת › ניהול',  type: SearchType.persona),

  // ── BS › חנות ספק ─────────────────────────────────────────────────────
  SearchEntry(emoji: '🏠', title: 'בית',           breadcrumb: 'BS › חנות ספק',          type: SearchType.persona),
  SearchEntry(emoji: '🔧', title: 'בהכנה',          breadcrumb: 'BS › חנות ספק › בית',    type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'מוכן לאיסוף',   breadcrumb: 'BS › חנות ספק › בית',    type: SearchType.persona),
  SearchEntry(emoji: '💰', title: 'מחזור פעיל',     breadcrumb: 'BS › חנות ספק › בית',    type: SearchType.persona),
  SearchEntry(emoji: '📥', title: 'הזמנות',         breadcrumb: 'BS › חנות ספק',          type: SearchType.persona),
  SearchEntry(emoji: '📥', title: 'לאישור',         breadcrumb: 'BS › חנות ספק › הזמנות', type: SearchType.persona),
  SearchEntry(emoji: '🔧', title: 'בהכנה',          breadcrumb: 'BS › חנות ספק › הזמנות', type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'מוכנות',         breadcrumb: 'BS › חנות ספק › הזמנות', type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'מלאי',           breadcrumb: 'BS › חנות ספק',          type: SearchType.persona),
  SearchEntry(emoji: '✅', title: 'זמין במלאי',     breadcrumb: 'BS › חנות ספק › מלאי',   type: SearchType.persona),
  SearchEntry(emoji: '❌', title: 'אזל',            breadcrumb: 'BS › חנות ספק › מלאי',   type: SearchType.persona),
  SearchEntry(emoji: '🧰', title: 'פורטל',          breadcrumb: 'BS › חנות ספק',          type: SearchType.persona),
  SearchEntry(emoji: '⭐', title: 'דירוג ספקים',    breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '⏱️', title: 'מעקב SLA',      breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '🗺️', title: 'אזורי הפצה',   breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '📉', title: 'הנחות כמות',     breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '🏷️', title: 'הפקת ברקודים', breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '🚛', title: 'ניהול צי רכב',   breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '💬', title: 'צ׳אט עם קבלן',  breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),
  SearchEntry(emoji: '🔄', title: 'עדכון מלאי',     breadcrumb: 'BS › חנות ספק › פורטל',  type: SearchType.persona),

  // ── BS › שליח ─────────────────────────────────────────────────────────
  SearchEntry(emoji: '🛵', title: 'הרכב שלי היום',          breadcrumb: 'BS › שליח',                   type: SearchType.persona),
  SearchEntry(emoji: '🛵', title: 'משלוח קטן',              breadcrumb: 'BS › שליח › הרכב שלי היום',   type: SearchType.persona),
  SearchEntry(emoji: '🚐', title: 'טנדר',                    breadcrumb: 'BS › שליח › הרכב שלי היום',   type: SearchType.persona),
  SearchEntry(emoji: '🚛', title: 'משאית',                   breadcrumb: 'BS › שליח › הרכב שלי היום',   type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'משלוחים ממתינים לאיסוף', breadcrumb: 'BS › שליח',                   type: SearchType.persona),
  SearchEntry(emoji: '🚚', title: 'משלוחים פעילים',         breadcrumb: 'BS › שליח',                   type: SearchType.persona),
  SearchEntry(emoji: '📦', title: 'אספתי מהחנות',           breadcrumb: 'BS › שליח › משלוחים פעילים', type: SearchType.persona),
  SearchEntry(emoji: '🚚', title: 'יצאתי לדרך',              breadcrumb: 'BS › שליח › משלוחים פעילים', type: SearchType.persona),
  SearchEntry(emoji: '✅', title: 'נמסר ללקוח',              breadcrumb: 'BS › שליח › משלוחים פעילים', type: SearchType.persona),
  SearchEntry(emoji: '🧰', title: 'פורטל השליח',             breadcrumb: 'BS › שליח',                   type: SearchType.persona),
  SearchEntry(emoji: '🧭', title: 'ניווט למשלוח',            breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),
  SearchEntry(emoji: '🚛', title: 'צי רכב',                  breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),
  SearchEntry(emoji: '⏱️', title: 'מעקב SLA',               breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),
  SearchEntry(emoji: '🗺️', title: 'אזורי הפצה',            breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),
  SearchEntry(emoji: '📸', title: 'אישור מסירה',              breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),
  SearchEntry(emoji: '💬', title: 'צ׳אט עם חנות',           breadcrumb: 'BS › שליח › פורטל השליח',     type: SearchType.persona),

  // ── BS › עובד ─────────────────────────────────────────────────────────
  SearchEntry(emoji: '🔨', title: 'המשימה הנוכחית שלך', breadcrumb: 'BS › עובד',                       type: SearchType.persona),
  SearchEntry(emoji: '🔨', title: 'בביצוע',              breadcrumb: 'BS › עובד › המשימה הנוכחית שלך', type: SearchType.persona),
  SearchEntry(emoji: '↩️', title: 'נדחה — לתקן',        breadcrumb: 'BS › עובד › המשימה הנוכחית שלך', type: SearchType.persona),
  SearchEntry(emoji: '⏳', title: 'הבאות בתור',          breadcrumb: 'BS › עובד',                       type: SearchType.persona),
  SearchEntry(emoji: '⏳', title: 'ממתינה',              breadcrumb: 'BS › עובד › הבאות בתור',          type: SearchType.persona),
  SearchEntry(emoji: '📋', title: 'שהגשת',               breadcrumb: 'BS › עובד',                       type: SearchType.persona),
  SearchEntry(emoji: '📸', title: 'ממתין לאישור',         breadcrumb: 'BS › עובד › שהגשת',               type: SearchType.persona),
  SearchEntry(emoji: '✅', title: 'אושר ✓',              breadcrumb: 'BS › עובד › שהגשת',               type: SearchType.persona),

  // ── Menu tabs (L1) ────────────────────────────────────────────────────
  SearchEntry(emoji: '🏠',  title: 'בית',        breadcrumb: 'תפריט', type: SearchType.menu),
  SearchEntry(emoji: '🏗️', title: 'הפרויקטים', breadcrumb: 'תפריט', type: SearchType.menu),
  SearchEntry(emoji: '🛒',  title: 'רכש',        breadcrumb: 'תפריט', type: SearchType.menu),
  SearchEntry(emoji: '⚙️',  title: 'הגדרות',     breadcrumb: 'תפריט', type: SearchType.menu),

  // ── Menu › בית ────────────────────────────────────────────────────────
  SearchEntry(emoji: '🤖',  title: 'בינה מלאכותית ואוטומציה', breadcrumb: 'תפריט › בית', type: SearchType.menu),
  SearchEntry(emoji: '📦',  title: 'חיזוי מלאי',              breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '📷',  title: 'סורק ברקוד',              breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '🎙️', title: 'דיבור למשימה',            breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '💡',  title: 'חלופות זולות',             breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '📐',  title: 'סריקת תוכניות',           breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '🔗',  title: 'התאמה משולשת',             breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '🌦️', title: 'אוטומציית מזג אוויר',     breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '🔧',  title: 'זיהוי בלאי',              breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '📊',  title: 'Analytics חכם',            breadcrumb: 'תפריט › בית › בינה מלאכותית ואוטומציה', type: SearchType.menu),
  SearchEntry(emoji: '📐',  title: 'סרוק תוכנית עבודה',       breadcrumb: 'תפריט › בית',                           type: SearchType.menu),
  SearchEntry(emoji: '🚿',  title: 'אינסטלציה',               breadcrumb: 'תפריט › בית › סרוק תוכנית עבודה',       type: SearchType.menu),
  SearchEntry(emoji: '⚡',  title: 'חשמל',                    breadcrumb: 'תפריט › בית › סרוק תוכנית עבודה',       type: SearchType.menu),
  SearchEntry(emoji: '🏛️', title: 'אדריכלות',                breadcrumb: 'תפריט › בית › סרוק תוכנית עבודה',       type: SearchType.menu),
  SearchEntry(emoji: '🎨',  title: 'גמר',                     breadcrumb: 'תפריט › בית › סרוק תוכנית עבודה',       type: SearchType.menu),
  SearchEntry(emoji: '📦',  title: 'המלאי שלי',               breadcrumb: 'תפריט › בית',                           type: SearchType.menu),
  SearchEntry(emoji: '🏬',  title: 'המחסן',                   breadcrumb: 'תפריט › בית › המלאי שלי',               type: SearchType.menu),
  SearchEntry(emoji: '🏗️', title: 'האתר',                    breadcrumb: 'תפריט › בית › המלאי שלי',               type: SearchType.menu),
  SearchEntry(emoji: '📋',  title: 'משימות העבודה',            breadcrumb: 'תפריט › בית',                           type: SearchType.menu),
  SearchEntry(emoji: '📅',  title: 'תרשים גאנט',              breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🔧',  title: 'רשימת ליקויים',           breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🏢',  title: 'קומה · דירה · חדר',       breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '📍',  title: 'נוכחות GPS',               breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '📓',  title: 'יומן עבודה',              breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🦺',  title: 'התראות בטיחות',           breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🔗',  title: 'תלויות חומרים',           breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '📸',  title: 'צילום לפני/אחרי',         breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🔍',  title: 'ביקורות מפקח',            breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),
  SearchEntry(emoji: '🗄️', title: 'ארכיון פרויקטים',         breadcrumb: 'תפריט › בית › משימות העבודה',            type: SearchType.menu),

  // ── Menu › הפרויקטים ──────────────────────────────────────────────────
  SearchEntry(emoji: '🏗️', title: 'מגדל הרצליה — קומה 4',  breadcrumb: 'תפריט › הפרויקטים',                type: SearchType.menu),
  SearchEntry(emoji: '🏗️', title: 'וילה כפר שמריהו',        breadcrumb: 'תפריט › הפרויקטים',                type: SearchType.menu),
  SearchEntry(emoji: '🏗️', title: 'שיפוץ משרדים — רעננה',  breadcrumb: 'תפריט › הפרויקטים',                type: SearchType.menu),
  SearchEntry(emoji: '📊',  title: 'מרכז פיננסים',           breadcrumb: 'תפריט › הפרויקטים',                type: SearchType.menu),
  SearchEntry(emoji: '📈',  title: 'הצמדה למדד',             breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '🗓️', title: 'תנאי תשלום',             breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '👷',  title: 'קבלני משנה',             breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '✅',  title: 'אישורי רכש',             breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '🔔',  title: 'התראות חריגה',           breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '📊',  title: 'ניתוח ROI',               breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '🧾',  title: 'פיצול חשבוניות',         breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '⏰',  title: 'פיצויים וקנסות',         breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '📄',  title: 'דוחות PDF',               breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),
  SearchEntry(emoji: '💱',  title: 'רכש במט״ח',              breadcrumb: 'תפריט › הפרויקטים › מרכז פיננסים', type: SearchType.menu),

  // ── Menu › רכש ────────────────────────────────────────────────────────
  SearchEntry(emoji: '🛒', title: 'הסל שלי',       breadcrumb: 'תפריט › רכש',                type: SearchType.menu),
  SearchEntry(emoji: '📦', title: 'ההזמנות שלי',   breadcrumb: 'תפריט › רכש',                type: SearchType.menu),
  SearchEntry(emoji: '🔧', title: 'השכרת כלים',    breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),
  SearchEntry(emoji: '💰', title: 'פקדונות',       breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),
  SearchEntry(emoji: '↩️', title: 'החזרה חדשה',   breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),
  SearchEntry(emoji: '📨', title: 'מכרז ספקים',    breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),
  SearchEntry(emoji: '🧪', title: 'גיליונות בטיחות', breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),
  SearchEntry(emoji: '📊', title: 'השוואת מחירים', breadcrumb: 'תפריט › רכש › ההזמנות שלי', type: SearchType.menu),

  // ── Settings groups (L1) ──────────────────────────────────────────────
  SearchEntry(emoji: '👤',  title: 'חשבון',             breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🔔',  title: 'התראות',            breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'תצוגה',             breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '♿',  title: 'נגישות',            breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'אבטחה והרשאות',    breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧',  title: 'שירות ותמיכה',      breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🚚',  title: 'משלוח ותשלום',      breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🌐',  title: 'אזור ושפה',         breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: 'ℹ️',  title: 'מידע',              breadcrumb: 'הגדרות', type: SearchType.setting),
  SearchEntry(emoji: '🔄',  title: 'איפוס לברירת מחדל', breadcrumb: 'הגדרות', type: SearchType.setting),

  // חשבון leaves
  SearchEntry(emoji: '👤', title: 'שם הקבלן',    breadcrumb: 'הגדרות › חשבון', type: SearchType.setting),
  SearchEntry(emoji: '👤', title: 'טלפון',        breadcrumb: 'הגדרות › חשבון', type: SearchType.setting),
  SearchEntry(emoji: '👤', title: 'סוג עוסק',    breadcrumb: 'הגדרות › חשבון', type: SearchType.setting),
  SearchEntry(emoji: '👤', title: 'תחום מקצועי', breadcrumb: 'הגדרות › חשבון', type: SearchType.setting),

  // התראות leaves
  SearchEntry(emoji: '🔔', title: 'עדכוני משלוחים', breadcrumb: 'הגדרות › התראות', type: SearchType.setting),
  SearchEntry(emoji: '🔔', title: 'מבצעים והטבות',  breadcrumb: 'הגדרות › התראות', type: SearchType.setting),
  SearchEntry(emoji: '🔔', title: 'התראות תקציב',   breadcrumb: 'הגדרות › התראות', type: SearchType.setting),
  SearchEntry(emoji: '🔔', title: 'עדכוני הזמנות',  breadcrumb: 'הגדרות › התראות', type: SearchType.setting),

  // תצוגה leaves
  SearchEntry(emoji: '🖥️', title: 'ערכת נושא',      breadcrumb: 'הגדרות › תצוגה',              type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'בהיר',            breadcrumb: 'הגדרות › תצוגה › ערכת נושא', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'כהה',             breadcrumb: 'הגדרות › תצוגה › ערכת נושא', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'גודל טקסט',      breadcrumb: 'הגדרות › תצוגה',              type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'קטן',             breadcrumb: 'הגדרות › תצוגה › גודל טקסט', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'בינוני',          breadcrumb: 'הגדרות › תצוגה › גודל טקסט', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'גדול',            breadcrumb: 'הגדרות › תצוגה › גודל טקסט', type: SearchType.setting),
  SearchEntry(emoji: '🖥️', title: 'הפחתת אנימציות', breadcrumb: 'הגדרות › תצוגה',              type: SearchType.setting),

  // נגישות leaves
  SearchEntry(emoji: '♿', title: 'מצב ניגודיות גבוהה (לשמש)', breadcrumb: 'הגדרות › נגישות', type: SearchType.setting),

  // אבטחה והרשאות leaves
  SearchEntry(emoji: '🛡️', title: 'מרכז האבטחה',  breadcrumb: 'הגדרות › אבטחה והרשאות',              type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'אימות דו-שלבי', breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'הרשאות גישה',   breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '👷', title: 'קבלן',           breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הרשאות גישה', type: SearchType.setting),
  SearchEntry(emoji: '👔', title: 'מנהל מערכת',     breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הרשאות גישה', type: SearchType.setting),
  SearchEntry(emoji: '🏪', title: 'ספק / חנות',     breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הרשאות גישה', type: SearchType.setting),
  SearchEntry(emoji: '🛵', title: 'שליח',           breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הרשאות גישה', type: SearchType.setting),
  SearchEntry(emoji: '🦺', title: 'עובד',           breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הרשאות גישה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'כניסה ביומטרית', breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'יומן ביקורת',   breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'הרשאת מיקום',   breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'נעילת הפעלה',   breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: '5 דק׳',          breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › נעילת הפעלה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: '15 דק׳',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › נעילת הפעלה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: '30 דק׳',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › נעילת הפעלה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: '60 דק׳',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › נעילת הפעלה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'הצפנת נתונים',   breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'תקשורת מוצפנת (HTTPS/TLS)', breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הצפנת נתונים', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'נתונים מקומיים מוגנים',    breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הצפנת נתונים', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'סיסמאות מאוחסנות כ-Hash',  breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הצפנת נתונים', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'גיבוי מוצפן בענן',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › הצפנת נתונים', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'היסטוריית כניסות',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'ניהול מכשירים',            breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'בקרת פרטיות',             breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'שיתוף נתוני שימוש',        breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › בקרת פרטיות', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'שירותי מיקום',             breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › בקרת פרטיות', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'התאמת תוכן שיווקי',        breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › בקרת פרטיות', type: SearchType.setting),
  SearchEntry(emoji: '🛡️', title: 'שליחת דוחות תקלה',         breadcrumb: 'הגדרות › אבטחה והרשאות › מרכז האבטחה › בקרת פרטיות', type: SearchType.setting),

  // שירות ותמיכה leaves
  SearchEntry(emoji: '🎧', title: 'מרכז השירות',   breadcrumb: 'הגדרות › שירות ותמיכה',               type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'מוקד תמיכה',    breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'צ׳אטבוט',       breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'דיווח על באג',   breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'המרת מידות',     breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'מחשבון כמויות',  breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'אריחים',         breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › מחשבון כמויות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'צבע',            breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › מחשבון כמויות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'בטון',           breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › מחשבון כמויות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'סנכרון יומן',    breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'לוח דרושים',     breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'סיור היכרות',    breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'מסך הבית',       breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'הזמנה',          breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'תקציב',          breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'משימות ואתר',    breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'מועדון BuildSmart', breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),
  SearchEntry(emoji: '🎧', title: 'מוכנים!',        breadcrumb: 'הגדרות › שירות ותמיכה › מרכז השירות › סיור היכרות', type: SearchType.setting),

  // משלוח ותשלום leaves
  SearchEntry(emoji: '🚚', title: 'סוג הובלה מועדף',             breadcrumb: 'הגדרות › משלוח ותשלום',                    type: SearchType.setting),
  SearchEntry(emoji: '🚚', title: 'משלוח קטן',                   breadcrumb: 'הגדרות › משלוח ותשלום › סוג הובלה מועדף', type: SearchType.setting),
  SearchEntry(emoji: '🚚', title: 'טנדר',                        breadcrumb: 'הגדרות › משלוח ותשלום › סוג הובלה מועדף', type: SearchType.setting),
  SearchEntry(emoji: '🚚', title: 'משאית',                       breadcrumb: 'הגדרות › משלוח ותשלום › סוג הובלה מועדף', type: SearchType.setting),
  SearchEntry(emoji: '🚚', title: 'ברירת מחדל — משלוח אקספרס',  breadcrumb: 'הגדרות › משלוח ותשלום',                    type: SearchType.setting),
  SearchEntry(emoji: '🚚', title: 'אמצעי תשלום',                 breadcrumb: 'הגדרות › משלוח ותשלום',                    type: SearchType.setting),

  // אזור ושפה leaves
  SearchEntry(emoji: '🌐', title: 'שפה',              breadcrumb: 'הגדרות › אזור ושפה',              type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'עברית',             breadcrumb: 'הגדרות › אזור ושפה › שפה',       type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'العربية',           breadcrumb: 'הגדרות › אזור ושפה › שפה',       type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'English',           breadcrumb: 'הגדרות › אזור ושפה › שפה',       type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'יחידות מידה',       breadcrumb: 'הגדרות › אזור ושפה',              type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'מטרי (מ׳, ק״ג)',   breadcrumb: 'הגדרות › אזור ושפה › יחידות מידה', type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'אימפריאלי',         breadcrumb: 'הגדרות › אזור ושפה › יחידות מידה', type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: 'מטבע',              breadcrumb: 'הגדרות › אזור ושפה',              type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: '₪ שקל',             breadcrumb: 'הגדרות › אזור ושפה › מטבע',      type: SearchType.setting),
  SearchEntry(emoji: '🌐', title: r'$ דולר',           breadcrumb: 'הגדרות › אזור ושפה › מטבע',      type: SearchType.setting),

  // מידע leaves
  SearchEntry(emoji: 'ℹ️', title: 'גרסה',             breadcrumb: 'הגדרות › מידע', type: SearchType.setting),
  SearchEntry(emoji: 'ℹ️', title: 'תנאי שימוש',       breadcrumb: 'הגדרות › מידע', type: SearchType.setting),
  SearchEntry(emoji: 'ℹ️', title: 'מדיניות פרטיות',   breadcrumb: 'הגדרות › מידע', type: SearchType.setting),
  SearchEntry(emoji: 'ℹ️', title: 'יצירת קשר',        breadcrumb: 'הגדרות › מידע', type: SearchType.setting),
];
