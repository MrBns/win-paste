# WinPaste

> An advanced, modern clipboard manager for Windows built with Flutter — featuring a blazing-fast popup UI, system tray integration, global hotkeys, and persistent clipboard history.

[![Flutter](https://img.shields.io/badge/Flutter-3.19%2B-blue)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightblue)](https://flutter.dev/desktop)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## Features

- **🚀 Instant popup** — summon your clipboard history with a global hotkey (`Ctrl+Shift+V` by default)
- **📋 Multi-type support** — captures text, images, and file paths
- **📌 Pin important items** — pin frequently-used clips so they're never rotated out
- **🔍 Full-text search** — instantly find any past clipboard entry
- **🏷️ Smart type filters** — filter by All / Text / Images / Files / Pinned
- **⌨️ Keyboard navigation** — `↑↓` navigate, `Enter` to copy, `Esc` to close
- **📜 Persistent history** — archived items stored in a local SQLite database
- **🎨 Developer-friendly previews** — detects hex colours, URLs, and code snippets
- **🌗 Dark/Light theme** — polished GitHub-inspired dark theme with light mode option
- **🖥️ System tray** — lives quietly in the tray; accessible any time
- **⚙️ Configurable** — customise hotkey, item limits, data size caps, window dimensions, and more

---

## Architecture

WinPaste follows **Hexagonal Architecture** (Ports & Adapters), keeping business logic completely isolated from platform-specific code.

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  PopupScreen  HistoryScreen  SettingsScreen  Widgets    │
└───────────────────────┬─────────────────────────────────┘
                        │ ChangeNotifier (Provider)
┌───────────────────────▼─────────────────────────────────┐
│                   Application Layer                      │
│  ClipboardProvider  SettingsProvider  ServiceLocator    │
└───────────────────────┬─────────────────────────────────┘
                        │ Use Cases
┌───────────────────────▼─────────────────────────────────┐
│                    Domain Layer                          │
│   Entities        Ports (interfaces)    Use Cases       │
│  ClipboardItem    ClipboardPort         Add/Get/Delete   │
│  AppSettings      StoragePort           Pin/Search/Copy  │
│  ClipboardType    HotkeyPort            History ops      │
│                   TrayPort              Settings ops     │
│                   WindowPort                             │
└───────────────────────┬─────────────────────────────────┘
                        │ Implements
┌───────────────────────▼─────────────────────────────────┐
│                   Adapters Layer                         │
│  clipboard_windows.dart  hotkey_windows.dart            │
│  tray_windows.dart       window_windows.dart            │
│  storage_sqlite.dart     settings_shared_prefs.dart     │
│  clipboard_linux.dart    clipboard_macos.dart (stubs)   │
└─────────────────────────────────────────────────────────┘
```

### Platform Adapter Table

| Port           | Windows (full)           | Linux (stub)           | macOS (stub)           |
|----------------|--------------------------|------------------------|------------------------|
| ClipboardPort  | `clipboard_windows.dart` | `clipboard_linux.dart` | `clipboard_macos.dart` |
| HotkeyPort     | `hotkey_windows.dart`    | `hotkey_linux.dart`    | `hotkey_macos.dart`    |
| TrayPort       | `tray_windows.dart`      | `tray_linux.dart`      | `tray_macos.dart`      |
| WindowPort     | `window_windows.dart`    | `window_linux.dart`    | `window_macos.dart`    |
| StoragePort    | `storage_sqlite.dart` (cross-platform) | ← same | ← same |
| SettingsPort   | `settings_shared_prefs.dart` (cross-platform) | ← same | ← same |

---

## Prerequisites

- **Flutter SDK** ≥ 3.19 ([install](https://flutter.dev/docs/get-started/install))
- **Windows 10** or later (for the full feature set)
- **Visual Studio 2022** with the "Desktop development with C++" workload

---

## Setup & Build

```bash
# 1. Clone the repository
git clone https://github.com/win-paste/win-paste.git
cd win-paste

# 2. Install Dart/Flutter dependencies
flutter pub get

# 3. Run in debug mode on Windows
flutter run -d windows

# 4. Build a release executable
flutter build windows --release
# Output: build/windows/x64/runner/Release/win_paste.exe
```

---

## Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/core/usecases/add_clipboard_item_usecase_test.dart
```

---

## Adding Support for a New Platform

To add full support for a new platform (e.g., Linux), implement the four port interfaces:

1. **`ClipboardPort`** — watch for clipboard changes and read/write all content types.  
   See `lib/adapters/clipboard/clipboard_windows.dart` as the reference implementation.

2. **`HotkeyPort`** — register and unregister system-wide global hotkeys.  
   See `lib/adapters/hotkey/hotkey_windows.dart`.

3. **`TrayPort`** — create a system tray icon with a context menu.  
   See `lib/adapters/tray/tray_windows.dart`.

4. **`WindowPort`** — control window visibility, size, position, and always-on-top state.  
   See `lib/adapters/window/window_windows.dart`.

Then wire your new adapters in `lib/application/di/service_locator.dart`:

```dart
} else if (Platform.isYourPlatform) {
  clipboardPort = ClipboardYourPlatform();
  hotkeyPort    = HotkeyYourPlatform();
  trayPort      = TrayYourPlatform();
  windowPort    = WindowYourPlatform();
}
```

No changes to the domain layer or use cases are required — that's the beauty of hexagonal architecture.

---

## Project Structure

```
lib/
  main.dart                     # Entry point — initialises window_manager & ServiceLocator
  app.dart                      # WinPasteApp widget + WindowsNavigationWrapper
  core/
    domain/
      entities/                 # ClipboardItem, ClipboardType, AppSettings
      ports/                    # Abstract interfaces (the hexagonal "ports")
      usecases/                 # Pure business logic, zero platform deps
  adapters/                     # Platform-specific implementations ("adapters")
    clipboard/  hotkey/  tray/  window/  storage/  settings/
  application/
    di/                         # ServiceLocator — wires ports to adapters
    providers/                  # ClipboardProvider, SettingsProvider (ChangeNotifier)
  presentation/
    screens/                    # PopupScreen, HistoryScreen, SettingsScreen
    widgets/                    # Reusable UI components
    theme/                      # AppTheme, AppColors
windows/                        # Flutter Windows runner (C++ / CMake)
assets/icons/                   # tray_icon.png
test/                           # Unit and widget tests
```

---

## License

MIT © WinPaste Contributors
