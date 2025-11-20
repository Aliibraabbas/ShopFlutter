import 'package:flutter/foundation.dart';

import '../../catalog/data/catalog_repository.dart';
import '../../catalog/domain/product.dart';

class CatalogViewModel extends ChangeNotifier {
  final CatalogRepository _repository;

  CatalogViewModel({required CatalogRepository repository})
      : _repository = repository;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  String? _listError;
  String? get listError => _listError;

  // Pour le détail
  Product? _selectedProduct;
  Product? get selectedProduct => _selectedProduct;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _detailError;
  String? get detailError => _detailError;

  /// Charge la liste des produits (catalogue)
  Future<void> loadProducts() async {
    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      _products = await _repository.fetchProducts();
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Charge le détail d'un produit
  Future<void> loadProductDetail(int id) async {
    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      // D'abord on essaie de le trouver dans la liste déjà chargée
      _selectedProduct =
          _products.firstWhere((p) => p.id == id, orElse: () => throw '');
    } catch (_) {
      // Sinon on va le chercher à l'API
      try {
        _selectedProduct = await _repository.fetchProduct(id);
      } catch (e) {
        _detailError = e.toString();
      }
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}
