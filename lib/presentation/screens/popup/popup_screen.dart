import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/application/providers/clipboard_provider.dart';
import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';
import 'package:win_paste/presentation/widgets/clipboard_item_card.dart';
import 'package:win_paste/presentation/widgets/empty_state_widget.dart';
import 'package:win_paste/presentation/widgets/filter_tabs_widget.dart';
import 'package:win_paste/presentation/widgets/search_filter_bar.dart';

class PopupScreen extends StatefulWidget {
  const PopupScreen({super.key});

  @override
  State<PopupScreen> createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> {
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _keyboardFocus = FocusNode();
  int _selectedIndex = 0;
  FilterTab _selectedTab = FilterTab.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final provider = context.read<ClipboardProvider>();
    final items = provider.filteredItems;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      ServiceLocator.windowPort.hide();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1).clamp(0, items.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1).clamp(0, items.length - 1);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (items.isNotEmpty && _selectedIndex < items.length) {
        _copyAndClose(provider, items[_selectedIndex]);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.keyF &&
        HardwareKeyboard.instance.isControlPressed) {
      _searchFocus.requestFocus();
    }
  }

  Future<void> _copyAndClose(
    ClipboardProvider provider,
    ClipboardItem item,
  ) async {
    await provider.copyToClipboard(item);
    await ServiceLocator.windowPort.hide();
  }

  void _onTabSelected(FilterTab tab) {
    setState(() {
      _selectedTab = tab;
      _selectedIndex = 0;
    });
    final provider = context.read<ClipboardProvider>();
    if (tab == FilterTab.pinned) {
      provider.filterPinnedOnly();
    } else {
      provider.filterByType(FilterTabsWidget.toClipboardType(tab));
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Column(
          children: [
            _Header(onClose: () => ServiceLocator.windowPort.hide()),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SearchFilterBar(
                focusNode: _searchFocus,
                onSearch: (q) {
                  setState(() => _selectedIndex = 0);
                  context.read<ClipboardProvider>().search(q);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: FilterTabsWidget(
                selected: _selectedTab,
                onSelected: _onTabSelected,
              ),
            ),
            Expanded(child: _ItemList(
              selectedIndex: _selectedIndex,
              onSelectIndex: (i) => setState(() => _selectedIndex = i),
              onCopyAndClose: (item) => _copyAndClose(
                context.read<ClipboardProvider>(),
                item,
              ),
              selectedTab: _selectedTab,
            )),
            _StatusBar(
              itemCount: context.watch<ClipboardProvider>().filteredItems.length,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.content_paste, color: AppColors.primaryAccent, size: 18),
          const SizedBox(width: 8),
          const Text(
            'WinPaste',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          _headerBtn(Icons.history_outlined, () {
            Navigator.pushNamed(context, '/history');
          }, 'History'),
          _headerBtn(Icons.settings_outlined, () {
            Navigator.pushNamed(context, '/settings');
          }, 'Settings'),
          _headerBtn(Icons.close, onClose, 'Close'),
        ],
      ),
    );
  }

  Widget _headerBtn(IconData icon, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;
  final Future<void> Function(ClipboardItem) onCopyAndClose;
  final FilterTab selectedTab;

  const _ItemList({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.onCopyAndClose,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ClipboardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        final items = provider.filteredItems;
        if (items.isEmpty) {
          if (provider.searchQuery.isNotEmpty) {
            return EmptyStateWidget.noSearchResults();
          }
          return EmptyStateWidget.noItems();
        }

        // Image grid view
        if (selectedTab == FilterTab.images) {
          return _ImageGrid(
            items: items,
            onCopyAndClose: onCopyAndClose,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ClipboardItemCard(
              item: item,
              isSelected: index == selectedIndex,
              onTap: () => onSelectIndex(index),
              onCopy: () => onCopyAndClose(item),
              onPin: () => context.read<ClipboardProvider>().pinItem(item.id),
              onDelete: () =>
                  context.read<ClipboardProvider>().deleteItem(item.id),
            );
          },
        );
      },
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<ClipboardItem> items;
  final Future<void> Function(ClipboardItem) onCopyAndClose;

  const _ImageGrid({required this.items, required this.onCopyAndClose});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onCopyAndClose(item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageData != null
                ? Image.memory(item.imageData!, fit: BoxFit.cover)
                : Container(
                    color: AppColors.darkSurfaceVariant,
                    child: const Icon(Icons.image, color: AppColors.textMuted),
                  ),
          ),
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  final int itemCount;

  const _StatusBar({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          Text(
            '$itemCount items',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          const Text(
            '↑↓ navigate · Enter to copy · Esc to close · Ctrl+F search',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
