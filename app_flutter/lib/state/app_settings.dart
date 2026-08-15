import 'dart:async';
import 'dart:convert';

import 'package:buildsmart/data/repositories/app_settings_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings — port of app/src/store/app-settings.ts.
/// Same storage key + same shape so values written by the Preact app
/// (when both apps live on the same domain) are readable here too.
const String _kStorageKey = 'bs.settings.v1';

enum BsTheme { light, dark }
// DEAD — not consumed (v6.14); kept for JSON round-trip + test_harness
enum BsTextSize { small, medium, large }
enum BsLang { he, ar, en }
// DEAD — not consumed (v6.14); kept for JSON round-trip + test_harness
enum BsUnits { metric, imperial }
// DEAD — not consumed (v6.14); kept for JSON round-trip + test_harness
enum BsCurrency { ils, usd }
// DEAD — not consumed (v6.14); kept for JSON round-trip + test_harness
enum BsHaulSize { small, van, truck }
// DEAD — not consumed (v6.14); kept for JSON round-trip + test_harness
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
    required this.privPresence,
    required this.consentedPolicyVersion,
  });

  final BsTheme theme;
  // DEAD — not consumed (v6.14); real write/read moved to CatalogSettings
  final BsTextSize textSize;
  // DEAD — not consumed (v6.14); real write/read moved to CatalogSettings
  final bool reduceMotion;
  final BsLang lang;
  // DEAD — not consumed (v6.14); placeholder field
  final BsUnits units;
  // DEAD — not consumed (v6.14); placeholder field
  final BsCurrency currency;
  // DEAD — not consumed (v6.14); placeholder field
  final BsHaulSize haul;
  // DEAD — not consumed (v6.14); placeholder field
  final bool express;
  // DEAD — not consumed (v6.14); real write/read moved to CatalogSettings
  final bool highContrast;
  // DEAD — not consumed (v6.14); placeholder field
  final bool twoFA;
  // DEAD — not consumed (v6.14); placeholder field
  final bool biometric;
  // DEAD — not consumed (v6.14); placeholder field
  final bool locationPerm;
  // DEAD — not consumed (v6.14); placeholder field
  final BsSessionTimeout sessionTimeout;
  // DEAD — not consumed (v6.14); real write/read moved to NotifSettings
  final bool notifShipments;
  // DEAD — not consumed (v6.14); real write/read moved to NotifSettings
  final bool notifDeals;
  // DEAD — not consumed (v6.14); real write/read moved to NotifSettings
  final bool notifBudget;
  // DEAD — not consumed (v6.14); real write/read moved to NotifSettings
  final bool notifOrders;
  final bool privAnalytics;
  final bool privLocation;
  final bool privMarketing;
  final bool privCrashReports;

  /// §9 (R1-2) — DENY-default presence toggle (customer online-presence). A
  /// SEPARATE consent axis from [privAnalytics] so all privacy defaults land
  /// together in step 86; the presence forward ANDs it with the consent
  /// version + backend (never staff — governance #84).
  final bool privPresence;

  /// The policy version the user has consented to (0 = never consented, the
  /// default). The analytics/presence forward requires
  /// `consentedPolicyVersion >= kCurrentPolicyVersion`, so a policy bump
  /// de-facto resets consent to DENY until re-opt-in (Amendment-13 re-notice).
  final int consentedPolicyVersion;

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
    privAnalytics: false,
    privLocation: true,
    privMarketing: false,
    privCrashReports: true,
    privPresence: false,
    consentedPolicyVersion: 0,
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
    bool? privPresence,
    int? consentedPolicyVersion,
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
      privPresence: privPresence ?? this.privPresence,
      consentedPolicyVersion:
          consentedPolicyVersion ?? this.consentedPolicyVersion,
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
            'presence': privPresence,
            'consentedPolicyVersion': consentedPolicyVersion,
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
      privAnalytics:    priv['analytics']    == true,
      privLocation:     priv['location']     != false,
      privMarketing:    priv['marketing']    == true,
      privCrashReports: priv['crashReports'] != false,
      privPresence:     priv['presence']     == true,
      consentedPolicyVersion:
          (priv['consentedPolicyVersion'] as num?)?.toInt() ?? 0,
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
  AppSettingsNotifier([this._repo]) : super(AppSettings.defaults) {
    unawaited(_load());
  }

  /// The server store (`appSettings/{uid}`) when USER_DATA_SERVER is on for a real
  /// signed-in user; null (the default) ⇒ the SharedPreferences path below.
  final AppSettingsRepository? _repo;

  Future<void> _load() async {
    final repo = _repo;
    if (repo != null) {
      // Server path: the settings live at `appSettings/{uid}`. Absent ⇒ keep
      // defaults (mirrors the local `raw == null` → return; the repo never throws).
      final s = await repo.load(repo.currentUid);
      if (s != null) state = s;
      return;
    }
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
    final repo = _repo;
    if (repo != null) {
      try {
        await repo.save(repo.currentUid, state);
      } on Object catch (_) {/* best-effort */}
      return;
    }
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
    final repo = _repo;
    if (repo != null) {
      try {
        await repo.save(repo.currentUid, AppSettings.defaults);
      } on Object catch (_) {/* ignore */}
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
  (ref) => AppSettingsNotifier(ref.watch(appSettingsRepositoryProvider)),
);
