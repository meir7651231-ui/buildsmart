// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «מה קרה?»: שורה/הדבקה/צילום ⇒ זיהוי-הרגע (דטרמיניסטי) ⇒ «הבנתי כך?» ⇒ טופס-השורש של המודול ממולא-מראש. צילום נקרא רק עם מפתח-הלקוח (ds_ai). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_ask_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_ai.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds_voice.dart';
import 'gen_balagan_confirm.dart';
import 'gen_balagan_home.dart';
import 'gen_balagan_moments.dart';
import 'gen_app_calendar_ent1.dart';
import 'gen_app_tasks_ent2.dart';
import 'gen_app_peruk01_ent1.dart';
import 'gen_app_peruk02_ent1.dart';
import 'gen_app_peruk03_ent1.dart';
import 'gen_app_peruk04_ent1.dart';
import 'gen_app_peruk05_ent1.dart';
import 'gen_app_peruk06_ent1.dart';
import 'gen_app_peruk07_ent1.dart';
import 'gen_app_peruk08_ent1.dart';
import 'gen_app_peruk09_ent1.dart';
import 'gen_app_peruk10_ent1.dart';
import 'gen_app_peruk11_ent1.dart';
import 'gen_app_peruk12_ent1.dart';
import 'gen_app_peruk13_ent1.dart';
import 'gen_app_peruk14_ent1.dart';
import 'gen_app_peruk15_ent1.dart';
import 'gen_app_peruk16_ent1.dart';
import 'gen_app_peruk17_ent1.dart';
import 'gen_app_peruk18_ent1.dart';
import 'gen_app_peruk19_ent1.dart';
import 'gen_app_peruk20_ent1.dart';
import 'gen_app_peruk21_ent1.dart';
import 'gen_app_peruk22_ent1.dart';
import 'gen_app_peruk23_ent1.dart';
import 'gen_app_peruk24_ent1.dart';
import 'gen_app_peruk25_ent1.dart';
import 'gen_app_peruk26_ent1.dart';
import 'gen_app_peruk27_ent1.dart';
import 'gen_app_peruk28_ent1.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Widget balaganOpen(int index, Map<String, String> initial) {
  switch (index) {
    case 0: return GenAppCalendarEnt1Screen(initial: initial);
    case 1: return GenAppTasksEnt2Screen(initial: initial);
    case 2: return GenAppPeruk01Ent1Screen(initial: initial);
    case 3: return GenAppPeruk02Ent1Screen(initial: initial);
    case 4: return GenAppPeruk03Ent1Screen(initial: initial);
    case 5: return GenAppPeruk04Ent1Screen(initial: initial);
    case 6: return GenAppPeruk05Ent1Screen(initial: initial);
    case 7: return GenAppPeruk06Ent1Screen(initial: initial);
    case 8: return GenAppPeruk07Ent1Screen(initial: initial);
    case 9: return GenAppPeruk08Ent1Screen(initial: initial);
    case 10: return GenAppPeruk09Ent1Screen(initial: initial);
    case 11: return GenAppPeruk10Ent1Screen(initial: initial);
    case 12: return GenAppPeruk11Ent1Screen(initial: initial);
    case 13: return GenAppPeruk12Ent1Screen(initial: initial);
    case 14: return GenAppPeruk13Ent1Screen(initial: initial);
    case 15: return GenAppPeruk14Ent1Screen(initial: initial);
    case 16: return GenAppPeruk15Ent1Screen(initial: initial);
    case 17: return GenAppPeruk16Ent1Screen(initial: initial);
    case 18: return GenAppPeruk17Ent1Screen(initial: initial);
    case 19: return GenAppPeruk18Ent1Screen(initial: initial);
    case 20: return GenAppPeruk19Ent1Screen(initial: initial);
    case 21: return GenAppPeruk20Ent1Screen(initial: initial);
    case 22: return GenAppPeruk21Ent1Screen(initial: initial);
    case 23: return GenAppPeruk22Ent1Screen(initial: initial);
    case 24: return GenAppPeruk23Ent1Screen(initial: initial);
    case 25: return GenAppPeruk24Ent1Screen(initial: initial);
    case 26: return GenAppPeruk25Ent1Screen(initial: initial);
    case 27: return GenAppPeruk26Ent1Screen(initial: initial);
    case 28: return GenAppPeruk27Ent1Screen(initial: initial);
    case 29: return GenAppPeruk28Ent1Screen(initial: initial);
    default: return const SizedBox.shrink();
  }
}

class GenBalaganAskScreen extends StatefulWidget {
  const GenBalaganAskScreen({this.initialText = '', this.autoPhoto = false, super.key});
  final String initialText;   // שיתוף (share_target ?text=) / הדבקה ⇒ נכנס לשדה ומזוהה מיד
  final bool autoPhoto;   // G54 · §7 «צלם מסמך»: נכנסים ישר למצלמה, בלי לחפש את הכפתור בתוך המסך
  @override
  State<GenBalaganAskScreen> createState() => _GenBalaganAskScreenState();
}

class _GenBalaganAskScreenState extends State<GenBalaganAskScreen> {
  final _c = TextEditingController();
  @override
  void initState() { super.initState(); if (widget.autoPhoto) { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _photo(); }); } if (widget.initialText.trim().isNotEmpty) { _c.text = widget.initialText.trim(); _note = gen_balagan_ask_c0; WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _go(); }); } }   // הגיע משיתוף ⇒ אפס-הקשות עד טופס-האישור
  Future<void> _voice() async {   // «דבר»: זיהוי-דיבור של הדפדפן (he-IL) ⇒ השדה ⇒ זיהוי — אפס-הקלדה; לא נתמך/לא שמע ⇒ הודעה כנה
    if (!voiceSupported) { setState(() => _note = gen_balagan_ask_c1); return; }
    setState(() { _busy = true; _note = gen_balagan_ask_c2; });
    final t = await voiceListen('he-IL');
    if (!mounted) return;
    setState(() { _busy = false; _note = (t == null || t.isEmpty) ? gen_balagan_ask_c3 : ''; });
    if (t != null && t.isNotEmpty) { _c.text = t; _go(); }
  }
  Future<void> _paste() async { final d = await Clipboard.getData('text/plain'); final t = (d?.text ?? '').trim(); if (t.isEmpty) { setState(() => _note = gen_balagan_ask_c4); return; } _c.text = t; _go(); }   // «הדבק» = הקשה אחת מהודעה שהועתקה
  List<BalaganHit> _hits = const [];
  Map<String, String> _extra = const {};
  String _doc = '';   // data:URI של הצילום (מוקטן) — נשמר עם הרשומה (מחסנית-מסמכים)
  bool _asked = false, _busy = false;
  String _note = '';

  void _go() { final hits = balaganIdentify(balaganSplit(_c.text).first); setState(() { _asked = true; _hits = hits; _note = hits.isEmpty ? gen_balagan_ask_c5 : ''; }); if (hits.isNotEmpty) _open(context, hits.first, hits.skip(1).map((h) => h.module).toList()); }   // הקשה אחת: זיהוי ⇒ ישר לטופס-האישור (החלופות בתוכו)
  void _skip() { setState(() { _hits = _hits.length > 1 ? _hits.sublist(1) : const []; if (_hits.isEmpty) _note = gen_balagan_ask_c6; }); }
  void _open(BuildContext context, BalaganHit h, [List<BalaganModule> alts = const []]) {
    final parts = balaganSplit(_c.text); final first = parts.first;
    final facts = {...balaganFacts(first, h.module), ..._extra}..removeWhere((key, v) => v.trim().isEmpty || !(h.module.dateFields.contains(key) || h.module.numFields.contains(key) || h.module.timeFields.contains(key) || h.module.phoneFields.contains(key) || h.module.personFields.contains(key) || h.module.percentFields.contains(key) || key == h.module.descField || key == h.module.longField || key.startsWith('__')));
    Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: h.module, facts: facts, doc: _doc, alternatives: alts, text: first, queue: parts.sublist(1)))).then((saved) { if (saved == true && mounted) setState(() { _c.clear(); _hits = const []; _extra = const {}; _doc = ''; _asked = false; _note = gen_balagan_ask_c7; }); });
  }
  Future<void> _photo() async {
    final key = appStore.setting('ai.key');
    if (key.isEmpty) { setState(() => _note = gen_balagan_ask_c8); return; }
    final x = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 60, maxWidth: 900);   // G56 · §7 «צלם מסמך»: בדפדפן-נייד זה פותח את המצלמה (capture); בשולחני נופל לבורר-קבצים — לא מוותרים על המצלמה בכל הפלטפורמות בגלל השולחני
    if (x == null) return;
    setState(() { _busy = true; _note = gen_balagan_ask_c9; });
    final bytes = await x.readAsBytes();
    _doc = bytes.length <= 160000 ? 'data:' + (x.mimeType ?? 'image/jpeg') + ';base64,' + base64Encode(bytes) : '';   // ≤160KB במכשיר; גדול ⇒ רק התמלול (כנות במסך)
    final r = await dsAiExtract(apiKey: key, image: bytes, imageMime: x.mimeType ?? 'image/jpeg', fields: const ['תאריך', 'סכום', 'שם'], model: appStore.setting('ai.model', 'claude-sonnet-5'));
    if (!mounted) return;
    if (r == null) { setState(() { _busy = false; _note = gen_balagan_ask_c10; }); return; }
    final text = (r['_text'] ?? '').trim();
    final extra = <String, String>{for (final e in r.entries) if (e.key != '_text' && e.value.trim().isNotEmpty) e.key: e.value};
    // G56 · מעבר שני: אחרי שהמסמך זוהה — חילוץ מול **השדות האמיתיים של אותו מודול**.
    //   בלעדיו הצילום מילא שלושה שדות גנריים (תאריך · סכום · שם) וטופס-האישור הגיע כמעט ריק.
    final hits0 = text.isEmpty ? const <BalaganHit>[] : balaganIdentify(balaganSplit(text).first);
    if (hits0.isNotEmpty) {
      final labels = [for (final f in hits0.first.module.fields) f.label];
      final r2 = await dsAiExtract(apiKey: key, image: bytes, imageMime: x.mimeType ?? 'image/jpeg', fields: labels, model: appStore.setting('ai.model', 'claude-sonnet-5'));
      if (r2 != null) { for (final e in r2.entries) { if (e.key == '_text') continue; final v = e.value.trim(); if (v.isNotEmpty) extra[e.key] = v; } }
    }
    if (!mounted) return;
    setState(() { _busy = false; _note = _doc.isEmpty ? gen_balagan_ask_c11 : gen_balagan_ask_c12; if (text.isNotEmpty) _c.text = text; _extra = extra; });
    _go();
  }

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final top = _hits.isNotEmpty ? _hits.first : null;
    return DsScaffold(title: gen_balagan_ask_c13, subtitle: gen_balagan_ask_c14, icon: gen_balagan_ask_c15, children: [
      Container(
        decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(lk.r)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(controller: _c, minLines: 3, maxLines: 8, autofocus: true, textInputAction: TextInputAction.done, style: TextStyle(color: lk.ink, fontSize: 16, height: 1.5), decoration: InputDecoration(border: InputBorder.none, hintText: gen_balagan_ask_c16, hintStyle: TextStyle(color: lk.faint)), onSubmitted: (_) => _go()),
      ),
      Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [
        Expanded(child: DsPrimaryButton(label: gen_balagan_ask_c17, onTap: _busy ? null : _go)),
        const SizedBox(width: 8),
        DsChipButton(label: gen_balagan_ask_c18, onTap: _busy ? null : _voice),
        const SizedBox(width: 8),
        DsChipButton(label: gen_balagan_ask_c19, onTap: _busy ? null : _paste),
        const SizedBox(width: 8),
        GestureDetector(onTap: _busy ? null : _photo, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(9)), child: Text(gen_balagan_ask_c20, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600)))),
      ])),
      if (!_asked && _c.text.trim().isEmpty) Padding(padding: const EdgeInsets.only(top: 14), child: Text(gen_balagan_ask_c21, style: TextStyle(color: lk.muted, fontSize: 13))),
      if (!_asked && _c.text.trim().isEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final ex in gen_balagan_ask_c22.split('|')) DsChipButton(label: ex, onTap: () { _c.text = ex; _go(); })])),   // אפס-הקלדה: דוגמה = הקשה אחת ⇒ טופס-האישור
      if (!_asked && _c.text.trim().isEmpty) for (final people in [balaganPeople()]) if (people.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final p in people) DsChipButton(label: p + ':', onTap: () => setState(() { _c.text = p + ': '; }))])),   // ב׳-ס · «רות לוי: » — השורה מתחילה מהאדם, בלי להקליד שם
      if (!_asked && _c.text.trim().isEmpty) for (final recent in [appStore.log.where((e) => e['kind'] == 'add' && e['undone'] != '1' && (e['entity'] ?? '').isNotEmpty && appStore.byId(e['entity'] ?? '', e['rid'] ?? '') != null).take(3).toList()]) if (recent.isNotEmpty) DsSection(title: gen_balagan_ask_c23, children: [for (final e in recent) DsNavTile(glyph: '', title: appStore.displayOf(e['entity'] ?? '', e['rid'] ?? ''), sub: (() { final at = DateTime.tryParse(e['at'] ?? ''); return at == null ? '' : balaganAgo(at, DateTime.now()); })(), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(e['entity'] ?? '', e['rid'] ?? ''))))]),   // ב׳-פה · «כבר הוספתי את זה?» — 3 האחרונים, הקשה ⇒ התיק
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: DsNote(message: _note, label: '', tone: 0)),
      if (_asked && top != null) DsSection(title: gen_balagan_ask_c24, children: [   // חזר בלי לשמור ⇒ הזיהוי נשאר על המסך (הקשה אחת חוזרת)
        DsApproveCard(question: gen_balagan_ask_c25.replaceAll('{title}', top.module.title).replaceAll('{moment}', top.module.moment), source: _c.text.length > 80 ? _c.text.substring(0, 80) : _c.text, okLabel: gen_balagan_ask_c26, noLabel: gen_balagan_ask_c27, onOk: () => _open(context, top, _hits.skip(1).map((h) => h.module).toList()), onNo: _skip),
        if (_hits.length > 1) DsFold(title: gen_balagan_ask_c28 + ' (' + (_hits.length - 1).toString() + ')', details: [for (final h in _hits.skip(1)) DsNavTile(glyph: '', title: h.module.title, sub: h.module.moment, onTap: () => _open(context, h))]),
      ]),
    ]);
  }
}
