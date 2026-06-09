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

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kUserProfileKey);
    if (raw == null) return;
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
    state = state.copyWith(
      name: name.trim(),
      contact: contact.trim(),
      registered: true,
    );
    _persist();
  }

  /// Continue without registering (demo / guest).
  void continueAsDemo() {
    state = state.copyWith(registered: false);
    _persist();
  }

  /// Set the picked trade.
  void setProfession(String profession) {
    state = state.copyWith(profession: profession);
    _persist();
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
