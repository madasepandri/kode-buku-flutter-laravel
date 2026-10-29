import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/task_detail_screen.dart';
import 'package:task_manager/services/task_api_service.dart';

class _FakeTaskRepo extends TaskRepository {
  _FakeTaskRepo() : super(TaskApiService(Dio()));

  Task stored = Task(
    id: 7,
    title: 'Judul lama',
    description: '',
    status: 'pending',
    dueDate: DateTime(2026, 11, 4),
  );

  @override
  Future<List<Task>> getTasks() async => [stored];

  @override
  Future<Task> getTask(int id) async => stored;

  @override
  Future<Task> updateTask(Task draft) async => stored = draft;
}

void main() {
  testWidgets('detail menampilkan data baru dan SnackBar setelah edit', (
    tester,
  ) async {
    final repo = _FakeTaskRepo();
    final provider = TaskProvider(repo);
    await tester.pumpWidget(
      ChangeNotifierProvider<TaskProvider>.value(
        value: provider,
        child: MaterialApp(home: TaskDetailScreen(task: repo.stored)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Judul lama'), findsOneWidget);

    await tester.tap(find.text('Edit task'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Judul baru');
    await tester.tap(find.text('Simpan task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Judul baru'), findsOneWidget);
    expect(find.text('Task berhasil diperbarui.'), findsOneWidget);
  });
}
