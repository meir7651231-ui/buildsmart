// ⚛️ אטום-Dart-דאטה (דרגת-חוזה) · template-defs — קודם מכנית ע"י gen-data-dart.mjs.
// מקור: new/atoms/template-defs.mjs (אטום-קבוע, צילום-ערך). טוהר: getter top-level,
// אפס import (רק dart:core). חוק-4 — ערך זהה-ביט למקור-ה-JS.
// ההמרה: ‏JS-const ⇒ ‏Dart-const (ליטרל שומר-סדר, LinkedHashMap≡סדר-מפתחות-JS).

/// Verbatim data port of `TEMPLATE_DEFS` from new/atoms/template-defs.mjs.
List<dynamic> get templateDefs => const [
        const {
          'key': 'wa.delivery',
          'label': '🚚 הודעת-מסירה (חלוקה)',
          'vars': const [
            'name',
            'org',
          ],
          'def': 'שלום {name}, משלוח מ{org} בדרך אליכם היום 🚚',
        },
        const {
          'key': 'wa.payment',
          'label': '💳 תזכורת-תשלום (חוגים)',
          'vars': const [
            'org',
            'what',
            'amount',
          ],
          'def': 'שלום, תזכורת ידידותית מ{org}: יתרה לתשלום עבור {what} — ₪{amount}. תודה רבה!',
        },
        const {
          'key': 'wa.birthday',
          'label': '🎂 ברכת יום-הולדת',
          'vars': const [
            'first',
            'org',
          ],
          'def': 'מזל טוב ל{first} ליום ההולדת! 🎂 באהבה, {org}',
        },
        const {
          'key': 'wa.dialer',
          'label': '📞 הודעת-חייגן (לא ענה)',
          'vars': const [
            'name',
            'org',
          ],
          'def': 'שלום {name}, ניסינו להשיג אתכם מ{org} ולא הצלחנו — נשמח שתחזרו אלינו 🙏',
        },
        const {
          'key': 'wa.paylink',
          'label': '💳 שליחת קישור-תשלום',
          'vars': const [
            'name',
            'org',
            'link',
          ],
          'def': 'שלום {name}, תודה על השיחה! לתרומה מקוונת ל{org}: {link} 🙏',
        },
      ];
