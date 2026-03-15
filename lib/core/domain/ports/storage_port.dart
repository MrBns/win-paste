import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';

abstract class StoragePort {
  Future<void> initialize();

  // Active clipboard items
  Future<void> insertItem(ClipboardItem item);
  Future<List<ClipboardItem>> getItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  });
  Future<ClipboardItem?> getItemById(String id);
  Future<void> updateItem(ClipboardItem item);
  Future<void> deleteItem(String id);
  Future<void> clearAllItems();
  Future<int> countItems();
  Future<List<ClipboardItem>> searchItems(
    String query, {
    ClipboardType? typeFilter,
  });
  Future<ClipboardItem?> getMostRecentItem();

  // History (rotated/archived items)
  Future<void> insertHistoryItem(ClipboardItem item);
  Future<List<ClipboardItem>> getHistoryItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  });
  Future<void> deleteHistoryItem(String id);
  Future<void> clearHistory();
  Future<int> countHistoryItems();
  Future<List<ClipboardItem>> searchHistoryItems(
    String query, {
    ClipboardType? typeFilter,
  });
}
