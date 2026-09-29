import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> dummyTasks = const [
    {'title': 'Menyusun laporan', 'status': 'pending', 'dueDate': '15 Okt 2026'},
    {'title': 'Membaca referensi', 'status': 'completed', 'dueDate': '12 Okt 2026'},
    {'title': 'Menyiapkan presentasi', 'status': 'pending', 'dueDate': '18 Okt 2026'},
    {'title': 'Memeriksa catatan', 'status': 'completed', 'dueDate': '10 Okt 2026'},
    {'title': 'Merapikan dokumentasi', 'status': 'pending', 'dueDate': '20 Okt 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount =
        dummyTasks.where((task) => task['status'] == 'completed').length;
    final pages = [
      DashboardView(
        totalCount: dummyTasks.length,
        completedCount: completedCount,
        onViewTasks: () => setState(() => _selectedIndex = 1),
      ),
      TaskListView(tasks: dummyTasks),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Task Management App')),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.onViewTasks,
  });

  final int totalCount;
  final int completedCount;
  final VoidCallback onViewTasks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Selamat datang', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        const Text('Lihat ringkasan task Anda hari ini.'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SummaryTile(
                label: 'Total task',
                value: '$totalCount',
                icon: Icons.assignment_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryTile(
                label: 'Selesai',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Langkah berikutnya', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Buka daftar untuk melihat task dan tanggal jatuh temponya.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onViewTasks,
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Lihat daftar task'),
        ),
      ],
    );
  }
}

class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label),
        ],
      ),
    );
  }
}

class TaskListView extends StatelessWidget {
  const TaskListView({super.key, required this.tasks});

  final List<Map<String, String>> tasks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daftar task', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${tasks.length} task tersedia'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TaskCard(task: task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Map<String, String> task;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['status'] == 'completed';
    final statusLabel = isCompleted ? 'Selesai' : 'Belum selesai';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('Jatuh tempo: ${task['dueDate'] ?? '-'}'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(statusLabel),
        ],
      ),
    );
  }
}
