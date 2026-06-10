import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local user profile — ported from the prototype's `bs.profile.v1`
/// (`app/src/store/user-profile.ts`). No server / password: identity data is
/// kept on-device (demo-friendly). Collected in the first-run opening flow
/// (welcome/register → profession) and editable later in settings.
class UserProfile {
  const UserProfile({
    this.name = '',
    this.contact = '',
    this.profession = '',
    this.address = '',
    this.businessId = '',
    this.registered = false,
  });

  /// Full name (שם מלא).
  final String name;

  /// Phone or email (טלפון או אימייל).
  final String contact;

  /// Trade picked in the profession step (אינסטלטור / חשמלאי / קבלן שיפוצים).
  final String profession;

  /// Address / service area (כתובת / אזור) — optional.
  final String address;

  /// Business id (ח.פ. / עוסק מורשה) — optional.
  final String businessId;

  /// `true` once the user registered; `false` if they chose "continue as demo".
  final bool registered;

  UserProfile copyWith({
    String? name,
    String? contact,
    String? profession,
    String? address,
    String? businessId,
    bool? registered,
  }) =>
      UserProfile(
        name: name ?? this.name,
        contact: contact ?? this.contact,
        profession: profession ?? this.profession,
        address: address ?? this.address,
        businessId: businessId ?? this.businessId,
        registered: registered ?? this.registered,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'contact': contact,
        'profession': profession,
        'address': address,
        'businessId': businessId,
        'registered': registered,
      };

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        name: j['name'] as String? ?? '',
        contact: j['contact'] as String? ?? '',
        profession: j['profession'] as String? ?? '',
        address: j['address'] as String? ?? '',
        businessId: j['businessId'] as String? ?? '',
        registered: j['registered'] as bool? ?? false,
      );
}

/// SharedPreferences key (mirrors the prototype's localStorage key).
const String kUserProfileKey = 'bs.profile.v1';

/// Registration is valid when both name and contact are non-empty — mirrors the
/// prototype's `checkRegistration` (the ✓ appears once the fields are filled).
/// Pure → unit-testable.
bool registrationValid(String name, String contact) =>
    name.trim().isNotEmpty && contact.trim().isNotEmpty;

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(const UserProfile()) {
    _load();
  }

  /// `true` once any mutating method (register/continueAsDemo/setProfession/
  /// update) has written state. The provider is lazy, so the constructor's
  /// async `_load()` can resolve AFTER a synchronous user write (ticket #24:
  /// re-registration overwritten by the late prefs read). This one-shot guard
  /// makes a late `_load()` non-destructive once the user has touched state.
  bool _userTouched = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUserProfileKey);
    if (raw == null) return;
    if (_userTouched) return;
    try {
      state = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (_) {
      // Corrupt value — keep defaults.
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kUserProfileKey, jsonEncode(state.toJson()));
  }

  /// Register with a name + contact (phone/email).
  void register({required String name, required String contact}) {
    _userTouched = true;
    state = state.copyWith(
      name: name.trim(),
      contact: contact.trim(),
      registered: true,
    );
    _persist();
  }

  /// Continue without registering (demo / guest).
  void continueAsDemo() {
    _userTouched = true;
    state = state.copyWith(registered: false);
    _persist();
  }

  /// Set the picked trade.
  void setProfession(String profession) {
    _userTouched = true;
    state = state.copyWith(profession: profession);
    _persist();
  }

  /// S1.7/S1.8 (auth) — wipe the profile back to defaults on logout / account
  /// deletion: clears the in-memory state AND removes the persisted key (this
  /// notifier owns `bs.profile.v1`, so the wipe lives here, not in the auth
  /// layer). Marks [_userTouched] so a still-pending [_load] cannot resurrect
  /// the old identity (same race as ticket #24, opposite direction).
  void reset() {
    _userTouched = true;
    state = const UserProfile();
    unawaited(
      SharedPreferences.getInstance().then((p) => p.remove(kUserProfileKey)),
    );
  }

  /// Edit profile fields from the profile screen. Unspecified fields are kept;
  /// `registered` flips true once name+contact are both valid, so a guest who
  /// fills them in graduates to a registered user (→ the name chip appears).
  void update({
    String? name,
    String? contact,
    String? profession,
    String? address,
    String? businessId,
  }) {
    _userTouched = true;
    final n = (name ?? state.name).trim();
    final c = (contact ?? state.contact).trim();
    state = state.copyWith(
      name: n,
      contact: c,
      profession: (profession ?? state.profession).trim(),
      address: (address ?? state.address).trim(),
      businessId: (businessId ?? state.businessId).trim(),
      registered: state.registered || registrationValid(n, c),
    );
    _persist();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);
