import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One analytics event. In-memory only — never persisted, since event
/// payloads may carry sensitive context. Roadmap step 91 (in-app event log
/// foundation; external analytics like GA/Mixpanel is a separate wall-step
/// — any future analytics layer subscribes to this primitive).
@immutable
class AnalyticsEvent {
  const AnalyticsEvent({
    required this.name,
    required this.at,
    this.props = const {},
  });

  final String name;
  final Map<String, String> props;
  final DateTime at;
}

class AnalyticsLogNotifier extends StateNotifier<List<AnalyticsEvent>> {
  AnalyticsLogNotifier({this.maxEntries = 500}) : super(const []);

  final int maxEntries;

  /// Add a new event to the **front** (newest first) and trim to [maxEntries].
  void record(String name, {Map<String, String> props = const {}}) {
    final event = AnalyticsEvent(
      name: name,
      props: props,
      at: DateTime.now(),
    );
    final next = <AnalyticsEvent>[event, ...state];
    if (next.length > maxEntries) {
      state = next.sublist(0, maxEntries);
    } else {
      state = next;
    }
  }

  void clear() {
    state = const [];
  }

  /// Count events with exact [name] match.
  int countByName(String name) {
    return state.where((e) => e.name == name).length;
  }

  /// Up to [limit] most-recent events matching the predicate. When [name] is
  /// non-null, only events whose name equals [name] are considered.
  List<AnalyticsEvent> recent({String? name, int limit = 50}) {
    final filtered = name == null
        ? state
        : state.where((e) => e.name == name).toList(growable: false);
    if (filtered.length <= limit) {
      return List<AnalyticsEvent>.unmodifiable(filtered);
    }
    return List<AnalyticsEvent>.unmodifiable(filtered.sublist(0, limit));
  }
}

final analyticsLogProvider =
    StateNotifierProvider<AnalyticsLogNotifier, List<AnalyticsEvent>>(
  (_) => AnalyticsLogNotifier(),
);
