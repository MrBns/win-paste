import 'dart:io';

import 'package:win_paste/adapters/clipboard/clipboard_linux.dart';
import 'package:win_paste/adapters/clipboard/clipboard_macos.dart';
import 'package:win_paste/adapters/clipboard/clipboard_windows.dart';
import 'package:win_paste/adapters/hotkey/hotkey_linux.dart';
import 'package:win_paste/adapters/hotkey/hotkey_macos.dart';
import 'package:win_paste/adapters/hotkey/hotkey_windows.dart';
import 'package:win_paste/adapters/settings/settings_shared_prefs.dart';
import 'package:win_paste/adapters/storage/storage_sqlite.dart';
import 'package:win_paste/adapters/tray/tray_linux.dart';
import 'package:win_paste/adapters/tray/tray_macos.dart';
import 'package:win_paste/adapters/tray/tray_windows.dart';
import 'package:win_paste/adapters/window/window_linux.dart';
import 'package:win_paste/adapters/window/window_macos.dart';
import 'package:win_paste/adapters/window/window_windows.dart';
import 'package:win_paste/core/domain/ports/clipboard_port.dart';
import 'package:win_paste/core/domain/ports/hotkey_port.dart';
import 'package:win_paste/core/domain/ports/settings_port.dart';
import 'package:win_paste/core/domain/ports/storage_port.dart';
import 'package:win_paste/core/domain/ports/tray_port.dart';
import 'package:win_paste/core/domain/ports/window_port.dart';
import 'package:win_paste/core/domain/usecases/add_clipboard_item_usecase.dart';
import 'package:win_paste/core/domain/usecases/copy_item_to_clipboard_usecase.dart';
import 'package:win_paste/core/domain/usecases/delete_clipboard_item_usecase.dart';
import 'package:win_paste/core/domain/usecases/delete_history_item_usecase.dart';
import 'package:win_paste/core/domain/usecases/get_clipboard_items_usecase.dart';
import 'package:win_paste/core/domain/usecases/get_history_usecase.dart';
import 'package:win_paste/core/domain/usecases/get_settings_usecase.dart';
import 'package:win_paste/core/domain/usecases/pin_clipboard_item_usecase.dart';
import 'package:win_paste/core/domain/usecases/save_settings_usecase.dart';
import 'package:win_paste/core/domain/usecases/search_clipboard_usecase.dart';

class ServiceLocator {
  static late final ClipboardPort clipboardPort;
  static late final HotkeyPort hotkeyPort;
  static late final TrayPort trayPort;
  static late final WindowPort windowPort;
  static late final StoragePort storagePort;
  static late final SettingsPort settingsPort;

  static late final AddClipboardItemUseCase addClipboardItemUseCase;
  static late final GetClipboardItemsUseCase getClipboardItemsUseCase;
  static late final DeleteClipboardItemUseCase deleteClipboardItemUseCase;
  static late final PinClipboardItemUseCase pinClipboardItemUseCase;
  static late final SearchClipboardUseCase searchClipboardUseCase;
  static late final CopyItemToClipboardUseCase copyItemToClipboardUseCase;
  static late final GetHistoryUseCase getHistoryUseCase;
  static late final DeleteHistoryItemUseCase deleteHistoryItemUseCase;
  static late final GetSettingsUseCase getSettingsUseCase;
  static late final SaveSettingsUseCase saveSettingsUseCase;

  static Future<void> initialize() async {
    storagePort = StorageSqlite();
    settingsPort = SettingsSharedPrefs();
    await storagePort.initialize();

    if (Platform.isWindows) {
      clipboardPort = ClipboardWindows();
      hotkeyPort = HotkeyWindows();
      trayPort = TrayWindows();
      windowPort = WindowWindows();
    } else if (Platform.isLinux) {
      clipboardPort = ClipboardLinux();
      hotkeyPort = HotkeyLinux();
      trayPort = TrayLinux();
      windowPort = WindowLinux();
    } else if (Platform.isMacOS) {
      clipboardPort = ClipboardMacOS();
      hotkeyPort = HotkeyMacOS();
      trayPort = TrayMacOS();
      windowPort = WindowMacOS();
    } else {
      throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
    }

    addClipboardItemUseCase = AddClipboardItemUseCase(storagePort, settingsPort);
    getClipboardItemsUseCase = GetClipboardItemsUseCase(storagePort);
    deleteClipboardItemUseCase = DeleteClipboardItemUseCase(storagePort);
    pinClipboardItemUseCase = PinClipboardItemUseCase(storagePort);
    searchClipboardUseCase = SearchClipboardUseCase(storagePort);
    copyItemToClipboardUseCase = CopyItemToClipboardUseCase(clipboardPort, storagePort);
    getHistoryUseCase = GetHistoryUseCase(storagePort);
    deleteHistoryItemUseCase = DeleteHistoryItemUseCase(storagePort);
    getSettingsUseCase = GetSettingsUseCase(settingsPort);
    saveSettingsUseCase = SaveSettingsUseCase(settingsPort, hotkeyPort);
  }
}
