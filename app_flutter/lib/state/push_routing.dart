// Where a tapped notification lands.
//
// A notification whose only promise is "the app will open" is barely a
// notification. The whole value is that it is a LINK: it says who wrote and what
// they said, and tapping it puts you in that conversation. The routing seam for
// this was built and left empty — `PushController._onOpened` carries the comment
// "actual deep-navigation ... is a documented FOLLOW-UP", and nothing ever passed
// an `onOpened`. So the payload arrived carrying its `threadId`, and the app
// opened on whatever screen it had been on.
//
// THE TRAP THIS FILE EXISTS TO AVOID. `ChatsScreen` opens a conversation when
// `updatesChatOpenProvider` CHANGES — it watches with `ref.listen`, which does
// not fire for a value that was already set before the listener existed. Every
// push route hits exactly that case:
//
//   cold launch   the app was not running; the id is known before any screen
//   web, no tab   the browser opens a fresh page with ?thread= in the URL
//   warm resume   the id is set, then we navigate — the screen mounts AFTER
//
// In all three the id is in place before `ChatsScreen` starts listening, so a
// listen-only handoff silently drops it — a notification that opens the app and
// then does nothing, which is worse than one that does not open it at all.
// Hence a pending value that is READ on arrival and cleared by whoever consumes
// it, rather than an event that must be caught mid-air.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A conversation a tapped notification asked for, waiting to be consumed.
///
/// Set by every push entry point; cleared by the screen that opens the thread.
/// It holds rather than fires precisely because the listener usually does not
/// exist yet — see the note above.
final pendingPushThreadProvider = StateProvider<String?>((_) => null);

/// Pull a thread id out of a push payload.
///
/// The key matches what `functions/src/push.ts` puts in the FCM data block
/// (`onChatMessageCreated` → `sendToUsers(..., { threadId })`). Anything else in
/// that payload is ignored: a notification about an order is not a conversation,
/// and routing it to one would be worse than routing it nowhere.
String? threadIdFrom(Map<String, dynamic> data) {
  final raw = data['threadId'];
  if (raw is! String) return null;
  final id = raw.trim();
  return id.isEmpty ? null : id;
}

/// The `?thread=` a fresh browser page is launched with when no tab was open.
///
/// Read once at startup. The value is a Firestore document id from our own
/// server payload, not free text — but it still only ever reaches a lookup that
/// fails closed on no match, never a route name or a query.
String? threadIdFromLaunchUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  final id = Uri.tryParse(url)?.queryParameters['thread']?.trim();
  return (id == null || id.isEmpty) ? null : id;
}

/// Hand a thread id to whoever opens conversations, from any entry point.
void requestThreadOpen(WidgetRef ref, String threadId) =>
    ref.read(pendingPushThreadProvider.notifier).state = threadId;

/// Take the waiting thread id, if there is one, and clear it in the same breath.
///
/// Clearing on read is what lets a SECOND notification for the same conversation
/// re-open it: without it the value would still be there, unchanged, and a
/// change-based listener would never fire again.
String? consumePendingThread(WidgetRef ref) {
  final id = ref.read(pendingPushThreadProvider);
  if (id != null) ref.read(pendingPushThreadProvider.notifier).state = null;
  return id;
}

/// Run [open] once the current frame is done.
///
/// Opening a conversation pushes a route, and a route cannot be pushed while the
/// widget tree is still building — the release-only crash this codebase has
/// already paid for once. Every push entry point lands during a build or a
/// lifecycle callback, so they all go through here.
void afterThisFrame(VoidCallback open) =>
    WidgetsBinding.instance.addPostFrameCallback((_) => open());
