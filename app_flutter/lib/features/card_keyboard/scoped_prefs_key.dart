// scoped_prefs_key.dart — namespaces a SharedPreferences key by the active identity
// so a shared fleet tablet never bleeds one employee's persisted state (favorites /
// recents / picks) to the next (round-2 blocker-5: every store used ONE global
// uid-less key). The stores adopt this in the P0.5 persistence steps; a null/empty
// uid preserves today's EXACT global key, so signed-out / flag-OFF behaviour is
// byte-identical. Pure — no Flutter, no IO.

/// The legacy [base] key when [uid] is null/empty (today's single global list);
/// `base::uid` for a real identity (so A's and B's lists never collide on disk).
String scopedPrefsKey(String base, String? uid) =>
    (uid == null || uid.isEmpty) ? base : '$base::$uid';
