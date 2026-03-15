import 'package:win_paste/core/domain/entities/app_settings.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';
import 'package:win_paste/core/domain/ports/hotkey_port.dart';

class SaveSettingsUseCase {
  final SettingsPort _settings;
  final HotkeyPort _hotkey;

  SaveSettingsUseCase(this._settings, this._hotkey);

  Future<void> execute(
    AppSettings newSettings,
    AppSettings oldSettings,
    void Function() onHotkeyTriggered,
  ) async {
    // Validate settings — enforced in both debug and release builds
    if (newSettings.maxDataSizeKb < 1 || newSettings.maxDataSizeKb > 102400) {
      throw ArgumentError('maxDataSizeKb must be between 1 and 102400');
    }
    if (newSettings.maxClipboardItems < 10 || newSettings.maxClipboardItems > 500) {
      throw ArgumentError('maxClipboardItems must be between 10 and 500');
    }
    if (newSettings.maxHistoryItems < 100 || newSettings.maxHistoryItems > 10000) {
      throw ArgumentError('maxHistoryItems must be between 100 and 10000');
    }
    if (newSettings.windowWidth < 300) {
      throw ArgumentError('windowWidth must be at least 300');
    }
    if (newSettings.windowHeight < 200) {
      throw ArgumentError('windowHeight must be at least 200');
    }

    await _settings.saveSettings(newSettings);

    // Re-register hotkey if changed
    if (newSettings.globalHotkey != oldSettings.globalHotkey) {
      await _hotkey.unregisterAll();
      await _hotkey.registerHotkey(newSettings.globalHotkey, onHotkeyTriggered);
    }
  }
}
