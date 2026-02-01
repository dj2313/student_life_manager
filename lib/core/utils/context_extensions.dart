import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

extension ContextExtensions on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary =>
      isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  Color get textTertiary =>
      isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;

  Color get cardColor =>
      Theme.of(this).cardTheme.color ??
      (isDarkMode ? AppColors.cardDark : AppColors.cardLight);
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get dividerColor => Theme.of(this).dividerColor;

  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
}
