import 'package:flutter/foundation.dart';

import '../../cart/presentation/cart_view_model.dart';
import '../../cart/domain/cart_item.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersRepository _repository;

  OrdersViewModel({required OrdersRepository repository})
      : _repository = repository;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.fetchOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrderFromCart(CartViewModel cart) async {
    if (cart.items.isEmpty) return;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: cart.items.map((item) {
        // On clone les items pour figer l'état
        return CartItem(
          product: item.product,
          quantity: item.quantity,
        );
      }).toList(),
      total: cart.totalPrice,
      createdAt: DateTime.now(),
    );

    await _repository.addOrder(order);
    _orders.insert(0, order);
    cart.clear();
    notifyListeners();
  }
}
