import 'package:flutter/material.dart';
import '../widgets/summary_tile.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.onViewTasks,
  });
  final int totalCount;
  final int completedCount;
  final VoidCallback onViewTasks;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Selamat datang', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Lihat ringkasan task hari ini.'),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: SummaryTile(label: 'Total task', value: '$totalCount', icon: Icons.assignment_outlined)),
            const SizedBox(width: 12),
            Expanded(child: SummaryTile(label: 'Selesai', value: '$completedCount', icon: Icons.check_circle_outline)),
          ]),
          const SizedBox(height: 24),
          Text('Langkah berikutnya', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Buka daftar untuk melihat task dan tanggal jatuh temponya.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onViewTasks,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lihat daftar task'),
          ),
        ],
      );
}
