import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/models/app_user.dart';
import 'package:task_manager/models/task_page.dart';
import 'package:task_manager/providers/auth_provider.dart';
import 'package:task_manager/providers/task_provider.dart';
import 'package:task_manager/repositories/auth_repository.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/task_home_page.dart';
import 'package:task_manager/services/auth_api_service.dart';
import 'package:task_manager/services/task_api_service.dart';
import 'package:task_manager/services/token_store.dart';

class _FakeAuthRepo extends AuthRepository {
  _FakeAuthRepo({required this.failClear})
      : super(AuthApiService(Dio()), TokenStore(const FlutterSecureStorage()));
  final bool failClear;
  bool cleared = false;

  @override
  Future<AppUser> login(String email, String password) async =>
      const AppUser(id: 1, name: 'Uji', email: 'uji@example.test');

  @override
  Future<void> logoutRemotely() async {}

  @override
  Future<void> clearToken() async {
    if (failClear) throw StateError('storage rusak');
    cleared = true;
  }
}

class _FakeTaskRepo extends TaskRepository {
  _FakeTaskRepo() : super(TaskApiService(Dio()));
  @override
  Future<TaskPage> getTasks({
    String search = '',
    String? status,
    String? priority,
    int page = 1,
  }) async =>
      const TaskPage(items: [], currentPage: 1, lastPage: 1, total: 0);
}

Future<AuthProvider> _pump(WidgetTester tester, {required bool failClear}) async {
  final tasks = TaskProvider(_FakeTaskRepo());
  final auth = AuthProvider(_FakeAuthRepo(failClear: failClear), tasks);
  await auth.login('uji@example.test', 'x');
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<TaskProvider>.value(value: tasks),
    ],
    child: const MaterialApp(home: TaskHomePage()),
  ));
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('SnackBar muncul bila sesi lokal gagal dibersihkan', (tester) async {
    final auth = await _pump(tester, failClear: true);
    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Keluar dari akun?'), findsOneWidget);
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(find.text('Sesi lokal belum dapat dibersihkan.'), findsOneWidget);
    expect(auth.state, AuthState.signedIn);
    expect(auth.busy, isFalse);
  });

  testWidgets('logout berhasil mengakhiri sesi tanpa SnackBar', (tester) async {
    final auth = await _pump(tester, failClear: false);
    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keluar'));
    await tester.pump(const Duration(milliseconds: 500)); // gate belum ada di test ini; spinner tidak pernah settle
    expect(find.text('Sesi lokal belum dapat dibersihkan.'), findsNothing);
    expect(auth.state, AuthState.signedOut);
  });
}
