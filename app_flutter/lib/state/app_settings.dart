import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings — port of app/src/store/app-settings.ts.
/// Same storage key + same shape so values written by the Preact app
/// (when both apps live on the same domain) are readable here too.
const String _kStorageKey = 'bs.settings.v1';

enum BsTheme { light, dark }
enum BsTextSize { small, medium, large }
enum BsLang { he, ar, en }
enum BsUnits { metric, imperial }
enum BsCurrency { ils, usd }
enum BsHaulSize { small, van, truck }
enum BsSessionTimeout { m5, m15, m30, m60 }

class AppSettings {
  const AppSettings({
    required this.theme,
    required this.textSize,
    required this.reduceMotion,
    required this.lang,
    required this.units,
    required this.currency,
    required this.haul,
    required this.express,
    required this.highContrast,
    required this.twoFA,
    required this.biometric,
    required this.locationPerm,
    required this.sessionTimeout,
    required this.notifShipments,
    required this.notifDeals,
    required this.notifBudget,
    required this.notifOrders,
    required this.privAnalytics,
    required this.privLocation,
    required this.privMarketing,
    required this.privCrashReports,
  });

  final BsTheme theme;
  final BsTextSize textSize;
  final bool reduceMotion;
  final BsLang lang;
  final BsUnits units;
  final BsCurrency currency;
  final BsHaulSize haul;
  final bool express;
  final bool highContrast;
  final bool twoFA;
  final bool biometric;
  final bool locationPerm;
  final BsSessionTimeout sessionTimeout;
  final bool notifShipments;
  final bool notifDeals;
  final bool notifBudget;
  final bool notifOrders;
  final bool privAnalytics;
  final bool privLocation;
  final bool privMarketing;
  final bool privCrashReports;

  static const AppSettings defaults = AppSettings(
    theme: BsTheme.light,
    textSize: BsTextSize.medium,
    reduceMotion: false,
    lang: BsLang.he,
    units: BsUnits.metric,
    currency: BsCurrency.ils,
    haul: BsHaulSize.small,
    express: false,
    highContrast: false,
    twoFA: false,
    biometric: false,
    locationPerm: false,
    sessionTimeout: BsSessionTimeout.m15,
    notifShipments: true,
    notifDeals: true,
    notifBudget: true,
    notifOrders: true,
    privAnalytics: true,
    privLocation: true,
    privMarketing: false,
    privCrashReports: true,
  );

  AppSettings copyWith({
    BsTheme? theme,
    BsTextSize? textSize,
    bool? reduceMotion,
    BsLang? lang,
    BsUnits? units,
    BsCurrency? currency,
    BsHaulSize? haul,
    bool? express,
    bool? highContrast,
    bool? twoFA,
    bool? biometric,
    bool? locationPerm,
    BsSessionTimeout? sessionTimeout,
    bool? notifShipments,
    bool? notifDeals,
    bool? notifBudget,
    bool? notifOrders,
    bool? privAnalytics,
    bool? privLocation,
    bool? privMarketing,
    bool? privCrashReports,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      textSize: textSize ?? this.textSize,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      lang: lang ?? this.lang,
      units: units ?? this.units,
      currency: currency ?? this.currency,
      haul: haul ?? this.haul,
      express: express ?? this.express,
      highContrast: highContrast ?? this.highContrast,
      twoFA: twoFA ?? this.twoFA,
      biometric: biometric ?? this.biometric,
      locationPerm: locationPerm ?? this.locationPerm,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      notifShipments: notifShipments ?? this.notifShipments,
      notifDeals: notifDeals ?? this.notifDeals,
      notifBudget: notifBudget ?? this.notifBudget,
      notifOrders: notifOrders ?? this.notifOrders,
      privAnalytics: privAnalytics ?? this.privAnalytics,
      privLocation: privLocation ?? this.privLocation,
      privMarketing: privMarketing ?? this.privMarketing,
      privCrashReports: privCrashReports ?? this.privCrashReports,
    );
  }

  Map<String, dynamic> toJson() => {
        'display': {
          'theme': theme.name,
          'textSize': textSize.name,
          'reduceMotion': reduceMotion,
        },
        'notif': {
          'shipments': notifShipments,
          'deals': notifDeals,
          'budget': notifBudget,
          'orders': notifOrders,
        },
        'region': {
          'lang': lang.name,
          'units': units.name,
          'currency': currency.name,
        },
        'delivery': {
          'defaultHaul': haul.name,
          'express': express,
        },
        'accessibility': {
          'highContrast': highContrast,
        },
        'security': {
          'twoFA': twoFA,
          'biometric': biometric,
          'locationPerm': locationPerm,
          'sessionTimeout': _timeoutToInt(sessionTimeout),
          'privacy': {
            'analytics': privAnalytics,
            'location': privLocation,
            'marketing': privMarketing,
            'crashReports': privCrashReports,
          },
        },
      };

  // Static rather than a constructor: needs to dispatch to defaults
  // and to massage the legacy JSON shape; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static AppSettings fromJson(Map<String, dynamic> j) {
    Map<String, dynamic> m(String k) =>
        (j[k] as Map<String, dynamic>?) ?? const {};
    final display = m('display');
    final notif = m('notif');
    final region = m('region');
    final delivery = m('delivery');
    final acc = m('accessibility');
    final sec = m('security');
    final priv = (sec['privacy'] as Map<String, dynamic>?) ?? const {};
    return AppSettings(
      theme: _enum(display['theme'], BsTheme.values, BsTheme.light),
      textSize: _enum(
        display['textSize'],
        BsTextSize.values,
        BsTextSize.medium,
      ),
      reduceMotion: display['reduceMotion'] == true,
      lang: _enum(region['lang'], BsLang.values, BsLang.he),
      units: _enum(region['units'], BsUnits.values, BsUnits.metric),
      currency: _enum(region['currency'], BsCurrency.values, BsCurrency.ils),
      haul: _enum(
        delivery['defaultHaul'],
        BsHaulSize.values,
        BsHaulSize.small,
      ),
      express: delivery['express'] == true,
      highContrast: acc['highContrast'] == true,
      twoFA: sec['twoFA'] == true,
      biometric: sec['biometric'] == true,
      locationPerm: sec['locationPerm'] == true,
      sessionTimeout: _intToTimeout(sec['sessionTimeout']),
      notifShipments: notif['shipments'] != false,
      notifDeals:     notif['deals']     != false,
      notifBudget:    notif['budget']    != false,
      notifOrders:    notif['orders']    != false,
      privAnalytics:    priv['analytics']    != false,
      privLocation:     priv['location']     != false,
      privMarketing:    priv['marketing']    == true,
      privCrashReports: priv['crashReports'] != false,
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

int _timeoutToInt(BsSessionTimeout t) => switch (t) {
      BsSessionTimeout.m5  => 5,
      BsSessionTimeout.m15 => 15,
      BsSessionTimeout.m30 => 30,
      BsSessionTimeout.m60 => 60,
    };

BsSessionTimeout _intToTimeout(Object? raw) {
  final n = raw is num ? raw.toInt() : 15;
  return switch (n) {
    5  => BsSessionTimeout.m5,
    30 => BsSessionTimeout.m30,
    60 => BsSessionTimeout.m60,
    _  => BsSessionTimeout.m15,
  };
}

/// Notifier that persists every change to SharedPreferences.
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(AppSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = AppSettings.fromJson(j);
    } on Object catch (_) {
      // Corrupt or unavailable storage — keep defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {
      // Persistence is best-effort; in-memory state already updated.
    }
  }

  void update(AppSettings Function(AppSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  Future<void> reset() async {
    state = AppSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (_) => AppSettingsNotifier(),
);
