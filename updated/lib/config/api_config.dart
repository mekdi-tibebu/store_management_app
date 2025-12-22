const String baseUrl = 'https://store-management-56xj.onrender.com/api';

class ApiConfig {
  static const String apiBaseUrl = baseUrl;
  
  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/token/';
  static const String refreshTokenEndpoint = '$baseUrl/token/refresh/';
  static const String signupEndpoint = '$baseUrl/signup/';
  static const String verifyEmailEndpoint = '$baseUrl/verify-email/';
  
  // Computer endpoints
  static const String computersEndpoint = '$baseUrl/computer-sales/';
  
  // Maintenance endpoints
  static const String maintenanceEndpoint = '$baseUrl/maintenance-jobs/';
  
  // Sold items
  static const String soldItemsEndpoint = '$baseUrl/sold-items/';
  
  // Subscription
  static const String subscriptionEndpoint = '$baseUrl/subscription-status/';
  static const String paymentEndpoint = '$baseUrl/start-payment/';
  
  // Headers
  static Map<String, String> jsonHeaders = {'Content-Type': 'application/json'};
  
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
