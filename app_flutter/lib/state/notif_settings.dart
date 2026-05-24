import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.notif-settings.v1';

enum NotifLockScreen { full, senderOnly, hidden }

class NotifSettings {
  const NotifSettings({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.typeOrders,
    required this.typeShipments,
    required this.typePriceDrops,
    required this.quietHoursEnabled,
    required this.quietStartHour,
    required this.quietStartMin,
    required this.quietEndHour,
    required this.quietEndMin,
    required this.dailySummary,
    required this.dailySummaryHour,
    required this.dailySummaryMin,
    required this.lockScreen,
    required this.snoozeUntilMs,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool typeOrders;
  final bool typeShipments;
  final bool typePriceDrops;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietStartMin;
  final int quietEndHour;
  final int quietEndMin;
  final bool dailySummary;
  final int dailySummaryHour;
  final int dailySummaryMin;
  final NotifLockScreen lockScreen;
  final int snoozeUntilMs;

  static const NotifSettings defaults = NotifSettings(
    pushEnabled: true,
    emailEnabled: true,
    typeOrders: true,
    typeShipments: true,
    typePriceDrops: true,
    quietHoursEnabled: false,
    quietStartHour: 22,
    quietStartMin: 0,
    quietEndHour: 7,
    quietEndMin: 0,
    dailySummary: false,
    dailySummaryHour: 8,
    dailySummaryMin: 0,
    lockScreen: NotifLockScreen.full,
    snoozeUntilMs: 0,
  );

  TimeOfDay get quietStart =>
      TimeOfDay(hour: quietStartHour, minute: quietStartMin);
  TimeOfDay get quietEnd =>
      TimeOfDay(hour: quietEndHour, minute: quietEndMin);
  TimeOfDay get dailySummaryTime =>
      TimeOfDay(hour: dailySummaryHour, minute: dailySummaryMin);

  bool get isSnoozedNow =>
      snoozeUntilMs > DateTime.now().millisecondsSinceEpoch;

  NotifSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? typeOrders,
    bool? typeShipments,
    bool? typePriceDrops,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietStartMin,
    int? quietEndHour,
    int? quietEndMin,
    bool? dailySummary,
    int? dailySummaryHour,
    int? dailySummaryMin,
    NotifLockScreen? lockScreen,
    int? snoozeUntilMs,
  }) {
    return NotifSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      typeOrders: typeOrders ?? this.typeOrders,
      typeShipments: typeShipments ?? this.typeShipments,
      typePriceDrops: typePriceDrops ?? this.typePriceDrops,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietStartMin: quietStartMin ?? this.quietStartMin,
      quietEndHour: quietEndHour ?? this.quietEndHour,
      quietEndMin: quietEndMin ?? this.quietEndMin,
      dailySummary: dailySummary ?? this.dailySummary,
      dailySummaryHour: dailySummaryHour ?? this.dailySummaryHour,
      dailySummaryMin: dailySummaryMin ?? this.dailySummaryMin,
      lockScreen: lockScreen ?? this.lockScreen,
      snoozeUntilMs: snoozeUntilMs ?? this.snoozeUntilMs,
    );
  }

  Map<String, dynamic> toJson() => {
        'pushEnabled': pushEnabled,
        'emailEnabled': emailEnabled,
        'typeOrders': typeOrders,
        'typeShipments': typeShipments,
        'typePriceDrops': typePriceDrops,
        'quietHoursEnabled': quietHoursEnabled,
        'quietStartHour': quietStartHour,
        'quietStartMin': quietStartMin,
        'quietEndHour': quietEndHour,
        'quietEndMin': quietEndMin,
        'dailySummary': dailySummary,
        'dailySummaryHour': dailySummaryHour,
        'dailySummaryMin': dailySummaryMin,
        'lockScreen': lockScreen.name,
        'snoozeUntilMs': snoozeUntilMs,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static NotifSettings fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) =>
        (j[k] as num?)?.toInt() ?? fallback;
    bool b(String k, {bool fallback = true}) =>
        j[k] is bool ? j[k] as bool : fallback;
    return NotifSettings(
      pushEnabled: b('pushEnabled'),
      emailEnabled: b('emailEnabled'),
      typeOrders: b('typeOrders'),
      typeShipments: b('typeShipments'),
      typePriceDrops: b('typePriceDrops'),
      quietHoursEnabled: b('quietHoursEnabled', fallback: false),
      quietStartHour: i('quietStartHour', 22),
      quietStartMin: i('quietStartMin', 0),
      quietEndHour: i('quietEndHour', 7),
      quietEndMin: i('quietEndMin', 0),
      dailySummary: b('dailySummary', fallback: false),
      dailySummaryHour: i('dailySummaryHour', 8),
      dailySummaryMin: i('dailySummaryMin', 0),
      lockScreen: _enum(
        j['lockScreen'],
        NotifLockScreen.values,
        NotifLockScreen.full,
      ),
      snoozeUntilMs: i('snoozeUntilMs', 0),
    );
  }
}

T _enum<T extends Enum>(Object? raw, List<T> values, T fallback) {
  if (raw is String) {
    for (final v in values) {
      if (v.name == raw) return v;
    }
  }
  return fallback;
}

class NotifSettingsNotifier extends StateNotifier<NotifSettings> {
  NotifSettingsNotifier() : super(NotifSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = NotifSettings.fromJson(j);
    } on Object catch (_) {/* keep defaults */}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {/* best-effort */}
  }

  void update(NotifSettings Function(NotifSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  void snoozeForMinutes(int minutes) {
    final until = DateTime.now().add(Duration(minutes: minutes));
    update((s) => s.copyWith(snoozeUntilMs: until.millisecondsSinceEpoch));
  }

  void cancelSnooze() {
    update((s) => s.copyWith(snoozeUntilMs: 0));
  }

  Future<void> reset() async {
    state = NotifSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final notifSettingsProvider =
    StateNotifierProvider<NotifSettingsNotifier, NotifSettings>(
  (_) => NotifSettingsNotifier(),
);
