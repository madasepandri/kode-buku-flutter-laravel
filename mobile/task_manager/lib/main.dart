import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'repositories/task_repository.dart';
import 'screens/login_screen.dart';
import 'services/local_task_service.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<TaskProvider>(
    create: (_) => TaskProvider(TaskRepository(LocalTaskService())),
    child: MaterialApp(
      title: 'Task Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
      home: const LoginScreen(),
    ),
  );
}
