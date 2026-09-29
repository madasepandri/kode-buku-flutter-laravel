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

  Future<void> _addTask() async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (!mounted || result == null) return;
    context.read<TaskProvider>().addTask(result);
    setState(() => _selectedIndex = 1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task ditambahkan pada daftar lokal')),
    );
  }

  Future<void> _openDetail(Task task) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
    if (!mounted || result == null) return;
    context.read<TaskProvider>().updateTask(result);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan task tersimpan sementara')),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Task Management App')),
      body: pages[_selectedIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add),
        label: const Text('Tambah task'),
      ),
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
