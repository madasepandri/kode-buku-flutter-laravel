import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/services/task_api_service.dart';

class _FakeTaskApiService extends TaskApiService {
  _FakeTaskApiService() : super(Dio(), token: 'test');

  @override
  Future<dynamic> fetchTasks() async => {
        'data': [
          {
            'id': 1,
            'title': 'Menyusun laporan',
            'description': '',
            'status': 'pending',
            'priority': 'medium',
            'due_date': '2026-10-21',
          },
        ],
      };
}

void main() {
  testWidgets('login memvalidasi form lalu membuka dashboard dari API',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<TaskProvider>(
        create: (_) => TaskProvider(TaskRepository(_FakeTaskApiService())),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'contoh');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Total task'), findsOneWidget);
    expect(find.text('1'), findsWidgets);

    await tester.tap(find.text('Lihat daftar task'));
    await tester.pumpAndSettle();
    expect(find.text('Menyusun laporan'), findsOneWidget);
  });
}
