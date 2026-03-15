import 'package:win_paste/core/domain/entities/clipboard_item.dart';

abstract class ClipboardPort {
  Future<void> initialize();
  Stream<ClipboardItem?> watchClipboard();
  Future<ClipboardItem?> readCurrentClipboard();
  Future<void> writeToClipboard(ClipboardItem item);
  Future<void> dispose();
}
