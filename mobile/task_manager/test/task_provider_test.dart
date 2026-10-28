import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_api_service.dart';
import 'package:task_manager/utils/task_load_exception.dart';

class _FakeTaskApiService extends TaskApiService {
  _FakeTaskApiService(this._result) : super(Dio(), token: 'test');

  final Future<dynamic> Function() _result;

  @override
  Future<dynamic> fetchTasks() => _result();
}

Map<String, dynamic> _json(int id, String status) => {
      'id': id,
      'title': 'Task $id',
      'description': '',
      'status': status,
      'priority': 'medium',
      'due_date': '2026-10-21',
    };

void main() {
  test('fetchTasks memuat daftar dan menghitung status', () async {
    final provider = TaskProvider(
      TaskRepository(
        _FakeTaskApiService(
          () async => {
            'data': [_json(1, 'pending'), _json(2, 'completed')],
          },
        ),
      ),
    );
    addTearDown(provider.dispose);

    expect(provider.state, TaskLoadState.initial);
    expect(provider.totalCount, 0);

    await provider.fetchTasks();

    expect(provider.state, TaskLoadState.success);
    expect(provider.totalCount, 2);
    expect(provider.completedCount, 1);
    expect(provider.errorMessage, isNull);
  });

  test('fetchTasks menyimpan pesan saat server gagal', () async {
    final provider = TaskProvider(
      TaskRepository(
        _FakeTaskApiService(
          () async => throw const TaskLoadException('Server tidak dapat dihubungi.'),
        ),
      ),
    );
    addTearDown(provider.dispose);

    await provider.fetchTasks();

    expect(provider.state, TaskLoadState.error);
    expect(provider.errorMessage, 'Server tidak dapat dihubungi.');
    expect(provider.totalCount, 0);
  });
}
