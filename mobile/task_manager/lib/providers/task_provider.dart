import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

class TaskProvider extends ChangeNotifier {
  TaskProvider(TaskRepository repository)
      : _repository = repository, _tasks = repository.getTasks();
  final TaskRepository _repository;
  List<Task> _tasks;
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((task) => task.status == 'completed').length;
  void addTask(Task task) {
    _repository.addTask(task);
    _tasks = _repository.getTasks();
    notifyListeners();
  }
  void updateTask(Task task) {
    _repository.updateTask(task);
    _tasks = _repository.getTasks();
    notifyListeners();
  }
}
