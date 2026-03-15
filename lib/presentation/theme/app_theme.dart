import 'package:flutter/material.dart';
import 'package:win_paste/presentation/theme/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryAccent,
          surface: AppColors.darkSurface,
          error: AppColors.errorRed,
          onPrimary: AppColors.darkBackground,
          onSurface: AppColors.textPrimary,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
          ),
          hintStyle: TextStyle(color: AppColors.textMuted),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodySmall: TextStyle(color: AppColors.textMuted),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        dividerColor: AppColors.darkBorder,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.darkSurfaceVariant,
          labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          side: BorderSide(color: AppColors.darkBorder),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        scrollbarTheme: const ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(AppColors.darkBorder),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryAccent,
          surface: AppColors.lightSurface,
          error: AppColors.errorRed,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            side: BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.lightBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.lightBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.lightSurfaceVariant,
          labelStyle: TextStyle(color: Colors.black87, fontSize: 12),
          side: BorderSide(color: AppColors.lightBorder),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );

  static BoxDecoration cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    );
  }
}
