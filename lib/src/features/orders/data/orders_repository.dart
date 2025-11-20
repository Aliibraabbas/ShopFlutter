import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/order.dart';

class OrdersRepository {
  static const String _ordersKey = 'orders';

  Future<List<Order>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ordersKey);
    if (jsonString == null) return [];

    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        jsonEncode(orders.map((o) => o.toJson()).toList());
    await prefs.setString(_ordersKey, jsonString);
  }

  Future<void> addOrder(Order order) async {
    final orders = await fetchOrders();
    orders.insert(0, order);
    await _saveOrders(orders);
  }
}
