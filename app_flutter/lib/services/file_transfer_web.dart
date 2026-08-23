// WEB implementation of the file-transfer seam — see file_transfer.dart.
// Selected only on web via the conditional import there
// (dart.library.js_interop), so package:web never reaches the native/VM
// compile path.
//
//   • download — text → Blob → object-URL → in-document <a download> click.
//     The text goes into the Blob AS-IS (callers add a BOM when needed).
//   • pick — <input type=file accept=…> → first File → FileReader.readAsText
//     (UTF-8 default). Cancelling the browser picker fires no change event,
//     so the future never resolves (documented v1 trade-off: the caller's
//     sheet simply stays open; no timeout, no invented result).
//   • reload — window.location.reload().

import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'file_transfer.dart';

/// Triggers a browser download of [text] as [filename] ([mime]). Returns true
/// once the anchor click was dispatched, false on any failure — never throws.
Future<bool> downloadTextFileImpl(
  String filename,
  String text,
  String mime,
) async {
  try {
    final blob = web.Blob(
      <JSAny>[text.toJS].toJS,
      web.BlobPropertyBag(type: mime),
    );
    final url = web.URL.createObjectURL(blob);
    try {
      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = filename;
      // In-document click (Firefox ignores clicks on detached anchors) — the
      // same append/remove dance as doc_print_web.dart's hidden iframe.
      web.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      return true;
    } finally {
      web.URL.revokeObjectURL(url);
    }
  } on Object catch (_) {
    return false; // browser refused (CSP, blob failure, …) — honest false
  }
}

/// Opens the browser file picker (accept=[accept]), reads the chosen file as
/// UTF-8 text, and resolves its name + content. Resolves null when the change
/// event carries no file or the read fails. A dismissed picker fires nothing —
/// the future stays pending (v1, see header).
Future<PickedTextFile?> pickTextFileImpl(String accept) {
  // The browser fires at most one change per pick, but stay defensive against
  // a double callback completing the Future twice (same as geo_web.dart).
  final completer = Completer<PickedTextFile?>();
  void finish(PickedTextFile? v) {
    if (!completer.isCompleted) completer.complete(v);
  }

  try {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept;
    input.onchange = ((web.Event _) {
      final file = input.files?.item(0);
      if (file == null) {
        finish(null); // change without a file — nothing honest to read
        return;
      }
      final reader = web.FileReader();
      reader.onload = ((web.Event _) {
        final result = reader.result;
        finish(
          result.isA<JSString>()
              ? PickedTextFile(file.name, (result! as JSString).toDart)
              : null, // non-text result — never an invented content
        );
      }).toJS;
      reader.onerror = ((web.Event _) => finish(null)).toJS;
      reader.readAsText(file); // UTF-8 is the FileReader default
    }).toJS;
    input.click();
  } on Object catch (_) {
    finish(null); // picker could not even open — honest null
  }
  return completer.future;
}

/// Full page reload — re-boots the Flutter web app so freshly imported
/// persisted state is read from storage on startup.
void reloadAppImpl() => web.window.location.reload();
