import 'package:flutter/material.dart';

void main() => runApp(const TaskManagerApp());

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Task Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
        home: const LoginScreen(),
      );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const TaskHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Task Management App',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    const Text('Isi form untuk melihat rancangan aplikasi.'),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email wajib diisi';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                          return 'Format email belum sesuai';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Kata sandi'),
                      obscureText: true,
                      validator: (value) => (value?.isEmpty ?? true)
                          ? 'Kata sandi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Masuk'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  int _selectedIndex = 0;
  final List<Map<String, String>> dummyTasks = [
    {'title': 'Menyusun laporan', 'status': 'pending', 'dueDateLabel': '15 Okt 2026'},
    {'title': 'Membaca referensi', 'status': 'completed', 'dueDateLabel': '12 Okt 2026'},
    {'title': 'Menyiapkan presentasi', 'status': 'pending', 'dueDateLabel': '18 Okt 2026'},
    {'title': 'Memeriksa catatan', 'status': 'completed', 'dueDateLabel': '10 Okt 2026'},
    {'title': 'Merapikan dokumentasi', 'status': 'pending', 'dueDateLabel': '20 Okt 2026'},
  ];

  Future<void> _addTask() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => const TaskFormScreen()),
    );
    if (!mounted || result == null) return;
    setState(() {
      dummyTasks.add(result);
      _selectedIndex = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task ditambahkan pada daftar lokal')),
    );
  }

  Future<void> _openDetail(int index) async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: dummyTasks[index])),
    );
    if (!mounted || result == null) return;
    setState(() => dummyTasks[index] = result);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan task tersimpan sementara')),
    );
  }

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
      TaskListView(tasks: dummyTasks, onTaskTap: _openDetail),
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
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selamat datang', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Lihat ringkasan task hari ini.'),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SummaryTile(label: 'Total task', value: '$totalCount', icon: Icons.assignment_outlined)),
            const SizedBox(width: 12),
            Expanded(child: SummaryTile(label: 'Selesai', value: '$completedCount', icon: Icons.check_circle_outline)),
          ]),
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

class SummaryTile extends StatelessWidget {
  const SummaryTile({super.key, required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label),
        ]),
      );
}

class TaskListView extends StatelessWidget {
  const TaskListView({super.key, required this.tasks, required this.onTaskTap});
  final List<Map<String, String>> tasks;
  final ValueChanged<int> onTaskTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Daftar task', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${tasks.length} task tersedia'),
          const SizedBox(height: 16),
          Expanded(child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TaskCard(task: tasks[index], onTap: () => onTaskTap(index)),
            ),
          )),
        ]),
      );
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});
  final Map<String, String> task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task['status'] == 'completed';
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(task['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Jatuh tempo: ${task['dueDateLabel'] ?? '-'}'),
            ])),
            const SizedBox(width: 8),
            Text(isCompleted ? 'Selesai' : 'Belum selesai'),
          ]),
        ),
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});
  final Map<String, String> task;

  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (!context.mounted || result == null) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final status = task['status'] == 'completed' ? 'Selesai' : 'Belum selesai';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail task')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(task['title'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Status: $status'),
        Text('Jatuh tempo: ${task['dueDateLabel'] ?? '-'}'),
        const SizedBox(height: 12),
        Text(task['description']?.isNotEmpty == true
            ? task['description']!
            : 'Belum ada deskripsi.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.edit),
          label: const Text('Edit task'),
        ),
      ]),
    );
  }
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});
  final Map<String, String>? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.task?['description'] ?? '');
    _dateController = TextEditingController(text: widget.task?['dueDateLabel'] ?? '');
    _status = widget.task?['status'] ?? 'pending';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || selected == null) return;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    _dateController.text = '${selected.day} ${months[selected.month - 1]} ${selected.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simpan task?'),
        content: const Text('Perubahan hanya tersimpan selama aplikasi berjalan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    Navigator.of(context).pop(<String, String>{
      ...?widget.task,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'status': _status,
      'dueDateLabel': _dateController.text,
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.task == null ? 'Tambah task' : 'Edit task')),
        body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul task'),
              validator: (value) => (value?.trim().isEmpty ?? true)
                  ? 'Judul task wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Belum selesai')),
                DropdownMenuItem(value: 'completed', child: Text('Selesai')),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'pending'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: _chooseDate,
              decoration: const InputDecoration(
                labelText: 'Jatuh tempo',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) => (value?.isEmpty ?? true)
                  ? 'Pilih tanggal jatuh tempo'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Simpan task')),
          ]),
        ),
      );
}
