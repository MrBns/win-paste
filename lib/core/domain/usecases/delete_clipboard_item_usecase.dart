import 'package:win_paste/core/domain/ports/storage_port.dart';

class DeleteClipboardItemUseCase {
  final StoragePort _storage;

  DeleteClipboardItemUseCase(this._storage);

  Future<void> execute(String id) async {
    await _storage.deleteItem(id);
  }
}
