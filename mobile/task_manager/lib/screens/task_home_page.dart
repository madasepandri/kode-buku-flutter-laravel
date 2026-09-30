import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/task_list_view.dart';
import 'task_detail_screen.dart';
import 'task_form_screen.dart';

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

  void _refreshTasks() {
    context.read<TaskProvider>().fetchTasks();
  }

  Future<void> _addTask() async {
    final saved = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (!mounted || saved == null) return;
    setState(() => _selectedIndex = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil ditambahkan.')),
    );
  }

  Future<void> _openDetail(Task task) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (!mounted || deleted != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil dihapus.')),
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
            TextButton(onPressed: _refreshTasks, child: const Text('Coba lagi')),
          ],
        ),
      );
    } else {
      content = pages[_selectedIndex];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management App'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang task',
            onPressed: taskProvider.state == TaskLoadState.loading
                ? null
                : _refreshTasks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content,
      floatingActionButton: taskProvider.state == TaskLoadState.success
          ? FloatingActionButton.extended(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              label: const Text('Tambah task'),
            )
          : null,
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
