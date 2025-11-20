import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/product.dart';

import 'package:shared_preferences/shared_preferences.dart';


class CatalogRepository {
  static const String _baseUrl = 'https://fakestoreapi.com';

  final http.Client _client;

  CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

  // Récupère la liste de tous les produits
  Future<List<Product>> fetchProducts() async {
    final uri = Uri.parse('$_baseUrl/products');
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Erreur réseau (code ${response.statusCode})');
      }

      // On sauvegarde la réponse brute en cache
      await prefs.setString('catalog_cache', response.body);

      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Si échec réseau, on tente d'utiliser le cache
      final cached = prefs.getString('catalog_cache');
      if (cached != null) {
        final List<dynamic> jsonList =
            jsonDecode(cached) as List<dynamic>;
        return jsonList
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      // Pas de cache → on remonte l'erreur
      rethrow;
    }
  }


  /// Récupère le détail d'un produit
  Future<Product> fetchProduct(int id) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur lors du chargement du produit '
          '(code ${response.statusCode})');
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Product.fromJson(json);
  }
}
