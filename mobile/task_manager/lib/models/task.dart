class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    this.priority = 'medium',
  });

  final int id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final String priority;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
    );
  }
}
