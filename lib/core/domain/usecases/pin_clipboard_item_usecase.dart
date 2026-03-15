import 'package:win_paste/core/domain/ports/storage_port.dart';

class PinClipboardItemUseCase {
  final StoragePort _storage;

  PinClipboardItemUseCase(this._storage);

  Future<void> execute(String id) async {
    final item = await _storage.getItemById(id);
    if (item == null) return;
    await _storage.updateItem(item.copyWith(isPinned: !item.isPinned));
  }
}
