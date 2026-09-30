import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'repositories/task_repository.dart';
import 'screens/login_screen.dart';
import 'services/api_config.dart';
import 'services/task_api_service.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<TaskProvider>(
        create: (_) {
          final dio = Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/json'},
            ),
          );
          final service = TaskApiService(dio, token: ApiConfig.demoToken);
          return TaskProvider(TaskRepository(service));
        },
        child: MaterialApp(
          title: 'Task Management App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: const LoginScreen(),
        ),
      );
}
