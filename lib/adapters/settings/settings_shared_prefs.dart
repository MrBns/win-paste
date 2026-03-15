import 'package:shared_preferences/shared_preferences.dart';

import 'package:win_paste/core/domain/entities/app_settings.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';

class SettingsSharedPrefs implements SettingsPort {
  static const _prefix = 'win_paste_';

  @override
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      globalHotkey: prefs.getString('${_prefix}globalHotkey') ?? 'ctrl+shift+v',
      enableImageSupport: prefs.getBool('${_prefix}enableImageSupport') ?? true,
      enableFileSupport: prefs.getBool('${_prefix}enableFileSupport') ?? true,
      maxDataSizeKb: prefs.getInt('${_prefix}maxDataSizeKb') ?? 10240,
      maxClipboardItems: prefs.getInt('${_prefix}maxClipboardItems') ?? 500,
      maxHistoryItems: prefs.getInt('${_prefix}maxHistoryItems') ?? 1000,
      persistentRotation: prefs.getBool('${_prefix}persistentRotation') ?? true,
      windowWidth: prefs.getDouble('${_prefix}windowWidth') ?? 700,
      windowHeight: prefs.getDouble('${_prefix}windowHeight') ?? 540,
      darkMode: prefs.getBool('${_prefix}darkMode') ?? true,
      launchOnStartup: prefs.getBool('${_prefix}launchOnStartup') ?? false,
      showNotifications: prefs.getBool('${_prefix}showNotifications') ?? true,
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefix}globalHotkey', settings.globalHotkey);
    await prefs.setBool('${_prefix}enableImageSupport', settings.enableImageSupport);
    await prefs.setBool('${_prefix}enableFileSupport', settings.enableFileSupport);
    await prefs.setInt('${_prefix}maxDataSizeKb', settings.maxDataSizeKb);
    await prefs.setInt('${_prefix}maxClipboardItems', settings.maxClipboardItems);
    await prefs.setInt('${_prefix}maxHistoryItems', settings.maxHistoryItems);
    await prefs.setBool('${_prefix}persistentRotation', settings.persistentRotation);
    await prefs.setDouble('${_prefix}windowWidth', settings.windowWidth);
    await prefs.setDouble('${_prefix}windowHeight', settings.windowHeight);
    await prefs.setBool('${_prefix}darkMode', settings.darkMode);
    await prefs.setBool('${_prefix}launchOnStartup', settings.launchOnStartup);
    await prefs.setBool('${_prefix}showNotifications', settings.showNotifications);
  }
}
