class Task {
  const Task({required this.id, required this.title, required this.description,
    required this.status, required this.dueDate});
  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;

  Task copyWith({String? title, String? description, String? status,
    DateTime? dueDate}) => Task(id: id, title: title ?? this.title,
      description: description ?? this.description, status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate);
}
