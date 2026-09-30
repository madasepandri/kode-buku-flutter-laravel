import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../utils/task_api_exception.dart';

enum TaskLoadState { initial, loading, success, error }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this._repository);

  final TaskRepository _repository;
  List<Task> _tasks = [];
  TaskLoadState _state = TaskLoadState.initial;
  String? _errorMessage;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  TaskLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get totalCount => _tasks.length;
  int get completedCount =>
      _tasks.where((task) => task.status == 'completed').length;

  Future<void> fetchTasks() async {
    _state = TaskLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTasks();
      _tasks = result;
      _state = TaskLoadState.success;
    } on TaskApiException catch (error) {
      _state = TaskLoadState.error;
      _errorMessage = error.message;
    } catch (_) {
      _state = TaskLoadState.error;
      _errorMessage = 'Data task tidak dapat diproses.';
    }

    notifyListeners();
  }

  Future<Task> fetchTask(int id) => _repository.getTask(id);

  Future<Task> createTask(Task draft) async {
    final saved = await _repository.createTask(draft);
    _tasks = [..._tasks, saved];
    notifyListeners();
    return saved;
  }

  Future<Task> updateTask(Task draft) async {
    final saved = await _repository.updateTask(draft);
    final index = _tasks.indexWhere((task) => task.id == saved.id);
    if (index >= 0) {
      _tasks = [
        ..._tasks.take(index),
        saved,
        ..._tasks.skip(index + 1),
      ];
    }
    notifyListeners();
    return saved;
  }

  Future<void> deleteTask(int id) async {
    await _repository.deleteTask(id);
    _tasks = _tasks.where((task) => task.id != id).toList();
    notifyListeners();
  }
}
