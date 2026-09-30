import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key, required this.onTaskTap});
  final ValueChanged<Task> onTaskTap;
  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  late final TextEditingController _search;
  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: context.read<TaskProvider>().search);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final loading = p.state == TaskLoadState.loading;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _search,
            maxLength: 100,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: 'Cari judul task',
              counterText: '',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => p.setQuery(
                  search: _search.text,
                  status: p.status,
                  priority: p.priority,
                ),
              ),
            ),
            onSubmitted: (value) => p.setQuery(
              search: value,
              status: p.status,
              priority: p.priority,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('status-${p.status}'),
                  initialValue: p.status ?? '',
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Semua')),
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Belum selesai'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Selesai'),
                    ),
                  ],
                  onChanged: (value) => p.setQuery(
                    search: p.search,
                    status: value == '' ? null : value,
                    priority: p.priority,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey('priority-${p.priority}'),
                  initialValue: p.priority ?? '',
                  decoration: const InputDecoration(labelText: 'Prioritas'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Semua')),
                    DropdownMenuItem(value: 'low', child: Text('Rendah')),
                    DropdownMenuItem(value: 'medium', child: Text('Sedang')),
                    DropdownMenuItem(value: 'high', child: Text('Tinggi')),
                  ],
                  onChanged: (value) => p.setQuery(
                    search: p.search,
                    status: p.status,
                    priority: value == '' ? null : value,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${p.tasks.length} dari ${p.totalCount} task hasil pencarian',
                ),
              ),
              TextButton(
                onPressed: () {
                  _search.clear();
                  p.setQuery(search: '');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          if (loading || p.refreshing) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: p.refreshTasks,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (p.state == TaskLoadState.error) ...[
                    Text(p.errorMessage ?? 'Task gagal dimuat.'),
                    TextButton(
                      onPressed: p.fetchTasks,
                      child: const Text('Coba lagi'),
                    ),
                  ] else if (p.state == TaskLoadState.success &&
                      p.tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        p.search.isEmpty &&
                                p.status == null &&
                                p.priority == null
                            ? 'Belum ada task. Tekan Tambah task untuk memulai.'
                            : 'Tidak ada task yang sesuai. Ubah atau reset pencarian.',
                      ),
                    ),
                  if (p.refreshError != null) ...[
                    Text('Daftar belum diperbarui. ${p.refreshError}'),
                    TextButton(
                      onPressed: p.refreshing ? null : p.refreshTasks,
                      child: const Text('Coba perbarui lagi'),
                    ),
                  ],
                  for (final task in p.tasks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(
                        task: task,
                        onTap: () => widget.onTaskTap(task),
                      ),
                    ),
                  if (p.moreError != null) Text(p.moreError!),
                  if (p.state == TaskLoadState.success && p.hasMore)
                    OutlinedButton(
                      onPressed:
                          p.loadingMore ||
                              p.refreshing ||
                              p.refreshError != null
                          ? null
                          : p.loadMore,
                      child: Text(
                        p.loadingMore
                            ? 'Memuat…'
                            : p.moreError == null
                            ? 'Muat lagi'
                            : 'Coba muat lagi',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
