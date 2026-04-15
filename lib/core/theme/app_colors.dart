import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color background = Color(0xFF0A0E27);
  static const Color surface = Color(0xFF131837);
  static const Color surfaceLight = Color(0xFF1C2147);
  static const Color card = Color(0xFF171D3A);

  // Accent colors
  static const Color primary = Color(0xFF667EEA);
  static const Color primaryLight = Color(0xFF7F95F7);
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentGlow = Color(0x3300D2FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF667EEA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1C2147), Color(0xFF131837)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreHighGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00C853)],
  );

  static const LinearGradient scoreMedGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
  );

  static const LinearGradient scoreLowGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFE53935)],
  );

  // Semantic colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textMuted = Color(0xFF6B7394);

  // Border
  static const Color border = Color(0xFF2A3055);
  static const Color borderLight = Color(0xFF3A4175);

  // Tag colors
  static const Color tagRemote = Color(0xFF00E676);
  static const Color tagFresher = Color(0xFF29B6F6);
  static const Color tagFullTime = Color(0xFFCE93D8);
  static const Color tagPartTime = Color(0xFFFFB74D);

  // Glass effect
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);
}
