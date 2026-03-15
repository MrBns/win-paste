import 'dart:typed_data';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';

class ClipboardItem {
  final String id;
  final ClipboardType type;
  final String? textContent;
  final Uint8List? imageData;
  final List<String>? filePaths;
  final DateTime createdAt;
  final bool isPinned;
  final String? previewTitle;

  const ClipboardItem({
    required this.id,
    required this.type,
    this.textContent,
    this.imageData,
    this.filePaths,
    required this.createdAt,
    this.isPinned = false,
    this.previewTitle,
  });

  int get sizeBytes {
    int size = 0;
    if (textContent != null) size += textContent!.length * 2;
    if (imageData != null) size += imageData!.lengthInBytes;
    if (filePaths != null) {
      for (final path in filePaths!) {
        size += path.length * 2;
      }
    }
    return size;
  }

  String get preview {
    switch (type) {
      case ClipboardType.text:
      case ClipboardType.richText:
        final text = textContent ?? '';
        if (text.length <= 200) return text;
        return '${text.substring(0, 200)}…';
      case ClipboardType.image:
        final kb = (sizeBytes / 1024).toStringAsFixed(1);
        return 'Image ($kb KB)';
      case ClipboardType.file:
        final count = filePaths?.length ?? 0;
        if (count == 1) return filePaths!.first.split(RegExp(r'[/\\]')).last;
        return '$count files';
    }
  }

  bool isSameContent(ClipboardItem other) {
    if (type != other.type) return false;
    switch (type) {
      case ClipboardType.text:
      case ClipboardType.richText:
        return textContent == other.textContent;
      case ClipboardType.image:
        if (imageData == null || other.imageData == null) return false;
        if (imageData!.length != other.imageData!.length) return false;
        for (int i = 0; i < imageData!.length; i++) {
          if (imageData![i] != other.imageData![i]) return false;
        }
        return true;
      case ClipboardType.file:
        final a = filePaths ?? [];
        final b = other.filePaths ?? [];
        if (a.length != b.length) return false;
        for (int i = 0; i < a.length; i++) {
          if (a[i] != b[i]) return false;
        }
        return true;
    }
  }

  ClipboardItem copyWith({
    String? id,
    ClipboardType? type,
    String? textContent,
    Uint8List? imageData,
    List<String>? filePaths,
    DateTime? createdAt,
    bool? isPinned,
    String? previewTitle,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      type: type ?? this.type,
      textContent: textContent ?? this.textContent,
      imageData: imageData ?? this.imageData,
      filePaths: filePaths ?? this.filePaths,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      previewTitle: previewTitle ?? this.previewTitle,
    );
  }

  @override
  String toString() =>
      'ClipboardItem(id: $id, type: $type, preview: ${preview.substring(0, preview.length.clamp(0, 50))})';
}
