import 'package:win_paste/core/domain/entities/app_settings.dart';

abstract class SettingsPort {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
}
