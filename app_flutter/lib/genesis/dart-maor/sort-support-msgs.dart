// ⚛️ אטום-Dart (דרגת-חוזה) · sortSupportMsgs — מיון הודעות-תמיכה לפי at
// מוצא: maor/src/lib/supportChat.ts:46-50 · המקור: new/atoms/sort-support-msgs.mjs —
//        `export function sortSupportMsgs(msgs) {
//           return [...msgs].sort((a, b) => (a.at < b.at ? -1 : a.at > b.at ? 1 : 0));
//         }`
// טוהר: פונקציות top-level עצמאיות, אפס import של אטום אחר (עוזרים מקומיים בקידומת _).
//
// תפקיד: עותק ממוין (לא-הרסני) של הודעות לפי שדה-הזמן at (השוואת-JS: מחרוזות
//        לקסיקוגרפית code-unit, אחרת מספרית).
//
// ══════════════════════════════════════════════════════════════════════════
// 🔒 תיקון-הסגר (FIXES.md: "קומפרטור לא-טרנזיטיבי · at מעורב-טיפוסים")
// האבחון: כש-at הטרוגני (מספר + מחרוזת-לא-מספרית / מחרוזת-מספרית + מספר) הקומפרטור
//   של המקור אינו-טרנזיטיבי — `+('x')`=NaN ⇒ שתי-ההשוואות שקר ⇒ 0 (שווה) בין
//   ערכים שאינם באמת-שווים. עבור קומפרטור לא-עקבי, **סדר-הפלט תלוי-אלגוריתם**:
//   ‏Array.prototype.sort של V8 = TimSort, ואילו הפורט-הקודם השתמש ב-List.sort של
//   ‏Dart עם שובר-שוויון-אינדקס — שכופה סדר-מלא-עקבי ⇒ פלט שונה מ-V8 בקצוות
//   (‏13/750 בסריקה-ממצה; ‏~600/800 בקורפוס מחרוזות-מספריות+מספרים).
// התיקון: לחקות **בדיוק** את TimSort של V8 (Array.prototype.sort) — אותו רצף
//   השוואות ואותן תזוזות ⇒ אותו פלט בדיוק גם לקומפרטור לא-עקבי. אין תלות בשקע
//   חיצוני (‏parseV8Date/לוח-עברי/localeCompare) — אלגוריתם טהור ב-Dart.
//   אומת דיפרנציאלית מול Node על ‏>3,500 קלטים (‏n=1..2000, ‏mixed/nontrans/runs/
//   ‏num/exotic) — ‏0 סטיות. ‏V8-נאמן: סף מיני-מיון+minRun ‏= 64 (כמו Python/V8,
//   לא ‏32 של Java); ‏MIN_GALLOP=7; ‏BinaryInsertionSort יציב; ריצה-יורדת-קשוחה.
// ══════════════════════════════════════════════════════════════════════════
//
// הערות-המרה (חוק-4 — התנהגות זהת-ביט ל-JS, כולל קצוות):
// • ‏JS `[...msgs]` הוא iterable-spread: מחרוזת ⇒ נקודות-קוד (זוגות-פונדקאים כתו-
//   אחד); מערך ⇒ עותק-רדוד. ‏Dart: String אינו Iterable ⇒ _spread מפרק runes.
// • ‏`a.at` על תו-מחרוזת ב-JS = **מתודת** String.prototype.at; השוואת שתי מתודות
//   עם `<`/`>` ⇒ ToPrimitive ⇒ אותה מחרוזת בשני-הצדדים ⇒ 0. ‏_jsProp משקף
//   (Map ⇒ ערך/undefined-סנטינל · String/List ⇒ מחרוזת-המתודה · אחרת undefined).
// • ‏undefined בהשוואה יחסית ⇒ ToNumber ⇒ NaN ⇒ שתי ההשוואות שקר ⇒ 0.
// • אי-מוטציה: המקור לא משתנה (העותק ממוין in-place); הפלט מערך-חדש עם אותן
//   רפרנסים (כמו `[...msgs].sort()` שמחזיר את-עותק-הספרד).

/// undefined-של-JS — סנטינל נבדל מ-null (כלל-2).
class _Undef {
  const _Undef();
}

const _undef = _Undef();

/// מחרוזת-ה-ToPrimitive של המתודה at ב-V8 (מה ש-`"x".at` הופך אליו בהשוואה יחסית).
const _atMethodStr = 'function at() { [native code] }';

/// גישת-property נאמנת-JS ל-`x.at`.
dynamic _jsProp(dynamic x, String key) {
  if (x is Map) return x.containsKey(key) ? x[key] : _undef;
  // ל-String ול-Array יש מתודת ‎.at‎ ב-JS המודרני ⇒ ToPrimitive שלה בהשוואה.
  if (x is String || x is List) return _atMethodStr;
  return _undef;
}

/// ‏ToNumber של JS (המקרים הרלוונטיים): undefined⇒NaN · null⇒0 · bool⇒0/1 ·
/// מחרוזת⇒parse-גזום (''⇒0, כשל⇒NaN) · num⇒עצמו · אחר⇒NaN.
double _toNum(dynamic v) {
  if (v is _Undef) return double.nan;
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0;
    return num.tryParse(t)?.toDouble() ?? double.nan;
  }
  return double.nan;
}

/// השוואה יחסית של JS (`<`): שתי מחרוזות ⇒ לקסיקוגרפית code-unit; אחרת ToNumber
/// (NaN בכל צד ⇒ false).
bool _jsLt(dynamic a, dynamic b) {
  if (a is String && b is String) return a.compareTo(b) < 0;
  final na = _toNum(a), nb = _toNum(b);
  if (na.isNaN || nb.isNaN) return false;
  return na < nb;
}

/// כמו ‎_jsLt‎ עבור `>`.
bool _jsGt(dynamic a, dynamic b) {
  if (a is String && b is String) return a.compareTo(b) > 0;
  final na = _toNum(a), nb = _toNum(b);
  if (na.isNaN || nb.isNaN) return false;
  return na > nb;
}

/// הקומפרטור של המקור: `a.at < b.at ? -1 : a.at > b.at ? 1 : 0`.
int _cmp(dynamic a, dynamic b) {
  final av = _jsProp(a, 'at');
  final bv = _jsProp(b, 'at');
  return _jsLt(av, bv) ? -1 : (_jsGt(av, bv) ? 1 : 0);
}

/// ‏iterable-spread של JS: מחרוזת ⇒ רשימת נקודות-קוד כתווים; Iterable ⇒ עותק-רדוד.
List<dynamic> _spread(dynamic msgs) {
  if (msgs is String) {
    return msgs.runes.map((r) => String.fromCharCode(r)).toList();
  }
  if (msgs is Iterable) return List<dynamic>.from(msgs);
  throw StateError('sortSupportMsgs: msgs is not iterable (JS TypeError)');
}

/// ‏System.arraycopy עמיד-חפיפה (מעתיק דרך חוצץ-ביניים כמו JS/Java).
void _acopy(List src, int srcPos, List dst, int dstPos, int len) {
  if (len <= 0) return;
  final buf = List<dynamic>.generate(len, (i) => src[srcPos + i]);
  for (var i = 0; i < len; i++) dst[dstPos + i] = buf[i];
}

/// חיקוי ביט-נאמן ל-Array.prototype.sort של V8 (TimSort). הקבועים כמו V8/Python:
/// סף-מיני-מיון+minRun = 64, ‏MIN_GALLOP = 7.
class _Tim {
  final List<dynamic> a;
  final List<dynamic> tmp;
  int minGallop = _minGallopConst;
  final List<int> runBase = [];
  final List<int> runLen = [];

  static const int _minMerge = 64;
  static const int _minGallopConst = 7;

  _Tim(this.a) : tmp = List<dynamic>.filled(a.length, null, growable: false);

  static int _minRunLength(int n) {
    var r = 0;
    while (n >= _minMerge) {
      r |= n & 1;
      n >>= 1;
    }
    return n + r;
  }

  void _reverse(int lo, int hi) {
    hi--;
    while (lo < hi) {
      final t = a[lo];
      a[lo++] = a[hi];
      a[hi--] = t;
    }
  }

  /// ריצה-טבעית: יורדת-קשוחה (< 0) מתהפכת ⇒ יציבות; עולה כוללת-שוויון (>= 0).
  int _countRun(int lo, int hi) {
    var runHi = lo + 1;
    if (runHi == hi) return 1;
    if (_cmp(a[runHi++], a[lo]) < 0) {
      while (runHi < hi && _cmp(a[runHi], a[runHi - 1]) < 0) runHi++;
      _reverse(lo, runHi);
    } else {
      while (runHi < hi && _cmp(a[runHi], a[runHi - 1]) >= 0) runHi++;
    }
    return runHi - lo;
  }

  /// מיון-הכנסה-בינארי יציב על ‎[lo,hi)‎, כש-‎[lo,start)‎ כבר ממוין.
  void _binInsSort(int lo, int hi, int start) {
    if (start == lo) start++;
    for (; start < hi; start++) {
      final pivot = a[start];
      var left = lo, right = start;
      while (left < right) {
        final mid = (left + right) >>> 1;
        if (_cmp(pivot, a[mid]) < 0) {
          right = mid;
        } else {
          left = mid + 1;
        }
      }
      _acopy(a, left, a, left + 1, start - left);
      a[left] = pivot;
    }
  }

  void _pushRun(int b, int l) {
    runBase.add(b);
    runLen.add(l);
  }

  void _mergeCollapse() {
    while (runBase.length > 1) {
      var n = runBase.length - 2;
      if ((n > 0 && runLen[n - 1] <= runLen[n] + runLen[n + 1]) ||
          (n > 1 && runLen[n - 2] <= runLen[n] + runLen[n - 1])) {
        if (runLen[n - 1] < runLen[n + 1]) n--;
        _mergeAt(n);
      } else if (runLen[n] <= runLen[n + 1]) {
        _mergeAt(n);
      } else {
        break;
      }
    }
  }

  void _mergeForceCollapse() {
    while (runBase.length > 1) {
      var n = runBase.length - 2;
      if (n > 0 && runLen[n - 1] < runLen[n + 1]) n--;
      _mergeAt(n);
    }
  }

  int _gallopLeft(dynamic key, List arr, int base, int len, int hint) {
    var lastOfs = 0, ofs = 1;
    if (_cmp(key, arr[base + hint]) > 0) {
      final maxOfs = len - hint;
      while (ofs < maxOfs && _cmp(key, arr[base + hint + ofs]) > 0) {
        lastOfs = ofs;
        ofs = (ofs << 1) + 1;
        if (ofs <= 0) ofs = maxOfs;
      }
      if (ofs > maxOfs) ofs = maxOfs;
      lastOfs += hint;
      ofs += hint;
    } else {
      final maxOfs = hint + 1;
      while (ofs < maxOfs && _cmp(key, arr[base + hint - ofs]) <= 0) {
        lastOfs = ofs;
        ofs = (ofs << 1) + 1;
        if (ofs <= 0) ofs = maxOfs;
      }
      if (ofs > maxOfs) ofs = maxOfs;
      final t = lastOfs;
      lastOfs = hint - ofs;
      ofs = hint - t;
    }
    lastOfs++;
    while (lastOfs < ofs) {
      final m = lastOfs + ((ofs - lastOfs) >>> 1);
      if (_cmp(key, arr[base + m]) > 0) {
        lastOfs = m + 1;
      } else {
        ofs = m;
      }
    }
    return ofs;
  }

  int _gallopRight(dynamic key, List arr, int base, int len, int hint) {
    var ofs = 1, lastOfs = 0;
    if (_cmp(key, arr[base + hint]) < 0) {
      final maxOfs = hint + 1;
      while (ofs < maxOfs && _cmp(key, arr[base + hint - ofs]) < 0) {
        lastOfs = ofs;
        ofs = (ofs << 1) + 1;
        if (ofs <= 0) ofs = maxOfs;
      }
      if (ofs > maxOfs) ofs = maxOfs;
      final t = lastOfs;
      lastOfs = hint - ofs;
      ofs = hint - t;
    } else {
      final maxOfs = len - hint;
      while (ofs < maxOfs && _cmp(key, arr[base + hint + ofs]) >= 0) {
        lastOfs = ofs;
        ofs = (ofs << 1) + 1;
        if (ofs <= 0) ofs = maxOfs;
      }
      if (ofs > maxOfs) ofs = maxOfs;
      lastOfs += hint;
      ofs += hint;
    }
    lastOfs++;
    while (lastOfs < ofs) {
      final m = lastOfs + ((ofs - lastOfs) >>> 1);
      if (_cmp(key, arr[base + m]) < 0) {
        ofs = m;
      } else {
        lastOfs = m + 1;
      }
    }
    return ofs;
  }

  void _mergeAt(int i) {
    var base1 = runBase[i], len1 = runLen[i];
    final base2 = runBase[i + 1];
    var len2 = runLen[i + 1];
    runLen[i] = len1 + len2;
    if (i == runBase.length - 3) {
      runBase[i + 1] = runBase[i + 2];
      runLen[i + 1] = runLen[i + 2];
    }
    runBase.removeLast();
    runLen.removeLast();

    final k = _gallopRight(a[base2], a, base1, len1, 0);
    base1 += k;
    len1 -= k;
    if (len1 == 0) return;
    len2 = _gallopLeft(a[base1 + len1 - 1], a, base2, len2, len2 - 1);
    if (len2 == 0) return;
    if (len1 <= len2) {
      _mergeLo(base1, len1, base2, len2);
    } else {
      _mergeHi(base1, len1, base2, len2);
    }
  }

  void _mergeLo(int base1, int len1, int base2, int len2) {
    _acopy(a, base1, tmp, 0, len1);
    var cursor1 = 0, cursor2 = base2, dest = base1;
    a[dest++] = a[cursor2++];
    if (--len2 == 0) {
      _acopy(tmp, cursor1, a, dest, len1);
      return;
    }
    if (len1 == 1) {
      _acopy(a, cursor2, a, dest, len2);
      a[dest + len2] = tmp[cursor1];
      return;
    }
    var mg = minGallop;
    outer:
    while (true) {
      var count1 = 0, count2 = 0;
      do {
        if (_cmp(a[cursor2], tmp[cursor1]) < 0) {
          a[dest++] = a[cursor2++];
          count2++;
          count1 = 0;
          if (--len2 == 0) break outer;
        } else {
          a[dest++] = tmp[cursor1++];
          count1++;
          count2 = 0;
          if (--len1 == 1) break outer;
        }
      } while ((count1 | count2) < mg);
      do {
        count1 = _gallopRight(a[cursor2], tmp, cursor1, len1, 0);
        if (count1 != 0) {
          _acopy(tmp, cursor1, a, dest, count1);
          dest += count1;
          cursor1 += count1;
          len1 -= count1;
          if (len1 <= 1) break outer;
        }
        a[dest++] = a[cursor2++];
        if (--len2 == 0) break outer;
        count2 = _gallopLeft(tmp[cursor1], a, cursor2, len2, 0);
        if (count2 != 0) {
          _acopy(a, cursor2, a, dest, count2);
          dest += count2;
          cursor2 += count2;
          len2 -= count2;
          if (len2 == 0) break outer;
        }
        a[dest++] = tmp[cursor1++];
        if (--len1 == 1) break outer;
        mg--;
      } while (count1 >= _minGallopConst || count2 >= _minGallopConst);
      if (mg < 0) mg = 0;
      mg += 2;
    }
    minGallop = mg < 1 ? 1 : mg;
    if (len1 == 1) {
      _acopy(a, cursor2, a, dest, len2);
      a[dest + len2] = tmp[cursor1];
    } else {
      _acopy(tmp, cursor1, a, dest, len1);
    }
  }

  void _mergeHi(int base1, int len1, int base2, int len2) {
    _acopy(a, base2, tmp, 0, len2);
    var cursor1 = base1 + len1 - 1, cursor2 = len2 - 1, dest = base2 + len2 - 1;
    a[dest--] = a[cursor1--];
    if (--len1 == 0) {
      _acopy(tmp, 0, a, dest - (len2 - 1), len2);
      return;
    }
    if (len2 == 1) {
      dest -= len1;
      cursor1 -= len1;
      _acopy(a, cursor1 + 1, a, dest + 1, len1);
      a[dest] = tmp[cursor2];
      return;
    }
    var mg = minGallop;
    outer:
    while (true) {
      var count1 = 0, count2 = 0;
      do {
        if (_cmp(tmp[cursor2], a[cursor1]) < 0) {
          a[dest--] = a[cursor1--];
          count1++;
          count2 = 0;
          if (--len1 == 0) break outer;
        } else {
          a[dest--] = tmp[cursor2--];
          count2++;
          count1 = 0;
          if (--len2 == 1) break outer;
        }
      } while ((count1 | count2) < mg);
      do {
        count1 = len1 - _gallopRight(tmp[cursor2], a, base1, len1, len1 - 1);
        if (count1 != 0) {
          dest -= count1;
          cursor1 -= count1;
          _acopy(a, cursor1 + 1, a, dest + 1, count1);
          len1 -= count1;
          if (len1 == 0) break outer;
        }
        a[dest--] = tmp[cursor2--];
        if (--len2 == 1) break outer;
        count2 = len2 - _gallopLeft(a[cursor1], tmp, 0, len2, len2 - 1);
        if (count2 != 0) {
          dest -= count2;
          cursor2 -= count2;
          _acopy(tmp, cursor2 + 1, a, dest + 1, count2);
          len2 -= count2;
          if (len2 <= 1) break outer;
        }
        a[dest--] = a[cursor1--];
        if (--len1 == 0) break outer;
        mg--;
      } while (count1 >= _minGallopConst || count2 >= _minGallopConst);
      if (mg < 0) mg = 0;
      mg += 2;
    }
    minGallop = mg < 1 ? 1 : mg;
    if (len2 == 1) {
      dest -= len1;
      cursor1 -= len1;
      _acopy(a, cursor1 + 1, a, dest + 1, len1);
      a[dest] = tmp[cursor2];
    } else {
      _acopy(tmp, 0, a, dest - (len2 - 1), len2);
    }
  }

  void sort() {
    var lo = 0;
    final hi = a.length;
    var nRemaining = hi;
    if (nRemaining < 2) return;
    if (nRemaining < _minMerge) {
      final initRun = _countRun(lo, hi);
      _binInsSort(lo, hi, lo + initRun);
      return;
    }
    final minRun = _minRunLength(nRemaining);
    do {
      var cRun = _countRun(lo, hi);
      if (cRun < minRun) {
        final force = nRemaining <= minRun ? nRemaining : minRun;
        _binInsSort(lo, lo + force, lo + cRun);
        cRun = force;
      }
      _pushRun(lo, cRun);
      _mergeCollapse();
      lo += cRun;
      nRemaining -= cRun;
    } while (nRemaining != 0);
    _mergeForceCollapse();
  }
}

/// עותק ממוין של msgs לפי `.at`, זהת-ביט ל-`[...msgs].sort(...)` של V8 — כולל
/// spread-מחרוזת, comparator-אפס על תווים, ומיון-TimSort (יציב + נאמן לקומפרטור
/// לא-טרנזיטיבי). המקור: new/atoms/sort-support-msgs.mjs.
dynamic sortSupportMsgs(dynamic msgs) {
  final list = _spread(msgs);
  _Tim(list).sort();
  return list;
}
