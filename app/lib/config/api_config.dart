class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'http://10.85.182.104:8001/api';

  static const String login = '$baseUrl/login';
  static const String register = '$baseUrl/register';
  static const String logout = '$baseUrl/logout';
  static const String profile = '$baseUrl/profil';
  static const String products = '$baseUrl/produits';
  static const String saleRequests = '$baseUrl/sale-requests';
  static const String activities = '$baseUrl/activities';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminActivities = '$baseUrl/admin/activities';
}
