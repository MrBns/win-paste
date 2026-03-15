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
    // Bounds match the _NumberRow constraints in SettingsScreen (400–1200 × 300–900)
    if (newSettings.windowWidth < 400 || newSettings.windowWidth > 1200) {
      throw ArgumentError('windowWidth must be between 400 and 1200');
    }
    if (newSettings.windowHeight < 300 || newSettings.windowHeight > 900) {
      throw ArgumentError('windowHeight must be between 300 and 900');
    }

    await _settings.saveSettings(newSettings);

    // Re-register hotkey if changed
    if (newSettings.globalHotkey != oldSettings.globalHotkey) {
      await _hotkey.unregisterAll();
      await _hotkey.registerHotkey(newSettings.globalHotkey, onHotkeyTriggered);
    }
  }
}
