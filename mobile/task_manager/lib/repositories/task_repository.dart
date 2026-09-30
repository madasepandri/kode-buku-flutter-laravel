import '../models/task.dart';
import '../models/task_page.dart';
import '../services/task_api_service.dart';
import '../utils/task_api_exception.dart';

Map<String, dynamic> _taskPayload(Task task) => {
      'title': task.title.trim(),
      'description': task.description.trim(),
      'status': task.status,
      'priority': task.priority,
      'due_date':
          '${task.dueDate.year.toString().padLeft(4, '0')}-'
          '${task.dueDate.month.toString().padLeft(2, '0')}-'
          '${task.dueDate.day.toString().padLeft(2, '0')}',
    };

class TaskRepository {
  TaskRepository(this._apiService);

  final TaskApiService _apiService;

  Future<TaskPage> getTasks({String search = '', String? status,
      String? priority, int page = 1}) async {
    final body = await _apiService.fetchTasks(query: {
      if (search.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      'page': page,
    });
    try {
      return TaskPage.fromJson(body as Map<String, dynamic>);
    } on FormatException {
      throw const TaskApiException('Format data dari server tidak sesuai.');
    } on TypeError {
      throw const TaskApiException('Format data dari server tidak sesuai.');
    }
  }

  Task _taskFromResponse(dynamic body) {
    try {
      if (body is! Map<String, dynamic> ||
          body['data'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      return Task.fromJson(body['data'] as Map<String, dynamic>);
    } on FormatException {
      throw const TaskApiException('Format data dari server tidak sesuai.');
    } on TypeError {
      throw const TaskApiException('Format data dari server tidak sesuai.');
    }
  }

  Future<Task> getTask(int id) async =>
      _taskFromResponse(await _apiService.fetchTask(id));

  Future<Task> createTask(Task draft) async =>
      _taskFromResponse(await _apiService.createTask(_taskPayload(draft)));

  Future<Task> updateTask(Task draft) async => _taskFromResponse(
        await _apiService.updateTask(draft.id, _taskPayload(draft)),
      );

  Future<void> deleteTask(int id) => _apiService.deleteTask(id);
}

