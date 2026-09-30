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
  int _queryGeneration = 0;
  String _search = '';
  String? _status;
  String? _priority;
  int _page = 0;
  int _lastPage = 1;
  int _total = 0;
  bool _loadingMore = false;
  String? _moreError;

  String get search => _search;
  String? get status => _status;
  String? get priority => _priority;
  int get currentPage => _page;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _page < _lastPage;
  String? get moreError => _moreError;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  TaskLoadState get state => _state;
  String? get errorMessage => _errorMessage;
  int get totalCount => _total;
  int get completedCount =>
      _tasks.where((task) => task.status == 'completed').length;

  bool _isCurrent(int generation) => generation == _sessionGeneration;

  void clearForSession() {
    _sessionGeneration++;
    _queryGeneration++;
    _search = '';
    _status = null;
    _priority = null;
    _page = 0;
    _lastPage = 1;
    _total = 0;
    _loadingMore = false;
    _moreError = null;
    _tasks = [];
    _state = TaskLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> setQuery({required String search, String? status,
      String? priority}) async {
    _search = search.trim();
    _status = status;
    _priority = priority;
    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    final generation = _sessionGeneration;
    final queryGeneration = ++_queryGeneration;
    _state = TaskLoadState.loading;
    _tasks = [];
    _total = 0;
    _page = 0;
    _lastPage = 1;
    _errorMessage = null;
    _moreError = null;
    _loadingMore = false;
    notifyListeners();

    try {
      final result = await _repository.getTasks(
        search: _search, status: _status, priority: _priority);
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      _tasks = result.items;
      _page = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
      _state = TaskLoadState.success;
    } on TaskApiException catch (error) {
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      _state = TaskLoadState.error;
      _errorMessage = error.message;
    } catch (_) {
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      _state = TaskLoadState.error;
      _errorMessage = 'Data task tidak dapat diproses.';
    }
    if (_isCurrent(generation) && queryGeneration == _queryGeneration) {
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_state != TaskLoadState.success || _loadingMore || !hasMore) return;
    final generation = _sessionGeneration;
    final queryGeneration = _queryGeneration;
    _loadingMore = true;
    _moreError = null;
    notifyListeners();
    try {
      final result = await _repository.getTasks(search: _search,
        status: _status, priority: _priority, page: _page + 1);
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      final ids = _tasks.map((task) => task.id).toSet();
      _tasks = [..._tasks, ...result.items.where((task) => ids.add(task.id))];
      _page = result.currentPage;
      _lastPage = result.lastPage;
      _total = result.total;
    } on TaskApiException catch (error) {
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      _moreError = error.message;
    } catch (_) {
      if (!_isCurrent(generation) || queryGeneration != _queryGeneration) return;
      _moreError = 'Halaman berikutnya gagal diproses.';
    } finally {
      if (_isCurrent(generation) && queryGeneration == _queryGeneration) {
        _loadingMore = false;
        notifyListeners();
      }
    }
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
    await fetchTasks();
    return saved;
  }

  Future<Task> updateTask(Task draft) async {
    final generation = _sessionGeneration;
    final saved = await _repository.updateTask(draft);
    if (!_isCurrent(generation)) {
      throw const TaskApiException('Sesi telah berubah. Ulangi operasi pada akun aktif.');
    }
    await fetchTasks();
    return saved;
  }

  Future<void> deleteTask(int id) async {
    final generation = _sessionGeneration;
    await _repository.deleteTask(id);
    if (!_isCurrent(generation)) return;
    await fetchTasks();
  }
}

