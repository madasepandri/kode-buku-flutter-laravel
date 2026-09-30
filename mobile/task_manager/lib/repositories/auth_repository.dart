import '../models/app_user.dart';
import '../services/auth_api_service.dart';
import '../services/token_store.dart';
import '../utils/auth_exception.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final AuthApiService _api;
  final TokenStore _tokens;

  Future<String?> storedToken() => _tokens.read();
  Future<void> clearToken() => _tokens.clear();

  AppUser _userFromBody(dynamic body) {
    try {
      if (body is! Map<String, dynamic> ||
          body['data'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return AppUser.fromJson(body['data'] as Map<String, dynamic>);
    } on FormatException {
      throw const AuthException('Response pengguna tidak sesuai.');
    } on TypeError {
      throw const AuthException('Response pengguna tidak sesuai.');
    }
  }

  Future<AppUser> register(String name, String email, String password) async {
    final body = await _api.register({
      'name': name,
      'email': email,
      'password': password,
    });
    return _userFromBody(body);
  }

  Future<AppUser> login(String email, String password) async {
    final body = await _api.login(email, password);
    try {
      if (body is! Map<String, dynamic> ||
          body['data'] is! Map<String, dynamic> ||
          body['token'] is! String ||
          (body['token'] as String).isEmpty ||
          body['token_type'] != 'Bearer') {
        throw const FormatException();
      }
      final user = AppUser.fromJson(body['data'] as Map<String, dynamic>);
      await _tokens.save(body['token'] as String);
      return user;
    } on FormatException {
      throw const AuthException('Response login tidak sesuai.');
    } on TypeError {
      throw const AuthException('Response login tidak sesuai.');
    }
  }

  Future<AppUser> currentUser() async => _userFromBody(await _api.currentUser());

  Future<void> logoutRemotely() => _api.logout();
}
