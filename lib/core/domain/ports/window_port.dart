abstract class WindowPort {
  Future<void> initialize({double width, double height});
  Future<void> show();
  Future<void> hide();
  Future<bool> isVisible();
  Future<void> focus();
  Future<void> setSize(double width, double height);
  Future<void> setAlwaysOnTop(bool value);
  Future<void> centerOnScreen();
  Future<void> setSkipTaskbar(bool skip);
  Stream<bool> get visibilityStream;
}
