// 🧭 חולל ע"י balagan (G33 · הכרעה-29 · חוק-6) — «חיבורים»: המפתחות של הלקוח, במכשיר בלבד. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_keys_content.dart';
import 'gen_balagan_home.dart';
import 'gen_balagan_moments.dart';   // G46 · balaganImportCsv
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenBalaganKeysScreen extends StatefulWidget {
  const GenBalaganKeysScreen({super.key});
  @override
  State<GenBalaganKeysScreen> createState() => _GenBalaganKeysScreenState();
}

class _GenBalaganKeysScreenState extends State<GenBalaganKeysScreen> {
  String _paste = '', _note = '';
  // גיבוי = טקסט (אותו JSON של ההתמדה) שהלקוח שומר איפה שנוח; שחזור מחליף הכל ושומר את הקודם פעם אחת ⇒ «בטל שחזור». אפס-שרת (חוק-6).
  Future<void> _copy() async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); appStore.setSetting('backupAt', DateTime.now().toIso8601String().substring(0, 10)); setState(() => _note = gen_balagan_keys_c0.replaceAll('{n}', t.length.toString())); }
  void _restore() { final n = appStore.importJson(_paste); setState(() { _note = n < 0 ? gen_balagan_keys_c1 : gen_balagan_keys_c2.replaceAll('{n}', n.toString()); if (n >= 0) _paste = ''; }); }
  void _undo() { final ok = appStore.undoImport(); setState(() => _note = ok ? gen_balagan_keys_c3 : gen_balagan_keys_c4); }
  String _csv = '', _csvNote = '';
  void _importCsv() { final r = balaganImportCsv(_csv); setState(() { _csvNote = (r[1] as int) == 0 ? gen_balagan_keys_c5 : gen_balagan_keys_c6.replaceAll('{n}', r[1].toString()).replaceAll('{module}', r[0] as String); if ((r[1] as int) > 0) _csv = ''; }); }   // ב׳-קמח · G46
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_balagan_keys_c7, subtitle: gen_balagan_keys_c8, icon: gen_balagan_keys_c9, children: [
    DsSection(title: gen_balagan_keys_c10, children: [
      for (final d in [DateTime.tryParse(appStore.setting('backupAt'))]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(d == null ? gen_balagan_keys_c11 : gen_balagan_keys_c12.replaceAll('{d}', balaganDayLabel(d, DateTime.now())), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13))),   // ב׳-מז · מתי גיבית לאחרונה
      DsPrimaryButton(label: gen_balagan_keys_c13, onTap: _copy),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c14, hint: '{…}', value: _paste, onChanged: (v) => _paste = v)),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c15, onTap: _restore), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c16, onTap: _undo)])),
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _note, label: '', tone: 0)),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c17, label: '', tone: 0)),
    ]),
    DsSection(title: gen_balagan_keys_c18, children: [
      DsField(label: gen_balagan_keys_c19, hint: 'מה,מועד,סכום', value: _csv, onChanged: (v) => _csv = v),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c20, onTap: _importCsv)])),
      if (_csvNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _csvNote, label: '', tone: 0)),   // ב׳-קמח · G46 · ייבוא CSV לפי שמות-שדות
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c21, label: '', tone: 0)),
    ]),
    DsField(label: gen_balagan_keys_c22, hint: gen_balagan_keys_c23, value: appStore.setting('ai.key'), onChanged: (v) => appStore.setSetting('ai.key', v.trim())),
    DsField(label: gen_balagan_keys_c24, hint: gen_balagan_keys_c25, value: appStore.setting('budget'), onChanged: (v) => appStore.setSetting('budget', v.trim())),   // ב׳-קלב · G42
    DsField(label: gen_balagan_keys_c26, hint: gen_balagan_keys_c27, value: appStore.setting('ai.model'), onChanged: (v) => appStore.setSetting('ai.model', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 12), child: DsNote(message: gen_balagan_keys_c28, label: '', tone: 0)),
    DsField(label: gen_balagan_keys_c29, hint: gen_balagan_keys_c30, value: appStore.setting('mail.token'), onChanged: (v) => appStore.setSetting('mail.token', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c31, label: '', tone: 0)),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c32, label: '', tone: 0)),
  ]));
}
