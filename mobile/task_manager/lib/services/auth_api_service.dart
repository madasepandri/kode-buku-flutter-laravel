import 'package:dio/dio.dart';

import '../utils/auth_exception.dart';

class AuthApiService {
  AuthApiService(this._dio);

  final Dio _dio;

  Future<dynamic> register(Map<String, String> input) async {
    try {
      final response = await _dio.post<dynamic>(
        '/register',
        data: input,
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {'public': true},
        ),
      );
      return response.data;
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'register'));
    }
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post<dynamic>(
        '/login',
        data: {'email': email, 'password': password},
        options: Options(
          contentType: Headers.jsonContentType,
          extra: {'public': true},
        ),
      );
      return response.data;
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'login'));
    }
  }

  Future<dynamic> currentUser() async {
    try {
      return (await _dio.get<dynamic>('/user')).data;
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'user'));
    }
  }

  Future<dynamic> updateProfile(String name, String email) async {
    try {
      return (await _dio.put<dynamic>('/user', data: {
        'name': name.trim(), 'email': email.trim(),
      }, options: Options(contentType: Headers.jsonContentType))).data;
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'profile'));
    }
  }

  Future<dynamic> uploadAvatar(String path, String filename) async {
    try {
      final form = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(path, filename: filename),
      });
      return (await _dio.post<dynamic>('/user/avatar', data: form)).data;
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'avatar'));
    }
  }

  Future<void> logout() async {
    try {
      final response = await _dio.post<dynamic>('/logout');
      if (response.statusCode != 204) {
        throw const AuthException('Logout belum dikonfirmasi server.');
      }
    } on DioException catch (error) {
      throw AuthException(_message(error, operation: 'logout'));
    }
  }

  String _message(DioException error, {required String operation}) {
    final status = error.response?.statusCode;
    if (status == 413) return 'Ukuran file melampaui batas server.';
    if (status == 422 && operation == 'avatar') {
      return 'Gunakan gambar JPG/PNG dengan ukuran maksimal 2 MB.';
    }
    if (status == 422) {
      return operation == 'login'
          ? 'Email atau password tidak sesuai.'
          : 'Data tidak valid atau email sudah digunakan.';
    }
    if (status == 401) {
      return 'Sesi berakhir. Silakan login kembali.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi ke server melewati batas waktu.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Server tidak dapat dihubungi.';
    }
    if (operation == 'profile' || operation == 'avatar') {
      return 'Perubahan profil gagal disimpan. Coba lagi.';
    }
    return operation == 'logout'
        ? 'Logout belum dapat dikonfirmasi server.'
        : 'Proses autentikasi gagal. Coba lagi.';
  }
}

