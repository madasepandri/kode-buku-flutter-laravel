import 'package:flutter/foundation.dart';

class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static void validate() {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw StateError('API_BASE_URL harus berupa URL HTTP/HTTPS yang valid.');
    }
    if (kReleaseMode && uri.scheme != 'https') {
      throw StateError('Build release harus menggunakan API_BASE_URL HTTPS.');
    }
  }
}
