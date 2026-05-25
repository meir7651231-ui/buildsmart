import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

typedef CartItem = ({String emoji, String name, int qty, String price});

class CartList {
  final String id;
  final String name;
  final List<CartItem> items;
  final DateTime createdAt;

  CartList({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
  });

  CartList copyWith({
    String? id,
    String? name,
    List<CartItem>? items,
    DateTime? createdAt,
  }) {
    return CartList(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items
          .map((item) => {
                'emoji': item.emoji,
                'name': item.name,
                'qty': item.qty,
                'price': item.price,
              })
          .toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CartList.fromJson(Map<String, dynamic> json) {
    return CartList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => (
                emoji: item['emoji'] as String,
                name: item['name'] as String,
                qty: item['qty'] as int,
                price: item['price'] as String,
              ))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CartListsNotifier extends StateNotifier<List<CartList>> {
  CartListsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('bs.cart-lists.v1');
      if (json != null) {
        final decoded = jsonDecode(json) as List<dynamic>;
        state = decoded
            .map((item) => CartList.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // Silently fail on malformed data
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(state.map((list) => list.toJson()).toList());
      await prefs.setString('bs.cart-lists.v1', json);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> saveCart(String name, List<CartItem> items) async {
    final newList = CartList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: items,
      createdAt: DateTime.now(),
    );
    state = [...state, newList];
    await _persist();
  }

  Future<void> deleteList(String id) async {
    state = state.where((list) => list.id != id).toList();
    await _persist();
  }

  Future<void> clearAllLists() async {
    state = [];
    await _persist();
  }
}

final cartListsProvider =
    StateNotifierProvider<CartListsNotifier, List<CartList>>(
  (_) => CartListsNotifier(),
);
