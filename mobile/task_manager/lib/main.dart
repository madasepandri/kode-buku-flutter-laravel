import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/task_repository.dart';
import 'screens/auth_gate.dart';
import 'services/api_config.dart';
import 'services/auth_api_service.dart';
import 'services/auth_interceptor.dart';
import 'services/task_api_service.dart';
import 'services/token_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStore = TokenStore(const FlutterSecureStorage());
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  final taskProvider = TaskProvider(
    TaskRepository(TaskApiService(dio)),
  );
  final authProvider = AuthProvider(
    AuthRepository(AuthApiService(dio), tokenStore),
    taskProvider,
  );

  dio.interceptors.add(
    AuthInterceptor(tokenStore, authProvider.expireSession),
  );
  authProvider.restore();

  runApp(
    TaskManagerApp(
      authProvider: authProvider,
      taskProvider: taskProvider,
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({
    super.key,
    required this.authProvider,
    required this.taskProvider,
  });

  final AuthProvider authProvider;
  final TaskProvider taskProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
      ],
      child: MaterialApp(
        title: 'Task Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
