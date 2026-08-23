// Injectable URL-launch seam for the contact 📞/💬 buttons.
//
// `url_launcher`'s real `launchUrl` cannot run in a unit/widget test (no
// platform channel), so every launch goes through THIS provider instead of
// calling `launchUrl` directly. Production binds it to the real launcher;
// tests `overrideWithValue` a capturing fake to assert the exact `tel:` /
// `https://wa.me/…` Uri a button builds — without a live platform.
//
// No in-app calling lives here: we only hand the Uri off to the OS (the native
// dialer for `tel:`, WhatsApp/the browser for `wa.me`).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// A function that opens [uri] with the platform handler and reports success.
/// Mirrors `launchUrl`'s `Future<bool>` contract so the default can be a thin
/// tear-off and a test fake is a drop-in replacement.
typedef UrlLauncher = Future<bool> Function(Uri uri);

/// The default real launcher — opens [uri] in an external application
/// (the dialer for `tel:`, WhatsApp/browser for `https://wa.me/…`).
Future<bool> launchExternalUri(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);

/// The seam. Production keeps [launchExternalUri]; tests override it with a
/// fake that records the Uri (see `test/contact_actions_test.dart`).
final urlLauncherProvider = Provider<UrlLauncher>((_) => launchExternalUri);
