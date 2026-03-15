import 'package:flutter/material.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  factory EmptyStateWidget.noItems() => const EmptyStateWidget(
        title: 'No clipboard items',
        subtitle: 'Copy something to get started',
        icon: Icons.content_paste_off_outlined,
      );

  factory EmptyStateWidget.noHistory() => const EmptyStateWidget(
        title: 'No history yet',
        subtitle: 'Rotated items will appear here',
        icon: Icons.history_outlined,
      );

  factory EmptyStateWidget.noSearchResults() => const EmptyStateWidget(
        title: 'No results found',
        subtitle: 'Try a different search term',
        icon: Icons.search_off_outlined,
      );

  factory EmptyStateWidget.featureDisabled(String feature) => EmptyStateWidget(
        title: '$feature support is disabled',
        subtitle: 'Enable it in Settings → Clipboard',
        icon: Icons.block_outlined,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
