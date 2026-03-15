import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';

class GetClipboardItemsUseCase {
  final StoragePort _storage;

  GetClipboardItemsUseCase(this._storage);

  Future<List<ClipboardItem>> execute({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
    bool pinnedOnly = false,
  }) async {
    final items = await _storage.getItems(
      limit: limit,
      offset: offset,
      typeFilter: typeFilter,
    );
    if (pinnedOnly) {
      return items.where((item) => item.isPinned).toList();
    }
    return items;
  }
}
