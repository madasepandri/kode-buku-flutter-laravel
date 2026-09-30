import 'package:dio/dio.dart';

import '../utils/task_api_exception.dart';

class TaskApiService {
  TaskApiService(this._dio, {required String token}) : _token = token;

  final Dio _dio;
  final String _token;

  Options _authOptions({bool json = false}) => Options(
        headers: {'Authorization': 'Bearer $_token'},
        contentType: json ? Headers.jsonContentType : null,
      );

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
    int expectedStatus,
  ) async {
    if (_token.isEmpty) {
      throw const TaskApiException('Token latihan belum diberikan.');
    }

    try {
      final response = await request();
      if (response.statusCode != expectedStatus) {
        throw const TaskApiException('Status response API tidak sesuai.');
      }
      return response;
    } on DioException catch (error) {
      switch (error.response?.statusCode) {
        case 401:
          throw const TaskApiException('Akses ditolak. Perbarui token latihan.');
        case 404:
          throw const TaskApiException('Task tidak ditemukan atau tidak dapat diakses.');
        case 422:
          throw const TaskApiException('Data ditolak server. Periksa isian task.');
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const TaskApiException('Koneksi ke server melewati batas waktu.');
      }
      if (error.type == DioExceptionType.connectionError) {
        throw const TaskApiException('Server tidak dapat dihubungi.');
      }
      throw const TaskApiException('Operasi task gagal. Coba lagi.');
    }
  }

  Future<dynamic> fetchTasks() async =>
      (await _send(
        () => _dio.get<dynamic>('/tasks', options: _authOptions()),
        200,
      ))
          .data;

  Future<dynamic> fetchTask(int id) async =>
      (await _send(
        () => _dio.get<dynamic>('/tasks/$id', options: _authOptions()),
        200,
      ))
          .data;

  Future<dynamic> createTask(Map<String, dynamic> payload) async =>
      (await _send(
        () => _dio.post<dynamic>(
          '/tasks',
          data: payload,
          options: _authOptions(json: true),
        ),
        201,
      ))
          .data;

  Future<dynamic> updateTask(int id, Map<String, dynamic> payload) async =>
      (await _send(
        () => _dio.put<dynamic>(
          '/tasks/$id',
          data: payload,
          options: _authOptions(json: true),
        ),
        200,
      ))
          .data;

  Future<void> deleteTask(int id) async {
    await _send(
      () => _dio.delete<dynamic>('/tasks/$id', options: _authOptions()),
      204,
    );
  }
}
