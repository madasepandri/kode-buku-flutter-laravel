import 'package:dio/dio.dart';

import '../utils/task_api_exception.dart';

class TaskApiService {
  TaskApiService(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
    int expectedStatus,
  ) async {
    try {
      final response = await request();
      if (response.statusCode != expectedStatus) {
        throw const TaskApiException('Status response API tidak sesuai.');
      }
      return response;
    } on DioException catch (error) {
      switch (error.response?.statusCode) {
        case 401:
          throw const TaskApiException('Sesi berakhir. Silakan login kembali.');
        case 404:
          throw const TaskApiException(
            'Task tidak ditemukan atau tidak dapat diakses.',
          );
        case 422:
          throw const TaskApiException(
            'Data ditolak server. Periksa isian task.',
          );
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

  Future<dynamic> fetchTasks({Map<String, dynamic>? query}) async =>
      (await _send(
        () => _dio.get<dynamic>('/tasks', queryParameters: query),
        200,
      )).data;

  Future<dynamic> fetchTask(int id) async =>
      (await _send(() => _dio.get<dynamic>('/tasks/$id'), 200)).data;

  Future<dynamic> createTask(Map<String, dynamic> payload) async =>
      (await _send(
        () => _dio.post<dynamic>(
          '/tasks',
          data: payload,
          options: Options(contentType: Headers.jsonContentType),
        ),
        201,
      )).data;

  Future<dynamic> updateTask(int id, Map<String, dynamic> payload) async =>
      (await _send(
        () => _dio.put<dynamic>(
          '/tasks/$id',
          data: payload,
          options: Options(contentType: Headers.jsonContentType),
        ),
        200,
      )).data;

  Future<void> deleteTask(int id) async {
    await _send(() => _dio.delete<dynamic>('/tasks/$id'), 204);
  }
}
