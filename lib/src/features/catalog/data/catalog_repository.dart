import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/product.dart';

class CatalogRepository {
  static const String _baseUrl = 'https://fakestoreapi.com';
  static const String _cacheKey = 'catalog_cache';

  final http.Client _client;

  CatalogRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    // Cas Web : pas de cache, on simplifie pour éviter les soucis de stockage
    if (kIsWeb) {
      final uri = Uri.parse('$_baseUrl/products');
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du chargement des produits '
            '(code ${response.statusCode})');
      }

      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // Mobile / desktop natif : on garde un cache léger en SharedPreferences
    try {
      final uri = Uri.parse('$_baseUrl/products');
      final prefs = await SharedPreferences.getInstance();

      try {
        final response = await _client.get(uri);

        if (response.statusCode != 200) {
          throw Exception('Erreur réseau (code ${response.statusCode})');
        }

        // On sauvegarde la réponse brute en cache
        await prefs.setString(_cacheKey, response.body);

        final List<dynamic> jsonList =
            jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Si échec réseau, on tente d'utiliser le cache
        final cached = prefs.getString(_cacheKey);
        if (cached != null) {
          final List<dynamic> jsonList =
              jsonDecode(cached) as List<dynamic>;
          return jsonList
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        rethrow;
      }
    } catch (e) {
      // Si SharedPreferences ou autre plante, on retombe sur un simple appel HTTP
      final uri = Uri.parse('$_baseUrl/products');
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Erreur lors du chargement des produits '
            '(code ${response.statusCode})');
      }

      final List<dynamic> jsonList =
          jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    }
  }

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
