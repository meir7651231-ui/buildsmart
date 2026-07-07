// ─────────────────────────────────────────────────────────────────────────────
// intel_sink — Pillar-3 STUDIO · step 90 — the REAL consent-gated, BATCHED
// forward sink (destination 3 of the IntelBus fan-out, step 89).
//
// This is the ONLY intel/ file that imports `cloud_firestore` — the SDK is
// ISOLATED here exactly like the Pillar-5 authored_products adapter
// (authored_products_firebase.dart), so the rest of the intel layer + the whole
// Firebase-free test suite never pull a live Firestore handle. The consent +
// backend DOUBLE-GATE lives in `intelSinkProvider` (intel_bus.dart): off-backend
// / pre-consent that provider yields the inert `NoopIntelSink` instead, so this
// class is NEVER constructed on the demo/test path — byte-identical, zero timer,
// zero platform channel (the connection_status.dart:82 `if (!_active) return;`
// inert idiom, expressed here as NON-CONSTRUCTION).
//
// THE CONTRACT (§2/§4):
//   • enqueue(e) APPENDS to an in-memory queue and RETURNS immediately — a tap
//     never blocks on I/O.
//   • a flush fires on the FIRST of: N events (kIntelBatchSize), T elapsed
//     (kIntelFlushInterval timer), or an explicit pause()/flush() (session_end /
//     logout, §9). ONE flush = ONE Firestore WriteBatch, one `set` per queued
//     event's toWire() into the `intelEvents` collection (auto-id docs).
//   • toWire() OMITS the human displayName + all PII by construction (R1-4) — only
//     the pseudonymous actorKey / uid + scalar props ever leave the device.
//   • a FAILED flush RE-QUEUES the batch (capped at kIntelQueueCap — the OLDEST
//     dropped beyond it, never unbounded) and NEVER throws to the caller — the
//     firestore_cached_repo.dart guardWrite fire-and-forget discipline (HARD RULE
//     #2, :20/:203): a network blip degrades to a retry, it never crashes a screen.
//
// The batch-write is abstracted behind the tiny [IntelBatchWriter] port so the
// sink's queue/flush/requeue logic is unit-tested with a recording fake and ZERO
// Firebase (test/intel/intel_sink_test.dart) — the realtime_wiring_test.dart:34
// `_FakeSource implements <port>` idiom.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:buildsmart/state/intel/intel_bus.dart' show IntelSink;
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Flush trigger — the queue length that forces an immediate batch (§2). At this
/// size the worst case is ≤ ~6 writes/min/active user, never a write-per-tap.
const int kIntelBatchSize = 25;

/// Flush trigger — the longest a tail event waits before its batch is written.
const Duration kIntelFlushInterval = Duration(seconds: 10);

/// The hard queue ceiling (§4). A re-queued backlog never grows past this: the
/// OLDEST events beyond it are dropped. Aligned with the Firestore WriteBatch
/// 500-op limit, so a full-queue flush is always ONE legal batch.
const int kIntelQueueCap = 500;

/// The intel-events collection — a clear, dedicated name (NEVER a `catalog_*`
/// collection, which stays static / zero-DB-cost per S3.K).
const String kIntelCollection = 'intelEvents';

/// The tiny batch-write PORT the sink forwards through. It speaks only neutral
/// wire maps (the `IntelEvent.toWire()` shape), NOT Firestore types, so a
/// recording fake drives every unit test Firebase-free and only
/// [FirestoreIntelBatchWriter] imports a live `cloud_firestore`. A failure THROWS
/// (the sink catches + re-queues); the port itself never swallows.
// ignore: one_member_abstracts
abstract class IntelBatchWriter {
  /// Write every doc in [docs] as ONE atomic batch. Throws on failure.
  Future<void> writeBatch(List<Map<String, Object?>> docs);
}

/// The REAL Firestore batch writer. Resolves `FirebaseFirestore.instance` LAZILY
/// (never at construction — a `const` ctor with a nullable injected instance), so
/// merely constructing it touches no platform channel; the instance is read only
/// inside [writeBatch]. Mirrors FirestoreCollectionSource
/// (firestore_cached_repo.dart:117) / FirestoreAuthoredProductsSource.
class FirestoreIntelBatchWriter implements IntelBatchWriter {
  const FirestoreIntelBatchWriter({
    FirebaseFirestore? firestore,
    this.collectionPath = kIntelCollection,
  }) : _injected = firestore;

  final FirebaseFirestore? _injected;
  final String collectionPath;

  FirebaseFirestore get _db => _injected ?? FirebaseFirestore.instance;

  @override
  Future<void> writeBatch(List<Map<String, Object?>> docs) async {
    if (docs.isEmpty) return;
    final db = _db;
    final col = db.collection(collectionPath);
    final batch = db.batch();
    for (final doc in docs) {
      // One auto-id doc per event — the sink never reuses ids (append-only
      // stream); the doc is the pseudonymous `toWire()` map (no displayName).
      batch.set(col.doc(), doc);
    }
    await batch.commit();
  }
}

/// The consent-gated, batched forward sink. Built ONLY behind the double-gate in
/// `intelSinkProvider` (intel_bus.dart) — off-backend / pre-consent that provider
/// returns the inert `NoopIntelSink` instead, so this class never exists on the
/// demo/test path. See the file header for the full N/T/paused + requeue + cap +
/// never-throw contract.
class FirestoreIntelSink implements IntelSink {
  FirestoreIntelSink({
    required IntelBatchWriter writer,
    Duration flushInterval = kIntelFlushInterval,
    int batchSize = kIntelBatchSize,
    int queueCap = kIntelQueueCap,
  })  : _writer = writer,
        _flushInterval = flushInterval,
        _batchSize = batchSize,
        _queueCap = queueCap;

  final IntelBatchWriter _writer;
  final Duration _flushInterval;
  final int _batchSize;
  final int _queueCap;

  /// The in-memory forward queue (oldest-first). Bounded by [_queueCap].
  final List<IntelEvent> _queue = <IntelEvent>[];

  /// The T-trigger timer — at most one pending at a time.
  Timer? _timer;

  /// Re-entrancy latch: a flush is async; a second flush while one is in flight
  /// no-ops (the in-flight one already owns the current batch).
  bool _flushing = false;

  /// Current queue depth — a test seam (queue-cap / requeue assertions).
  @visibleForTesting
  int get queueLength => _queue.length;

  /// §2 — APPEND + return immediately (never blocks a tap). Enforces the cap,
  /// then flushes NOW if the batch is full, else schedules the T-timer.
  @override
  void enqueue(IntelEvent e) {
    _queue.add(e);
    _enforceCap();
    if (_queue.length >= _batchSize) {
      unawaited(flush());
    } else {
      _ensureTimer();
    }
  }

  /// Flush the WHOLE queue as ONE batch (§2). Fired by N (enqueue), T (timer) or
  /// an explicit [pause]/flush. NEVER throws: a failed write re-queues (capped)
  /// and is swallowed + logged — the guardWrite discipline (§4).
  Future<void> flush() async {
    if (_flushing) return; // a flush already owns the current batch
    _timer?.cancel();
    _timer = null;
    if (_queue.isEmpty) return;
    _flushing = true;
    final batch = List<IntelEvent>.of(_queue);
    _queue.clear();
    try {
      await _writer.writeBatch(
        batch.map((e) => e.toWire()).toList(growable: false),
      );
    } on Object catch (e) {
      // Re-queue the failed batch (oldest-first preserved) — capped, never lost
      // unboundedly, never re-raised. A later flush retries it.
      _requeue(batch);
      debugPrint(
        'FirestoreIntelSink: flush failed, re-queued ${batch.length} (ignored): $e',
      );
    } finally {
      _flushing = false;
      // A tail that arrived DURING the flush, or the just-re-queued batch, still
      // needs a scheduled flush.
      if (_queue.isNotEmpty) _ensureTimer();
    }
  }

  /// §9 — flush the tail on session_end / logout so the last events are not lost
  /// before exit. Just an explicit [flush] (which also cancels the T-timer).
  Future<void> pause() => flush();

  /// Prepend the failed [batch] back to the FRONT (chronological order kept),
  /// then drop the OLDEST beyond the cap.
  void _requeue(List<IntelEvent> batch) {
    _queue.insertAll(0, batch);
    _enforceCap();
  }

  /// §4 — the hard cap: never let the queue grow unbounded. Drops the OLDEST.
  void _enforceCap() {
    if (_queue.length > _queueCap) {
      _queue.removeRange(0, _queue.length - _queueCap);
    }
  }

  /// Schedule the single T-trigger timer if none is pending.
  void _ensureTimer() {
    _timer ??= Timer(_flushInterval, () {
      _timer = null;
      unawaited(flush());
    });
  }

  /// Cancel the pending timer (the provider wires this to `ref.onDispose`). Does
  /// NOT flush — use [pause]/[flush] to drain the tail before disposing.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
