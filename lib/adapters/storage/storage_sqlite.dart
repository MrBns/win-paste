import 'dart:convert';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';

class StorageSqlite implements StoragePort {
  Database? _db;

  static const _dbName = 'win_paste.db';
  static const _itemsTable = 'clipboard_items';
  static const _historyTable = 'history_items';

  static const _schema = '''
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    text_content TEXT,
    image_data BLOB,
    file_paths TEXT,
    created_at INTEGER NOT NULL,
    is_pinned INTEGER NOT NULL DEFAULT 0,
    preview_title TEXT
  ''';

  @override
  Future<void> initialize() async {
    final dir = await getApplicationSupportDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE $_itemsTable ($_schema)');
        await db.execute('CREATE TABLE $_historyTable ($_schema)');
      },
    );
  }

  Database get _database {
    if (_db == null) throw StateError('StorageSqlite not initialized');
    return _db!;
  }

  // ─── Active Items ──────────────────────────────────────────────────────────

  @override
  Future<void> insertItem(ClipboardItem item) async {
    await _database.insert(
      _itemsTable,
      _toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ClipboardItem>> getItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  }) async {
    final where = typeFilter != null ? 'type = ?' : null;
    final whereArgs = typeFilter != null ? [_typeToString(typeFilter)] : null;
    final rows = await _database.query(
      _itemsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'is_pinned DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<ClipboardItem?> getItemById(String id) async {
    final rows = await _database.query(
      _itemsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  @override
  Future<void> updateItem(ClipboardItem item) async {
    await _database.update(
      _itemsTable,
      _toMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await _database.delete(_itemsTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearAllItems() async {
    await _database.delete(_itemsTable);
  }

  @override
  Future<int> countItems() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as c FROM $_itemsTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<ClipboardItem>> searchItems(
    String query, {
    ClipboardType? typeFilter,
  }) async {
    final conditions = ['text_content LIKE ?'];
    final args = <dynamic>['%$query%'];
    if (typeFilter != null) {
      conditions.add('type = ?');
      args.add(_typeToString(typeFilter));
    }
    final rows = await _database.query(
      _itemsTable,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'is_pinned DESC, created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<ClipboardItem?> getMostRecentItem() async {
    final rows = await _database.query(
      _itemsTable,
      orderBy: 'created_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  // ─── History Items ─────────────────────────────────────────────────────────

  @override
  Future<void> insertHistoryItem(ClipboardItem item) async {
    await _database.insert(
      _historyTable,
      _toMap(item),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ClipboardItem>> getHistoryItems({
    int? limit,
    int? offset,
    ClipboardType? typeFilter,
  }) async {
    final where = typeFilter != null ? 'type = ?' : null;
    final whereArgs = typeFilter != null ? [_typeToString(typeFilter)] : null;
    final rows = await _database.query(
      _historyTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(_fromMap).toList();
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    await _database.delete(_historyTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> clearHistory() async {
    await _database.delete(_historyTable);
  }

  @override
  Future<int> countHistoryItems() async {
    final result = await _database.rawQuery(
      'SELECT COUNT(*) as c FROM $_historyTable',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<List<ClipboardItem>> searchHistoryItems(
    String query, {
    ClipboardType? typeFilter,
  }) async {
    final conditions = ['text_content LIKE ?'];
    final args = <dynamic>['%$query%'];
    if (typeFilter != null) {
      conditions.add('type = ?');
      args.add(_typeToString(typeFilter));
    }
    final rows = await _database.query(
      _historyTable,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _toMap(ClipboardItem item) => {
        'id': item.id,
        'type': _typeToString(item.type),
        'text_content': item.textContent,
        'image_data': item.imageData,
        'file_paths': item.filePaths != null
            ? jsonEncode(item.filePaths)
            : null,
        'created_at': item.createdAt.millisecondsSinceEpoch,
        'is_pinned': item.isPinned ? 1 : 0,
        'preview_title': item.previewTitle,
      };

  ClipboardItem _fromMap(Map<String, dynamic> map) {
    List<String>? filePaths;
    if (map['file_paths'] != null) {
      filePaths = List<String>.from(jsonDecode(map['file_paths'] as String));
    }
    return ClipboardItem(
      id: map['id'] as String,
      type: _typeFromString(map['type'] as String),
      textContent: map['text_content'] as String?,
      imageData: map['image_data'] as Uint8List?,
      filePaths: filePaths,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isPinned: (map['is_pinned'] as int) == 1,
      previewTitle: map['preview_title'] as String?,
    );
  }

  String _typeToString(ClipboardType type) => type.name;

  ClipboardType _typeFromString(String value) =>
      ClipboardType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ClipboardType.text,
      );
}
