import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/models/task_page.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_api_service.dart';
import 'package:task_manager/utils/task_api_exception.dart';

Task task(int id) => Task(id: id, title: 'Task $id', description: '',
  status: 'pending', dueDate: DateTime(2026, 10, 1));
TaskPage page(List<int> ids, int current) => TaskPage(
  items: ids.map(task).toList(), currentPage: current, lastPage: 2, total: 3);

class FakeRepository extends TaskRepository {
  FakeRepository(this.respond) : super(TaskApiService(Dio()));
  final Future<TaskPage> Function(String, int) respond;
  @override
  Future<TaskPage> getTasks({String search = '', String? status,
      String? priority, int page = 1}) => respond(search, page);
}

void main() {
  test('append deduplicates and refresh replaces page while keeping query', () async {
    final calls = <String>[];
    final p = TaskProvider(FakeRepository((search, current) async {
      calls.add('$search:$current');
      return page(current == 1 ? [1, 2] : [2, 3], current);
    }));
    addTearDown(p.dispose);
    await p.setQuery(search: ' laporan ');
    await p.loadMore();
    expect(p.tasks.map((t) => t.id), [1, 2, 3]);
    expect(p.hasMore, false);
    await p.fetchTasks();
    expect(p.tasks.map((t) => t.id), [1, 2]);
    expect(calls, ['laporan:1', 'laporan:2', 'laporan:1']);
  });
  test('a late old query cannot overwrite newer search results', () async {
    final old = Completer<TaskPage>();
    final p = TaskProvider(FakeRepository((search, current) =>
      search == 'old' ? old.future : Future.value(page([9], 1))));
    addTearDown(p.dispose);
    final pending = p.setQuery(search: 'old');
    await p.setQuery(search: 'new');
    old.complete(page([1], 1));
    await pending;
    expect(p.tasks.single.id, 9);
    expect(p.search, 'new');
  });
  test('load more failure preserves loaded items and page for retry', () async {
    final p = TaskProvider(FakeRepository((search, current) async {
      if (current == 2) { throw const TaskApiException('offline'); }
      return page([1], current);
    }));
    addTearDown(p.dispose);
    await p.fetchTasks();
    await p.loadMore();
    expect(p.tasks.single.id, 1);
    expect(p.currentPage, 1);
    expect(p.moreError, 'offline');
    expect(p.state, TaskLoadState.success);
    expect(p.loadingMore, false);
  });
}
