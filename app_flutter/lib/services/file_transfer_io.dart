// IO (mobile/desktop-native) side of the file-transfer seam — see
// file_transfer.dart. Phase A is web-first (the web preview links are the
// target); no native download/pick/reload path is wired yet, so these stubs
// honestly report "unavailable" — false / null / nothing, never a throw and
// never a pretend success.

import 'file_transfer.dart';

/// Mobile/desktop leg arrives with the store build — honest false (no
/// download happened), never a throw.
Future<bool> downloadTextFileImpl(
  String filename,
  String text,
  String mime,
) async =>
    false;

/// Mobile/desktop leg arrives with the store build — honest null (no picker
/// here), never a throw.
Future<PickedTextFile?> pickTextFileImpl(String accept) async => null;

/// Mobile/desktop leg arrives with the store build — honest no-op (nothing
/// reloads), never a throw.
void reloadAppImpl() {}
