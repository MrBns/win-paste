import 'package:tray_manager/tray_manager.dart';

import 'package:win_paste/core/domain/ports/tray_port.dart';

class TrayWindows implements TrayPort, TrayListener {
  List<TrayMenuItem> _menuItems = [];

  @override
  Future<void> initialize({
    required List<TrayMenuItem> menuItems,
    String? iconPath,
  }) async {
    _menuItems = menuItems;
    trayManager.addListener(this);
    if (iconPath != null) {
      await trayManager.setIcon(iconPath);
    }
    await trayManager.setToolTip('WinPaste');
    await _applyMenu(menuItems);
  }

  @override
  Future<void> updateMenu(List<TrayMenuItem> menuItems) async {
    _menuItems = menuItems;
    await _applyMenu(menuItems);
  }

  @override
  Future<void> destroy() async {
    trayManager.removeListener(this);
    await trayManager.destroy();
  }

  Future<void> _applyMenu(List<TrayMenuItem> menuItems) async {
    final items = menuItems.map(_toTrayMenuItem).toList();
    await trayManager.setContextMenu(Menu(items: items));
  }

  MenuItem _toTrayMenuItem(TrayMenuItem item) {
    if (item is TrayMenuSeparator) {
      return MenuItem.separator();
    }
    if (item is TrayMenuAction) {
      return MenuItem(
        key: item.label,
        label: item.label,
        onClick: (_) => item.onTap(),
      );
    }
    return MenuItem.separator();
  }

  @override
  void onTrayIconMouseDown() {
    // On left click, trigger the first action item (Open)
    for (final item in _menuItems) {
      if (item is TrayMenuAction) {
        item.onTap();
        break;
      }
    }
  }

  @override
  void onTrayIconRightMouseDown() {}

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    // Menu click handled by MenuItem.onClick callback
  }

  @override
  void onTrayIconMouseUp() {}
}
