import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('Dashboard and task list show dummy data', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    expect(find.text('Total task'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('Lihat daftar task'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(TaskListView),
        matching: find.text('Daftar task'),
      ),
      findsOneWidget,
    );
    expect(find.text('Menyusun laporan'), findsOneWidget);
    expect(find.byType(TaskCard), findsWidgets);

    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang'), findsOneWidget);
  });
}
