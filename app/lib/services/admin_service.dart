import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/activity_log.dart';
import '../models/user.dart';

class AdminSnapshot {
  final List<User> users;
  final List<ActivityLog> activities;

  const AdminSnapshot({
    required this.users,
    required this.activities,
  });
}

class AdminService {
  Map<String, String> _headers(String token) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<AdminSnapshot> loadDashboard(String token) async {
    final responses = await Future.wait([
      http.get(Uri.parse(ApiConfig.adminUsers), headers: _headers(token)),
      http.get(Uri.parse(ApiConfig.adminActivities), headers: _headers(token)),
    ]);

    final usersResponse = responses[0];
    final activitiesResponse = responses[1];

    if (usersResponse.statusCode != 200) {
      throw Exception('Chargement utilisateurs impossible');
    }
    if (activitiesResponse.statusCode != 200) {
      throw Exception('Chargement activites impossible');
    }

    final usersBody = jsonDecode(usersResponse.body);
    final activitiesBody = jsonDecode(activitiesResponse.body);

    return AdminSnapshot(
      users: (usersBody['users'] as List)
          .map((item) => User.fromJson(item))
          .toList(),
      activities: (activitiesBody['activities'] as List)
          .map((item) => ActivityLog.fromJson(item))
          .toList(),
    );
  }
}
