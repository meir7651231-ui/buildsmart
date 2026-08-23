// File-transfer seam (import/export wave) — download a text file, pick+read a
// text file, and reload the app.
//
// Phase A is WEB-FIRST: the target is the web preview links, so only the web
// leg does real work. Zero new dependencies — `package:web ^1.1.0` is already
// a direct dep (photo_downscale_web / geo_web / doc_print_web use it).
//
// Conditional import/export keeps `package:web` / `dart:js_interop` OFF the
// native + VM compile path (flutter test runs on the Dart VM, where
// package:web's js-interop helpers do not compile) — the suite stays green —
// while the web build picks up the real implementations. Same pattern as
// services/geo.dart and services/photo_downscale.dart.
//   • WEB (file_transfer_web.dart) — Blob → object-URL → <a download> click;
//     <input type=file> pick + FileReader.readAsText; window.location.reload.
//   • NATIVE/VM (file_transfer_io.dart) — honest no-ops (false / null /
//     nothing, never a throw) until the store build brings the native legs.
//
// Widgets go through the Riverpod providers below — the injectable-seam idiom
// of lib/state/share_seam.dart — so widget tests `overrideWithValue` capturing
// fakes and never touch the platform.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'file_transfer_io.dart'
    if (dart.library.js_interop) 'file_transfer_web.dart';

export 'file_transfer_io.dart'
    if (dart.library.js_interop) 'file_transfer_web.dart';

/// A text file the user picked: its [name] (as reported by the platform
/// picker) and its full decoded UTF-8 [content].
class PickedTextFile {
  const PickedTextFile(this.name, this.content);

  final String name;
  final String content;
}

/// Downloads [text] to the user's device as [filename] (MIME type [mime]).
/// Resolves true when the download was handed to the platform, false when the
/// platform has no download path (IO leg) or the attempt failed — never
/// throws. The text is written AS-IS: callers prepend a BOM themselves when
/// they need one.
typedef DownloadTextFile =
    Future<bool> Function(String filename, String text, String mime);

/// Opens the platform file picker (filtered to [accept], e.g. '.json') and
/// resolves the chosen file's name + text content, or null when nothing could
/// be read. NOTE (web v1): dismissing the browser picker fires no event, so
/// the future simply never resolves — callers must keep their UI usable while
/// awaiting (the sheet just stays open).
typedef PickTextFile = Future<PickedTextFile?> Function(String accept);

/// Reloads the whole app (web: `window.location.reload()`); no-op on IO.
typedef ReloadApp = void Function();

/// The download seam. Production keeps the platform impl (conditional import
/// above); tests override with a capturing fake — same idiom as
/// `shareTextProvider`.
final downloadTextFileProvider =
    Provider<DownloadTextFile>((_) => downloadTextFileImpl);

/// The pick seam. Tests override it to feed a canned [PickedTextFile] (or
/// null) without a live browser picker.
final pickTextFileProvider = Provider<PickTextFile>((_) => pickTextFileImpl);

/// The reload seam. Tests override it to assert a reload was requested
/// without actually tearing the test harness down.
final reloadAppProvider = Provider<ReloadApp>((_) => reloadAppImpl);
