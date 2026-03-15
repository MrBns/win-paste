import 'package:flutter/foundation.dart';

sealed class TrayMenuItem {}

class TrayMenuAction extends TrayMenuItem {
  final String label;
  final VoidCallback onTap;
  TrayMenuAction({required this.label, required this.onTap});
}

class TrayMenuSeparator extends TrayMenuItem {}

abstract class TrayPort {
  Future<void> initialize({
    required List<TrayMenuItem> menuItems,
    String? iconPath,
  });
  Future<void> updateMenu(List<TrayMenuItem> menuItems);
  Future<void> destroy();
}
