import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_label.dart';
import '../utils/task_api_exception.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.task});

  final Task task;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> _detailFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = context.read<TaskProvider>().fetchTask(widget.task.id);
  }

  void _reloadDetail() {
    setState(() {
      _detailFuture = context.read<TaskProvider>().fetchTask(widget.task.id);
    });
  }

  Future<void> _edit(Task task) async {
    final saved = await Navigator.of(
      context,
    ).push<Task>(MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)));
    if (!mounted || saved == null) return;
    setState(() => _detailFuture = Future.value(saved));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Task berhasil diperbarui.')));
  }

  Future<void> _delete(Task task) async {
    if (_isDeleting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus task?'),
        content: Text('“${task.title}” akan dihapus dari database.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _isDeleting = true);
    var deletedSuccessfully = false;
    try {
      await context.read<TaskProvider>().deleteTask(task.id);
      if (!mounted) return;
      deletedSuccessfully = true;
      Navigator.of(context).pop(true);
    } on TaskApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Task gagal dihapus.')));
      }
    } finally {
      if (mounted && !deletedSuccessfully) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Widget _detailContent(Task task) {
    final status = task.status == 'completed' ? 'Selesai' : 'Belum selesai';
    final priority = switch (task.priority) {
      'low' => 'Rendah',
      'high' => 'Tinggi',
      _ => 'Sedang',
    };

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text('Status: $status'),
        Text('Prioritas: $priority'),
        Text('Jatuh tempo: ${formatDueDate(task.dueDate)}'),
        const SizedBox(height: 12),
        Text(
          task.description.isNotEmpty
              ? task.description
              : 'Belum ada deskripsi.',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _isDeleting ? null : () => _edit(task),
          icon: const Icon(Icons.edit),
          label: const Text('Edit task'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isDeleting ? null : () => _delete(task),
          icon: const Icon(Icons.delete_outline),
          label: Text(_isDeleting ? 'Menghapus…' : 'Hapus task'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail task')),
      body: FutureBuilder<Task>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final message = snapshot.error is TaskApiException
                ? (snapshot.error! as TaskApiException).message
                : 'Detail task gagal dimuat.';
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message),
                  TextButton(
                    onPressed: _reloadDetail,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          return _detailContent(snapshot.data!);
        },
      ),
    );
  }
}
