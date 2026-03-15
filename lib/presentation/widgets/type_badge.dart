import 'package:flutter/material.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

class TypeBadge extends StatelessWidget {
  final ClipboardType type;

  const TypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      ClipboardType.text => ('Text', AppColors.primaryAccent),
      ClipboardType.image => ('Image', AppColors.successGreen),
      ClipboardType.file => ('File', AppColors.warningYellow),
      ClipboardType.richText => ('Rich', AppColors.primaryAccent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
