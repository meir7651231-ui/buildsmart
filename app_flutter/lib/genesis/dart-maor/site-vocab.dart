// חוט · site-vocab — תוויות-פעולה של האתר-הציבורי תלויות-סוג-ארגון:
// מסחרי (בלי §46) ⇒ "צרו קשר"; עמותתי ⇒ "לתרומה" (+♡ בצ׳יפים).
// חוזה: site-vocab.contract.md
// המרה מ-JS (new/atoms/site-vocab.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// טהור, אפס שקעים, אפס-import (dart-core בלבד).
// אנגלית רק כש-lang=='en' (השוואת-זהות כמו ===); כל שפה אחרת ⇒ עברית.
// סדר-המפתחות במפה = סדר-ההכנסה של המקור (LinkedHashMap ≡ סדר-אובייקט-JS —
// אין כאן מפתחות דמויי-שלם, כלל-14 לא נדרש).
dynamic siteVocab(dynamic commercial, dynamic lang, {required String Function(String) term}) {
  final en = lang == 'en';
  // truthiness של JS על commercial (כלל-7): בחוזה commercial הוא boolean,
  // אך נשמרת סמנטיקת if(x) של JS לקצוות.
  if (_truthy(commercial)) {
    return {
      'heroCta': en ? 'Get in touch' : term('tsrv-kshr'),
      'navCta': en ? 'Contact' : term('tsrv-kshr'),
      'give': en ? 'Contact us' : term('tsrv-kshr'),
      'giveLabel': en ? 'Your request' : term('hpnyyh-shlk'),
      'commercial': true,
    };
  }
  return {
    'heroCta': en ? 'Donate now' : term('ltrvmh-akshyv'),
    'navCta': (en ? 'Donate' : term('ltrvmh')) + ' ♡',
    'give': (en ? 'Donate' : term('ltrvmh')) + ' ♡',
    'giveLabel': en ? 'Your gift' : term('htrvmh-shlk'),
    'commercial': false,
  };
}

// עוזר מקומי (קידומת _): truthiness נאמן-JS — false/null/0/NaN/'' ⇒ שקרי.
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
