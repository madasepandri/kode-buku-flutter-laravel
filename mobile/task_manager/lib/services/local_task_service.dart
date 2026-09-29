import '../models/task.dart';

class LocalTaskService {
  final List<Task> _tasks = [
    Task(id: 1, title: 'Menyusun laporan', description: '', status: 'pending', dueDate: DateTime(2026, 10, 15)),
    Task(id: 2, title: 'Membaca referensi', description: '', status: 'completed', dueDate: DateTime(2026, 10, 12)),
    Task(id: 3, title: 'Menyiapkan presentasi', description: '', status: 'pending', dueDate: DateTime(2026, 10, 18)),
    Task(id: 4, title: 'Memeriksa catatan', description: '', status: 'completed', dueDate: DateTime(2026, 10, 10)),
    Task(id: 5, title: 'Merapikan dokumentasi', description: '', status: 'pending', dueDate: DateTime(2026, 10, 20)),
  ];
  int _nextId = 6;
  List<Task> getTasks() => List.unmodifiable(_tasks);
  Task addTask(Task task) {
    final saved = Task(id: _nextId++, title: task.title,
      description: task.description, status: task.status, dueDate: task.dueDate);
    _tasks.add(saved);
    return saved;
  }
  void updateTask(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) throw StateError('Task tidak ditemukan');
    _tasks[index] = task;
  }
}
