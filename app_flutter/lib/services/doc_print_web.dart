// WEB implementation of the document print seam (#106/#107 · contract Builder-2).
// Selected only on web via the conditional import in doc_print.dart
// (dart.library.js_interop), so package:web never reaches the native/VM compile
// path. Injects the printable HTML into a hidden same-document iframe, then calls
// the iframe's `contentWindow.print()` to raise the browser print / "Save as
// PDF" dialog. Any failure completes with false — never a pretend success.

import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Prints [html] via a hidden iframe and returns true once the print dialog has
/// been triggered. Returns false on any failure (no iframe document/window, or a
/// thrown error). [title] is applied to the iframe document for the dialog/PDF
/// filename hint.
Future<bool> printDocument({required String title, required String html}) {
  try {
    final iframe = web.HTMLIFrameElement()
      ..setAttribute('aria-hidden', 'true')
      // Off-screen + zero-size so the iframe never affects layout.
      ..style.position = 'fixed'
      ..style.right = '0'
      ..style.bottom = '0'
      ..style.width = '0'
      ..style.height = '0'
      ..style.border = '0';
    web.document.body?.append(iframe);

    final win = iframe.contentWindow;
    final doc = iframe.contentDocument;
    if (win == null || doc == null) {
      iframe.remove();
      return Future<bool>.value(false);
    }

    doc.open();
    doc.write(html.toJS);
    doc.title = title;
    doc.close();

    // Trigger after the document settles; clean the iframe up afterwards.
    win.focus();
    win.print();

    void cleanup() => iframe.remove();
    // Remove the iframe once the dialog closes (afterprint) and as a fallback
    // on a delay in case the event never fires.
    win.addEventListener('afterprint', ((web.Event _) => cleanup()).toJS);
    web.window.setTimeout(cleanup.toJS, 60000.toJS);

    return Future<bool>.value(true);
  } on Object catch (_) {
    return Future<bool>.value(false); // any failure — honest false
  }
}
