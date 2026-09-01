// 🗄️ חנות-מצב חיה (חוט-טהור) — מודל-נתונים אמיתי לאפליקציה. כל רשומה נושאת מזהה
// יציב (__id), נגישה לפי-מזהה (לא לפי-אינדקס), ומפתח-זר מצביע במזהה — לא במחרוזת-תצוגה.
// שמירה · עדכון · מחיקה · קידום-מסע · צבירה — הכל מגיב לאותו מקור-אמת (ChangeNotifier).
import 'dart:convert';
import 'package:flutter/foundation.dart';
// גבול-הפלטפורמה מבודד ב-conditional-import: web ⇒ localStorage · אחר ⇒ no-op (טהור).
import 'ds_persist_stub.dart' if (dart.library.js_interop) 'ds_persist_web.dart';

class AppStore extends ChangeNotifier {
  // ממופתח ב-slug יציב (app_entN) — לא בשם-תצוגה חתוך (שמנע דליפת-נתונים בין ישויות).
  final Map<String, List<Map<String, String>>> _rec = {};
  int _seq = 0;
  int _role = 0;   // התפקיד-הנבחר (נשמר בין רענונים — session רך; אימות-אמת = תשתית)

  int get role => _role;
  void setRole(int i) { _role = i; notifyListeners(); }

  // 👤 "מי-אני" רך (RLS צד-לקוח = סינון-תצוגה, לא אכיפה!). ריק ⇒ בלי-סינון (ביט-זהה).
  String _actor = '';
  String get actor => _actor;
  void setActor(String v) { _actor = v; notifyListeners(); }

  // היקף-שורה: רשומות שערך-השדה שלהן שווה ל-actor. field ריק / actor ריק ⇒ הכל (בלי-סינון).
  List<Map<String, String>> scoped(String entity, String field) =>
      (field.isEmpty || _actor.isEmpty) ? records(entity) : records(entity).where((r) => (r[field] ?? '') == _actor).toList();

  // ערכי-סינון ייחודיים לשדה (למילוי בורר-"מי-אני").
  List<String> distinctValues(String entity, String field) {
    final out = <String>{};
    for (final r in records(entity)) { final v = (r[field] ?? '').trim(); if (v.isNotEmpty) out.add(v); }
    return out.toList()..sort();
  }

  static const idKey = '__id';       // מזהה-רשומה יציב
  static const stageKey = '__stage'; // אינדקס שלב-המסע הנוכחי
  static const _pkey = 'ds_app_v1';  // מפתח-ההתמדה

  AppStore() { _load(); }

  // התמדה: טעינה בלידה, שמירה בכל שינוי (מרוכב על notifyListeners). נכשל-רך.
  void _load() {
    final raw = persistLoad(_pkey);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _seq = (data['seq'] as num?)?.toInt() ?? 0;
      _role = (data['role'] as num?)?.toInt() ?? 0;
      _actor = (data['actor'] as String?) ?? '';
      (data['rec'] as Map<String, dynamic>).forEach((k, v) {
        _rec[k] = (v as List)
            .map((e) => (e as Map).map((kk, vv) => MapEntry(kk.toString(), vv.toString())))
            .toList();
      });
    } catch (_) {}
  }

  @override
  void notifyListeners() {
    try {
      persistSave(_pkey, jsonEncode({'seq': _seq, 'role': _role, 'actor': _actor, 'rec': _rec}));
    } catch (_) {}
    super.notifyListeners();
  }

  List<Map<String, String>> records(String entity) => _rec[entity] ?? const [];
  int count(String entity) => _rec[entity]?.length ?? 0;

  Map<String, String>? byId(String entity, String id) {
    for (final r in records(entity)) {
      if (r[idKey] == id) return r;
    }
    return null;
  }

  // "שם" רשומה = הערך-הראשון-הלא-ריק שאינו מטא (לתצוגת מפתח-זר ולבורר-קשר).
  String _display(Map<String, String> r) {
    for (final e in r.entries) {
      if (e.key == idKey || e.key == stageKey) continue;
      if (e.value.trim().isNotEmpty) return e.value.trim();
    }
    return r[idKey] ?? '';
  }

  // אפשרויות לבורר-קשר: זוגות (מזהה → תצוגה). הבורר שומר מזהה, מציג תצוגה.
  List<MapEntry<String, String>> options(String entity) {
    final out = <MapEntry<String, String>>[];
    for (final r in records(entity)) {
      final id = r[idKey] ?? '';
      if (id.isNotEmpty) out.add(MapEntry(id, _display(r)));
    }
    return out;
  }

  // תצוגת מפתח-זר: מזהה מאוחסן ⇒ שם-הרשומה ביעד (ריק אם היעד נמחק — מפתח יתום גלוי).
  String displayOf(String entity, String id) {
    if (id.isEmpty) return '';
    final r = byId(entity, id);
    return r == null ? '' : _display(r);
  }

  // קשר-רבים: מחרוזת-מזהים מופרדת-פסיק ⇒ שמות-התצוגה מצורפים (', ').
  String displayList(String entity, String csv) => csv
      .split(',')
      .map((x) => x.trim())
      .where((x) => x.isNotEmpty)
      .map((id) => displayOf(entity, id))
      .where((d) => d.isNotEmpty)
      .join(', ');

  // אינדקס-הפוך (קשר-נגדי): רשומות של entity ששדה-הקשר שלהן מצביע על id.
  // מודע-CSV: קשר-יחיד ⇒ r[field]==id · קשר-רבים ⇒ id ברשימת-המזהים המופרדת-פסיק.
  // (קשר-יחיד נשאר ביט-זהה — ערך-יחיד בלי פסיק split-ל-[ערך] שמכיל את עצמו.)
  List<Map<String, String>> referencing(String entity, String field, String id) =>
      records(entity).where((r) {
        final v = r[field] ?? '';
        return v == id || v.split(',').map((x) => x.trim()).contains(id);
      }).toList();

  int stageOf(String entity, String id) {
    final r = byId(entity, id);
    return int.tryParse(r?[stageKey] ?? '0') ?? 0;
  }

  // צבירה טיפוסית (בסיס לדשבורדי-מדדים אמיתיים): סכום/ממוצע/מונה על שדה מספרי.
  double sum(String entity, String field) {
    var t = 0.0;
    for (final r in records(entity)) {
      t += double.tryParse((r[field] ?? '').replaceAll(RegExp(r'[^0-9.\-]'), '')) ?? 0;
    }
    return t;
  }

  double avg(String entity, String field) {
    final n = count(entity);
    return n == 0 ? 0 : sum(entity, field) / n;
  }

  // ── שדה-צבירה (Rollup): אגרגט חי על רשומות-הבן שמצביעות על id-ההורה, דרך referencing
  //    (מודע-CSV). נגזרת טהורה פר-רשומת-הורה — קריאה-בלבד, לא-מתמיד.
  double sumRef(String child, String field, String pid, String col) {
    var t = 0.0;
    for (final r in referencing(child, field, pid)) {
      t += double.tryParse((r[col] ?? '').replaceAll(RegExp(r'[^0-9.\-]'), '')) ?? 0;
    }
    return t;
  }

  int countRef(String child, String field, String pid) => referencing(child, field, pid).length;

  double avgRef(String child, String field, String pid, String col) {
    final n = countRef(child, field, pid);
    return n == 0 ? 0 : sumRef(child, field, pid, col) / n;
  }

  String add(String entity, Map<String, String> record) {
    final id = 'r${++_seq}';
    final rec = <String, String>{idKey: id, ...record};
    (_rec[entity] ??= <Map<String, String>>[]).add(rec);
    notifyListeners();
    return id;
  }

  void update(String entity, String id, Map<String, String> values) {
    final r = byId(entity, id);
    if (r == null) return;
    values.forEach((k, v) {
      if (k != idKey) r[k] = v;
    });
    notifyListeners();
  }

  void advance(String entity, String id, int stageCount) {
    final r = byId(entity, id);
    if (r == null) return;
    final cur = int.tryParse(r[stageKey] ?? '0') ?? 0;
    if (cur + 1 < stageCount) {
      r[stageKey] = '${cur + 1}';
      notifyListeners();
    }
  }

  // קפיצה לכל שלב (מסע לא-ליניארי — כולל דחייה/חזרה/הסתעפות).
  void setStage(String entity, String id, int i) {
    final r = byId(entity, id);
    if (r == null || i < 0) return;
    r[stageKey] = '$i';
    notifyListeners();
  }

  // ── שלמות-קשר (Referential Integrity) — גרף-הקשרים נרשם בלידה כ-data (מבנה, לא-מתמיד).
  //    ‏policy: 0=חסימה(restrict) · 1=מפל(cascade) · 2=ניתוק(set-null). אין-קשר-רשום ⇒
  //    removeById מתנהג כמקודם (מחיקה-עיוורת) ⇒ ביט-זהה לאפליקציה בלי '| מחיקה:'.
  final List<_Rel> _rels = [];
  void registerRelation(String child, String field, String parent, int policy, {bool multi = false}) {
    _rels.add(_Rel(child, field, parent, policy, multi));
  }

  // חברוּת: האם רשומת-ילד מצביעה על id (יחיד: שוויון · רבים: id ברשימה מופרדת-פסיק).
  bool _pointsAt(Map<String, String> r, String field, String id, bool multi) {
    final v = r[field] ?? '';
    return multi ? v.split(',').map((x) => x.trim()).contains(id) : v == id;
  }

  // כמה רשומות מצביעות על (parent,id) בכל הקשרים הרשומים.
  int inboundRefs(String parent, String id) {
    var n = 0;
    for (final rel in _rels) {
      if (rel.parent != parent) continue;
      for (final r in records(rel.child)) {
        if (_pointsAt(r, rel.field, id, rel.multi)) n++;
      }
    }
    return n;
  }

  // המדיניות החמורה-ביותר על מחיקת parent (חסימה גוברת). אין-קשר ⇒ null.
  int? policyOf(String parent) {
    int? p;
    for (final rel in _rels) {
      if (rel.parent != parent) continue;
      if (rel.policy == 0) return 0;
      p = rel.policy;
    }
    return p;
  }

  void _pull(Map<String, String> r, String field, String id) {
    r[field] = (r[field] ?? '').split(',').map((x) => x.trim()).where((x) => x.isNotEmpty && x != id).join(',');
  }

  // מחיקה עם אכיפת-שלמות (מחזיר: הצליח?). חסימה ⇒ false בלי-מוטציה · מפל ⇒ מוחק/מנתק
  // ילדים (רבים: מסיר-מהרשימה, לא מוחק-שורה) · ניתוק ⇒ מנקה את המפתח-הזר. שומר-מחזור.
  bool removeById(String entity, String id, [Set<String>? seen]) {
    seen ??= <String>{};
    if (!seen.add('$entity/$id')) return true;   // כבר בטיפול (מחזור)
    for (final rel in _rels) {
      if (rel.parent != entity) continue;
      final refs = records(rel.child).where((r) => _pointsAt(r, rel.field, id, rel.multi)).toList();
      if (refs.isEmpty) continue;
      if (rel.policy == 0) return false;                        // חסימה
      for (final r in refs) {
        if (rel.policy == 1 && !rel.multi) {
          removeById(rel.child, r[idKey] ?? '', seen);          // מפל — יחיד: מחיקה רקורסיבית
        } else {
          _pull(r, rel.field, id);                              // מפל-רבים / ניתוק — מסיר מהרשימה/מנקה
          if (rel.policy == 2 && !rel.multi) r[rel.field] = '';
        }
      }
    }
    _rec[entity]?.removeWhere((r) => r[idKey] == id);
    notifyListeners();
    return true;
  }
}

// קשר-רשום (ילד.מפתח ⇒ הורה, + מדיניות-מחיקה). נבנה בלידה מקובץ-הרישום המחולל.
class _Rel {
  const _Rel(this.child, this.field, this.parent, this.policy, this.multi);
  final String child, field, parent;
  final int policy;
  final bool multi;
}

// מקור-אמת יחיד לאפליקציה כולה (חוצה-מסכים דרך ה-Navigator).
final AppStore appStore = AppStore();
