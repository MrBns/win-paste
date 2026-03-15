import 'dart:async';

import 'package:flutter/services.dart';
import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:uuid/uuid.dart';

import 'package:win_paste/core/domain/entities/clipboard_item.dart';
import 'package:win_paste/core/domain/entities/clipboard_type.dart';
import 'package:win_paste/core/domain/ports/clipboard_port.dart';

// TODO: Implement full Linux clipboard support using xclip/wl-clipboard
class ClipboardLinux implements ClipboardPort, ClipboardListener {
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
    // Basic text support only on Linux
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
    if (item.textContent != null) {
      await Clipboard.setData(ClipboardData(text: item.textContent!));
    }
    // Image/file writing not supported on Linux stub
  }

  @override
  Future<void> dispose() async {
    clipboardWatcher.removeListener(this);
    await clipboardWatcher.stop();
    await _controller.close();
    _initialized = false;
  }
}
