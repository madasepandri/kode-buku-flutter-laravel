import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_label.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});
  final Task task;

  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );
    if (!context.mounted || result == null) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final status = task.status == 'completed' ? 'Selesai' : 'Belum selesai';
    return Scaffold(
      appBar: AppBar(title: const Text('Detail task')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Status: $status'),
        Text('Jatuh tempo: ${formatDueDate(task.dueDate)}'),
        const SizedBox(height: 12),
        Text(task.description.isNotEmpty
            ? task.description
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
