import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/services/local_task_service.dart';

void main() {
  test('task lokal memperbarui daftar dan hitungan status', () {
    final provider = TaskProvider(TaskRepository(LocalTaskService()));
    addTearDown(provider.dispose);
    expect(provider.totalCount, 5);
    expect(provider.completedCount, 2);

    provider.addTask(Task(id: 0, title: 'Membeli buku', description: '',
      status: 'pending', dueDate: DateTime(2026, 10, 21)));
    expect(provider.totalCount, 6);
    expect(provider.completedCount, 2);

    final created = provider.tasks.last;
    provider.updateTask(created.copyWith(status: 'completed'));
    expect(provider.totalCount, 6);
    expect(provider.completedCount, 3);
    expect(provider.tasks.last.id, created.id);
  });
}
