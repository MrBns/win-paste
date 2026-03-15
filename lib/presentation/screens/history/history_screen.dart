import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/application/providers/clipboard_provider.dart';
import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';
import 'package:win_paste/presentation/widgets/empty_state_widget.dart';
import 'package:win_paste/presentation/widgets/type_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ClipboardItem> _items = [];
  List<ClipboardItem> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _items = await ServiceLocator.getHistoryUseCase.execute();
    _applySearch();
    setState(() => _isLoading = false);
  }

  void _applySearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      final q = _searchQuery.toLowerCase();
      _filteredItems = _items.where((item) {
        return (item.textContent?.toLowerCase().contains(q) ?? false) ||
            (item.filePaths?.any((p) => p.toLowerCase().contains(q)) ?? false);
      }).toList();
    }
  }

  Future<void> _delete(String id) async {
    await ServiceLocator.deleteHistoryItemUseCase.execute(id);
    await _load();
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Clear History', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete all history items.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ServiceLocator.storagePort.clearHistory();
      await _load();
    }
  }

  Map<String, List<ClipboardItem>> _groupByDate(List<ClipboardItem> items) {
    final map = <String, List<ClipboardItem>>{};
    final now = DateTime.now();
    for (final item in items) {
      final diff = now.difference(item.createdAt);
      String key;
      if (diff.inDays == 0) {
        key = 'Today';
      } else if (diff.inDays == 1) {
        key = 'Yesterday';
      } else if (diff.inDays < 7) {
        key = DateFormat('EEEE').format(item.createdAt);
      } else {
        key = DateFormat('MMMM d, yyyy').format(item.createdAt);
      }
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Clipboard History'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _applySearch();
                });
              },
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search history…',
                prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                isDense: true,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear history',
            color: AppColors.errorRed,
            onPressed: _clearAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
          : _filteredItems.isEmpty
              ? (_searchQuery.isNotEmpty
                  ? EmptyStateWidget.noSearchResults()
                  : EmptyStateWidget.noHistory())
              : _buildTimeline(),
    );
  }

  Widget _buildTimeline() {
    final groups = _groupByDate(_filteredItems);
    final entries = groups.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: entries.fold(0, (sum, e) => sum + e.value.length + 1),
      itemBuilder: (context, globalIndex) {
        int offset = 0;
        for (final entry in entries) {
          if (globalIndex == offset) {
            return _DateHeader(label: entry.key);
          }
          offset++;
          if (globalIndex < offset + entry.value.length) {
            final item = entry.value[globalIndex - offset];
            return _HistoryItemTile(
              item: item,
              onDelete: () => _delete(item.id),
              onCopy: () async {
                await context.read<ClipboardProvider>().copyToClipboard(item);
                if (context.mounted) Navigator.pop(context);
              },
            );
          }
          offset += entry.value.length;
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final ClipboardItem item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const _HistoryItemTile({
    required this.item,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: TypeBadge(type: item.type),
      title: Text(
        item.preview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      ),
      subtitle: Text(
        DateFormat('HH:mm').format(item.createdAt),
        style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 15),
            color: AppColors.textSecondary,
            onPressed: onCopy,
            tooltip: 'Copy',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 15),
            color: AppColors.errorRed,
            onPressed: onDelete,
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
