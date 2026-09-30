import 'package:flutter/material.dart';

import '../models/task.dart';
import '../utils/date_label.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final status = task.status == 'completed' ? 'Selesai' : 'Belum selesai';
    final priority = switch (task.priority) {
      'low' => 'Rendah',
      'high' => 'Tinggi',
      _ => 'Sedang',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Detail task')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Status: $status'),
          Text('Prioritas: $priority'),
          Text('Jatuh tempo: ${formatDueDate(task.dueDate)}'),
          const SizedBox(height: 12),
          Text(task.description.isNotEmpty
              ? task.description
              : 'Belum ada deskripsi.'),
        ],
      ),
    );
  }
}
