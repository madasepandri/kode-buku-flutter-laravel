import '../models/task.dart';
import '../services/local_task_service.dart';

class TaskRepository {
  TaskRepository(this._service);
  final LocalTaskService _service;
  List<Task> getTasks() => _service.getTasks();
  Task addTask(Task task) => _service.addTask(task);
  void updateTask(Task task) => _service.updateTask(task);
}
