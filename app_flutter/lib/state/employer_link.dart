import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The contractor (employer) a worker is employed by, as the worker's screens
/// need to read it — name / businessId / address / contact. A read-only
/// projection: there is no setter here, because the worker never edits the
/// employer's details (only the contractor owns their own [UserProfile]).
class EmployerProfile {
  const EmployerProfile({
    this.name = '',
    this.businessId = '',
    this.address = '',
    this.contact = '',
  });

  /// Employer (contractor) full name (שם הקבלן / העסק).
  final String name;

  /// Employer business id (ח.פ. / עוסק מורשה).
  final String businessId;

  /// Employer address / business address (כתובת העסק).
  final String address;

  /// Employer phone or email (טלפון או אימייל של המעסיק).
  final String contact;

  /// `true` when no employer detail is known — the worker has no resolvable
  /// employer link yet (empty `employerId`, or a contractor with a blank
  /// profile). Consumers use this to show the honest "will connect to the
  /// server" hint instead of a half-filled employer block.
  bool get isEmpty =>
      name.isEmpty && businessId.isEmpty && address.isEmpty && contact.isEmpty;
}

/// Resolves a worker's `employerId` (the link minted in `board_auth.dart`) to
/// the employing contractor's [EmployerProfile].
///
/// SERVER-SWAP SEAM (mirrors the `orders_local.dart` server-ready foundation).
/// When the backend lands this body becomes a `contractors/{employerId}`
/// repo/cache-bridge fetch — only THIS provider swaps, and every consumer that
/// reads `employerProfileProvider(session.employerId)` is unchanged. TODAY the
/// single-device demo holds exactly ONE contractor (the device's own
/// [userProfileProvider], key `bs.profile.v1`), so ANY non-empty `employerId`
/// resolves to that one device contractor — honest, because there is one
/// contractor per device and we fabricate no second identity. An empty
/// `employerId` (no link — e.g. the contractor/manager/store themselves) yields
/// `const EmployerProfile()` so [EmployerProfile.isEmpty] is true and the
/// consumer shows the "to be connected with the server" hint.
final employerProfileProvider =
    Provider.family<EmployerProfile, String>((ref, employerId) {
  if (employerId.isEmpty) return const EmployerProfile();
  // SERVER-SWAP: → fetch `contractors/{employerId}` (cache-bridged). Until then,
  // the one device contractor IS the employer (one contractor per device).
  final contractor = ref.watch(userProfileProvider);
  return EmployerProfile(
    name: contractor.name,
    businessId: contractor.businessId,
    address: contractor.address,
    contact: contractor.contact,
  );
});
