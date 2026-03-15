import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:win_paste/core/domain/ports/window_port.dart';

// TODO: Address Linux-specific gaps (skip taskbar may not work on all DEs)
class WindowLinux implements WindowPort, WindowListener {
  final _visibilityController = StreamController<bool>.broadcast();
  bool _initialized = false;

  @override
  Future<void> initialize({double width = 700, double height = 540}) async {
    if (_initialized) return;
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    const options = WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.transparent,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.setSize(Size(width, height));
      await windowManager.center();
    });
    _initialized = true;
  }

  @override
  Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
    _visibilityController.add(true);
  }

  @override
  Future<void> hide() async {
    await windowManager.hide();
    _visibilityController.add(false);
  }

  @override
  Future<bool> isVisible() async => windowManager.isVisible();

  @override
  Future<void> focus() async => windowManager.focus();

  @override
  Future<void> setSize(double width, double height) async =>
      windowManager.setSize(Size(width, height));

  @override
  Future<void> setAlwaysOnTop(bool value) async =>
      windowManager.setAlwaysOnTop(value);

  @override
  Future<void> centerOnScreen() async => windowManager.center();

  @override
  Future<void> setSkipTaskbar(bool skip) async =>
      windowManager.setSkipTaskbar(skip);

  @override
  Stream<bool> get visibilityStream => _visibilityController.stream;

  @override
  void onWindowBlur() => hide();

  @override
  void onWindowFocus() => _visibilityController.add(true);

  @override
  void onWindowClose() => hide();

  @override
  void onWindowEvent(String eventName) {}

  @override
  void onWindowEnterFullScreen() {}

  @override
  void onWindowLeaveFullScreen() {}

  @override
  void onWindowMaximize() {}

  @override
  void onWindowMinimize() {}

  @override
  void onWindowMove() {}

  @override
  void onWindowMoveStart() {}

  @override
  void onWindowMoveEnd() {}

  @override
  void onWindowResize() {}

  @override
  void onWindowResizeStart() {}

  @override
  void onWindowResizeEnd() {}

  @override
  void onWindowRestore() {}

  @override
  void onWindowUnmaximize() {}

  @override
  void onWindowDocked() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowVisibilityChange(bool isVisible) =>
      _visibilityController.add(isVisible);
}
