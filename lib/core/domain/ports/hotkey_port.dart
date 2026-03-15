abstract class HotkeyPort {
  Future<void> initialize();
  Future<void> registerHotkey(String hotkeyString, void Function() onActivated);
  Future<void> unregisterHotkey(String hotkeyString);
  Future<void> unregisterAll();
  Future<void> dispose();
}
