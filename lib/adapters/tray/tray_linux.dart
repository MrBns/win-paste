import 'package:win_paste/core/domain/ports/tray_port.dart';

// TODO: Implement using AppIndicator or StatusNotifierItem
class TrayLinux implements TrayPort {
  @override
  Future<void> initialize({
    required List<TrayMenuItem> menuItems,
    String? iconPath,
  }) async {
    // No-op stub
  }

  @override
  Future<void> updateMenu(List<TrayMenuItem> menuItems) async {}

  @override
  Future<void> destroy() async {}
}
