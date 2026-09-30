import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task_page.dart';

void main() {
  test('TaskPage maps tasks and pagination metadata', () {
    final page = TaskPage.fromJson({
      'data': [
        {
          'id': 7,
          'title': 'Menyusun laporan',
          'description': '',
          'status': 'pending',
          'priority': 'high',
          'due_date': '2026-10-01',
        },
      ],
      'meta': {'current_page': 1, 'last_page': 2, 'total': 12},
    });
    expect(page.items.single.id, 7);
    expect(page.items.single.title, 'Menyusun laporan');
    expect(page.items.single.priority, 'high');
    expect(page.items.single.dueDate, DateTime(2026, 10, 1));
    expect(page.currentPage, 1);
    expect(page.lastPage, 2);
    expect(page.total, 12);
  });

  test('TaskPage accepts an empty result', () {
    final page = TaskPage.fromJson({
      'data': <dynamic>[],
      'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
    });
    expect(page.items, isEmpty);
    expect(page.total, 0);
  });
}
