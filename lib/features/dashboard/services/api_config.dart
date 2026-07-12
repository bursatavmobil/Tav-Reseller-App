

// class ApiConfig {
//   static final String baseUrl = dotenv.env['API_URL'] ?? '';
//   static const String tokenKey = 'auth_token';
// }

class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );
  static const String tokenKey = 'auth_token';
}
