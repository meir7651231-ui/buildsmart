// ⚛️ אטום-Dart · lipskeyAccFor
// מוצא: buildsmart/app_flutter/lib/data/lipskey_smart_data.dart:330-332 (חצב-בינה · מפל-מינימום · חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
//   מפל: הטיפוס `LipskeyCatAcc` (:4-18) הוטבע verbatim; הקבועים `kLipskeyAccBySku` (:327)
//        ו-`kLipskeyAccByCategory` (:97-204) הוטבעו verbatim (נתוני-קטלוג, dart:core בלבד).

class LipskeyCatAcc {
  final String name;
  final String emoji;
  final int? price;
  final String why;
  final bool must;

  const LipskeyCatAcc({
    required this.name,
    required this.emoji,
    this.price,
    required this.why,
    this.must = false,
  });
}

const Map<String, List<LipskeyCatAcc>> kLipskeyAccBySku = {};

const Map<String, List<LipskeyCatAcc>> kLipskeyAccByCategory = {
  'מחסומים גלויים': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם את ההברגה — חובה', must: true),
    LipskeyCatAcc(name: 'אטם גומי 32/50mm', emoji: '⚫', price: 8,
        why: 'מונע נזילה בחיבור', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק הסיפון', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום בין הסיפון למשטח', must: false),
  ],
  'מחסומי רצפה': [
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'איטום חיבור לצינור', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם הברגת מכסה', must: true),
    LipskeyCatAcc(name: 'מלט מפרקים', emoji: '🪣',
        why: 'לסביבת הרצפה לאחר התקנה', must: false),
  ],
  'מאספים וקולטים': [
    LipskeyCatAcc(name: 'אטם גומי', emoji: '⚫', price: 8,
        why: 'לחיבורי הצינורות', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'לאיטום ההברגות', must: true),
  ],
  'מסעפים וחיבורי אסלה': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'חיבור לצינור ניקוז', must: true),
  ],
  'מצמדים וצינורות': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק המצמד', must: true),
  ],
  'מושבי אסלה': [
    LipskeyCatAcc(name: 'ברגי הידוק', emoji: '🔩', price: 8,
        why: 'לחיבור המושב לאסלה', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 12,
        why: 'איטום בין המושב לאסלה', must: false),
  ],
  'אמבט ואגנית': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגות', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום פריפריאלי', must: true),
    LipskeyCatAcc(name: 'מפתח צינורות', emoji: '🔧', price: 39,
        why: 'להידוק', must: true),
  ],
  'אביזרי תבריג': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם ההברגה', must: true),
    LipskeyCatAcc(name: 'מפתח ברגים', emoji: '🔩', price: 25,
        why: 'לחיבור', must: true),
  ],
  'אטמים ופקקים': [
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'לאיטום נוסף', must: false),
  ],
  'ברכיים': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום החיבור לצינור', must: true),
    LipskeyCatAcc(name: 'מפתח שבדי', emoji: '🔧', price: 45,
        why: 'להידוק אומי החיבור', must: true),
  ],
  'אביזרי שקע-תקע': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום החיבורים', must: false),
  ],
  'זקיף אסלה': [
    LipskeyCatAcc(name: 'אטם גומי 110mm', emoji: '⚫', price: 12,
        why: 'איטום חיבור לאסלה', must: true),
    LipskeyCatAcc(name: 'סרט טפלון', emoji: '🎗️', price: 4,
        why: 'אוטם הברגות', must: true),
  ],
  'צינורות': [
    LipskeyCatAcc(name: 'סיליקון שחור לביוב', emoji: '🧴', price: 18,
        why: 'איטום חיבורים', must: false),
    LipskeyCatAcc(name: 'מסור לפלסטיק', emoji: '🪚', price: 35,
        why: 'חיתוך לאורך הנכון', must: true),
    LipskeyCatAcc(name: 'מחבר כפול', emoji: '🔌', price: 12,
        why: 'חיבור בין הצינורות', must: true),
  ],
  'התקנה גבוהה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור המיכל לקיר', must: true),
    LipskeyCatAcc(name: 'צינור חיבור גמיש', emoji: '🪠', price: 15,
        why: 'מחבר מיכל לקערה', must: true),
  ],
  'התקנה נמוכה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור המיכל לקיר', must: true),
    LipskeyCatAcc(name: 'אטם גומי מיכל', emoji: '⚫', price: 6,
        why: 'מונע נזילה', must: true),
  ],
  'התקנה צמודה': [
    LipskeyCatAcc(name: 'ברגי הידוק נירוסטה', emoji: '🔩', price: 8,
        why: 'לחיבור הקערה לרצפה', must: true),
    LipskeyCatAcc(name: 'סיליקון סניטרי', emoji: '🧴', price: 21,
        why: 'איטום בסיס הקערה', must: true),
  ],
  'חלקים סניטריים': [
    LipskeyCatAcc(name: 'ברגי הידוק', emoji: '🔩', price: 6,
        why: 'חיבור החלק החדש', must: true),
  ],
};


/// אביזרים למוצר: דריסת-SKU → ברירת-קטגוריה → ריק. PURE.
List<LipskeyCatAcc> lipskeyAccFor(String sku, String categoryHe) =>
    kLipskeyAccBySku[sku] ?? kLipskeyAccByCategory[categoryHe] ?? const [];
