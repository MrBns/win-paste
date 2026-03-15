import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';

class GetHistoryUseCase {
  final StoragePort _storage;

  GetHistoryUseCase(this._storage);

  Future<List<ClipboardItem>> execute({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  }) async {
    return _storage.getHistoryItems(
      limit: limit,
      offset: offset,
      typeFilter: typeFilter,
    );
  }
}
