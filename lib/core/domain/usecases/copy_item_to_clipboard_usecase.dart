import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/ports/clipboard_port.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';

class CopyItemToClipboardUseCase {
  final ClipboardPort _clipboard;
  final StoragePort _storage;

  CopyItemToClipboardUseCase(this._clipboard, this._storage);

  Future<void> execute(ClipboardItem item) async {
    await _clipboard.writeToClipboard(item);
    // Move item to top by updating its createdAt timestamp
    final updated = item.copyWith(createdAt: DateTime.now());
    await _storage.updateItem(updated);
  }
}
