import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';

class SearchClipboardUseCase {
  final StoragePort _storage;

  SearchClipboardUseCase(this._storage);

  Future<List<ClipboardItem>> execute(
    String query, {
    ClipboardType? typeFilter,
  }) async {
    if (query.trim().isEmpty) {
      return _storage.getItems(typeFilter: typeFilter);
    }
    return _storage.searchItems(query, typeFilter: typeFilter);
  }
}
