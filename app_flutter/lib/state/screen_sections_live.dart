// ─────────────────────────────────────────────────────────────────────────────
// Screen-management LIVE lane — the read/subscribe half of "the manager's screen
// layout reaches everyone" (the write half is state/screen_sections_sink_firebase
// .dart + the publish hook in state/screen_sections.dart).
//
// It subscribes to the ONE owner-writable doc (`screenSectionsLive/current`) and
// feeds every remote layout map into [screenSectionsProvider] live — so a manager
// edit (reorder / hide / rename a screen's sections) reaches all open clients,
// exactly like org_config_live.dart adopts `orgConfigLive`.
//
// DoD: [useScreenSectionsLive] is false in every define-less build (and whenever
// Firebase is not initialised — so the whole test suite by construction) ⇒ the
// provider returns WITHOUT subscribing ⇒ zero I/O ⇒ byte-identical to today.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/state/screen_sections.dart'
    show screenSectionsProvider;
import 'package:buildsmart/state/screen_sections_sink_firebase.dart'
    show
        FirestoreScreenSectionsDocPort,
        ScreenSectionsDocPort,
        useScreenSectionsLive;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Test seam: override with a fake [ScreenSectionsDocPort] to drive the adopt
/// logic Firebase-free. Live builds resolve the real Firestore adapter.
final screenSectionsDocPortProvider = Provider<ScreenSectionsDocPort>(
  (ref) => const FirestoreScreenSectionsDocPort(),
);

/// Watch this at the app root to arm the live subscription. When
/// [useScreenSectionsLive] is false it returns immediately (no listener) — the
/// zero-regression path. Otherwise it adopts every remote layout map into
/// [screenSectionsProvider] via the notifier's tolerant `adoptRemote`.
final screenSectionsLiveProvider = Provider<void>((ref) {
  if (!useScreenSectionsLive) return; // flag off / no Firebase ⇒ byte-identical
  final port = ref.watch(screenSectionsDocPortProvider);
  final sub = port.snapshots().listen(
    (encoded) {
      try {
        ref
            .read(screenSectionsProvider.notifier)
            .adoptRemote(encoded ?? '');
      } on Object catch (e) {
        // A hiccup must never blank the layout — the last adopted map stands.
        debugPrint('screenSectionsLive adopt (ignored): $e');
      }
    },
    onError: (Object e) =>
        debugPrint('screenSectionsLive stream (ignored): $e'),
  );
  ref.onDispose(sub.cancel);
});
