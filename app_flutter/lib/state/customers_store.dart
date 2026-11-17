// ─────────────────────────────────────────────────────────────────────────────
// BuildSmart · GIANT Phase-2 · store-הלקוחות-השמורים (CRM) — StateNotifier+persist.
//
// הפער האסטרטגי (מפת-מאור #3): היום "לקוח" הוא אגרגט-נגזר מהזמנות לפי שם
// (`mgrCustomerList`) — אין ישות-לקוח שמורה. כאן נוחתת ישות שמורה: id·שם·טלפון·
// מייל·הערות·תגיות, עם **dedup-על-קלט** (מפתח = normName(שם)+normalizePhone(טלפון)
// מ-ליבת-ה-CRM המשותפת). מתחבר להזמנות **לפי-שם** (אפס-מיגרציה — אותו מפתח
// שהטאב כבר משתמש בו), לא ב-id חדש.
//
// AUGMENT ולא replace: `managerCustomersProvider` הנגזר לא-נגוע; הטאב הקיים
// מרנדר בדיוק כמו היום כשהפיצ'ר כבוי. משמעת-persist: שיבוט orders_engine
// (guard-first · tolerant-per-entry · write-behind). מפתח `bs.saved-customers.v1`.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:buildsmart/data/repositories/saved_customers_repository.dart';
import 'package:buildsmart/logic/input_validators.dart' show normalizePhone;
import 'package:buildsmart/logic/text_normalize.dart' show normName;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kSavedCustomersKey = 'bs.saved-customers.v1';

/// A saved CRM customer entity — immutable. Orders join by NAME (normName),
/// so [name] is the link key; [phone] sharpens dedup and drives contact.
class SavedCustomer {
  const SavedCustomer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.businessId = '',
    this.notes = '',
    this.tags = const [],
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String businessId; // ח"פ / עוסק מורשה — optional
  final String notes;
  final List<String> tags;

  /// The dedup identity: normalized name + normalized phone. Two inputs that
  /// fold to the same key are the SAME customer (a re-entry updates, never
  /// duplicates).
  String get dedupKey => '${normName(name)}|${normalizePhone(phone)}';

  SavedCustomer copyWith({
    String? name,
    String? phone,
    String? email,
    String? businessId,
    String? notes,
    List<String>? tags,
  }) => SavedCustomer(
    id: id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    businessId: businessId ?? this.businessId,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (phone.isNotEmpty) 'phone': phone,
    if (email.isNotEmpty) 'email': email,
    if (businessId.isNotEmpty) 'businessId': businessId,
    if (notes.isNotEmpty) 'notes': notes,
    if (tags.isNotEmpty) 'tags': tags,
  };

  static SavedCustomer? tryFromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'];
    final name = j['name'];
    if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
      return null; // structural — a customer needs an id and a name
    }
    return SavedCustomer(
      id: id,
      name: name,
      phone: j['phone'] is String ? j['phone'] as String : '',
      email: j['email'] is String ? j['email'] as String : '',
      businessId: j['businessId'] is String ? j['businessId'] as String : '',
      notes: j['notes'] is String ? j['notes'] as String : '',
      tags:
          j['tags'] is List
              ? [
                for (final t in j['tags'] as List)
                  if (t is String) t,
              ]
              : const [],
    );
  }
}

/// PURE dedup-on-input: fold [incoming] into [list]. If an entry shares the
/// dedup key (or the same id), it is REPLACED IN PLACE keeping its id and list
/// position (an edit, not a move); otherwise [incoming] is appended. This is
/// the whole CRM dedup contract — unit-tested without any prefs/widget.
List<SavedCustomer> upsertCustomer(
  List<SavedCustomer> list,
  SavedCustomer incoming,
) {
  final key = incoming.dedupKey;
  final idx = list.indexWhere((c) => c.id == incoming.id || c.dedupKey == key);
  if (idx < 0) return [...list, incoming];
  final kept = list[idx];
  // Keep the EXISTING id (a dedup hit on name+phone edits the found record).
  final merged = SavedCustomer(
    id: kept.id,
    name: incoming.name,
    phone: incoming.phone,
    email: incoming.email,
    businessId: incoming.businessId,
    notes: incoming.notes,
    tags: incoming.tags,
  );
  return [...list.sublist(0, idx), merged, ...list.sublist(idx + 1)];
}

/// The saved-customer for a display name (the order→customer join, by
/// normalized name). null when no saved entity matches. PURE.
SavedCustomer? customerForName(List<SavedCustomer> list, String displayName) {
  final key = normName(displayName);
  for (final c in list) {
    if (normName(c.name) == key) return c;
  }
  return null;
}

class CustomersStore extends StateNotifier<List<SavedCustomer>> {
  CustomersStore([this._repo]) : super(const []) {
    _load();
  }

  /// The server store for the CRM (`savedCustomers/{uid}`) when USER_DATA_SERVER
  /// is on for a real signed-in user; null (the default) ⇒ the SharedPreferences
  /// path below, byte-identical to before. Injected by [savedCustomersProvider].
  final SavedCustomersRepository? _repo;

  /// True once the initial load has finished (data, empty or failed). Until
  /// then a mutation is applied to the visible list AND remembered in
  /// [_pending], but NOT persisted: persisting a list built on the empty
  /// constructor state would overwrite every stored customer. When the load
  /// lands, the pending mutations are REPLAYED on top of the loaded list and
  /// the merged result is persisted once. (Before: a write that came first —
  /// e.g. a CSV import before any customer sheet watched the provider — set a
  /// "skip load" latch, so the stored CRM was dropped and overwritten.)
  bool _ready = false;
  final List<List<SavedCustomer> Function(List<SavedCustomer>)> _pending = [];

  void _mutate(List<SavedCustomer> Function(List<SavedCustomer>) op) {
    super.state = op(state);
    if (_ready) {
      _persist(state);
    } else {
      _pending.add(op);
    }
  }

  /// Load finished: rebase pending mutations onto [loaded] (null = nothing
  /// stored / load failed ⇒ rebase onto the current base, i.e. empty).
  void _settle(List<SavedCustomer>? loaded) {
    if (_ready) return;
    _ready = true;
    var next = loaded ?? const <SavedCustomer>[];
    final hadPending = _pending.isNotEmpty;
    for (final op in _pending) {
      next = op(next);
    }
    _pending.clear();
    // Disposed mid-load: still persist the merge so a pending write isn't lost.
    if (mounted) super.state = next;
    if (hadPending) _persist(next);
  }

  Future<void> _load() async {
    final repo = _repo;
    if (repo != null) {
      // Server path (USER_DATA_SERVER): the CRM lives at `savedCustomers/{uid}`.
      List<SavedCustomer>? list;
      try {
        list = await repo.load(repo.currentUid);
      } on Object catch (e) {
        debugPrint('CustomersStore: server load failed (ignored): $e');
      }
      _settle(list);
      return;
    }
    List<SavedCustomer>? out;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kSavedCustomersKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          out = <SavedCustomer>[];
          for (final e in decoded) {
            final c = SavedCustomer.tryFromJson(e);
            if (c != null) out.add(c); // per-entry tolerant — bad row skipped
          }
        }
      }
    } on Object catch (e) {
      debugPrint('CustomersStore: load failed (ignored): $e');
    }
    _settle(out);
  }

  /// Persist [list] — a snapshot taken by the caller, so a late async hop
  /// never reads `state` after dispose.
  Future<void> _persist(List<SavedCustomer> list) async {
    final repo = _repo;
    if (repo != null) {
      // Server path: mirror the whole CRM to `savedCustomers/{uid}`.
      try {
        await repo.save(repo.currentUid, list);
      } on Object catch (e) {
        debugPrint('CustomersStore: server persist failed (ignored): $e');
      }
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kSavedCustomersKey,
        jsonEncode([for (final c in list) c.toJson()]),
      );
    } on Object catch (e) {
      debugPrint('CustomersStore: persist failed (quota?): $e');
    }
  }

  /// Add or edit — dedups on name+phone (see [upsertCustomer]).
  void upsert(SavedCustomer c) => _mutate((l) => upsertCustomer(l, c));

  /// Bulk import — fold every [incoming] row through the SAME dedup as
  /// [upsert], then assign ONCE so prefs is written a single time (a per-row
  /// upsert would persist N times and interleave). Empty input is a no-op.
  void importAll(List<SavedCustomer> incoming) {
    if (incoming.isEmpty) return;
    _mutate((list) {
      var next = list;
      for (final c in incoming) {
        next = upsertCustomer(next, c);
      }
      return next;
    });
  }

  /// Forget a saved customer by id.
  void remove(String id) => _mutate(
    (l) => [
      for (final c in l)
        if (c.id != id) c,
    ],
  );
}

final savedCustomersProvider =
    StateNotifierProvider<CustomersStore, List<SavedCustomer>>(
      (ref) => CustomersStore(ref.watch(savedCustomersRepositoryProvider)),
    );

/// The saved entity matching a display name (the by-name order join), or null.
final savedCustomerForProvider = Provider.family<SavedCustomer?, String>(
  (ref, name) => customerForName(ref.watch(savedCustomersProvider), name),
);
