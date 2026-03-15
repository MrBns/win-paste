import 'package:win_paste/core/domain/ports/storage_port.dart';

class DeleteHistoryItemUseCase {
  final StoragePort _storage;

  DeleteHistoryItemUseCase(this._storage);

  Future<void> execute(String id) async {
    await _storage.deleteHistoryItem(id);
  }
}
