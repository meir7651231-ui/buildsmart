import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:buildsmart/data/related_info.dart';

/// A product assigned to a project location from the SmartProduct card.
/// Roadmap steps 71 (add to project), 72 (duplicate to many points),
/// 74 (cumulative project BOM).
class ProjectItem {
  const ProjectItem({
    required this.project,
    required this.location,
    required this.productKey,
    required this.brandName,
    required this.sku,
    this.qty = 1,
  });

  final String project; // e.g. "דירה 4"
  final String location; // e.g. "מטבח"
  final String productKey;
  final String brandName;
  final String sku;
  final int qty;

  String get id => '$project|$location|$productKey|$brandName';

  ProjectItem copyWith({int? qty}) => ProjectItem(
        project: project,
        location: location,
        productKey: productKey,
        brandName: brandName,
        sku: sku,
        qty: qty ?? this.qty,
      );

  Map<String, dynamic> toJson() => {
        'project': project,
        'location': location,
        'productKey': productKey,
        'brandName': brandName,
        'sku': sku,
        'qty': qty,
      };

  factory ProjectItem.fromJson(Map<String, dynamic> j) => ProjectItem(
        project: j['project'] as String,
        location: j['location'] as String,
        productKey: j['productKey'] as String,
        brandName: j['brandName'] as String,
        sku: j['sku'] as String? ?? '',
        qty: (j['qty'] as num?)?.toInt() ?? 1,
      );
}

/// Pure: merge [item] into [current], summing qty when the same id already
/// exists. Unit-testable without SharedPreferences.
List<ProjectItem> projectItemsAfterAdd(
    List<ProjectItem> current, ProjectItem item) {
  final out = <ProjectItem>[];
  var merged = false;
  for (final e in current) {
    if (e.id == item.id) {
      out.add(e.copyWith(qty: e.qty + item.qty));
      merged = true;
    } else {
      out.add(e);
    }
  }
  if (!merged) out.add(item);
  return out;
}

/// Step 75 — a plain-text customer quote for a whole project, aggregating each
/// assigned item at its estimated unit price. Pure (price via `priceFor`).
String projectQuoteText(String project, List<ProjectItem> items) {
  final lines = <String>['הצעת מחיר — פרויקט "$project"'];
  var total = 0;
  for (final it in items) {
    final prod = catalogProductForSku(it.sku);
    final unit = prod == null ? 0 : (priceFor(prod) ?? 0);
    final sub = unit * it.qty;
    total += sub;
    lines.add('• ${it.location}: ${it.brandName} ×${it.qty} — ~₪$sub');
  }
  lines.add('סה"כ משוער: ~₪$total');
  lines.add('— נוצר ב-BuildSmart');
  return lines.join('\n');
}

class CardProjectsNotifier extends StateNotifier<List<ProjectItem>> {
  CardProjectsNotifier() : super(const []) {
    _load();
  }

  static const _key = 'bs.card-projects.v1';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      state = (jsonDecode(raw) as List)
          .map((e) => ProjectItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  /// Step 71 — add one product to a project location (merges qty).
  void add(ProjectItem item) {
    state = projectItemsAfterAdd(state, item);
    _persist();
  }

  /// Step 72 — duplicate the same product to several locations at once.
  void addToLocations(ProjectItem template, List<String> locations) {
    var next = state;
    for (final loc in locations) {
      next = projectItemsAfterAdd(
          next, ProjectItem(
              project: template.project,
              location: loc,
              productKey: template.productKey,
              brandName: template.brandName,
              sku: template.sku,
              qty: template.qty));
    }
    state = next;
    _persist();
  }

  void removeProject(String project) {
    state = state.where((e) => e.project != project).toList();
    _persist();
  }

  List<ProjectItem> forProject(String project) =>
      state.where((e) => e.project == project).toList();

  int get totalUnits => state.fold(0, (s, e) => s + e.qty);

  Set<String> get projects => {for (final e in state) e.project};
}

final cardProjectsProvider =
    StateNotifierProvider<CardProjectsNotifier, List<ProjectItem>>(
  (_) => CardProjectsNotifier(),
);
