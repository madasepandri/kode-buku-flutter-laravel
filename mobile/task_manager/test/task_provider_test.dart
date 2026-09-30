import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/task_api_service.dart';

void main() {
  test('clearForSession resets task state for a new session', () {
    final provider = TaskProvider(TaskRepository(TaskApiService(Dio())));
    addTearDown(provider.dispose);

    expect(provider.state, TaskLoadState.initial);
    expect(provider.totalCount, 0);
    expect(provider.completedCount, 0);
    expect(provider.errorMessage, isNull);

    provider.clearForSession();

    expect(provider.state, TaskLoadState.initial);
    expect(provider.totalCount, 0);
    expect(provider.completedCount, 0);
    expect(provider.errorMessage, isNull);
  });
}
