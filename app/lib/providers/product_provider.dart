import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  Product? _selected;
  bool _loading = false;
  String? _error;
  String? _success;

  List<Product> get products => _products;
  Product? get selected => _selected;
  bool get loading => _loading;
  String? get error => _error;
  String? get success => _success;

  final ProductService _service = ProductService();

  void _setLoading(bool val) {
    _loading = val;
    notifyListeners();
  }

  // CHARGER TOUS LES PRODUITS
  Future<void> loadProducts(String token) async {
    _setLoading(true);
    _error = null;

    final result = await _service.getProducts(token);

    if (result.success) {
      _products = result.products ?? [];
    } else {
      _error = result.message;
    }

    _setLoading(false);
  }

  // CHARGER UN PRODUIT
  Future<void> loadProduct(String token, int id) async {
    _setLoading(true);
    _error = null;

    final result = await _service.getProduct(token, id);

    if (result.success) {
      _selected = result.product;
    } else {
      _error = result.message;
    }

    _setLoading(false);
  }

  // CRÉER UN PRODUIT
  Future<bool> createProduct(String token, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    _success = null;

    final result = await _service.createProduct(token, data);

    if (result.success) {
      _success = result.message;
      await loadProducts(token); // Recharge la liste
    } else {
      _error = result.message;
    }

    _setLoading(false);
    return result.success;
  }

  // MODIFIER UN PRODUIT
  Future<bool> updateProduct(
      String token, int id, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    _success = null;

    final result = await _service.updateProduct(token, id, data);

    if (result.success) {
      _success = result.message;
      await loadProducts(token);
    } else {
      _error = result.message;
    }

    _setLoading(false);
    return result.success;
  }

  // SUPPRIMER UN PRODUIT
  Future<bool> deleteProduct(String token, int id) async {
    _setLoading(true);
    _error = null;
    _success = null;

    final result = await _service.deleteProduct(token, id);

    if (result.success) {
      _success = result.message;
      _products.removeWhere((p) => p.id == id);
    } else {
      _error = result.message;
    }

    _setLoading(false);
    return result.success;
  }

  void clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }
}
