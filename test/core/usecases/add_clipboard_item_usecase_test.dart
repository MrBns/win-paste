import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:win_paste/core/domain/entities/app_settings.dart';
import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';
import 'package:win_paste/core/domain/usecases/add_clipboard_item_usecase.dart';

// ─── In-memory storage stub ──────────────────────────────────────────────────

class _InMemoryStorage implements StoragePort {
  final List<ClipboardItem> _items = [];
  final List<ClipboardItem> _history = [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> insertItem(ClipboardItem item) async => _items.insert(0, item);

  @override
  Future<List<ClipboardItem>> getItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  }) async {
    var result = typeFilter == null
        ? List<ClipboardItem>.from(_items)
        : _items.where((i) => i.type == typeFilter).toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (offset != null) result = result.skip(offset).toList();
    if (limit != null) result = result.take(limit).toList();
    return result;
  }

  @override
  Future<ClipboardItem?> getItemById(String id) async =>
      _items.cast<ClipboardItem?>().firstWhere(
            (i) => i?.id == id,
            orElse: () => null,
          );

  @override
  Future<void> updateItem(ClipboardItem item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) _items[idx] = item;
  }

  @override
  Future<void> deleteItem(String id) async =>
      _items.removeWhere((i) => i.id == id);

  @override
  Future<void> clearAllItems() async => _items.clear();

  @override
  Future<int> countItems() async => _items.length;

  @override
  Future<List<ClipboardItem>> searchItems(
    String query, {
    ClipboardType? typeFilter,
  }) async =>
      _items
          .where((i) =>
              i.textContent?.contains(query) == true &&
              (typeFilter == null || i.type == typeFilter))
          .toList();

  @override
  Future<ClipboardItem?> getMostRecentItem() async {
    if (_items.isEmpty) return null;
    final sorted = List<ClipboardItem>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }

  @override
  Future<void> insertHistoryItem(ClipboardItem item) async =>
      _history.insert(0, item);

  @override
  Future<List<ClipboardItem>> getHistoryItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  }) async {
    var result = typeFilter == null
        ? List<ClipboardItem>.from(_history)
        : _history.where((i) => i.type == typeFilter).toList();
    if (offset != null) result = result.skip(offset).toList();
    if (limit != null) result = result.take(limit).toList();
    return result;
  }

  @override
  Future<void> deleteHistoryItem(String id) async =>
      _history.removeWhere((i) => i.id == id);

  @override
  Future<void> clearHistory() async => _history.clear();

  @override
  Future<int> countHistoryItems() async => _history.length;

  @override
  Future<List<ClipboardItem>> searchHistoryItems(
    String query, {
    ClipboardType? typeFilter,
  }) async =>
      _history
          .where((i) =>
              i.textContent?.contains(query) == true &&
              (typeFilter == null || i.type == typeFilter))
          .toList();
}

// ─── Settings stub ────────────────────────────────────────────────────────────

class _SettingsStub implements SettingsPort {
  AppSettings _settings;
  _SettingsStub(this._settings);

  @override
  Future<AppSettings> loadSettings() async => _settings;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

ClipboardItem _textItem(String id, String text, {bool isPinned = false}) =>
    ClipboardItem(
      id: id,
      type: ClipboardType.text,
      textContent: text,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    );

ClipboardItem _imageItem(String id) => ClipboardItem(
      id: id,
      type: ClipboardType.image,
      imageData: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime.now(),
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late _InMemoryStorage storage;
  late AddClipboardItemUseCase usecase;

  setUp(() {
    storage = _InMemoryStorage();
    usecase = AddClipboardItemUseCase(
      storage,
      _SettingsStub(const AppSettings()),
    );
  });

  group('AddClipboardItemUseCase', () {
    test('adds a new text item successfully', () async {
      final item = _textItem('1', 'Hello World');
      final added = await usecase.execute(item);
      expect(added, isTrue);
      expect(await storage.countItems(), 1);
    });

    test('rejects duplicate of most recent item', () async {
      final item = _textItem('1', 'same content');
      await usecase.execute(item);

      final duplicate = _textItem('2', 'same content');
      final added = await usecase.execute(duplicate);

      expect(added, isFalse);
      expect(await storage.countItems(), 1);
    });

    test('allows non-duplicate items', () async {
      await usecase.execute(_textItem('1', 'first'));
      final added = await usecase.execute(_textItem('2', 'second'));
      expect(added, isTrue);
      expect(await storage.countItems(), 2);
    });

    test('rejects oversized items', () async {
      // Use a small string that clearly exceeds the 1KB limit
      final bigText = 'x' * 2048; // 2KB > 1KB limit
      final item = ClipboardItem(
        id: 'big',
        type: ClipboardType.text,
        textContent: bigText,
        createdAt: DateTime.now(),
      );
      final settingsStub = _SettingsStub(
        const AppSettings(maxDataSizeKb: 1), // 1KB max
      );
      final smallLimitUsecase = AddClipboardItemUseCase(storage, settingsStub);
      final added = await smallLimitUsecase.execute(item);
      expect(added, isFalse);
    });

    test('rejects image items when enableImageSupport is false', () async {
      final settingsStub = _SettingsStub(
        const AppSettings(enableImageSupport: false),
      );
      final usecase2 = AddClipboardItemUseCase(storage, settingsStub);
      final item = _imageItem('img1');
      final added = await usecase2.execute(item);
      expect(added, isFalse);
      expect(await storage.countItems(), 0);
    });

    test('rotates oldest non-pinned item to history when at capacity', () async {
      final settingsStub = _SettingsStub(
        const AppSettings(maxClipboardItems: 3, persistentRotation: true),
      );
      final usecase3 = AddClipboardItemUseCase(storage, settingsStub);

      await usecase3.execute(_textItem('a', 'item a'));
      await usecase3.execute(_textItem('b', 'item b'));
      await usecase3.execute(_textItem('c', 'item c'));
      expect(await storage.countItems(), 3);

      // Adding a 4th should rotate oldest ('a') to history
      await usecase3.execute(_textItem('d', 'item d'));
      expect(await storage.countItems(), 3);
      expect(await storage.countHistoryItems(), 1);
      final history = await storage.getHistoryItems();
      expect(history.first.id, equals('a'));
    });

    test('deletes oldest non-pinned item without history when persistentRotation is false',
        () async {
      final settingsStub = _SettingsStub(
        const AppSettings(maxClipboardItems: 3, persistentRotation: false),
      );
      final usecase4 = AddClipboardItemUseCase(storage, settingsStub);

      await usecase4.execute(_textItem('a', 'item a'));
      await usecase4.execute(_textItem('b', 'item b'));
      await usecase4.execute(_textItem('c', 'item c'));
      await usecase4.execute(_textItem('d', 'item d'));

      expect(await storage.countItems(), 3);
      expect(await storage.countHistoryItems(), 0);
    });

    test('does not rotate pinned items when at capacity', () async {
      final settingsStub = _SettingsStub(
        const AppSettings(maxClipboardItems: 2, persistentRotation: true),
      );
      final usecase5 = AddClipboardItemUseCase(storage, settingsStub);

      // Add a pinned item first
      await usecase5.execute(_textItem('pinned', 'pinned item', isPinned: true));
      await usecase5.execute(_textItem('normal', 'normal item'));

      // At capacity (2). Adding another should rotate 'normal' (not the pinned)
      await usecase5.execute(_textItem('new', 'new item'));

      expect(await storage.countItems(), 2);
      final items = await storage.getItems();
      final ids = items.map((i) => i.id).toSet();
      expect(ids.contains('pinned'), isTrue);
      expect(ids.contains('normal'), isFalse);
    });
  });
}
