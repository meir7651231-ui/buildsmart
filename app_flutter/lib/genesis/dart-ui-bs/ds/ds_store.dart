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

  // ── G51 · בריאות-האחסון (הכרעת-הביקורת 10.9): כשל-שמירה ואי-קריאות אסור שיהיו שקטים.
  //    _saveOk=false ⇒ עבודה שלא נשמרה (מכסה מלאה / אחסון חסום) · _blocked=true ⇒ הבלוב
  //    הקיים לא נקרא, הכתיבה מושהית כדי לא לדרוס אותו, והעותק נשמר תחת '<key>.corrupt'.
  bool _saveOk = true, _blocked = false;
  bool get storageOk => _saveOk;
  bool get storageBlocked => _blocked;
  /// המשתמש הכריע «התחל חדש» — משחרר את חסימת-הכתיבה (העותק הפגום נשאר שמור).
  void clearStorageBlock() { _blocked = false; notifyListeners(); }

  // ── G32 · שכבת-הטריגרים (הכרעה-28): יומן-פעולות (אוטומטיות/שליחה, עם החזר) · זיכרון-הכרעות (אשר/דחה/תמיד) · הגדרות-התנהגות — באותו JSON ──
  final List<Map<String, String>> _log = [];
  String _group = '';
  /// ב׳-צג · פעולה-מרוכזת: כל שורות-היומן שנכתבות בתוך body חולקות group אחד ⇒ «החזר» אחד מחזיר את כולן (גם «סיים» שיצר רגע-חוזר)
  void grouped(void Function() body) { _group = 'g' + DateTime.now().microsecondsSinceEpoch.toString(); try { body(); } finally { _group = ''; } }
  final Map<String, String> _decided = {};
  final Map<String, String> _settings = {};
  List<Map<String, String>> get log => List.unmodifiable(_log);
  String decision(String key) => _decided[key] ?? '';
  void decide(String key, String v) { _decided[key] = v; notifyListeners(); }
  String setting(String key, [String def = '']) => (_settings[key] ?? '').isEmpty ? def : _settings[key]!;
  void setSetting(String key, String v) { _settings[key] = v; notifyListeners(); }
  /// רישום פעולה: kind = auto (לבד) · decide (הכרעה שניתן להחזיר) · send (שליחה החוצה) · next (צעד-הבא). prev/field = מה להחזיר.
  String logAction(String kind, String what, {String entity = '', String rid = '', String field = '', String prev = '', String group = ''}) {
    final id = 'l${++_seq}';
    _log.insert(0, {'id': id, 'at': DateTime.now().toIso8601String(), 'kind': kind, 'what': what, 'entity': entity, 'rid': rid, 'field': field, 'prev': prev, 'undone': '', if ((group.isNotEmpty ? group : _group).isNotEmpty) 'group': group.isNotEmpty ? group : _group});   // ב׳-פז · group: פעולה-מרוכזת ⇒ החזר אחד לכולן
    if (_log.length > 200) _log.removeRange(200, _log.length);
    notifyListeners(); return id;
  }
  /// החזר: משחזר שדה-רשומה (entity+rid+field ⇒ prev) או מוחק הכרעה (kind=decide: field = מפתח-ההכרעה).
  bool undo(String logId) {
    final i = _log.indexWhere((x) => x['id'] == logId);
    if (i < 0 || _log[i]['undone'] == '1') return false;
    final e = _log[i];
    if ((e['kind'] ?? '') == 'decide') { _decided.remove(e['field']); for (final k in (e['prev'] ?? '').split(',')) { if (k.isNotEmpty) _decided.remove(k); } }   /* ב׳-לז · הכרעה-מרוכזת: מפתחות נוספים ב-prev, החזר אחד מוחק את כולן */
    else if ((e['kind'] ?? '') == 'add') { removeById(e['entity'] ?? '', e['rid'] ?? ''); }   // החזר של שמירה = מחיקת הרשומה
    else if ((e['kind'] ?? '') == 'del') { if (!restoreSubtree(e['prev'] ?? '')) { try { final m = (jsonDecode(e['prev'] ?? '{}') as Map).map((k, v) => MapEntry(k.toString(), v.toString())); restore(e['entity'] ?? '', m); } catch (_) {} } }   // G51 · תת-עץ מלא (צאצאים+שדות-מנוקים); פורמט-ישן ⇒ נפילה לרשומה-בודדת
    else if ((e['kind'] ?? '') == 'merge') { final r = byId(e['entity'] ?? '', e['rid'] ?? ''); if (r != null) { try { ((jsonDecode(e['prev'] ?? '{}') as Map)).forEach((k, v) { r[k.toString()] = v.toString(); }); } catch (_) {} } }   // undo of a merge: every touched field goes back (prev = JSON map)
    else if ((e['kind'] ?? '') == 'done') { _decided.remove('ign:${e['rid']}:${e['field']}'); final r = byId(e['entity'] ?? '', e['rid'] ?? ''); if (r != null && (e['prev'] ?? '').isNotEmpty) r[stageKey] = e['prev']!; }   // undo of «done»: the date row returns and the stage goes back
    else if ((e['entity'] ?? '').isNotEmpty && (e['field'] ?? '').isNotEmpty) { final r = byId(e['entity']!, e['rid'] ?? ''); if (r != null) r[e['field']!] = e['prev'] ?? ''; }
    e['undone'] = '1';
    final g = e['group'] ?? ''; if (g.isNotEmpty) { for (final x in _log.where((x) => (x['group'] ?? '') == g && x['undone'] != '1').toList()) { undo(x['id'] ?? ''); } }   // ב׳-פז · החזר-קבוצתי: «דחה הכל למחר» חוזר בהקשה אחת
    notifyListeners(); return true;
  }
  Map<String, String>? lastLog(String kind, String rid) { for (final x in _log) { if (x['kind'] == kind && x['rid'] == rid && x['undone'] != '1') return x; } return null; }

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
      for (final e in (data['log'] as List? ?? const [])) _log.add((e as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
      ((data['decided'] as Map?) ?? const {}).forEach((k, v) => _decided[k.toString()] = v.toString());
      ((data['settings'] as Map?) ?? const {}).forEach((k, v) => _settings[k.toString()] = v.toString());
      (data['rec'] as Map<String, dynamic>).forEach((k, v) {
        _rec[k] = (v as List)
            .map((e) => (e as Map).map((kk, vv) => MapEntry(kk.toString(), vv.toString())))
            .toList();
      });
    } catch (_) {
      // G51 · בלוב קיים שלא נקרא: שומרים עותק וחוסמים כתיבה. בלי זה הכתיבה הבאה דורסת אותו לתמיד.
      persistSave('\$_pkey.corrupt', raw);
      _blocked = true;
    }
  }

  /// Backup as text (same JSON as persistence). Restore replaces everything; the previous state is kept once for undo.
  String exportJson() => jsonEncode({'seq': _seq, 'role': _role, 'actor': _actor, 'rec': _rec, 'log': _log, 'decided': _decided, 'settings': _settings});
  int importJson(String raw) {
    Map<String, dynamic> data;
    try { data = jsonDecode(raw) as Map<String, dynamic>; } catch (_) { return -1; }
    if (data['rec'] is! Map) return -1;
    // G51 · אין דרך-חזרה ⇒ לא משחזרים. (-2 = «לא הצלחתי לשמור עותק»; קודם המחיקה קרתה בכל מקרה.)
    final back = exportJson();
    final backOk = persistSave('\$_pkey.prev', back); final backRead = persistLoad('\$_pkey.prev');
    if (!backOk || (backRead != null && backRead != back)) return -2;   // readback==null = שכבה ללא-התמדה (בדיקות) ⇒ לא כשל
    _rec.clear(); _log.clear(); _decided.clear(); _settings.clear();
    _seq = (data['seq'] as num?)?.toInt() ?? 0; _role = (data['role'] as num?)?.toInt() ?? 0; _actor = (data['actor'] as String?) ?? '';
    for (final e in (data['log'] as List? ?? const [])) _log.add((e as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
    ((data['decided'] as Map?) ?? const {}).forEach((k, v) => _decided[k.toString()] = v.toString());
    ((data['settings'] as Map?) ?? const {}).forEach((k, v) => _settings[k.toString()] = v.toString());
    (data['rec'] as Map<String, dynamic>).forEach((k, v) { _rec[k] = (v as List).map((e) => (e as Map).map((kk, vv) => MapEntry(kk.toString(), vv.toString()))).toList(); });
    notifyListeners();
    return _rec.values.fold<int>(0, (a, b) => a + b.length);
  }
  bool undoImport() { final prev = persistLoad('\$_pkey.prev'); if (prev == null || prev.isEmpty) return false; final n = importJson(prev); return n >= 0; }
  /// Text search across every entity: any value containing q (case-insensitive). Returns (entity, id, matching value).
  List<List<String>> search(String q) {
    final needle = q.trim().toLowerCase(); if (needle.length < 2) return const [];
    final digits = RegExp(r'^[0-9][0-9,.\- ]*$').hasMatch(needle) ? needle.replaceAll(RegExp(r'[^0-9]'), '') : '';   // ב׳-צב · שאילתת-ספרות ⇒ גם התאמה ספרות-מול-ספרות (סכום עם פסיקים · טלפון עם מקפים)
    final out = <List<String>>[];
    _rec.forEach((entity, rows) { for (final r in rows) { for (final e in r.entries) { if (e.key == AppStore.idKey || e.key == '__doc' || e.key == '__at' || e.key == '__stage') continue; if (e.value.toLowerCase().contains(needle) || (digits.length >= 2 && e.value.replaceAll(RegExp(r'[^0-9]'), '').contains(digits))) { out.add([entity, r[AppStore.idKey] ?? '', e.value]); break; } } } });
    return out;
  }

  @override
  void notifyListeners() {
    if (_blocked) { super.notifyListeners(); return; }   // G51 · לא דורסים בלוב שלא נקרא
    try {
      _saveOk = persistSave(_pkey, jsonEncode({'seq': _seq, 'role': _role, 'actor': _actor, 'rec': _rec, 'log': _log, 'decided': _decided, 'settings': _settings}));
    } catch (_) { _saveOk = false; }   // G51 · כשל-שמירה נראה במסך, לא נבלע
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
      if (e.key == idKey || e.key == stageKey || e.key.startsWith('__')) continue;   // מטא (__at · __doc · __note) אינו שם-תצוגה
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
    final rec = <String, String>{idKey: id, '__at': DateTime.now().toIso8601String().substring(0, 10), ...record};   // G33 · חותמת-יצירה (תיק שעומד בלי תנועה)
    (_rec[entity] ??= <Map<String, String>>[]).add(rec);
    notifyListeners();
    return id;
  }

  /// Put a record back exactly as it was (undo of a delete): same id, same fields, at the end of the list.
  // ── G51 · החזר-מחיקה מלא: removeById מוחק במפל גם צאצאים (וגם מנקה שדות-מצביעים);
  //    צילום-הרשומה-לבדה החזיר רק את האב והבנות אבדו לתמיד. כאן מצלמים את כל תת-העץ.
  void _snap(String entity, String id, Set<String> seen, Map<String, List<Map<String, String>>> acc) {
    if (!seen.add('$entity/$id')) return;
    final r0 = byId(entity, id);
    if (r0 != null) (acc[entity] ??= <Map<String, String>>[]).add(Map<String, String>.from(r0));
    for (final rel in _rels) {
      if (rel.parent != entity) continue;
      for (final r in records(rel.child).where((r) => _pointsAt(r, rel.field, id, rel.multi)).toList()) {
        final cid = r[idKey] ?? '';
        if (rel.policy == 1 && !rel.multi) { _snap(rel.child, cid, seen, acc); }
        else if (seen.add('${rel.child}/$cid')) { (acc[rel.child] ??= <Map<String, String>>[]).add(Map<String, String>.from(r)); }
      }
    }
  }
  /// צילום כל מה שמחיקת (entity,id) תמחק או תשנה ⇒ JSON להחזר מלא.
  String snapshotSubtree(String entity, String id) {
    final acc = <String, List<Map<String, String>>>{};
    _snap(entity, id, <String>{}, acc);
    return jsonEncode({'e': entity, 'id': id, 'rows': acc});
  }
  /// שחזור תת-עץ מצילום. רשומה שנמחקה חוזרת; רשומה ששרדה מקבלת בחזרה את השדות שנוקו. פורמט-ישן ⇒ false.
  bool restoreSubtree(String raw) {
    try {
      final rows = (jsonDecode(raw) as Map<String, dynamic>)['rows'];
      if (rows is! Map) return false;
      rows.forEach((ent, list) {
        final e = ent.toString();
        for (final row in (list as List)) {
          final m = (row as Map).map((k, v) => MapEntry(k.toString(), v.toString()));
          final id = m[idKey] ?? ''; if (id.isEmpty) continue;
          final cur = byId(e, id);
          if (cur == null) { (_rec[e] ??= <Map<String, String>>[]).add(m); } else { m.forEach((k, v) { cur[k] = v; }); }
        }
      });
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  void restore(String entity, Map<String, String> record) {
    final id = record[idKey] ?? ''; if (id.isEmpty) return;
    final list = _rec[entity] ??= <Map<String, String>>[];
    if (list.any((r) => r[idKey] == id)) return;
    list.add(Map<String, String>.from(record)); notifyListeners();
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
