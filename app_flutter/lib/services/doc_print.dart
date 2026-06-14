// SERVER-SWAP — document print/PDF seam (#106/#107 · Wave-3 contract Builder-2).
//
// One public seam: [printDocument] hands a printable HTML body (built by the
// pure logic/printable_docs.dart) to the platform. On WEB it opens the doc and
// triggers the browser print/"Save as PDF" dialog; on native/VM there is no
// printer wired yet so it returns false — the caller shows an honest toast
// ('הדפסה זמינה בדפדפן') rather than pretending it printed.
//
// Conditional import keeps `package:web` / `dart:js_interop` OFF the native + VM
// compile path (flutter test runs on the Dart VM, where package:web's js-interop
// helpers do not compile) — the suite stays green — while the web build picks up
// the real implementation. Same pattern as services/geo.dart and
// services/photo_downscale.dart.
//   • WEB (doc_print_web.dart) — hidden iframe + contentWindow.print(); false on
//     any failure.
//   • NATIVE/VM (doc_print_stub.dart) — STUB returning false. SERVER-SWAP: file
//     the rendered PDF server-side here when going native; the
//     `Future<bool> printDocument(...)` contract stays byte-identical so callers
//     need no change.
import 'doc_print_stub.dart' if (dart.library.js_interop) 'doc_print_web.dart'
    as impl;

/// Sends [html] (a self-contained printable document, e.g. from
/// `buildPrintableHtml`) to the platform print/PDF flow under the window [title].
///
/// Returns true when the print dialog was triggered (web), false when printing
/// is unavailable on this target (native/VM until the SERVER-SWAP) or any error
/// occurred — never throws.
Future<bool> printDocument({required String title, required String html}) =>
    impl.printDocument(title: title, html: html);
