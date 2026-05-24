import 'package:flutter/material.dart';

import '../models/sale_request.dart';
import '../services/sale_request_service.dart';

class SaleRequestProvider extends ChangeNotifier {
  final SaleRequestService _service = SaleRequestService();

  List<SaleRequest> _requests = [];
  bool _loading = false;
  String? _error;

  List<SaleRequest> get requests => _requests;
  bool get loading => _loading;
  String? get error => _error;
  int get pendingCount =>
      _requests.where((request) => request.status == 'pending').length;

  Future<void> load(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _service.getRequests(token);
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> create(
    String token, {
    required int productId,
    required int quantity,
    String? clientName,
    String? note,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createRequest(
        token,
        productId: productId,
        quantity: quantity,
        clientName: clientName,
        note: note,
      );
      await load(token);
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> approve(String token, int id) async {
    try {
      await _service.approve(token, id);
      await load(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> reject(String token, int id) async {
    try {
      await _service.reject(token, id);
      await load(token);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
