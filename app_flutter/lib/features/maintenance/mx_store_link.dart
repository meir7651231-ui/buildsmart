/// Maintenance module — the independent-store connection.
///
/// Channel 1 (zero install): the approved PO goes to the store owner over
/// WhatsApp as plain Hebrew text + a no-login link `<base>/s/<token>`. The link
/// opens the store page (confirm / missing / ready + invoice & allocation no.).
/// Channel 2: the store owner works from the BuildSmart store dashboard.
///
/// Channel 3 (prices): the store sends its price list as CSV/Excel-export;
/// [mxParsePriceList] maps it onto our SKUs.
///
/// Sending itself is a `wa.me` deep link opened by the manager's phone — the
/// app never sends messages on its own (WhatsApp Business API = phase 3).
library;

import 'package:buildsmart/data/csv_kernel.dart';

import 'package:buildsmart/features/maintenance/mx_engine.dart';
import 'package:buildsmart/features/maintenance/mx_model.dart';
import 'package:buildsmart/features/maintenance/mx_templates.dart';

/// Normalize an Israeli phone to international digits for wa.me:
/// '050-123 4567' / '+972 50 1234567' / '0501234567' → '972501234567'.
/// Returns '' when it is not a plausible Israeli number.
String mxIntlPhone(String raw) {
  var d = raw.replaceAll(RegExp('[^0-9]'), '');
  if (d.startsWith('00972')) d = d.substring(2);
  if (d.startsWith('972')) {
    d = d.substring(3);
  } else if (d.startsWith('0')) {
    d = d.substring(1);
  }
  // Mobile 5X-XXXXXXX (9 digits) or landline 2/3/4/8/9-XXXXXXX (8 digits).
  final ok =
      RegExp(r'^5\d{8}$').hasMatch(d) || RegExp(r'^[23489]\d{7}$').hasMatch(d);
  return ok ? '972$d' : '';
}

/// The store page URL for a PO token.
String mxStoreLink(String baseUrl, String token) {
  final b =
      baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
  return '$b/s/$token';
}

/// The WhatsApp text sent to the store for an approved PO.
String mxStoreMessage(
  MxDb db,
  MxPurchaseOrder o, {
  required String baseUrl,
  required String orgName,
}) {
  if (o.token.isEmpty) throw const MxError('ההזמנה עוד לא אושרה');
  final s = db.store(o.storeId);
  final site = mxPoDeliverySite(db, o);
  final b =
      StringBuffer()
        ..writeln('שלום ${s.name},')
        ..writeln('${mxPoLabel(o.id)} מ$orgName:')
        ..writeln();
  for (final l in o.lines) {
    b.writeln('• ${l.qty} × ${db.part(l.sku).name}');
  }
  b
    ..writeln()
    ..writeln('סה״כ משוער: ${mxShekels(o.totalAgorot)} לפני מע״מ')
    ..writeln(
      'כתובת: ${site.address.isEmpty ? '${site.city} – ${site.name}' : site.address}',
    )
    ..writeln(
      kMxManagerPhone.isEmpty
          ? 'איש קשר: $kMxManagerTitle'
          : 'איש קשר: $kMxManagerTitle, $kMxManagerPhone',
    )
    ..writeln()
    ..writeln('לאישור, לסימון מה חסר ולעדכון שההזמנה מוכנה:')
    ..write(mxStoreLink(baseUrl, o.token));
  return b.toString();
}

/// `https://wa.me/<intl>?text=<encoded>` — opens WhatsApp with the message
/// ready; the human presses send. Throws when the store has no valid phone.
Uri mxWhatsAppUri(
  MxDb db,
  MxPurchaseOrder o, {
  required String baseUrl,
  required String orgName,
}) {
  final phone = mxIntlPhone(db.store(o.storeId).phone);
  if (phone.isEmpty) throw const MxError('לחנות אין מספר טלפון תקין');
  return Uri.https('wa.me', '/$phone', {
    'text': mxStoreMessage(db, o, baseUrl: baseUrl, orgName: orgName),
  });
}

// ── price list import ────────────────────────────────────────────────────────

/// Header aliases (normalized lower-case) accepted in a store price list.
const Set<String> kMxSkuHeaders = {'מק"ט', 'מקט', 'sku', 'קוד', 'קוד פריט'};
const Set<String> kMxOurSkuHeaders = {
  'מק"ט שלנו',
  'מקט שלנו',
  'our sku',
  'our_sku',
};
const Set<String> kMxNameHeaders = {
  'שם',
  'תיאור',
  'שם פריט',
  'name',
  'description',
};
const Set<String> kMxPriceHeaders = {
  'מחיר',
  'מחיר ליחידה',
  'price',
  'unit price',
};

class MxPriceRow {
  const MxPriceRow({
    required this.storeSku,
    required this.ourSku,
    required this.name,
    required this.agorot,
  });
  final String storeSku;

  /// Our SKU this row maps to, or '' when unmatched (shown for manual mapping).
  final String ourSku;
  final String name;
  final int agorot;
}

class MxPriceImport {
  const MxPriceImport({required this.rows, required this.errors});
  final List<MxPriceRow> rows;

  /// Human-readable problems, e.g. 'שורה 7: מחיר לא תקין'.
  final List<String> errors;

  List<MxPriceRow> get matched =>
      rows.where((r) => r.ourSku.isNotEmpty).toList();
  List<MxPriceRow> get unmatched =>
      rows.where((r) => r.ourSku.isEmpty).toList();
}

/// "12.50" / "12,50" / "₪ 1,234.5" → agorot; null when not a price.
int? mxParseAgorot(String raw) {
  var s = raw.replaceAll(RegExp(r'[₪\s]|ש"ח|שח'), '');
  if (s.isEmpty) return null;
  // "1,234.50" → thousands comma; "12,50" (single comma, ≤2 decimals) → decimal.
  if (s.contains(',') && s.contains('.')) {
    s = s.replaceAll(',', '');
  } else if (RegExp(r'^\d+,\d{1,2}$').hasMatch(s)) {
    s = s.replaceAll(',', '.');
  } else {
    s = s.replaceAll(',', '');
  }
  final v = double.tryParse(s);
  if (v == null || v < 0 || v.isNaN || v.isInfinite) return null;
  return (v * 100).round();
}

/// Parse a store price list (CSV text, comma/semicolon/tab auto-detected).
/// A row maps to our SKU by an explicit "מק"ט שלנו" column, else when the
/// store's SKU equals one of ours, else by exact part name.
MxPriceImport mxParsePriceList(String text, List<MxPart> parts) {
  final known = {
    ...kMxSkuHeaders,
    ...kMxOurSkuHeaders,
    ...kMxNameHeaders,
    ...kMxPriceHeaders,
  };
  final records = tokenizeCsvAutodetect(text, known);
  final errors = <String>[];
  if (records.isEmpty) {
    return const MxPriceImport(rows: [], errors: ['הקובץ ריק']);
  }
  final h = csvHeaderIndex(records);
  if (h < 0) {
    return const MxPriceImport(rows: [], errors: ['לא נמצאה שורת כותרות']);
  }
  final head = [for (final c in records[h].cells) normHeader(c)];
  int col(Set<String> names) => head.indexWhere(names.contains);
  final cSku = col(kMxSkuHeaders);
  final cOur = col(kMxOurSkuHeaders);
  final cName = col(kMxNameHeaders);
  final cPrice = col(kMxPriceHeaders);
  if (cPrice < 0) {
    return const MxPriceImport(rows: [], errors: ['חסרה עמודת מחיר']);
  }
  if (cSku < 0 && cName < 0) {
    return const MxPriceImport(rows: [], errors: ['חסרה עמודת מק"ט או שם']);
  }

  final bySku = {for (final p in parts) p.sku.toLowerCase(): p.sku};
  final byName = {for (final p in parts) _normName(p.name): p.sku};
  final rows = <MxPriceRow>[];
  for (var i = h + 1; i < records.length; i++) {
    final cells = records[i].cells;
    if (csvIsBlank(cells) || csvIsComment(cells)) continue;
    String at(int c) => c >= 0 && c < cells.length ? cells[c].trim() : '';
    final line = records[i].line;
    final price = mxParseAgorot(at(cPrice));
    if (price == null) {
      errors.add('שורה $line: מחיר לא תקין "${at(cPrice)}"');
      continue;
    }
    final storeSku = at(cSku);
    final name = at(cName);
    var ours = '';
    final explicit = at(cOur);
    if (explicit.isNotEmpty) {
      ours = bySku[explicit.toLowerCase()] ?? '';
      if (ours.isEmpty) errors.add('שורה $line: מק"ט שלנו לא קיים "$explicit"');
    } else {
      ours = bySku[storeSku.toLowerCase()] ?? byName[_normName(name)] ?? '';
    }
    rows.add(
      MxPriceRow(storeSku: storeSku, ourSku: ours, name: name, agorot: price),
    );
  }
  return MxPriceImport(rows: rows, errors: errors);
}

/// Name key tolerant to how stores type Hebrew marks: ״/" and ׳/' are
/// equivalent, extra spaces ignored.
String _normName(String s) =>
    s
        .replaceAll('״', '"')
        .replaceAll('׳', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

/// Store the matched prices on the db for [storeId] (replaces that store's list).
MxDb mxApplyPrices(MxDb db, String storeId, MxPriceImport imp) {
  db.store(storeId); // validates
  return db.copyWith(
    storePrices: {
      ...db.storePrices,
      storeId: {for (final r in imp.matched) r.ourSku: r.agorot},
    },
  );
}
