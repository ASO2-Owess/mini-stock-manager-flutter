class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> profilePreferences;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePreferences = const {},
  });

  static Map<String, dynamic> _mapFromJsonValue(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      profilePreferences: _mapFromJsonValue(json['profile_preferences']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_preferences': profilePreferences,
    };
  }

  bool get isAdmin => role == 'admin';

  String get displayName {
    final value = profilePreferences['display_name'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return name;
  }

  String get avatarLabel {
    final value = profilePreferences['avatar_label'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim().toUpperCase();
    }
    return name.isEmpty ? '?' : name.trim()[0].toUpperCase();
  }

  String get themeColor {
    final value = profilePreferences['theme_color'];
    if (value is String && value.trim().isNotEmpty) return value.trim();
    return '#1A3A5C';
  }
}
