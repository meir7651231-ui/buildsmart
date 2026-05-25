import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kStorageKey = 'bs.store-settings.v1';

enum StoreSortDefault { priceAsc, rating, distance }
enum StorePayment { card, bit, applePay, supplierCredit }
enum StoreDeliveryWindow { morning, noon, evening, flexible }
enum StoreInstallments { one, three, six, twelve }
enum StoreMinRating { any, two, three, four, five }
enum StoreDisplayMode { list, grid }
enum StoreUnitSystem { metric, imperial }
enum StoreReturnPolicy { days7, days14, days30 }

class StoreSettings {
  const StoreSettings({
    required this.defaultAddress,
    required this.defaultPayment,
    required this.vatInclusive,
    required this.minOrderAmount,
    required this.sortDefault,
    required this.notifDeals,
    required this.notifBackInStock,
    required this.confirmLargeOrder,
    required this.largeOrderThreshold,
    // Shipping
    required this.preferredDeliveryWindow,
    required this.deliveryAreas,
    required this.courierInstructions,
    required this.selfPickupDefault,
    // Payment
    required this.defaultInstallments,
    required this.supplierCreditEnabled,
    // Invoices
    required this.businessName,
    required this.businessId,
    required this.exportToAccountant,
    required this.autoReceipts,
    // Notifications
    required this.notifPriceDrop,
    required this.notifOrderStatus,
    required this.notifShipmentEnRoute,
    // Cart
    required this.repeatOrders,
    required this.shareCartWithTeam,
    required this.saveCartToProject,
    // Suppliers
    required this.maxSupplierDistance,
    required this.minSupplierRating,
    required this.localSuppliersOnly,
    // Display
    required this.displayMode,
    required this.unitSystem,
    required this.showStock,
    // Logistics
    required this.fastDelivery,
    required this.regularDelivery,
    required this.returnPolicy,
    required this.extendedWarranty,
    // Privacy
    required this.purchaseHistory,
    required this.biometricConfirm,
    required this.dailyCreditLimit,
  });

  final String defaultAddress;
  final StorePayment defaultPayment;
  final bool vatInclusive;
  final int minOrderAmount;
  final StoreSortDefault sortDefault;
  final bool notifDeals;
  final bool notifBackInStock;
  final bool confirmLargeOrder;
  final int largeOrderThreshold;

  // Shipping
  final StoreDeliveryWindow preferredDeliveryWindow;
  final String deliveryAreas;
  final String courierInstructions;
  final bool selfPickupDefault;

  // Payment
  final StoreInstallments defaultInstallments;
  final bool supplierCreditEnabled;

  // Invoices
  final String businessName;
  final String businessId;
  final bool exportToAccountant;
  final bool autoReceipts;

  // Notifications
  final bool notifPriceDrop;
  final bool notifOrderStatus;
  final bool notifShipmentEnRoute;

  // Cart
  final bool repeatOrders;
  final bool shareCartWithTeam;
  final bool saveCartToProject;

  // Suppliers
  final int maxSupplierDistance;
  final StoreMinRating minSupplierRating;
  final bool localSuppliersOnly;

  // Display
  final StoreDisplayMode displayMode;
  final StoreUnitSystem unitSystem;
  final bool showStock;

  // Logistics
  final bool fastDelivery;
  final bool regularDelivery;
  final StoreReturnPolicy returnPolicy;
  final bool extendedWarranty;

  // Privacy
  final bool purchaseHistory;
  final bool biometricConfirm;
  final int dailyCreditLimit;

  static const StoreSettings defaults = StoreSettings(
    defaultAddress: '',
    defaultPayment: StorePayment.card,
    vatInclusive: true,
    minOrderAmount: 0,
    sortDefault: StoreSortDefault.priceAsc,
    notifDeals: true,
    notifBackInStock: true,
    confirmLargeOrder: true,
    largeOrderThreshold: 5000,
    // Shipping
    preferredDeliveryWindow: StoreDeliveryWindow.flexible,
    deliveryAreas: '',
    courierInstructions: '',
    selfPickupDefault: false,
    // Payment
    defaultInstallments: StoreInstallments.one,
    supplierCreditEnabled: false,
    // Invoices
    businessName: '',
    businessId: '',
    exportToAccountant: false,
    autoReceipts: true,
    // Notifications
    notifPriceDrop: true,
    notifOrderStatus: true,
    notifShipmentEnRoute: true,
    // Cart
    repeatOrders: true,
    shareCartWithTeam: false,
    saveCartToProject: true,
    // Suppliers
    maxSupplierDistance: 0,
    minSupplierRating: StoreMinRating.any,
    localSuppliersOnly: false,
    // Display
    displayMode: StoreDisplayMode.list,
    unitSystem: StoreUnitSystem.metric,
    showStock: true,
    // Logistics
    fastDelivery: true,
    regularDelivery: true,
    returnPolicy: StoreReturnPolicy.days14,
    extendedWarranty: false,
    // Privacy
    purchaseHistory: true,
    biometricConfirm: false,
    dailyCreditLimit: 0,
  );

  StoreSettings copyWith({
    String? defaultAddress,
    StorePayment? defaultPayment,
    bool? vatInclusive,
    int? minOrderAmount,
    StoreSortDefault? sortDefault,
    bool? notifDeals,
    bool? notifBackInStock,
    bool? confirmLargeOrder,
    int? largeOrderThreshold,
    // Shipping
    StoreDeliveryWindow? preferredDeliveryWindow,
    String? deliveryAreas,
    String? courierInstructions,
    bool? selfPickupDefault,
    // Payment
    StoreInstallments? defaultInstallments,
    bool? supplierCreditEnabled,
    // Invoices
    String? businessName,
    String? businessId,
    bool? exportToAccountant,
    bool? autoReceipts,
    // Notifications
    bool? notifPriceDrop,
    bool? notifOrderStatus,
    bool? notifShipmentEnRoute,
    // Cart
    bool? repeatOrders,
    bool? shareCartWithTeam,
    bool? saveCartToProject,
    // Suppliers
    int? maxSupplierDistance,
    StoreMinRating? minSupplierRating,
    bool? localSuppliersOnly,
    // Display
    StoreDisplayMode? displayMode,
    StoreUnitSystem? unitSystem,
    bool? showStock,
    // Logistics
    bool? fastDelivery,
    bool? regularDelivery,
    StoreReturnPolicy? returnPolicy,
    bool? extendedWarranty,
    // Privacy
    bool? purchaseHistory,
    bool? biometricConfirm,
    int? dailyCreditLimit,
  }) {
    return StoreSettings(
      defaultAddress: defaultAddress ?? this.defaultAddress,
      defaultPayment: defaultPayment ?? this.defaultPayment,
      vatInclusive: vatInclusive ?? this.vatInclusive,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      sortDefault: sortDefault ?? this.sortDefault,
      notifDeals: notifDeals ?? this.notifDeals,
      notifBackInStock: notifBackInStock ?? this.notifBackInStock,
      confirmLargeOrder: confirmLargeOrder ?? this.confirmLargeOrder,
      largeOrderThreshold: largeOrderThreshold ?? this.largeOrderThreshold,
      // Shipping
      preferredDeliveryWindow:
          preferredDeliveryWindow ?? this.preferredDeliveryWindow,
      deliveryAreas: deliveryAreas ?? this.deliveryAreas,
      courierInstructions: courierInstructions ?? this.courierInstructions,
      selfPickupDefault: selfPickupDefault ?? this.selfPickupDefault,
      // Payment
      defaultInstallments: defaultInstallments ?? this.defaultInstallments,
      supplierCreditEnabled:
          supplierCreditEnabled ?? this.supplierCreditEnabled,
      // Invoices
      businessName: businessName ?? this.businessName,
      businessId: businessId ?? this.businessId,
      exportToAccountant: exportToAccountant ?? this.exportToAccountant,
      autoReceipts: autoReceipts ?? this.autoReceipts,
      // Notifications
      notifPriceDrop: notifPriceDrop ?? this.notifPriceDrop,
      notifOrderStatus: notifOrderStatus ?? this.notifOrderStatus,
      notifShipmentEnRoute: notifShipmentEnRoute ?? this.notifShipmentEnRoute,
      // Cart
      repeatOrders: repeatOrders ?? this.repeatOrders,
      shareCartWithTeam: shareCartWithTeam ?? this.shareCartWithTeam,
      saveCartToProject: saveCartToProject ?? this.saveCartToProject,
      // Suppliers
      maxSupplierDistance: maxSupplierDistance ?? this.maxSupplierDistance,
      minSupplierRating: minSupplierRating ?? this.minSupplierRating,
      localSuppliersOnly: localSuppliersOnly ?? this.localSuppliersOnly,
      // Display
      displayMode: displayMode ?? this.displayMode,
      unitSystem: unitSystem ?? this.unitSystem,
      showStock: showStock ?? this.showStock,
      // Logistics
      fastDelivery: fastDelivery ?? this.fastDelivery,
      regularDelivery: regularDelivery ?? this.regularDelivery,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      extendedWarranty: extendedWarranty ?? this.extendedWarranty,
      // Privacy
      purchaseHistory: purchaseHistory ?? this.purchaseHistory,
      biometricConfirm: biometricConfirm ?? this.biometricConfirm,
      dailyCreditLimit: dailyCreditLimit ?? this.dailyCreditLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'defaultAddress': defaultAddress,
        'defaultPayment': defaultPayment.name,
        'vatInclusive': vatInclusive,
        'minOrderAmount': minOrderAmount,
        'sortDefault': sortDefault.name,
        'notifDeals': notifDeals,
        'notifBackInStock': notifBackInStock,
        'confirmLargeOrder': confirmLargeOrder,
        'largeOrderThreshold': largeOrderThreshold,
        // Shipping
        'preferredDeliveryWindow': preferredDeliveryWindow.name,
        'deliveryAreas': deliveryAreas,
        'courierInstructions': courierInstructions,
        'selfPickupDefault': selfPickupDefault,
        // Payment
        'defaultInstallments': defaultInstallments.name,
        'supplierCreditEnabled': supplierCreditEnabled,
        // Invoices
        'businessName': businessName,
        'businessId': businessId,
        'exportToAccountant': exportToAccountant,
        'autoReceipts': autoReceipts,
        // Notifications
        'notifPriceDrop': notifPriceDrop,
        'notifOrderStatus': notifOrderStatus,
        'notifShipmentEnRoute': notifShipmentEnRoute,
        // Cart
        'repeatOrders': repeatOrders,
        'shareCartWithTeam': shareCartWithTeam,
        'saveCartToProject': saveCartToProject,
        // Suppliers
        'maxSupplierDistance': maxSupplierDistance,
        'minSupplierRating': minSupplierRating.name,
        'localSuppliersOnly': localSuppliersOnly,
        // Display
        'displayMode': displayMode.name,
        'unitSystem': unitSystem.name,
        'showStock': showStock,
        // Logistics
        'fastDelivery': fastDelivery,
        'regularDelivery': regularDelivery,
        'returnPolicy': returnPolicy.name,
        'extendedWarranty': extendedWarranty,
        // Privacy
        'purchaseHistory': purchaseHistory,
        'biometricConfirm': biometricConfirm,
        'dailyCreditLimit': dailyCreditLimit,
      };

  // Dispatches to defaults via [_enum] / null fallbacks; awkward as a factory.
  // ignore: prefer_constructors_over_static_methods
  static StoreSettings fromJson(Map<String, dynamic> j) {
    return StoreSettings(
      defaultAddress: (j['defaultAddress'] as String?) ?? '',
      defaultPayment: _enum(
        j['defaultPayment'],
        StorePayment.values,
        StorePayment.card,
      ),
      vatInclusive: j['vatInclusive'] != false,
      minOrderAmount: (j['minOrderAmount'] as num?)?.toInt() ?? 0,
      sortDefault: _enum(
        j['sortDefault'],
        StoreSortDefault.values,
        StoreSortDefault.priceAsc,
      ),
      notifDeals: j['notifDeals'] != false,
      notifBackInStock: j['notifBackInStock'] != false,
      confirmLargeOrder: j['confirmLargeOrder'] != false,
      largeOrderThreshold:
          (j['largeOrderThreshold'] as num?)?.toInt() ?? 5000,
      // Shipping
      preferredDeliveryWindow: _enum(
        j['preferredDeliveryWindow'],
        StoreDeliveryWindow.values,
        StoreDeliveryWindow.flexible,
      ),
      deliveryAreas: (j['deliveryAreas'] as String?) ?? '',
      courierInstructions: (j['courierInstructions'] as String?) ?? '',
      selfPickupDefault: j['selfPickupDefault'] == true,
      // Payment
      defaultInstallments: _enum(
        j['defaultInstallments'],
        StoreInstallments.values,
        StoreInstallments.one,
      ),
      supplierCreditEnabled: j['supplierCreditEnabled'] == true,
      // Invoices
      businessName: (j['businessName'] as String?) ?? '',
      businessId: (j['businessId'] as String?) ?? '',
      exportToAccountant: j['exportToAccountant'] == true,
      autoReceipts: j['autoReceipts'] != false,
      // Notifications
      notifPriceDrop: j['notifPriceDrop'] != false,
      notifOrderStatus: j['notifOrderStatus'] != false,
      notifShipmentEnRoute: j['notifShipmentEnRoute'] != false,
      // Cart
      repeatOrders: j['repeatOrders'] != false,
      shareCartWithTeam: j['shareCartWithTeam'] == true,
      saveCartToProject: j['saveCartToProject'] != false,
      // Suppliers
      maxSupplierDistance: (j['maxSupplierDistance'] as num?)?.toInt() ?? 0,
      minSupplierRating: _enum(
        j['minSupplierRating'],
        StoreMinRating.values,
        StoreMinRating.any,
      ),
      localSuppliersOnly: j['localSuppliersOnly'] == true,
      // Display
      displayMode: _enum(
        j['displayMode'],
        StoreDisplayMode.values,
        StoreDisplayMode.list,
      ),
      unitSystem: _enum(
        j['unitSystem'],
        StoreUnitSystem.values,
        StoreUnitSystem.metric,
      ),
      showStock: j['showStock'] != false,
      // Logistics
      fastDelivery: j['fastDelivery'] != false,
      regularDelivery: j['regularDelivery'] != false,
      returnPolicy: _enum(
        j['returnPolicy'],
        StoreReturnPolicy.values,
        StoreReturnPolicy.days14,
      ),
      extendedWarranty: j['extendedWarranty'] == true,
      // Privacy
      purchaseHistory: j['purchaseHistory'] != false,
      biometricConfirm: j['biometricConfirm'] == true,
      dailyCreditLimit: (j['dailyCreditLimit'] as num?)?.toInt() ?? 0,
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

class StoreSettingsNotifier extends StateNotifier<StoreSettings> {
  StoreSettingsNotifier() : super(StoreSettings.defaults) {
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kStorageKey);
      if (raw == null) return;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      state = StoreSettings.fromJson(j);
    } on Object catch (_) {
      // Corrupt or unavailable storage — keep defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStorageKey, jsonEncode(state.toJson()));
    } on Object catch (_) {
      // Best-effort.
    }
  }

  void update(StoreSettings Function(StoreSettings) f) {
    state = f(state);
    unawaited(_persist());
  }

  Future<void> reset() async {
    state = StoreSettings.defaults;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kStorageKey);
    } on Object catch (_) {/* ignore */}
  }
}

final storeSettingsProvider =
    StateNotifierProvider<StoreSettingsNotifier, StoreSettings>(
  (_) => StoreSettingsNotifier(),
);
