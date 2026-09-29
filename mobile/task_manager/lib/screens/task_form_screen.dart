import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/date_label.dart';

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
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate;
    _dateController = TextEditingController(
      text: _selectedDate == null ? '' : formatDueDate(_selectedDate!),
    );
    _status = widget.task?.status ?? 'pending';
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
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedDate = selected);
    _dateController.text = formatDueDate(selected);
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
    Navigator.of(context).pop(Task(
      id: widget.task?.id ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      dueDate: _selectedDate!,
    ));
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
