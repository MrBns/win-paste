class AppSettings {
  final String globalHotkey;
  final bool enableImageSupport;
  final bool enableFileSupport;
  final int maxDataSizeKb;
  final int maxClipboardItems;
  final int maxHistoryItems;
  final bool persistentRotation;
  final double windowWidth;
  final double windowHeight;
  final bool darkMode;
  final bool launchOnStartup;
  final bool showNotifications;

  const AppSettings({
    this.globalHotkey = 'ctrl+shift+v',
    this.enableImageSupport = true,
    this.enableFileSupport = true,
    this.maxDataSizeKb = 10240,
    this.maxClipboardItems = 500,
    this.maxHistoryItems = 1000,
    this.persistentRotation = true,
    this.windowWidth = 700,
    this.windowHeight = 540,
    this.darkMode = true,
    this.launchOnStartup = false,
    this.showNotifications = true,
  });

  Map<String, dynamic> toMap() => {
        'globalHotkey': globalHotkey,
        'enableImageSupport': enableImageSupport,
        'enableFileSupport': enableFileSupport,
        'maxDataSizeKb': maxDataSizeKb,
        'maxClipboardItems': maxClipboardItems,
        'maxHistoryItems': maxHistoryItems,
        'persistentRotation': persistentRotation,
        'windowWidth': windowWidth,
        'windowHeight': windowHeight,
        'darkMode': darkMode,
        'launchOnStartup': launchOnStartup,
        'showNotifications': showNotifications,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        globalHotkey: (map['globalHotkey'] as String?) ?? 'ctrl+shift+v',
        enableImageSupport: (map['enableImageSupport'] as bool?) ?? true,
        enableFileSupport: (map['enableFileSupport'] as bool?) ?? true,
        maxDataSizeKb: (map['maxDataSizeKb'] as int?) ?? 10240,
        maxClipboardItems: (map['maxClipboardItems'] as int?) ?? 500,
        maxHistoryItems: (map['maxHistoryItems'] as int?) ?? 1000,
        persistentRotation: (map['persistentRotation'] as bool?) ?? true,
        windowWidth: (map['windowWidth'] as num?)?.toDouble() ?? 700,
        windowHeight: (map['windowHeight'] as num?)?.toDouble() ?? 540,
        darkMode: (map['darkMode'] as bool?) ?? true,
        launchOnStartup: (map['launchOnStartup'] as bool?) ?? false,
        showNotifications: (map['showNotifications'] as bool?) ?? true,
      );

  AppSettings copyWith({
    String? globalHotkey,
    bool? enableImageSupport,
    bool? enableFileSupport,
    int? maxDataSizeKb,
    int? maxClipboardItems,
    int? maxHistoryItems,
    bool? persistentRotation,
    double? windowWidth,
    double? windowHeight,
    bool? darkMode,
    bool? launchOnStartup,
    bool? showNotifications,
  }) =>
      AppSettings(
        globalHotkey: globalHotkey ?? this.globalHotkey,
        enableImageSupport: enableImageSupport ?? this.enableImageSupport,
        enableFileSupport: enableFileSupport ?? this.enableFileSupport,
        maxDataSizeKb: maxDataSizeKb ?? this.maxDataSizeKb,
        maxClipboardItems: maxClipboardItems ?? this.maxClipboardItems,
        maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
        persistentRotation: persistentRotation ?? this.persistentRotation,
        windowWidth: windowWidth ?? this.windowWidth,
        windowHeight: windowHeight ?? this.windowHeight,
        darkMode: darkMode ?? this.darkMode,
        launchOnStartup: launchOnStartup ?? this.launchOnStartup,
        showNotifications: showNotifications ?? this.showNotifications,
      );
}
