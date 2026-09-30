import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../repositories/auth_repository.dart';
import '../utils/auth_exception.dart';
import 'task_provider.dart';

enum AuthState { checking, signedOut, signedIn, retryableError }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository, this._tasks);

  final AuthRepository _repository;
  final TaskProvider _tasks;

  AuthState _state = AuthState.checking;
  AppUser? _user;
  String? _errorMessage;
  bool _busy = false;

  AuthState get state => _state;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;

  Future<void> restore() async {
    _state = AuthState.checking;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _repository.storedToken();
      if (token == null || token.isEmpty) {
        _user = null;
        _state = AuthState.signedOut;
      } else {
        _user = await _repository.currentUser();
        if (_state != AuthState.signedOut) {
          _state = AuthState.signedIn;
        }
      }
    } on AuthException catch (error) {
      if (_state != AuthState.signedOut) {
        _user = null;
        _state = AuthState.retryableError;
        _errorMessage = error.message;
      }
    } catch (_) {
      if (_state != AuthState.signedOut) {
        _user = null;
        _state = AuthState.retryableError;
        _errorMessage = 'Sesi belum dapat diperiksa. Coba lagi.';
      }
    }

    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    await _repository.register(name, email, password);
  }

  Future<void> login(String email, String password) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();

    try {
      final user = await _repository.login(email, password);
      _tasks.clearForSession();
      _user = user;
      _state = AuthState.signedIn;
      _errorMessage = null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> expireSession(String? requestToken) async {
    if (requestToken == null || requestToken.isEmpty) return;

    final currentToken = await _repository.storedToken();
    if (currentToken != requestToken) {
      return;
    }

    await _endLocalSession();
  }

  Future<void> _endLocalSession() async {
    await _repository.clearToken();
    _tasks.clearForSession();
    _user = null;
    _state = AuthState.signedOut;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> clearDeviceSession() => _endLocalSession();

  Future<void> logout() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();

    try {
      try {
        await _repository.logoutRemotely();
      } on AuthException {
        // Akses lokal tetap diakhiri bila server tidak dapat mengonfirmasi logout.
      }
      await _endLocalSession();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
