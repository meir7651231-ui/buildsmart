// 🧭 חולל ע"י balagan (G33 · הכרעה-29 · חוק-6) — «חיבורים»: המפתחות של הלקוח, במכשיר בלבד. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_keys_content.dart';
import 'gen_balagan_home.dart';
import 'gen_balagan_moments.dart';   // G46 · balaganImportCsv
import 'gen_behaviors.dart';   // G50 · bhTextScale
import '../dart-ui-bs/ds/ds_download_stub.dart' if (dart.library.js_interop) '../dart-ui-bs/ds/ds_download_web.dart';   // G51 · גיבוי-לקובץ
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
  Future<void> _copy() async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); setState(() => _note = gen_balagan_keys_c0.replaceAll('{n}', t.length.toString())); }   // G51 · העתקה-ללוח אינה גיבוי ⇒ אינה חותמת
  /// G51 · הגיבוי היחיד שנחשב: קובץ שירד בפועל. רק הוא חותם backupAt.
  void _download() { final t = appStore.exportJson(); final ok = downloadText('balagan-' + DateTime.now().toIso8601String().substring(0, 10) + '.json', t); if (ok) appStore.setSetting('backupAt', DateTime.now().toIso8601String().substring(0, 10)); setState(() => _note = ok ? gen_balagan_keys_c1 : gen_balagan_keys_c2); }
  void _restore() { final n = appStore.importJson(_paste); setState(() { _note = n == -2 ? gen_balagan_keys_c3 : n < 0 ? gen_balagan_keys_c4 : gen_balagan_keys_c5.replaceAll('{n}', n.toString()); if (n >= 0) _paste = ''; }); }   // G51 · -2 = אין דרך-חזרה ⇒ לא נגענו בכלום
  void _undo() { final ok = appStore.undoImport(); setState(() => _note = ok ? gen_balagan_keys_c6 : gen_balagan_keys_c7); }
  String _csv = '', _csvNote = '', _vcf = '', _vcfNote = '';
  void _importVcf() { final r = balaganImportVcf(_vcf); setState(() { _vcfNote = r[1] == 0 && r[0] == 0 ? gen_balagan_keys_c8 : gen_balagan_keys_c9.replaceAll('{n}', r[0].toString()).replaceAll('{m}', r[1].toString()); if (r[0] > 0) _vcf = ''; }); }   // ב׳-קנד · G48
  void _importCsv() { final r = balaganImportCsv(_csv); setState(() { _csvNote = (r[1] as int) == 0 ? gen_balagan_keys_c10 : gen_balagan_keys_c11.replaceAll('{n}', r[1].toString()).replaceAll('{module}', r[0] as String); if ((r[1] as int) > 0) _csv = ''; }); }   // ב׳-קמח · G46
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_balagan_keys_c12, subtitle: gen_balagan_keys_c13, icon: gen_balagan_keys_c14, children: [
    DsSection(title: gen_balagan_keys_c15, children: [
      for (final d in [DateTime.tryParse(appStore.setting('backupAt'))]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(d == null ? gen_balagan_keys_c16 : gen_balagan_keys_c17.replaceAll('{d}', balaganDayLabel(d, DateTime.now())), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13))),   // ב׳-מז · מתי גיבית לאחרונה
      DsPrimaryButton(label: gen_balagan_keys_c18, onTap: _download),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c19, onTap: _copy)])),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c20, onTap: () async { final t = balaganCsvAll(); await Clipboard.setData(ClipboardData(text: t)); setState(() => _note = gen_balagan_keys_c21.replaceAll('{n}', (t.split('\n').length - 1).toString())); })])),   // ב׳-קנא · G47 · כל התיקים לאקסל
      Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c22, hint: '{…}', value: _paste, onChanged: (v) => _paste = v)),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c23, onTap: _restore), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c24, onTap: _undo)])),
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _note, label: '', tone: 0)),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c25, label: '', tone: 0)),
    ]),
    DsSection(title: gen_balagan_keys_c26, children: [
      DsField(label: gen_balagan_keys_c27, hint: 'מה,מועד,סכום', value: _csv, onChanged: (v) => _csv = v),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c28, onTap: _importCsv)])),
      if (_csvNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _csvNote, label: '', tone: 0)),   // ב׳-קמח · G46 · ייבוא CSV לפי שמות-שדות
    ]),
    DsSection(title: gen_balagan_keys_c29, children: [
      DsField(label: gen_balagan_keys_c30, hint: 'BEGIN:VCARD…', value: _vcf, onChanged: (v) => _vcf = v),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c31, onTap: _importVcf)])),
      if (_vcfNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _vcfNote, label: '', tone: 0)),   // ב׳-קנד · G48 · אנשי-קשר ⇒ ספר-טלפונים (לא תיקים)
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c32, label: '', tone: 0)),
    ]),
    DsField(label: gen_balagan_keys_c33, hint: gen_balagan_keys_c34, value: appStore.setting('ai.key'), onChanged: (v) => appStore.setSetting('ai.key', v.trim())),
    DsField(label: gen_balagan_keys_c35, hint: gen_balagan_keys_c36, value: appStore.setting('budget'), onChanged: (v) => appStore.setSetting('budget', v.trim())),   // ב׳-קלב · G42
    Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Text(gen_balagan_keys_c37, style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), const SizedBox(width: 10), DsChipButton(label: gen_balagan_keys_c38, onTap: () => appStore.setSetting('textScale', bhTextScaleStep(bhTextScale(appStore.setting('textScale')), -1).toString())), const SizedBox(width: 8), Text((bhTextScale(appStore.setting('textScale')) * 100).round().toString() + '%'), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c39, onTap: () => appStore.setSetting('textScale', bhTextScaleStep(bhTextScale(appStore.setting('textScale')), 1).toString()))])),   // ב׳-קסא · G50 · נגישות: 80%–160% (clampScale · stepScale מהמדף)
    DsField(label: gen_balagan_keys_c40, hint: gen_balagan_keys_c41, value: appStore.setting('ai.model'), onChanged: (v) => appStore.setSetting('ai.model', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 12), child: DsNote(message: gen_balagan_keys_c42, label: '', tone: 0)),
    DsField(label: gen_balagan_keys_c43, hint: gen_balagan_keys_c44, value: appStore.setting('mail.token'), onChanged: (v) => appStore.setSetting('mail.token', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c45, label: '', tone: 0)),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c46, label: '', tone: 0)),
  ]));
}
