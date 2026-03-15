import 'package:flutter/material.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

enum FilterTab { all, text, images, files, pinned }

class FilterTabsWidget extends StatelessWidget {
  final FilterTab selected;
  final ValueChanged<FilterTab> onSelected;

  const FilterTabsWidget({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: FilterTab.values.map((tab) {
          final isSelected = tab == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(_label(tab)),
              selected: isSelected,
              onSelected: (_) => onSelected(tab),
              avatar: Icon(_icon(tab), size: 14),
              showCheckmark: false,
              selectedColor: AppColors.primaryAccent.withOpacity(0.2),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.darkBorder,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              iconTheme: IconThemeData(
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.textMuted,
              ),
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _label(FilterTab tab) => switch (tab) {
        FilterTab.all => 'All',
        FilterTab.text => 'Text',
        FilterTab.images => 'Images',
        FilterTab.files => 'Files',
        FilterTab.pinned => 'Pinned',
      };

  IconData _icon(FilterTab tab) => switch (tab) {
        FilterTab.all => Icons.all_inclusive,
        FilterTab.text => Icons.text_snippet_outlined,
        FilterTab.images => Icons.image_outlined,
        FilterTab.files => Icons.folder_outlined,
        FilterTab.pinned => Icons.push_pin_outlined,
      };

  static ClipboardType? toClipboardType(FilterTab tab) => switch (tab) {
        FilterTab.text => ClipboardType.text,
        FilterTab.images => ClipboardType.image,
        FilterTab.files => ClipboardType.file,
        _ => null,
      };
}
