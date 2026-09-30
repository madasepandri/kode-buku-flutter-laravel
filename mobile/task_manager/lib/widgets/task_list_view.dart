import 'package:flutter/material.dart';

import '../models/task.dart';
import 'task_card.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({super.key, required this.tasks, required this.onTaskTap});

  final List<Task> tasks;
  final ValueChanged<Task> onTaskTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daftar task', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('${tasks.length} task tersedia'),
            const SizedBox(height: 16),
            if (tasks.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('Belum ada task. Tekan Tambah task untuk memulai.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(
                        task: task,
                        onTap: () => onTaskTap(task),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
}
