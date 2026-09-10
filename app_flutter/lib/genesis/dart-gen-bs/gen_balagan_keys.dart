// 🧭 חולל ע"י balagan (G33 · הכרעה-29 · חוק-6) — «חיבורים»: המפתחות של הלקוח, במכשיר בלבד. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_keys_content.dart';
import 'gen_balagan_home.dart';
import 'gen_balagan_moments.dart';   // G46 · balaganImportCsv
import 'gen_behaviors.dart';   // G50 · bhTextScale
import '../dart-ui-bs/ds/ds_download_stub.dart' if (dart.library.js_interop) '../dart-ui-bs/ds/ds_download_web.dart';   // G51 · גיבוי-לקובץ
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_field.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds_cloud.dart';   // G58 · החוט לענן
import '../dart-ui-bs/ds/ds_push.dart';   // G59 · טוקן-דחיפה
import '../dart-ui-bs/ds/ds_oauth.dart';   // G60 · חיבור-גוגל מתחדש
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GenBalaganKeysScreen extends StatefulWidget {
  const GenBalaganKeysScreen({super.key});
  @override
  State<GenBalaganKeysScreen> createState() => _GenBalaganKeysScreenState();
}

class _GenBalaganKeysScreenState extends State<GenBalaganKeysScreen> {
  String _paste = '', _note = '';
  // ── G58 · ענן (הכרעה-31): הקונפיג והחשבון של הבעלים, נשמרים **במכשיר**.
  //   בלי קונפיג תקין: אין אתחול, אין רשת, אפס שינוי. הכפתורים כאן הם כל מה שמפעיל אותו.
  String _mail = '', _pass = '', _cloudNote = '';
  bool _cloudBusy = false;
  Future<void> _cloudConnect() async {
    setState(() { _cloudBusy = true; _cloudNote = ''; });
    final r = await cloudSignIn(appStore.setting('cloud.config'), _mail, _pass);
    if (!mounted) return;
    if (!r.ok) { setState(() { _cloudBusy = false; _cloudNote = gen_balagan_keys_c0.replaceAll('{code}', r.note); }); return; }
    final st = await balaganCloudSync();
    if (!mounted) return;
    setState(() { _cloudBusy = false; _cloudNote = _syncNote(st); });
  }
  // G59 · רישום המכשיר לדחיפה. אין רשות/אין VAPID ⇒ אומרים, לא מזייפים.
  Future<void> _pushOn() async {
    setState(() { _cloudBusy = true; });
    final t = await pushToken(appStore.setting('cloud.config'), appStore.setting('push.vapid'));
    final ok = t != null && await cloudPutToken(t);
    if (!mounted) return;
    setState(() { _cloudBusy = false; _cloudNote = ok ? gen_balagan_keys_c1 : gen_balagan_keys_c2; });
  }
  // G60 · פותח את מסך-ההסכמה של גוגל. מכאן והלאה השרת מחזיק את טוקן-הרענון
  //   והלקוח מקבל רק טוקן קצר — הטוקן במייל מפסיק למות אחרי שעה.
  Future<void> _oauth() async {
    final u = await oauthUrl(clientId: appStore.setting('oauth.clientId'), fnBase: appStore.setting('oauth.fnBase'));
    if (!mounted) return;
    if (u == null) { setState(() => _cloudNote = gen_balagan_keys_c3); return; }
    await launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
    if (mounted) setState(() => _cloudNote = gen_balagan_keys_c4);
  }
  Future<void> _cloudOut() async { await cloudSignOut(); if (mounted) setState(() => _cloudNote = ''); }
  Future<void> _cloudSync() async {
    setState(() { _cloudBusy = true; });
    final st = await balaganCloudSync();
    if (!mounted) return;
    setState(() { _cloudBusy = false; _cloudNote = _syncNote(st); });
  }
  String _syncNote(String st) {
    if (st.startsWith('ok:')) { final n = int.tryParse(st.substring(3)) ?? 0; return n > 0 ? gen_balagan_keys_c5.replaceAll('{n}', n.toString()) : gen_balagan_keys_c6; }
    if (st == 'net') return gen_balagan_keys_c7;
    if (st == 'off') return gen_balagan_keys_c8;
    return gen_balagan_keys_c9;
  }
  String _cloudState() {
    final cfg = appStore.setting('cloud.config');
    if (cfg.trim().isEmpty) return gen_balagan_keys_c10;
    if (cloudOptions(cfg) == null) return gen_balagan_keys_c11;
    if (cloudUid().isEmpty) return gen_balagan_keys_c12;
    final at = appStore.setting('cloud.at');
    return at.isEmpty ? gen_balagan_keys_c13 : gen_balagan_keys_c14.replaceAll('{at}', at.replaceFirst('T', ' ').substring(0, 16));
  }
  // גיבוי = טקסט (אותו JSON של ההתמדה) שהלקוח שומר איפה שנוח; שחזור מחליף הכל ושומר את הקודם פעם אחת ⇒ «בטל שחזור». אפס-שרת (חוק-6).
  Future<void> _copy() async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); setState(() => _note = gen_balagan_keys_c15.replaceAll('{n}', t.length.toString())); }   // G51 · העתקה-ללוח אינה גיבוי ⇒ אינה חותמת
  /// G51 · הגיבוי היחיד שנחשב: קובץ שירד בפועל. רק הוא חותם backupAt.
  void _download() { final t = appStore.exportJson(); final ok = downloadText('balagan-' + DateTime.now().toIso8601String().substring(0, 10) + '.json', t); if (ok) appStore.setSetting('backupAt', DateTime.now().toIso8601String().substring(0, 10)); setState(() => _note = ok ? gen_balagan_keys_c16 : gen_balagan_keys_c17); }
  void _restore() { final n = appStore.importJson(_paste); setState(() { _note = n == -2 ? gen_balagan_keys_c18 : n < 0 ? gen_balagan_keys_c19 : gen_balagan_keys_c20.replaceAll('{n}', n.toString()); if (n >= 0) _paste = ''; }); }   // G51 · -2 = אין דרך-חזרה ⇒ לא נגענו בכלום
  void _undo() { final ok = appStore.undoImport(); setState(() => _note = ok ? gen_balagan_keys_c21 : gen_balagan_keys_c22); }
  String _csv = '', _csvNote = '', _vcf = '', _vcfNote = '';
  void _importVcf() { final r = balaganImportVcf(_vcf); setState(() { _vcfNote = r[1] == 0 && r[0] == 0 ? gen_balagan_keys_c23 : gen_balagan_keys_c24.replaceAll('{n}', r[0].toString()).replaceAll('{m}', r[1].toString()); if (r[0] > 0) _vcf = ''; }); }   // ב׳-קנד · G48
  void _importCsv() { final r = balaganImportCsv(_csv); setState(() { _csvNote = (r[1] as int) == 0 ? gen_balagan_keys_c25 : gen_balagan_keys_c26.replaceAll('{n}', r[1].toString()).replaceAll('{module}', r[0] as String); if ((r[1] as int) > 0) _csv = ''; }); }   // ב׳-קמח · G46
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) => DsScaffold(title: gen_balagan_keys_c27, subtitle: gen_balagan_keys_c28, icon: gen_balagan_keys_c29, children: [
    // G58 · ענן — ראשון במסך: זה מה שמחבר את המכשירים. בלי הדבקת-קונפיג הוא רק אומר שהוא כבוי.
    DsSection(title: gen_balagan_keys_c44, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_cloudState(), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13))),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c30, hint: '{}', value: appStore.setting('cloud.config'), onChanged: (v) => appStore.setSetting('cloud.config', v))),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c31, label: '', tone: 0)),
      if (cloudOptions(appStore.setting('cloud.config')) != null && cloudUid().isEmpty) ...[
        Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c32, hint: '', value: _mail, onChanged: (v) => _mail = v)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c33, hint: '', value: _pass, onChanged: (v) => _pass = v)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsPrimaryButton(label: gen_balagan_keys_c34, onTap: _cloudBusy ? null : _cloudConnect)),
      ],
      if (cloudUid().isNotEmpty) ...[
        Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c35, hint: 'B', value: appStore.setting('push.vapid'), onChanged: (v) => appStore.setSetting('push.vapid', v))),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c36, hint: '', value: appStore.setting('oauth.clientId'), onChanged: (v) => appStore.setSetting('oauth.clientId', v))),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c37, hint: 'https://', value: appStore.setting('oauth.fnBase'), onChanged: (v) => appStore.setSetting('oauth.fnBase', v))),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c38, label: '', tone: 0)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c39, label: '', tone: 0)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsChipButton(label: gen_balagan_keys_c40, onTap: _cloudBusy ? null : _pushOn)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsChipButton(label: gen_balagan_keys_c41, onTap: _cloudBusy ? null : _oauth)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsChipButton(label: gen_balagan_keys_c42, onTap: _cloudBusy ? null : _cloudSync)),
        Padding(padding: const EdgeInsets.only(top: 8), child: DsChipButton(label: gen_balagan_keys_c43, onTap: _cloudBusy ? null : _cloudOut)),
      ],
      if (_cloudNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _cloudNote, label: '', tone: 0)),
    ]),
    DsSection(title: gen_balagan_keys_c45, children: [
      for (final d in [DateTime.tryParse(appStore.setting('backupAt'))]) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(d == null ? gen_balagan_keys_c46 : gen_balagan_keys_c47.replaceAll('{d}', balaganDayLabel(d, DateTime.now())), style: TextStyle(color: DsLook.of(context).muted, fontSize: 13))),   // ב׳-מז · מתי גיבית לאחרונה
      DsPrimaryButton(label: gen_balagan_keys_c48, onTap: _download),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c49, onTap: _copy)])),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c50, onTap: () async { final t = balaganCsvAll(); await Clipboard.setData(ClipboardData(text: t)); setState(() => _note = gen_balagan_keys_c51.replaceAll('{n}', (t.split('\n').length - 1).toString())); })])),   // ב׳-קנא · G47 · כל התיקים לאקסל
      Padding(padding: const EdgeInsets.only(top: 8), child: DsField(label: gen_balagan_keys_c52, hint: '{…}', value: _paste, onChanged: (v) => _paste = v)),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c53, onTap: _restore), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c54, onTap: _undo)])),
      if (_note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _note, label: '', tone: 0)),
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c55, label: '', tone: 0)),
    ]),
    DsSection(title: gen_balagan_keys_c56, children: [
      DsField(label: gen_balagan_keys_c57, hint: 'מה,מועד,סכום', value: _csv, onChanged: (v) => _csv = v),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c58, onTap: _importCsv)])),
      if (_csvNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _csvNote, label: '', tone: 0)),   // ב׳-קמח · G46 · ייבוא CSV לפי שמות-שדות
    ]),
    DsSection(title: gen_balagan_keys_c59, children: [
      DsField(label: gen_balagan_keys_c60, hint: 'BEGIN:VCARD…', value: _vcf, onChanged: (v) => _vcf = v),
      Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [DsChipButton(label: gen_balagan_keys_c61, onTap: _importVcf)])),
      if (_vcfNote.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: _vcfNote, label: '', tone: 0)),   // ב׳-קנד · G48 · אנשי-קשר ⇒ ספר-טלפונים (לא תיקים)
      Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c62, label: '', tone: 0)),
    ]),
    DsField(label: gen_balagan_keys_c63, hint: gen_balagan_keys_c64, value: appStore.setting('ai.key'), onChanged: (v) => appStore.setSetting('ai.key', v.trim())),
    DsField(label: gen_balagan_keys_c65, hint: gen_balagan_keys_c66, value: appStore.setting('budget'), onChanged: (v) => appStore.setSetting('budget', v.trim())),   // ב׳-קלב · G42
    Padding(padding: const EdgeInsets.only(top: 10), child: Row(children: [Text(gen_balagan_keys_c67, style: TextStyle(color: DsLook.of(context).muted, fontSize: 13)), const SizedBox(width: 10), DsChipButton(label: gen_balagan_keys_c68, onTap: () => appStore.setSetting('textScale', bhTextScaleStep(bhTextScale(appStore.setting('textScale')), -1).toString())), const SizedBox(width: 8), Text((bhTextScale(appStore.setting('textScale')) * 100).round().toString() + '%'), const SizedBox(width: 8), DsChipButton(label: gen_balagan_keys_c69, onTap: () => appStore.setSetting('textScale', bhTextScaleStep(bhTextScale(appStore.setting('textScale')), 1).toString()))])),   // ב׳-קסא · G50 · נגישות: 80%–160% (clampScale · stepScale מהמדף)
    DsField(label: gen_balagan_keys_c70, hint: gen_balagan_keys_c71, value: appStore.setting('ai.model'), onChanged: (v) => appStore.setSetting('ai.model', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 12), child: DsNote(message: gen_balagan_keys_c72, label: '', tone: 0)),
    DsField(label: gen_balagan_keys_c73, hint: gen_balagan_keys_c74, value: appStore.setting('mail.token'), onChanged: (v) => appStore.setSetting('mail.token', v.trim())),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c75, label: '', tone: 0)),
    Padding(padding: const EdgeInsets.only(top: 8), child: DsNote(message: gen_balagan_keys_c76, label: '', tone: 0)),
  ]));
}
