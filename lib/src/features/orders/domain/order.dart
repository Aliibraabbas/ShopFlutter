import '../../cart/domain/cart_item.dart';

class Order {
  final String id; 
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return Order(
      id: json['id'] as String,
      total: (json['total'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: itemsJson
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
