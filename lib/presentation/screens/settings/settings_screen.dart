import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:win_paste/application/di/service_locator.dart';
import 'package:win_paste/application/providers/settings_provider.dart';
import 'package:win_paste/core/domain/entities/app_settings.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';
import 'package:win_paste/presentation/widgets/hotkey_recorder_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SettingsProvider>();
    _draft = provider.settings;
  }

  void _update(AppSettings updated) {
    setState(() {
      _draft = updated;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    await context.read<SettingsProvider>().updateSettings(
      _draft,
      _onHotkeyTriggered,
    );
    // Apply window size change
    await ServiceLocator.windowPort.setSize(_draft.windowWidth, _draft.windowHeight);
    setState(() => _dirty = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _onHotkeyTriggered() {
    ServiceLocator.windowPort.show();
  }

  Future<void> _reset() async {
    await context.read<SettingsProvider>().resetToDefaults(_onHotkeyTriggered);
    setState(() {
      _draft = context.read<SettingsProvider>().settings;
      _dirty = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          if (_dirty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: AppColors.darkBackground,
                ),
                child: const Text('Save'),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: 'Hotkey',
            children: [
              _SettingRow(
                label: 'Global Hotkey',
                description: 'Keyboard shortcut to show/hide WinPaste',
                child: HotkeyRecorderWidget(
                  currentHotkey: _draft.globalHotkey,
                  onChange: (v) => _update(_draft.copyWith(globalHotkey: v)),
                ),
              ),
            ],
          ),
          _Section(
            title: 'Clipboard',
            children: [
              _ToggleRow(
                label: 'Image Support',
                description: 'Capture and store images from clipboard',
                value: _draft.enableImageSupport,
                onChanged: (v) => _update(_draft.copyWith(enableImageSupport: v)),
              ),
              _ToggleRow(
                label: 'File Support',
                description: 'Capture and store file paths from clipboard',
                value: _draft.enableFileSupport,
                onChanged: (v) => _update(_draft.copyWith(enableFileSupport: v)),
              ),
              _SliderRow(
                label: 'Max Item Size',
                description: 'Maximum size per clipboard item',
                value: _draft.maxDataSizeKb.toDouble(),
                min: 1,
                max: 102400,
                displayValue: '${(_draft.maxDataSizeKb / 1024).toStringAsFixed(0)} MB',
                onChanged: (v) => _update(_draft.copyWith(maxDataSizeKb: v.round())),
              ),
              _NumberRow(
                label: 'Max Clipboard Items',
                description: 'Maximum number of items to keep (10–500)',
                value: _draft.maxClipboardItems,
                min: 10,
                max: 500,
                onChanged: (v) => _update(_draft.copyWith(maxClipboardItems: v)),
              ),
            ],
          ),
          _Section(
            title: 'History',
            children: [
              _ToggleRow(
                label: 'Persistent Rotation',
                description: 'Archive rotated items to history instead of deleting',
                value: _draft.persistentRotation,
                onChanged: (v) => _update(_draft.copyWith(persistentRotation: v)),
              ),
              _NumberRow(
                label: 'Max History Items',
                description: 'Maximum number of history items (100–10000)',
                value: _draft.maxHistoryItems,
                min: 100,
                max: 10000,
                onChanged: (v) => _update(_draft.copyWith(maxHistoryItems: v)),
              ),
            ],
          ),
          _Section(
            title: 'Appearance',
            children: [
              _ToggleRow(
                label: 'Dark Mode',
                description: 'Use dark color scheme',
                value: _draft.darkMode,
                onChanged: (v) => _update(_draft.copyWith(darkMode: v)),
              ),
              _NumberRow(
                label: 'Window Width',
                description: 'Popup window width in pixels',
                value: _draft.windowWidth.round(),
                min: 400,
                max: 1200,
                onChanged: (v) => _update(_draft.copyWith(windowWidth: v.toDouble())),
              ),
              _NumberRow(
                label: 'Window Height',
                description: 'Popup window height in pixels',
                value: _draft.windowHeight.round(),
                min: 300,
                max: 900,
                onChanged: (v) => _update(_draft.copyWith(windowHeight: v.toDouble())),
              ),
            ],
          ),
          _Section(
            title: 'System',
            children: [
              _ToggleRow(
                label: 'Launch on Startup',
                description: 'Start WinPaste when Windows starts',
                value: _draft.launchOnStartup,
                onChanged: (v) => _update(_draft.copyWith(launchOnStartup: v)),
              ),
              _ToggleRow(
                label: 'Show Notifications',
                description: 'Display system notifications',
                value: _draft.showNotifications,
                onChanged: (v) => _update(_draft.copyWith(showNotifications: v)),
              ),
            ],
          ),
          _Section(
            title: 'About',
            children: [
              _AboutRow(),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryAccent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(
                      children: [
                        e.value,
                        if (e.key < children.length - 1)
                          const Divider(
                            height: 1,
                            color: AppColors.darkBorder,
                            indent: 16,
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String description;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryAccent,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                displayValue,
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppColors.primaryAccent,
            inactiveColor: AppColors.darkBorder,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NumberRow extends StatefulWidget {
  final String label;
  final String description;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberRow({
    required this.label,
    required this.description,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_NumberRow> createState() => _NumberRowState();
}

class _NumberRowState extends State<_NumberRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_NumberRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _ctrl.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.description,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: _ctrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: const InputDecoration(isDense: true),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n >= widget.min && n <= widget.max) {
                  widget.onChanged(n);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.content_paste, color: AppColors.primaryAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'WinPaste',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'v1.0.0',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Advanced clipboard manager for Windows',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.code, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              const Text(
                // TODO: update to the actual repository URL before shipping
                'https://github.com/MrBns/win-paste',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
