// Generated file - do not edit.
// This file is generated from template by flutter tools.

#include "generated_plugin_registrant.h"

#include <clipboard_watcher/clipboard_watcher_plugin_c_api.h>
#include <hotkey_manager_windows/hotkey_manager_windows_plugin_c_api.h>
#include <pasteboard/pasteboard_plugin.h>
#include <screen_retriever_windows/screen_retriever_windows_plugin_c_api.h>
#include <tray_manager/tray_manager_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  ClipboardWatcherPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ClipboardWatcherPluginCApi"));
  HotkeyManagerWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("HotkeyManagerWindowsPluginCApi"));
  PasteboardPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PasteboardPlugin"));
  ScreenRetrieverWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverWindowsPluginCApi"));
  TrayManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TrayManagerPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
