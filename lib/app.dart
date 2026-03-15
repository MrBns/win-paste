import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/application/providers/clipboard_provider.dart';
import 'package:win_paste/application/providers/settings_provider.dart';
import 'package:win_paste/core/domain/ports/tray_port.dart';
import 'package:win_paste/presentation/screens/history/history_screen.dart';
import 'package:win_paste/presentation/screens/popup/popup_screen.dart';
import 'package:win_paste/presentation/screens/settings/settings_screen.dart';
import 'package:win_paste/presentation/theme/app_theme.dart';

class WinPasteApp extends StatelessWidget {
  const WinPasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClipboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'WinPaste',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (_) => const WindowsNavigationWrapper(),
              '/history': (_) => const HistoryScreen(),
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}

class WindowsNavigationWrapper extends StatefulWidget {
  const WindowsNavigationWrapper({super.key});

  @override
  State<WindowsNavigationWrapper> createState() =>
      _WindowsNavigationWrapperState();
}

class _WindowsNavigationWrapperState extends State<WindowsNavigationWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    final settingsProvider = context.read<SettingsProvider>();
    await settingsProvider.loadSettings();
    final settings = settingsProvider.settings;

    await context.read<ClipboardProvider>().initialize();

    // Initialize window
    await ServiceLocator.windowPort.initialize(
      width: settings.windowWidth,
      height: settings.windowHeight,
    );
    await ServiceLocator.windowPort.setSkipTaskbar(true);
    await ServiceLocator.windowPort.setAlwaysOnTop(true);

    // Setup tray
    await _setupTray();

    // Register hotkey
    await ServiceLocator.hotkeyPort.initialize();
    await ServiceLocator.hotkeyPort.registerHotkey(
      settings.globalHotkey,
      _onHotkeyTriggered,
    );
  }

  Future<void> _setupTray() async {
    await ServiceLocator.trayPort.initialize(
      iconPath: 'assets/icons/tray_icon.png',
      menuItems: _buildTrayMenu(),
    );
  }

  List<TrayMenuItem> _buildTrayMenu() {
    return [
      TrayMenuAction(
        label: 'Open WinPaste',
        onTap: () => ServiceLocator.windowPort.show(),
      ),
      TrayMenuAction(
        label: 'History',
        onTap: () async {
          await ServiceLocator.windowPort.show();
          if (mounted) Navigator.pushNamed(context, '/history');
        },
      ),
      TrayMenuAction(
        label: 'Settings',
        onTap: () async {
          await ServiceLocator.windowPort.show();
          if (mounted) Navigator.pushNamed(context, '/settings');
        },
      ),
      TrayMenuSeparator(),
      TrayMenuAction(
        label: 'Quit',
        onTap: () async {
          await ServiceLocator.trayPort.destroy();
          await ServiceLocator.hotkeyPort.dispose();
          await ServiceLocator.clipboardPort.dispose();
        },
      ),
    ];
  }

  void _onHotkeyTriggered() async {
    final isVisible = await ServiceLocator.windowPort.isVisible();
    if (isVisible) {
      await ServiceLocator.windowPort.hide();
    } else {
      await ServiceLocator.windowPort.centerOnScreen();
      await ServiceLocator.windowPort.show();
    }
  }

  @override
  Widget build(BuildContext context) => const PopupScreen();
}
