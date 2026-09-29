import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('form, navigation, and local task flow', (tester) async {
    await tester.pumpWidget(const TaskManagerApp());
    expect(find.text('Login'), findsOneWidget);
    await tester.tap(find.text('Masuk'));
    await tester.pump();
    expect(find.text('Email wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'demo@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'contoh');
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();
    expect(find.text('Total task'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.text('Lihat daftar task'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Menyusun laporan'));
    await tester.pumpAndSettle();
    expect(find.text('Detail task'), findsOneWidget);
    await tester.tap(find.text('Edit task'));
    await tester.pumpAndSettle();
    expect(find.text('Menyusun laporan'), findsOneWidget);
    expect(find.text('Simpan task'), findsOneWidget);
  });
}
