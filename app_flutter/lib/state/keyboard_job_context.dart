// The JOB the floating keyboard is currently helping with — the product SKUs of
// the task the user opened (its "מה להביא" kit). This is the keystroke-ZERO signal
// (swarm finding #2): it steers even the FIRST pick, on an empty cart, toward what
// the OPEN JOB needs — because from the letters alone the keyboard can't know which
// of ~100 "couplers" you mean, but the job you're on can.
//
// Empty by default ⇒ NO effect: the dive ranking falls back to letters + prominence
// + (once something's staged) the compat mate-boost. Read only inside the
// [kGlobalSearch] branch of diveResultsProvider, so flag-off / unused ⇒
// byte-identical. Server-ready: the real open-job's product list replaces whatever
// a task screen seeds here.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SKUs of the job the keyboard is steering toward. A task screen sets this when
/// the user opens it; empty means "no job in focus" (the safe default).
final keyboardJobSkusProvider = StateProvider<List<String>>((_) => const []);
