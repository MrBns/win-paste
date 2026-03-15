import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:uuid/uuid.dart';
import 'package:win32/win32.dart';

import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/clipboard_port.dart';

class ClipboardWindows implements ClipboardPort, ClipboardListener {
  final _controller = StreamController<ClipboardItem?>.broadcast();
  final _uuid = const Uuid();
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    clipboardWatcher.addListener(this);
    await clipboardWatcher.start();
    _initialized = true;
  }

  @override
  Stream<ClipboardItem?> watchClipboard() => _controller.stream;

  @override
  void onClipboardChanged() async {
    final item = await readCurrentClipboard();
    _controller.add(item);
  }

  @override
  Future<ClipboardItem?> readCurrentClipboard() async {
    // Try image first
    final imageBytes = await Pasteboard.image;
    if (imageBytes != null) {
      return ClipboardItem(
        id: _uuid.v4(),
        type: ClipboardType.image,
        imageData: imageBytes,
        createdAt: DateTime.now(),
      );
    }

    // Try files
    final files = await _readFilesFromClipboard();
    if (files != null && files.isNotEmpty) {
      return ClipboardItem(
        id: _uuid.v4(),
        type: ClipboardType.file,
        filePaths: files,
        createdAt: DateTime.now(),
      );
    }

    // Try text
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      return ClipboardItem(
        id: _uuid.v4(),
        type: ClipboardType.text,
        textContent: data.text,
        createdAt: DateTime.now(),
      );
    }

    return null;
  }

  @override
  Future<void> writeToClipboard(ClipboardItem item) async {
    switch (item.type) {
      case ClipboardType.text:
      case ClipboardType.richText:
        if (item.textContent != null) {
          await Clipboard.setData(ClipboardData(text: item.textContent!));
        }
        break;
      case ClipboardType.image:
        if (item.imageData != null) {
          await Pasteboard.writeImageBytes(item.imageData!);
        }
        break;
      case ClipboardType.file:
        if (item.filePaths != null) {
          await Pasteboard.writeFiles(item.filePaths!);
        }
        break;
    }
  }

  Future<List<String>?> _readFilesFromClipboard() async {
    if (!OpenClipboard(0).toBool()) return null;
    final hDrop = GetClipboardData(CF_HDROP);
    if (hDrop == 0) {
      CloseClipboard();
      return null;
    }
    final count = DragQueryFile(hDrop, 0xFFFFFFFF, nullptr, 0);
    final files = <String>[];
    for (int i = 0; i < count; i++) {
      final size = DragQueryFile(hDrop, i, nullptr, 0) + 1;
      final buffer = wsalloc(size);
      DragQueryFile(hDrop, i, buffer, size);
      files.add(buffer.toDartString());
      free(buffer);
    }
    CloseClipboard();
    return files.isEmpty ? null : files;
  }

  @override
  Future<void> dispose() async {
    clipboardWatcher.removeListener(this);
    await clipboardWatcher.stop();
    await _controller.close();
    _initialized = false;
  }
}
