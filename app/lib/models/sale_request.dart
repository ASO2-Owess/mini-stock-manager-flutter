import 'product.dart';
import 'user.dart';

class SaleRequest {
  final int id;
  final Product product;
  final User? user;
  final int quantity;
  final String? clientName;
  final String status;
  final String? note;
  final DateTime? createdAt;

  const SaleRequest({
    required this.id,
    required this.product,
    this.user,
    required this.quantity,
    this.clientName,
    required this.status,
    this.note,
    this.createdAt,
  });

  factory SaleRequest.fromJson(Map<String, dynamic> json) {
    return SaleRequest(
      id: json['id'],
      product: Product.fromJson(json['produit']),
      user: json['user'] == null ? null : User.fromJson(json['user']),
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      clientName: json['client_name'],
      status: json['status'] ?? 'pending',
      note: json['note'],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at']),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'Validée';
      case 'rejected':
        return 'Refusée';
      default:
        return 'En attente';
    }
  }
}
