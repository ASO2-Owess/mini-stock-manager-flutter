import 'user.dart';

class ActivityLog {
  final int id;
  final String action;
  final String? subjectType;
  final int? subjectId;
  final Map<String, dynamic> metadata;
  final User? user;
  final DateTime? createdAt;

  const ActivityLog({
    required this.id,
    required this.action,
    this.subjectType,
    this.subjectId,
    this.metadata = const {},
    this.user,
    this.createdAt,
  });

  static Map<String, dynamic> _mapFromJsonValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      action: json['action'],
      subjectType: json['subject_type'],
      subjectId: json['subject_id'],
      metadata: _mapFromJsonValue(json['metadata']),
      user: json['user'] == null ? null : User.fromJson(json['user']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at']),
    );
  }

  String get label {
    switch (action) {
      case 'auth.login':
        return 'Connexion';
      case 'auth.logout':
        return 'Deconnexion';
      case 'auth.registered':
        return 'Creation de compte';
      case 'profile.updated':
        return 'Profil modifie';
      case 'products.listed':
        return 'Stock consulté';
      case 'products.viewed':
        return 'Pièce consultée';
      case 'products.created':
        return 'Pièce créée';
      case 'products.updated':
        return 'Pièce modifiée';
      case 'products.deleted':
        return 'Pièce supprimée';
      default:
        return action;
    }
  }
}
