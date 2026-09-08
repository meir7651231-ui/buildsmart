// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «מה קרה?»: שורה/הדבקה/צילום ⇒ זיהוי-הרגע (דטרמיניסטי) ⇒ «הבנתי כך?» ⇒ טופס-השורש של המודול ממולא-מראש. צילום נקרא רק עם מפתח-הלקוח (ds_ai). אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_ask_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_ai.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_balagan_moments.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Widget balaganOpen(int index, Map<String, String> initial) {
  switch (index) {
    case 0: return GenAppPeruk01Ent1Screen(initial: initial);
    case 1: return GenAppPeruk02Ent1Screen(initial: initial);
    case 2: return GenAppPeruk03Ent1Screen(initial: initial);
    case 3: return GenAppPeruk04Ent1Screen(initial: initial);
    case 4: return GenAppPeruk05Ent1Screen(initial: initial);
    case 5: return GenAppPeruk06Ent1Screen(initial: initial);
    case 6: return GenAppPeruk07Ent1Screen(initial: initial);
    case 7: return GenAppPeruk08Ent1Screen(initial: initial);
    case 8: return GenAppPeruk09Ent1Screen(initial: initial);
    case 9: return GenAppPeruk10Ent1Screen(initial: initial);
    case 10: return GenAppPeruk11Ent1Screen(initial: initial);
    case 11: return GenAppPeruk12Ent1Screen(initial: initial);
    case 12: return GenAppPeruk13Ent1Screen(initial: initial);
    case 13: return GenAppPeruk14Ent1Screen(initial: initial);
    case 14: return GenAppPeruk15Ent1Screen(initial: initial);
    case 15: return GenAppPeruk16Ent1Screen(initial: initial);
    case 16: return GenAppPeruk17Ent1Screen(initial: initial);
    case 17: return GenAppPeruk18Ent1Screen(initial: initial);
    case 18: return GenAppPeruk19Ent1Screen(initial: initial);
    case 19: return GenAppPeruk20Ent1Screen(initial: initial);
    case 20: return GenAppPeruk21Ent1Screen(initial: initial);
    case 21: return GenAppPeruk22Ent1Screen(initial: initial);
    case 22: return GenAppPeruk23Ent1Screen(initial: initial);
    case 23: return GenAppPeruk24Ent1Screen(initial: initial);
    case 24: return GenAppPeruk25Ent1Screen(initial: initial);
    case 25: return GenAppPeruk26Ent1Screen(initial: initial);
    case 26: return GenAppPeruk27Ent1Screen(initial: initial);
    case 27: return GenAppPeruk28Ent1Screen(initial: initial);
    default: return const SizedBox.shrink();
  }
}

class GenBalaganAskScreen extends StatefulWidget {
  const GenBalaganAskScreen({super.key});
  @override
  State<GenBalaganAskScreen> createState() => _GenBalaganAskScreenState();
}

class _GenBalaganAskScreenState extends State<GenBalaganAskScreen> {
  final _c = TextEditingController();
  List<BalaganHit> _hits = const [];
  Map<String, String> _extra = const {};
  bool _asked = false, _busy = false;
  String _note = '';

  void _go() { setState(() { _asked = true; _hits = balaganIdentify(_c.text); _note = _hits.isEmpty ? gen_balagan_ask_c0 : ''; }); }
  void _skip() { setState(() { _hits = _hits.length > 1 ? _hits.sublist(1) : const []; if (_hits.isEmpty) _note = gen_balagan_ask_c1; }); }
  void _open(BuildContext context, BalaganHit h) {
    final facts = {...balaganFacts(_c.text, h.module), ..._extra}..removeWhere((key, v) => v.trim().isEmpty || !(h.module.dateFields.contains(key) || h.module.numFields.contains(key) || key == h.module.descField || key == h.module.longField));
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpen(h.module.index, facts)));
  }
  Future<void> _photo() async {
    final key = appStore.setting('ai.key');
    if (key.isEmpty) { setState(() => _note = gen_balagan_ask_c2); return; }
    final x = await ImagePicker().pickImage(source: kIsWeb ? ImageSource.gallery : ImageSource.camera, imageQuality: 85);
    if (x == null) return;
    setState(() { _busy = true; _note = gen_balagan_ask_c3; });
    final bytes = await x.readAsBytes();
    final r = await dsAiExtract(apiKey: key, image: bytes, imageMime: x.mimeType ?? 'image/jpeg', fields: const ['תאריך', 'סכום', 'שם'], model: appStore.setting('ai.model', 'claude-sonnet-5'));
    if (!mounted) return;
    if (r == null) { setState(() { _busy = false; _note = gen_balagan_ask_c4; }); return; }
    final text = (r['_text'] ?? '').trim();
    setState(() { _busy = false; _note = ''; if (text.isNotEmpty) _c.text = text; _extra = {for (final e in r.entries) if (e.key != '_text' && e.value.trim().isNotEmpty) e.key: e.value}; });
    _go();
  }

  @override
  Widget build(BuildContext context) {
    final lk = DsLook.of(context);
    final top = _hits.isNotEmpty ? _hits.first : null;
    return DsScaffold(title: gen_balagan_ask_c5, subtitle: gen_balagan_ask_c6, icon: gen_balagan_ask_c7, children: [
      Container(
        decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(lk.r)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TextField(controller: _c, minLines: 3, maxLines: 8, autofocus: true, style: TextStyle(color: lk.ink, fontSize: 16, height: 1.5), decoration: InputDecoration(border: InputBorder.none, hintText: gen_balagan_ask_c8, hintStyle: TextStyle(color: lk.faint)), onSubmitted: (_) => _go()),
      ),
      Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [
        Expanded(child: DsPrimaryButton(label: gen_balagan_ask_c9, onTap: _busy ? null : _go)),
        const SizedBox(width: 8),
        GestureDetector(onTap: _busy ? null : _photo, child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(border: Border.all(color: lk.line), borderRadius: BorderRadius.circular(9)), child: Text(gen_balagan_ask_c10, style: TextStyle(color: lk.ink, fontSize: 14, fontWeight: FontWeight.w600)))),
      ])),
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: DsNote(message: _note, label: '', tone: 0)),
      if (_asked && top != null) DsSection(title: gen_balagan_ask_c11, children: [
        DsApproveCard(question: gen_balagan_ask_c12.replaceAll('{title}', top.module.title).replaceAll('{moment}', top.module.moment), source: _c.text.length > 80 ? _c.text.substring(0, 80) : _c.text, okLabel: gen_balagan_ask_c13, noLabel: gen_balagan_ask_c14, onOk: () => _open(context, top), onNo: _skip),
        if (_hits.length > 1) DsFold(title: gen_balagan_ask_c15 + ' (' + (_hits.length - 1).toString() + ')', details: [for (final h in _hits.skip(1)) DsNavTile(glyph: '', title: h.module.title, sub: h.module.moment, onTap: () => _open(context, h))]),
      ]),
    ]);
  }
}
