import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_api_service.dart';

Map<String, dynamic> _json(int id, String status) => {
      'id': id,
      'title': 'Task $id',
      'description': '',
      'status': status,
      'priority': 'medium',
      'due_date': '2026-10-21',
    };

// Server tiruan di memori: mengembalikan bentuk response yang sama dengan API.
class _FakeTaskApiService extends TaskApiService {
  _FakeTaskApiService() : super(Dio(), token: 'test');

  final _rows = [_json(1, 'pending'), _json(2, 'completed')];

  @override
  Future<dynamic> fetchTasks() async => {'data': List.of(_rows)};

  @override
  Future<dynamic> createTask(Map<String, dynamic> payload) async => {
        'data': {'id': 3, ...payload},
      };

  @override
  Future<dynamic> updateTask(int id, Map<String, dynamic> payload) async => {
        'data': {'id': id, ...payload},
      };

  @override
  Future<void> deleteTask(int id) async {}
}

void main() {
  late TaskProvider provider;

  setUp(() async {
    provider = TaskProvider(TaskRepository(_FakeTaskApiService()));
    addTearDown(provider.dispose);
    await provider.fetchTasks();
  });

  test('daftar awal dimuat dari API', () {
    expect(provider.state, TaskLoadState.success);
    expect(provider.totalCount, 2);
    expect(provider.completedCount, 1);
  });

  test('createTask menambahkan hasil server ke daftar', () async {
    final saved = await provider.createTask(Task(
      id: 0,
      title: 'Membeli buku',
      description: '',
      status: 'pending',
      dueDate: DateTime(2026, 10, 21),
    ));

    expect(saved.id, 3);
    expect(provider.totalCount, 3);
    expect(provider.completedCount, 1);
    expect(provider.tasks.last.id, 3);
  });

  test('updateTask mengganti item dengan ID yang sama', () async {
    final first = provider.tasks.first;
    await provider.updateTask(Task(
      id: first.id,
      title: first.title,
      description: first.description,
      status: 'completed',
      dueDate: first.dueDate,
    ));

    expect(provider.totalCount, 2);
    expect(provider.completedCount, 2);
    expect(provider.tasks.first.id, first.id);
  });

  test('deleteTask menghapus item dari daftar', () async {
    await provider.deleteTask(1);

    expect(provider.totalCount, 1);
    expect(provider.tasks.single.id, 2);
  });
}
