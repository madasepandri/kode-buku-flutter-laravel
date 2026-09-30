import 'task.dart';

class TaskPage {
  const TaskPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
  final List<Task> items;
  final int currentPage;
  final int lastPage;
  final int total;

  factory TaskPage.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>;
    return TaskPage(
      items: (json['data'] as List)
          .map((item) => Task.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      currentPage: meta['current_page'] as int,
      lastPage: meta['last_page'] as int,
      total: meta['total'] as int,
    );
  }
}
