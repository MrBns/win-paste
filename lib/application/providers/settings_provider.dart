import 'package:flutter/foundation.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/core/domain/entities/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await ServiceLocator.getSettingsUseCase.execute();
    notifyListeners();
  }

  Future<void> updateSettings(
    AppSettings newSettings,
    void Function() onHotkeyTriggered,
  ) async {
    final old = _settings;
    await ServiceLocator.saveSettingsUseCase.execute(
      newSettings,
      old,
      onHotkeyTriggered,
    );
    _settings = newSettings;
    notifyListeners();
  }

  Future<void> resetToDefaults(void Function() onHotkeyTriggered) async {
    await updateSettings(const AppSettings(), onHotkeyTriggered);
  }
}
