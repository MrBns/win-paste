import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';

class ClipboardProvider extends ChangeNotifier {
  List<ClipboardItem> _items = [];
  List<ClipboardItem> _filteredItems = [];
  String _searchQuery = '';
  ClipboardType? _activeFilter;
  bool _isLoading = false;
  bool _pinnedOnly = false;
  StreamSubscription<ClipboardItem?>? _clipboardSubscription;

  List<ClipboardItem> get items => _items;
  List<ClipboardItem> get filteredItems => _filteredItems;
  String get searchQuery => _searchQuery;
  ClipboardType? get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get pinnedOnly => _pinnedOnly;

  Future<void> initialize() async {
    await ServiceLocator.clipboardPort.initialize();
    await loadItems();
    _clipboardSubscription = ServiceLocator.clipboardPort
        .watchClipboard()
        .listen(_onClipboardChanged);
  }

  Future<void> _onClipboardChanged(ClipboardItem? item) async {
    if (item == null) return;
    await ServiceLocator.addClipboardItemUseCase.execute(item);
    await loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await ServiceLocator.getClipboardItemsUseCase.execute(
      typeFilter: _activeFilter,
      pinnedOnly: _pinnedOnly,
    );
    _applySearch();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _applySearch();
      notifyListeners();
      return;
    }
    _filteredItems = await ServiceLocator.searchClipboardUseCase.execute(
      query,
      typeFilter: _activeFilter,
    );
    notifyListeners();
  }

  void filterByType(ClipboardType? type) {
    _activeFilter = type;
    _pinnedOnly = false;
    loadItems();
  }

  void filterPinnedOnly() {
    _pinnedOnly = true;
    _activeFilter = null;
    loadItems();
  }

  Future<void> deleteItem(String id) async {
    await ServiceLocator.deleteClipboardItemUseCase.execute(id);
    await loadItems();
  }

  Future<void> pinItem(String id) async {
    await ServiceLocator.pinClipboardItemUseCase.execute(id);
    await loadItems();
  }

  Future<void> copyToClipboard(ClipboardItem item) async {
    await ServiceLocator.copyItemToClipboardUseCase.execute(item);
    await loadItems();
  }

  Future<void> refreshItems() async {
    await loadItems();
  }

  void _applySearch() {
    if (_searchQuery.trim().isEmpty) {
      _filteredItems = List.from(_items);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredItems = _items.where((item) {
        final text = item.textContent?.toLowerCase() ?? '';
        final paths = item.filePaths?.join(' ').toLowerCase() ?? '';
        return text.contains(query) || paths.contains(query);
      }).toList();
    }
  }

  @override
  void dispose() {
    _clipboardSubscription?.cancel();
    ServiceLocator.clipboardPort.dispose();
    super.dispose();
  }
}
