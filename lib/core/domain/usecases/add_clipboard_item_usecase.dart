import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';

class AddClipboardItemUseCase {
  final StoragePort _storage;
  final SettingsPort _settings;

  AddClipboardItemUseCase(this._storage, this._settings);

  Future<bool> execute(ClipboardItem item) async {
    final settings = await _settings.loadSettings();

    // Check feature flags
    if (item.type == ClipboardType.image && !settings.enableImageSupport) {
      return false;
    }
    if (item.type == ClipboardType.file && !settings.enableFileSupport) {
      return false;
    }

    // Check item size
    final sizeKb = item.sizeBytes / 1024;
    if (sizeKb > settings.maxDataSizeKb) {
      return false;
    }

    // Deduplicate against most recent item
    final mostRecent = await _storage.getMostRecentItem();
    if (mostRecent != null && item.isSameContent(mostRecent)) {
      return false;
    }

    // Enforce max items with rotation
    final count = await _storage.countItems();
    if (count >= settings.maxClipboardItems) {
      final items = await _storage.getItems();
      // Find oldest non-pinned item
      ClipboardItem? oldest;
      for (int i = items.length - 1; i >= 0; i--) {
        if (!items[i].isPinned) {
          oldest = items[i];
          break;
        }
      }
      if (oldest != null) {
        if (settings.persistentRotation) {
          await _storage.insertHistoryItem(oldest);
          // Trim history if needed
          final historyCount = await _storage.countHistoryItems();
          if (historyCount > settings.maxHistoryItems) {
            final history = await _storage.getHistoryItems();
            final excess = historyCount - settings.maxHistoryItems;
            for (int i = history.length - excess; i < history.length; i++) {
              await _storage.deleteHistoryItem(history[i].id);
            }
          }
        }
        await _storage.deleteItem(oldest.id);
      }
    }

    await _storage.insertItem(item);
    return true;
  }
}
