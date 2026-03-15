import 'package:win_paste/core/domain/ports/hotkey_port.dart';

// TODO: Implement using xdotool/libxdo or keybind service
class HotkeyLinux implements HotkeyPort {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> registerHotkey(
    String hotkeyString,
    void Function() onActivated,
  ) async {
    // No-op: Linux global hotkeys require keybind daemon integration
  }

  @override
  Future<void> unregisterHotkey(String hotkeyString) async {}

  @override
  Future<void> unregisterAll() async {}

  @override
  Future<void> dispose() async {}
}
