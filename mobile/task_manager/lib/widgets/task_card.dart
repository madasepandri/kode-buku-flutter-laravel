import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_label.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});
  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == 'completed';
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
              Text(task.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Jatuh tempo: ${formatDueDate(task.dueDate)}'),
            ])),
            const SizedBox(width: 8),
            Text(isCompleted ? 'Selesai' : 'Belum selesai'),
          ]),
        ),
      ),
    );
  }
}
