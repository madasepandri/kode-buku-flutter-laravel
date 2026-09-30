import 'package:dio/dio.dart';

import '../utils/task_load_exception.dart';

class TaskApiService {
  TaskApiService(this._dio, {required String token}) : _token = token;

  final Dio _dio;
  final String _token;

  Future<dynamic> fetchTasks() async {
    if (_token.isEmpty) {
      throw const TaskLoadException('Token latihan belum diberikan.');
    }

    try {
      final response = await _dio.get<dynamic>(
        '/tasks',
        options: Options(headers: {'Authorization': 'Bearer $_token'}),
      );
      return response.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        throw const TaskLoadException('Akses ditolak. Perbarui token latihan.');
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        throw const TaskLoadException('Koneksi ke server melewati batas waktu.');
      }
      if (error.type == DioExceptionType.connectionError) {
        throw const TaskLoadException('Server tidak dapat dihubungi.');
      }
      throw const TaskLoadException('Gagal mengambil daftar task.');
    }
  }
}
