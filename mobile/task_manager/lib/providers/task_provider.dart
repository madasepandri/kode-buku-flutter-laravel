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
  int _sessionGeneration = 0;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  TaskLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get totalCount => _tasks.length;
  int get completedCount =>
      _tasks.where((task) => task.status == 'completed').length;

  bool _isCurrent(int generation) => generation == _sessionGeneration;

  void clearForSession() {
    _sessionGeneration++;
    _tasks = [];
    _state = TaskLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    final generation = _sessionGeneration;
    _state = TaskLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getTasks();
      if (!_isCurrent(generation)) return;
      _tasks = result;
      _state = TaskLoadState.success;
    } on TaskApiException catch (error) {
      if (!_isCurrent(generation)) return;
      _state = TaskLoadState.error;
      _errorMessage = error.message;
    } catch (_) {
      if (!_isCurrent(generation)) return;
      _state = TaskLoadState.error;
      _errorMessage = 'Data task tidak dapat diproses.';
    }

    if (_isCurrent(generation)) notifyListeners();
  }

  Future<Task> fetchTask(int id) async {
    final generation = _sessionGeneration;
    final task = await _repository.getTask(id);
    if (!_isCurrent(generation)) {
      throw const TaskApiException('Sesi telah berubah. Buka kembali task pada akun aktif.');
    }
    return task;
  }

  Future<Task> createTask(Task draft) async {
    final generation = _sessionGeneration;
    final saved = await _repository.createTask(draft);
    if (!_isCurrent(generation)) {
      throw const TaskApiException('Sesi telah berubah. Ulangi operasi pada akun aktif.');
    }
    _tasks = [..._tasks, saved];
    notifyListeners();
    return saved;
  }

  Future<Task> updateTask(Task draft) async {
    final generation = _sessionGeneration;
    final saved = await _repository.updateTask(draft);
    if (!_isCurrent(generation)) {
      throw const TaskApiException('Sesi telah berubah. Ulangi operasi pada akun aktif.');
    }
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
    final generation = _sessionGeneration;
    await _repository.deleteTask(id);
    if (!_isCurrent(generation)) return;
    _tasks = _tasks.where((task) => task.id != id).toList();
    notifyListeners();
  }
}
