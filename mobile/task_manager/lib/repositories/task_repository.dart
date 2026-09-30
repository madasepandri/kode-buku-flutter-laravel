import '../models/task.dart';
import '../services/task_api_service.dart';
import '../utils/task_load_exception.dart';

class TaskRepository {
  TaskRepository(this._apiService);

  final TaskApiService _apiService;

  Future<List<Task>> getTasks() async {
    final body = await _apiService.fetchTasks();
    try {
      if (body is! Map<String, dynamic> || body['data'] is! List) {
        throw const FormatException();
      }

      return (body['data'] as List).map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException();
        }
        return Task.fromJson(item);
      }).toList(growable: false);
    } on FormatException {
      throw const TaskLoadException('Format data dari server tidak sesuai.');
    } on TypeError {
      throw const TaskLoadException('Format data dari server tidak sesuai.');
    }
  }
}
