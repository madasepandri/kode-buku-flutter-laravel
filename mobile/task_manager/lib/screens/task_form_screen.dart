import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/date_label.dart';
import '../utils/task_api_exception.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.task});

  final Task? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  String _status = 'pending';
  String _priority = 'medium';
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _selectedDate = widget.task?.dueDate;
    _dateController = TextEditingController(
      text: _selectedDate == null ? '' : formatDueDate(_selectedDate!),
    );
    _status = widget.task?.status ?? 'pending';
    _priority = widget.task?.priority ?? 'medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    if (_isSubmitting) return;
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedDate = selected);
    _dateController.text = formatDueDate(selected);
  }

  Future<void> _save() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Simpan task?'),
        content: const Text('Task akan disimpan ke server.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    final draft = Task(
      id: widget.task?.id ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _selectedDate!,
    );

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    var savedSuccessfully = false;
    try {
      final provider = context.read<TaskProvider>();
      final saved = widget.task == null
          ? await provider.createTask(draft)
          : await provider.updateTask(draft);
      if (!mounted) return;
      savedSuccessfully = true;
      Navigator.of(context).pop(saved);
    } on TaskApiException catch (error) {
      if (mounted) setState(() => _submitError = error.message);
    } catch (_) {
      if (mounted) setState(() => _submitError = 'Task gagal disimpan.');
    } finally {
      if (mounted && !savedSuccessfully) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.task == null ? 'Tambah task' : 'Edit task'),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _titleController,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(labelText: 'Judul task'),
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? 'Judul task wajib diisi'
                : null,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (opsional)',
            ),
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
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _status = value ?? 'pending'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Prioritas'),
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Rendah')),
              DropdownMenuItem(value: 'medium', child: Text('Sedang')),
              DropdownMenuItem(value: 'high', child: Text('Tinggi')),
            ],
            onChanged: _isSubmitting
                ? null
                : (value) => setState(() => _priority = value ?? 'medium'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            enabled: !_isSubmitting,
            onTap: _chooseDate,
            decoration: const InputDecoration(
              labelText: 'Jatuh tempo',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Pilih tanggal jatuh tempo' : null,
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 16),
            Text(
              _submitError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _save,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan task'),
          ),
        ],
      ),
    ),
  );
}
