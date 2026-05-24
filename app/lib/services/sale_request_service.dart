import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/sale_request.dart';

class SaleRequestService {
  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<SaleRequest>> getRequests(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.saleRequests),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('Chargement des demandes impossible');
    }

    final body = jsonDecode(response.body);
    return (body['sale_requests'] as List)
        .map((item) => SaleRequest.fromJson(item))
        .toList();
  }

  Future<void> createRequest(
    String token, {
    required int productId,
    required int quantity,
    String? clientName,
    String? note,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.saleRequests),
      headers: _headers(token),
      body: jsonEncode({
        'produit_id': productId,
        'quantity': quantity,
        'client_name': clientName,
        'note': note,
      }),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Demande impossible');
    }
  }

  Future<void> approve(String token, int id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.saleRequests}/$id/approve'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Validation impossible');
    }
  }

  Future<void> reject(String token, int id) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.saleRequests}/$id/reject'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Refus impossible');
    }
  }
}
