import 'package:win_paste/core/domain/ports/hotkey_port.dart';

// TODO: Implement using macOS Accessibility API or CGEventTap
class HotkeyMacOS implements HotkeyPort {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> registerHotkey(
    String hotkeyString,
    void Function() onActivated,
  ) async {
    // No-op: macOS global hotkeys require Accessibility API permissions
  }

  @override
  Future<void> unregisterHotkey(String hotkeyString) async {}

  @override
  Future<void> unregisterAll() async {}

  @override
  Future<void> dispose() async {}
}
