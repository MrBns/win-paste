import 'dart:async';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'package:win_paste/core/domain/ports/window_port.dart';

class WindowWindows implements WindowPort, WindowListener {
  final _visibilityController = StreamController<bool>.broadcast();
  bool _initialized = false;

  @override
  Future<void> initialize({double width = 700, double height = 540}) async {
    if (_initialized) return;
    await windowManager.ensureInitialized();
    windowManager.addListener(this);

    const options = WindowOptions(
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
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
  Future<bool> isVisible() async {
    return windowManager.isVisible();
  }

  @override
  Future<void> focus() async {
    await windowManager.focus();
  }

  @override
  Future<void> setSize(double width, double height) async {
    await windowManager.setSize(Size(width, height));
  }

  @override
  Future<void> setAlwaysOnTop(bool value) async {
    await windowManager.setAlwaysOnTop(value);
  }

  @override
  Future<void> centerOnScreen() async {
    await windowManager.center();
  }

  @override
  Future<void> setSkipTaskbar(bool skip) async {
    await windowManager.setSkipTaskbar(skip);
  }

  @override
  Stream<bool> get visibilityStream => _visibilityController.stream;

  @override
  void onWindowBlur() {
    // Auto-hide when window loses focus; guard to avoid a redundant call
    // if the window is already hidden (e.g. programmatic hide triggered this).
    windowManager.isVisible().then((visible) {
      if (visible) hide();
    });
  }

  @override
  void onWindowFocus() {
    _visibilityController.add(true);
  }

  @override
  void onWindowClose() {
    hide();
  }

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
  void onWindowVisibilityChange(bool isVisible) {
    _visibilityController.add(isVisible);
  }

  void dispose() {
    windowManager.removeListener(this);
    _visibilityController.close();
  }
}
