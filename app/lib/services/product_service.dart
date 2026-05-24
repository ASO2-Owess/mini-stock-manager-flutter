import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';

class ProductResult {
  final bool success;
  final String message;
  final List<Product>? products;
  final Product? product;

  ProductResult({
    required this.success,
    required this.message,
    this.products,
    this.product,
  });
}

class ProductService {
  // Headers avec token d'authentification
  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET ALL PRODUCTS
  Future<ProductResult> getProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.products),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['produits'];
        final products = list.map((item) => Product.fromJson(item)).toList();

        return ProductResult(
          success: true,
          message: data['message'],
          products: products,
        );
      }
      return ProductResult(
        success: false,
        message: 'Erreur lors du chargement',
      );
    } catch (e) {
      return ProductResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }

  // GET ONE PRODUCT
  Future<ProductResult> getProduct(String token, int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.products}/$id'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        return ProductResult(
          success: true,
          message: 'Produit trouvé',
          product: Product.fromJson(jsonDecode(response.body)),
        );
      }
      return ProductResult(
        success: false,
        message: 'Produit introuvable',
      );
    } catch (e) {
      return ProductResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }

  // CREATE PRODUCT
  Future<ProductResult> createProduct(
      String token, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.products),
        headers: _headers(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ProductResult(
          success: true,
          message: body['message'],
          product: Product.fromJson(body['produit']),
        );
      }
      return ProductResult(
        success: false,
        message: body['message'] ?? 'Erreur création',
      );
    } catch (e) {
      return ProductResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }

  // UPDATE PRODUCT
  Future<ProductResult> updateProduct(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.products}/$id'),
        headers: _headers(token),
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProductResult(
          success: true,
          message: body['message'],
          product: Product.fromJson(body['produit']),
        );
      }
      return ProductResult(
        success: false,
        message: body['message'] ?? 'Erreur modification',
      );
    } catch (e) {
      return ProductResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }

  // DELETE PRODUCT
  Future<ProductResult> deleteProduct(String token, int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.products}/$id'),
        headers: _headers(token),
      );

      final body = jsonDecode(response.body);

      return ProductResult(
        success: response.statusCode == 200,
        message: body['message'] ?? 'Erreur suppression',
      );
    } catch (e) {
      return ProductResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }
}
