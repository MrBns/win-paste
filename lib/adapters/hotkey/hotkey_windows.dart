import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import 'package:win_paste/core/domain/ports/hotkey_port.dart';

class HotkeyWindows implements HotkeyPort {
  final Map<String, HotKey> _registeredKeys = {};

  @override
  Future<void> initialize() async {
    await hotKeyManager.unregisterAll();
  }

  @override
  Future<void> registerHotkey(
    String hotkeyString,
    void Function() onActivated,
  ) async {
    final hotkey = _parseHotkey(hotkeyString);
    if (hotkey == null) return;
    _registeredKeys[hotkeyString] = hotkey;
    await hotKeyManager.register(
      hotkey,
      keyDownHandler: (_) => onActivated(),
    );
  }

  @override
  Future<void> unregisterHotkey(String hotkeyString) async {
    final hotkey = _registeredKeys.remove(hotkeyString);
    if (hotkey != null) {
      await hotKeyManager.unregister(hotkey);
    }
  }

  @override
  Future<void> unregisterAll() async {
    await hotKeyManager.unregisterAll();
    _registeredKeys.clear();
  }

  @override
  Future<void> dispose() async {
    await unregisterAll();
  }

  HotKey? _parseHotkey(String hotkeyString) {
    final parts = hotkeyString.toLowerCase().split('+');
    if (parts.isEmpty) return null;

    final modifiers = <HotKeyModifier>[];
    LogicalKeyboardKey? key;

    for (final part in parts) {
      switch (part.trim()) {
        case 'ctrl':
        case 'control':
          modifiers.add(HotKeyModifier.control);
          break;
        case 'shift':
          modifiers.add(HotKeyModifier.shift);
          break;
        case 'alt':
          modifiers.add(HotKeyModifier.alt);
          break;
        case 'meta':
        case 'win':
        case 'super':
          modifiers.add(HotKeyModifier.meta);
          break;
        default:
          key = _parseKey(part.trim());
      }
    }

    if (key == null) return null;
    return HotKey(key: key, modifiers: modifiers);
  }

  LogicalKeyboardKey? _parseKey(String keyStr) {
    if (keyStr.length == 1) {
      final char = keyStr.toLowerCase();
      const letterMap = {
        'a': LogicalKeyboardKey.keyA,
        'b': LogicalKeyboardKey.keyB,
        'c': LogicalKeyboardKey.keyC,
        'd': LogicalKeyboardKey.keyD,
        'e': LogicalKeyboardKey.keyE,
        'f': LogicalKeyboardKey.keyF,
        'g': LogicalKeyboardKey.keyG,
        'h': LogicalKeyboardKey.keyH,
        'i': LogicalKeyboardKey.keyI,
        'j': LogicalKeyboardKey.keyJ,
        'k': LogicalKeyboardKey.keyK,
        'l': LogicalKeyboardKey.keyL,
        'm': LogicalKeyboardKey.keyM,
        'n': LogicalKeyboardKey.keyN,
        'o': LogicalKeyboardKey.keyO,
        'p': LogicalKeyboardKey.keyP,
        'q': LogicalKeyboardKey.keyQ,
        'r': LogicalKeyboardKey.keyR,
        's': LogicalKeyboardKey.keyS,
        't': LogicalKeyboardKey.keyT,
        'u': LogicalKeyboardKey.keyU,
        'v': LogicalKeyboardKey.keyV,
        'w': LogicalKeyboardKey.keyW,
        'x': LogicalKeyboardKey.keyX,
        'y': LogicalKeyboardKey.keyY,
        'z': LogicalKeyboardKey.keyZ,
        '0': LogicalKeyboardKey.digit0,
        '1': LogicalKeyboardKey.digit1,
        '2': LogicalKeyboardKey.digit2,
        '3': LogicalKeyboardKey.digit3,
        '4': LogicalKeyboardKey.digit4,
        '5': LogicalKeyboardKey.digit5,
        '6': LogicalKeyboardKey.digit6,
        '7': LogicalKeyboardKey.digit7,
        '8': LogicalKeyboardKey.digit8,
        '9': LogicalKeyboardKey.digit9,
      };
      return letterMap[char];
    }
    switch (keyStr) {
      case 'space':
        return LogicalKeyboardKey.space;
      case 'enter':
        return LogicalKeyboardKey.enter;
      case 'escape':
      case 'esc':
        return LogicalKeyboardKey.escape;
      case 'tab':
        return LogicalKeyboardKey.tab;
      case 'f1':
        return LogicalKeyboardKey.f1;
      case 'f2':
        return LogicalKeyboardKey.f2;
      case 'f3':
        return LogicalKeyboardKey.f3;
      case 'f4':
        return LogicalKeyboardKey.f4;
      case 'f5':
        return LogicalKeyboardKey.f5;
      case 'f6':
        return LogicalKeyboardKey.f6;
      case 'f7':
        return LogicalKeyboardKey.f7;
      case 'f8':
        return LogicalKeyboardKey.f8;
      case 'f9':
        return LogicalKeyboardKey.f9;
      case 'f10':
        return LogicalKeyboardKey.f10;
      case 'f11':
        return LogicalKeyboardKey.f11;
      case 'f12':
        return LogicalKeyboardKey.f12;
      default:
        return null;
    }
  }
}
