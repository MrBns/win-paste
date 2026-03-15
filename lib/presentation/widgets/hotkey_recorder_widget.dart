import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

class HotkeyRecorderWidget extends StatefulWidget {
  final String currentHotkey;
  final ValueChanged<String> onChange;

  const HotkeyRecorderWidget({
    super.key,
    required this.currentHotkey,
    required this.onChange,
  });

  @override
  State<HotkeyRecorderWidget> createState() => _HotkeyRecorderWidgetState();
}

class _HotkeyRecorderWidgetState extends State<HotkeyRecorderWidget> {
  bool _isRecording = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _focusNode.requestFocus();
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    _focusNode.unfocus();
  }

  String _formatHotkey(KeyEvent event) {
    final parts = <String>[];
    final data = HardwareKeyboard.instance;
    if (data.isControlPressed) parts.add('ctrl');
    if (data.isShiftPressed) parts.add('shift');
    if (data.isAltPressed) parts.add('alt');
    if (data.isMetaPressed) parts.add('meta');

    final key = event.logicalKey;
    final keyLabel = key.keyLabel.toLowerCase();
    if (keyLabel.isNotEmpty &&
        keyLabel != 'control' &&
        keyLabel != 'shift' &&
        keyLabel != 'alt' &&
        keyLabel != 'meta') {
      // Flutter key labels use spaces for multi-word keys (e.g. "Page Up").
      // We normalise to underscores so the string is a valid single token
      // for hotkey_manager parsing (e.g. "page_up").
      parts.add(keyLabel.replaceAll(' ', '_'));
    }

    return parts.join('+');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (!_isRecording) return;
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              _stopRecording();
              return;
            }
            final hotkey = _formatHotkey(event);
            if (hotkey.contains('+') && !hotkey.endsWith('+')) {
              widget.onChange(hotkey);
              _stopRecording();
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isRecording
                ? AppColors.primaryAccent.withOpacity(0.1)
                : AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isRecording
                  ? AppColors.primaryAccent
                  : AppColors.darkBorder,
              width: _isRecording ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isRecording ? Icons.fiber_manual_record : Icons.keyboard,
                size: 14,
                color: _isRecording
                    ? AppColors.primaryAccent
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording
                    ? 'Press hotkey combination…'
                    : widget.currentHotkey,
                style: TextStyle(
                  color: _isRecording
                      ? AppColors.primaryAccent
                      : AppColors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              if (_isRecording) ...[
                const SizedBox(width: 8),
                const Text(
                  'Esc to cancel',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
