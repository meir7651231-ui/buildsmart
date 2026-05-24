import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.notif-settings.v1';

enum NotifLockScreen { full, senderOnly, hidden }

enum NotifImportance { all, important, critical }

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
    // Section 1 — Channels
    required this.smsEnabled,
    required this.whatsappEnabled,
    // Section 2 — Types
    required this.typeDeals,
    required this.typeSupplierOffers,
    required this.typeBackInStock,
    required this.typeReminders,
    required this.typeNewChats,
    required this.typeProjectUpdates,
    // Section 3 — Quiet Hours
    required this.quietOnShabbat,
    required this.quietInMeetings,
    required this.quietWhileDriving,
    // Section 4 — Sound
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.soundPerType,
    // Section 5 — Importance
    required this.importanceFilter,
    // Section 6 — Persona
    required this.personaContractor,
    required this.personaStore,
    required this.personaCourier,
    required this.personaWorker,
    required this.personaAdmin,
    // Section 7 — Summaries
    required this.morningReport,
    required this.morningReportHour,
    required this.morningReportMin,
    required this.eveningSummary,
    required this.eveningSummaryHour,
    required this.eveningSummaryMin,
    required this.weeklySummary,
    required this.monthlySummary,
    // Section 8 — Lock Screen
    required this.biometricToOpen,
    required this.dontForwardToWatch,
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

  // Section 1 — Channels
  final bool smsEnabled;
  final bool whatsappEnabled;

  // Section 2 — Types
  final bool typeDeals;
  final bool typeSupplierOffers;
  final bool typeBackInStock;
  final bool typeReminders;
  final bool typeNewChats;
  final bool typeProjectUpdates;

  // Section 3 — Quiet Hours
  final bool quietOnShabbat;
  final bool quietInMeetings;
  final bool quietWhileDriving;

  // Section 4 — Sound
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool soundPerType;

  // Section 5 — Importance
  final NotifImportance importanceFilter;

  // Section 6 — Persona
  final bool personaContractor;
  final bool personaStore;
  final bool personaCourier;
  final bool personaWorker;
  final bool personaAdmin;

  // Section 7 — Summaries
  final bool morningReport;
  final int morningReportHour;
  final int morningReportMin;
  final bool eveningSummary;
  final int eveningSummaryHour;
  final int eveningSummaryMin;
  final bool weeklySummary;
  final bool monthlySummary;

  // Section 8 — Lock Screen
  final bool biometricToOpen;
  final bool dontForwardToWatch;

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
    // Section 1
    smsEnabled: false,
    whatsappEnabled: false,
    // Section 2
    typeDeals: true,
    typeSupplierOffers: true,
    typeBackInStock: true,
    typeReminders: true,
    typeNewChats: true,
    typeProjectUpdates: true,
    // Section 3
    quietOnShabbat: false,
    quietInMeetings: false,
    quietWhileDriving: false,
    // Section 4
    soundEnabled: true,
    vibrationEnabled: true,
    soundPerType: false,
    // Section 5
    importanceFilter: NotifImportance.all,
    // Section 6
    personaContractor: true,
    personaStore: true,
    personaCourier: true,
    personaWorker: true,
    personaAdmin: true,
    // Section 7
    morningReport: false,
    morningReportHour: 7,
    morningReportMin: 0,
    eveningSummary: false,
    eveningSummaryHour: 18,
    eveningSummaryMin: 0,
    weeklySummary: false,
    monthlySummary: false,
    // Section 8
    biometricToOpen: false,
    dontForwardToWatch: false,
  );

  TimeOfDay get quietStart =>
      TimeOfDay(hour: quietStartHour, minute: quietStartMin);
  TimeOfDay get quietEnd =>
      TimeOfDay(hour: quietEndHour, minute: quietEndMin);
  TimeOfDay get dailySummaryTime =>
      TimeOfDay(hour: dailySummaryHour, minute: dailySummaryMin);
  TimeOfDay get morningReportTime =>
      TimeOfDay(hour: morningReportHour, minute: morningReportMin);
  TimeOfDay get eveningSummaryTime =>
      TimeOfDay(hour: eveningSummaryHour, minute: eveningSummaryMin);

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
    // Section 1
    bool? smsEnabled,
    bool? whatsappEnabled,
    // Section 2
    bool? typeDeals,
    bool? typeSupplierOffers,
    bool? typeBackInStock,
    bool? typeReminders,
    bool? typeNewChats,
    bool? typeProjectUpdates,
    // Section 3
    bool? quietOnShabbat,
    bool? quietInMeetings,
    bool? quietWhileDriving,
    // Section 4
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? soundPerType,
    // Section 5
    NotifImportance? importanceFilter,
    // Section 6
    bool? personaContractor,
    bool? personaStore,
    bool? personaCourier,
    bool? personaWorker,
    bool? personaAdmin,
    // Section 7
    bool? morningReport,
    int? morningReportHour,
    int? morningReportMin,
    bool? eveningSummary,
    int? eveningSummaryHour,
    int? eveningSummaryMin,
    bool? weeklySummary,
    bool? monthlySummary,
    // Section 8
    bool? biometricToOpen,
    bool? dontForwardToWatch,
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
      smsEnabled: smsEnabled ?? this.smsEnabled,
      whatsappEnabled: whatsappEnabled ?? this.whatsappEnabled,
      typeDeals: typeDeals ?? this.typeDeals,
      typeSupplierOffers: typeSupplierOffers ?? this.typeSupplierOffers,
      typeBackInStock: typeBackInStock ?? this.typeBackInStock,
      typeReminders: typeReminders ?? this.typeReminders,
      typeNewChats: typeNewChats ?? this.typeNewChats,
      typeProjectUpdates: typeProjectUpdates ?? this.typeProjectUpdates,
      quietOnShabbat: quietOnShabbat ?? this.quietOnShabbat,
      quietInMeetings: quietInMeetings ?? this.quietInMeetings,
      quietWhileDriving: quietWhileDriving ?? this.quietWhileDriving,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundPerType: soundPerType ?? this.soundPerType,
      importanceFilter: importanceFilter ?? this.importanceFilter,
      personaContractor: personaContractor ?? this.personaContractor,
      personaStore: personaStore ?? this.personaStore,
      personaCourier: personaCourier ?? this.personaCourier,
      personaWorker: personaWorker ?? this.personaWorker,
      personaAdmin: personaAdmin ?? this.personaAdmin,
      morningReport: morningReport ?? this.morningReport,
      morningReportHour: morningReportHour ?? this.morningReportHour,
      morningReportMin: morningReportMin ?? this.morningReportMin,
      eveningSummary: eveningSummary ?? this.eveningSummary,
      eveningSummaryHour: eveningSummaryHour ?? this.eveningSummaryHour,
      eveningSummaryMin: eveningSummaryMin ?? this.eveningSummaryMin,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      biometricToOpen: biometricToOpen ?? this.biometricToOpen,
      dontForwardToWatch: dontForwardToWatch ?? this.dontForwardToWatch,
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
        // Section 1
        'smsEnabled': smsEnabled,
        'whatsappEnabled': whatsappEnabled,
        // Section 2
        'typeDeals': typeDeals,
        'typeSupplierOffers': typeSupplierOffers,
        'typeBackInStock': typeBackInStock,
        'typeReminders': typeReminders,
        'typeNewChats': typeNewChats,
        'typeProjectUpdates': typeProjectUpdates,
        // Section 3
        'quietOnShabbat': quietOnShabbat,
        'quietInMeetings': quietInMeetings,
        'quietWhileDriving': quietWhileDriving,
        // Section 4
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'soundPerType': soundPerType,
        // Section 5
        'importanceFilter': importanceFilter.name,
        // Section 6
        'personaContractor': personaContractor,
        'personaStore': personaStore,
        'personaCourier': personaCourier,
        'personaWorker': personaWorker,
        'personaAdmin': personaAdmin,
        // Section 7
        'morningReport': morningReport,
        'morningReportHour': morningReportHour,
        'morningReportMin': morningReportMin,
        'eveningSummary': eveningSummary,
        'eveningSummaryHour': eveningSummaryHour,
        'eveningSummaryMin': eveningSummaryMin,
        'weeklySummary': weeklySummary,
        'monthlySummary': monthlySummary,
        // Section 8
        'biometricToOpen': biometricToOpen,
        'dontForwardToWatch': dontForwardToWatch,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static NotifSettings fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) =>
        (j[k] as num?)?.toInt() ?? fallback;
    // bTrue: field defaults to true → missing key → true
    // bFalse: field defaults to false → missing key → false
    bool bTrue(String k) => j[k] != false;
    bool bFalse(String k) => j[k] == true;
    return NotifSettings(
      pushEnabled: bTrue('pushEnabled'),
      emailEnabled: bTrue('emailEnabled'),
      typeOrders: bTrue('typeOrders'),
      typeShipments: bTrue('typeShipments'),
      typePriceDrops: bTrue('typePriceDrops'),
      quietHoursEnabled: bFalse('quietHoursEnabled'),
      quietStartHour: i('quietStartHour', 22),
      quietStartMin: i('quietStartMin', 0),
      quietEndHour: i('quietEndHour', 7),
      quietEndMin: i('quietEndMin', 0),
      dailySummary: bFalse('dailySummary'),
      dailySummaryHour: i('dailySummaryHour', 8),
      dailySummaryMin: i('dailySummaryMin', 0),
      lockScreen: _enum(
        j['lockScreen'],
        NotifLockScreen.values,
        NotifLockScreen.full,
      ),
      snoozeUntilMs: i('snoozeUntilMs', 0),
      // Section 1 — false defaults
      smsEnabled: bFalse('smsEnabled'),
      whatsappEnabled: bFalse('whatsappEnabled'),
      // Section 2 — true defaults
      typeDeals: bTrue('typeDeals'),
      typeSupplierOffers: bTrue('typeSupplierOffers'),
      typeBackInStock: bTrue('typeBackInStock'),
      typeReminders: bTrue('typeReminders'),
      typeNewChats: bTrue('typeNewChats'),
      typeProjectUpdates: bTrue('typeProjectUpdates'),
      // Section 3 — false defaults
      quietOnShabbat: bFalse('quietOnShabbat'),
      quietInMeetings: bFalse('quietInMeetings'),
      quietWhileDriving: bFalse('quietWhileDriving'),
      // Section 4 — soundEnabled/vibrationEnabled true, soundPerType false
      soundEnabled: bTrue('soundEnabled'),
      vibrationEnabled: bTrue('vibrationEnabled'),
      soundPerType: bFalse('soundPerType'),
      // Section 5
      importanceFilter: _enum(
        j['importanceFilter'],
        NotifImportance.values,
        NotifImportance.all,
      ),
      // Section 6 — true defaults
      personaContractor: bTrue('personaContractor'),
      personaStore: bTrue('personaStore'),
      personaCourier: bTrue('personaCourier'),
      personaWorker: bTrue('personaWorker'),
      personaAdmin: bTrue('personaAdmin'),
      // Section 7 — false defaults for booleans
      morningReport: bFalse('morningReport'),
      morningReportHour: i('morningReportHour', 7),
      morningReportMin: i('morningReportMin', 0),
      eveningSummary: bFalse('eveningSummary'),
      eveningSummaryHour: i('eveningSummaryHour', 18),
      eveningSummaryMin: i('eveningSummaryMin', 0),
      weeklySummary: bFalse('weeklySummary'),
      monthlySummary: bFalse('monthlySummary'),
      // Section 8 — false defaults
      biometricToOpen: bFalse('biometricToOpen'),
      dontForwardToWatch: bFalse('dontForwardToWatch'),
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
