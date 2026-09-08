// 🧭 חולל ע"י balagan (G33 · הכרעה-29 · חוק-6) — «חיבורים»: המפתחות של הלקוח, במכשיר בלבד. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_keys_content.dart';
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
  Future<void> _copy() async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); setState(() => _note = gen_balagan_keys_c0.replaceAll('{n}', t.length.toString())); }
  void _restore() { final n = appStore.importJson(_paste); setState(() { _note = n < 0 ? gen_balagan_keys_c1 : gen_balagan_keys_c2.replaceAll('{n}', n.toString()); if (n >= 0) _paste = ''; }); }
  void _undo() { final ok = appStore.undoImport(); setState(() => _note = ok ? gen_balagan_keys_c3 : gen_balagan_keys_c4); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_balagan_keys_c5, subtitle: gen_balagan_keys_c6, icon: gen_balagan_keys_c7, children: [
    DsSection(title: gen_balagan_keys_c8, children: [
      DsPrimaryButton(label: gen_balagan_keys_c9, onTap: _copy),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c10, hint: '{…}', value: _paste, onChanged: (v) => _paste = v)),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c11, onTap: _restore), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c12, onTap: _undo)])),
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _note, label: '', tone: 0)),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c13, label: '', tone: 0)),
    ]),
    DsField(label: gen_balagan_keys_c14, hint: gen_balagan_keys_c15, value: appStore.setting('ai.key'), onChanged: (v) => appStore.setSetting('ai.key', v.trim())),
    DsField(label: gen_balagan_keys_c16, hint: gen_balagan_keys_c17, value: appStore.setting('ai.model'), onChanged: (v) => appStore.setSetting('ai.model', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 12), child: DsNote(message: gen_balagan_keys_c18, label: '', tone: 0)),
    DsField(label: gen_balagan_keys_c19, hint: gen_balagan_keys_c20, value: appStore.setting('mail.token'), onChanged: (v) => appStore.setSetting('mail.token', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c21, label: '', tone: 0)),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c22, label: '', tone: 0)),
  ]));
}
