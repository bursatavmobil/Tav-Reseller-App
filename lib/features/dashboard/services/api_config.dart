import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static final String baseUrl = dotenv.env['API_URL'] ?? '';
  static const String tokenKey = 'auth_token';
}
