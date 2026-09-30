class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const demoToken = String.fromEnvironment('DEMO_API_TOKEN');
}
