import 'package:flutter/material.dart';

/// 应用颜色常量
/// 基于安全岛视觉风格：安静、稳定、治愈
class AppColors {
  AppColors._();

  // 主背景色（深海蓝）
  static const Color background = Color(0xFF0A2342);

  // 表面色（浅蓝灰）
  static const Color surface = Color(0xFF1A3A5F);

  // 主色（希望青）
  static const Color primary = Color(0xFF4ECDC4);

  // 强调色（柔和白）
  static const Color accent = Color(0xFFF8F9FA);

  // 危机色（柔和红）
  static const Color error = Color(0xFFE74C3C);

  // 文本颜色
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFB0B8C4);

  // 透明度变体
  static Color primaryWithOpacity(double opacity) =>
      primary.withOpacity(opacity);

  static Color surfaceWithOpacity(double opacity) =>
      surface.withOpacity(opacity);

  static Color backgroundWithOpacity(double opacity) =>
      background.withOpacity(opacity);
}
