import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:win_paste/app.dart';
import 'package:win_paste/application/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // window_manager must be initialized before anything else
  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(700, 540),
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    backgroundColor: Colors.transparent,
    alwaysOnTop: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  });

  await ServiceLocator.initialize();

  runApp(const WinPasteApp());
}
