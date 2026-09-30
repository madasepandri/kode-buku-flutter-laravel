import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/task_list_view.dart';
import 'task_detail_screen.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<TaskProvider>().fetchTasks();
    });
  }

  void _retry() {
    context.read<TaskProvider>().fetchTasks();
  }

  Future<void> _openDetail(Task task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final pages = [
      DashboardView(
        totalCount: taskProvider.totalCount,
        completedCount: taskProvider.completedCount,
        onViewTasks: () => setState(() => _selectedIndex = 1),
      ),
      TaskListView(tasks: taskProvider.tasks, onTaskTap: _openDetail),
    ];

    final Widget content;
    if (taskProvider.state == TaskLoadState.initial ||
        taskProvider.state == TaskLoadState.loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (taskProvider.state == TaskLoadState.error) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(taskProvider.errorMessage ?? 'Gagal memuat task.'),
            TextButton(onPressed: _retry, child: const Text('Coba lagi')),
          ],
        ),
      );
    } else {
      content = pages[_selectedIndex];
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Task Management App')),
      body: content,
      floatingActionButton: null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Daftar task',
          ),
        ],
      ),
    );
  }
}
