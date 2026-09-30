import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../utils/task_load_exception.dart';

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
    } on TaskLoadException catch (error) {
      _state = TaskLoadState.error;
      _errorMessage = error.message;
    } catch (_) {
      _state = TaskLoadState.error;
      _errorMessage = 'Data task tidak dapat diproses.';
    }

    notifyListeners();
  }
}
