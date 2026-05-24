class Product {
  final int id;
  final String nom;
  final String? reference;
  final String? description;
  final String type;
  final String vehicleType;
  final int quantity;
  final int alertThreshold;
  final double unitPrice;
  final String? location;
  final bool actif;

  const Product({
    required this.id,
    required this.nom,
    this.reference,
    this.description,
    required this.type,
    required this.vehicleType,
    required this.quantity,
    required this.alertThreshold,
    required this.unitPrice,
    this.location,
    required this.actif,
  });

  static String _normalizeType(dynamic value) {
    const allowed = {
      'moteur',
      'freinage',
      'suspension',
      'electrique',
      'carrosserie',
      'pneu',
      'accessoire',
      'autre',
    };
    final type = '${value ?? 'autre'}';
    return allowed.contains(type) ? type : 'autre';
  }

  static String _normalizeVehicle(dynamic value) {
    const allowed = {'voiture', 'moto', 'velo', 'camion', 'autre'};
    final vehicle = '${value ?? 'voiture'}';
    return allowed.contains(vehicle) ? vehicle : 'voiture';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nom: json['nom'],
      reference: json['reference'],
      description: json['description'],
      type: _normalizeType(json['type']),
      vehicleType: _normalizeVehicle(json['vehicle_type']),
      quantity: int.tryParse('${json['quantity'] ?? 0}') ?? 0,
      alertThreshold: int.tryParse('${json['alert_threshold'] ?? 5}') ?? 5,
      unitPrice: double.tryParse(
              '${json['unit_price'] ?? json['montant_min'] ?? 0}') ??
          0,
      location: json['location'],
      actif: json['actif'] == true || json['actif'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'reference': reference,
      'description': description,
      'type': type,
      'vehicle_type': vehicleType,
      'quantity': quantity,
      'alert_threshold': alertThreshold,
      'unit_price': unitPrice,
      'location': location,
      'actif': actif,
    };
  }

  bool get isLowStock => quantity <= alertThreshold;
  bool get isOutOfStock => quantity <= 0;

  String get typeLabel {
    switch (type) {
      case 'moteur':
        return 'Moteur';
      case 'freinage':
        return 'Freinage';
      case 'suspension':
        return 'Suspension';
      case 'electrique':
        return 'Electrique';
      case 'carrosserie':
        return 'Carrosserie';
      case 'pneu':
        return 'Pneu';
      case 'accessoire':
        return 'Accessoire';
      default:
        return 'Autre';
    }
  }

  String get vehicleLabel {
    switch (vehicleType) {
      case 'voiture':
        return 'Voiture';
      case 'moto':
        return 'Moto';
      case 'velo':
        return 'Velo';
      case 'camion':
        return 'Camion';
      default:
        return 'Autre';
    }
  }

  String get priceFormatted {
    return '${unitPrice.toStringAsFixed(0)} FCFA';
  }
}
