import 'package:flutter/material.dart';

import '../models/activity_log.dart';
import '../models/user.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<User> _users = [];
  List<ActivityLog> _activities = [];
  bool _loading = false;
  String? _error;

  List<User> get users => _users;
  List<ActivityLog> get activities => _activities;
  bool get loading => _loading;
  String? get error => _error;

  int get adminCount => _users.where((user) => user.isAdmin).length;
  int get employeeCount => _users.where((user) => !user.isAdmin).length;

  Future<void> load(String token) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _service.loadDashboard(token);
      _users = snapshot.users;
      _activities = snapshot.activities;
    } catch (e) {
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
