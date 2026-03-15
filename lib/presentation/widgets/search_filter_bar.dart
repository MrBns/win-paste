import 'dart:async';

import 'package:flutter/material.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

class SearchFilterBar extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final FocusNode? focusNode;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    this.focusNode,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: _onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search clipboard…',
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.textMuted,
          size: 18,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                color: AppColors.textMuted,
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
        isDense: true,
      ),
    );
  }
}
