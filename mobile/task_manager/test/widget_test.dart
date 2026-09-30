import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/auth_repository.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/login_screen.dart';
import 'package:task_manager/services/auth_api_service.dart';
import 'package:task_manager/services/task_api_service.dart';
import 'package:task_manager/services/token_store.dart';

void main() {
  testWidgets('login form validates required fields', (tester) async {
    final dio = Dio();
    final taskProvider = TaskProvider(TaskRepository(TaskApiService(dio)));
    final authProvider = AuthProvider(
      AuthRepository(
        AuthApiService(dio),
        TokenStore(const FlutterSecureStorage()),
      ),
      taskProvider,
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
  });
}
