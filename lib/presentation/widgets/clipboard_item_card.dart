import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';
import 'package:win_paste/presentation/widgets/type_badge.dart';

class ClipboardItemCard extends StatefulWidget {
  final ClipboardItem item;
  final bool isSelected;
  final VoidCallback onCopy;
  final VoidCallback onPin;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ClipboardItemCard({
    super.key,
    required this.item,
    this.isSelected = false,
    required this.onCopy,
    required this.onPin,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<ClipboardItemCard> createState() => _ClipboardItemCardState();
}

class _ClipboardItemCardState extends State<ClipboardItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.primaryAccent.withOpacity(0.1)
                : (_hovered
                    ? (isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant)
                    : (isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.primaryAccent
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TypeIcon(type: item.type),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PreviewContent(item: item),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              TypeBadge(type: item.type),
                              const SizedBox(width: 6),
                              _TimestampLabel(time: item.createdAt),
                              const SizedBox(width: 6),
                              _SizeLabel(bytes: item.sizeBytes),
                              if (item.type == ClipboardType.text &&
                                  item.textContent != null) ...[
                                const SizedBox(width: 6),
                                _WordCountLabel(text: item.textContent!),
                              ],
                              const Spacer(),
                              _ContentIndicators(item: item),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (_hovered || widget.isSelected)
                      _ActionButtons(
                        item: item,
                        onCopy: widget.onCopy,
                        onPin: widget.onPin,
                        onDelete: widget.onDelete,
                      ),
                  ],
                ),
              ),
              if (item.isPinned)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.push_pin,
                    size: 12,
                    color: AppColors.primaryAccent.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  final ClipboardType type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      ClipboardType.text => Icons.article_outlined,
      ClipboardType.richText => Icons.text_fields_outlined,
      ClipboardType.image => Icons.image_outlined,
      ClipboardType.file => Icons.folder_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  final ClipboardItem item;

  const _PreviewContent({required this.item});

  @override
  Widget build(BuildContext context) {
    switch (item.type) {
      case ClipboardType.image:
        return _ImagePreview(imageData: item.imageData);
      case ClipboardType.file:
        return _FilePreview(paths: item.filePaths ?? []);
      case ClipboardType.text:
      case ClipboardType.richText:
        return _TextPreview(text: item.textContent ?? '');
    }
  }
}

class _TextPreview extends StatelessWidget {
  final String text;

  const _TextPreview({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        height: 1.4,
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List? imageData;

  const _ImagePreview({this.imageData});

  @override
  Widget build(BuildContext context) {
    if (imageData == null) {
      return const SizedBox(height: 60, child: Center(child: Icon(Icons.broken_image)));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.memory(
        imageData!,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(
          height: 60,
          child: Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}

class _FilePreview extends StatelessWidget {
  final List<String> paths;

  const _FilePreview({required this.paths});

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paths.take(3).map((path) {
        final name = path.split(RegExp(r'[/\\]')).last;
        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            name,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

class _TimestampLabel extends StatelessWidget {
  final DateTime time;

  const _TimestampLabel({required this.time});

  String _relative(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _relative(time),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
    );
  }
}

class _SizeLabel extends StatelessWidget {
  final int bytes;

  const _SizeLabel({required this.bytes});

  String _format(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _format(bytes),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
    );
  }
}

class _WordCountLabel extends StatelessWidget {
  final String text;

  const _WordCountLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final count = text.trim().split(RegExp(r'\s+')).length;
    return Text(
      '$count words',
      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
    );
  }
}

class _ContentIndicators extends StatelessWidget {
  final ClipboardItem item;

  const _ContentIndicators({required this.item});

  @override
  Widget build(BuildContext context) {
    final text = item.textContent;
    if (text == null) return const SizedBox.shrink();

    final indicators = <Widget>[];

    if (_isHexColor(text)) {
      final color = _parseHexColor(text);
      if (color != null) {
        indicators.add(_dot(color));
      }
    } else if (_isUrl(text)) {
      indicators.add(const Icon(Icons.link, size: 12, color: AppColors.primaryAccent));
    } else if (_isCode(text)) {
      indicators.add(const Icon(Icons.code, size: 12, color: AppColors.successGreen));
    }

    if (indicators.isEmpty) return const SizedBox.shrink();
    return Row(mainAxisSize: MainAxisSize.min, children: indicators);
  }

  bool _isHexColor(String text) {
    final t = text.trim();
    return RegExp(r'^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$').hasMatch(t);
  }

  Color? _parseHexColor(String text) {
    final t = text.trim().replaceFirst('#', '');
    final hex = t.length == 3
        ? '${t[0]}${t[0]}${t[1]}${t[1]}${t[2]}${t[2]}'
        : t;
    final value = int.tryParse('FF$hex', radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  bool _isUrl(String text) {
    return text.trim().startsWith('http://') ||
        text.trim().startsWith('https://');
  }

  // Simple heuristic to detect code-like content. Produces some false positives
  // (e.g., text with semicolons) but is intentionally lightweight for preview hints.
  bool _isCode(String text) {
    return text.contains('{') ||
        text.contains(';') ||
        text.trim().startsWith('def ') ||
        text.trim().startsWith('function ') ||
        text.trim().startsWith('class ') ||
        text.trim().startsWith('import ') ||
        text.trim().startsWith('const ') ||
        text.trim().startsWith('var ') ||
        text.trim().startsWith('let ');
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
      );
}

class _ActionButtons extends StatelessWidget {
  final ClipboardItem item;
  final VoidCallback onCopy;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _ActionButtons({
    required this.item,
    required this.onCopy,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(Icons.copy_outlined, onCopy, 'Copy', AppColors.textSecondary),
        _iconBtn(
          item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
          onPin,
          item.isPinned ? 'Unpin' : 'Pin',
          item.isPinned ? AppColors.primaryAccent : AppColors.textSecondary,
        ),
        _iconBtn(Icons.delete_outline, onDelete, 'Delete', AppColors.errorRed),
      ],
    );
  }

  Widget _iconBtn(
    IconData icon,
    VoidCallback onPressed,
    String tooltip,
    Color color,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
