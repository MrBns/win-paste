import 'package:win_paste/core/domain/entities/app_settings.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';

class GetSettingsUseCase {
  final SettingsPort _settings;

  GetSettingsUseCase(this._settings);

  Future<AppSettings> execute() async {
    return _settings.loadSettings();
  }
}
