import 'package:flutter/material.dart';

class AppColors {
  static const Color summerCampBlue = Color(0xFF2364AA);
  static const Color californiaBlue = Color(0xFF3DA5D9);
  static const Color greenSheen = Color(0xFF73BFB8);
  static const Color mikadoYellow = Color(0xFFFEC601);
  static const Color nectarine = Color(0xFFEA7317);
  static const Color white = Color(0xFFE5E7EB);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFF44336);
  static const Color darkIndigoBlue = Color(0xFF111184);
  static const Color transparent = Color(0x00000000);

  static const Color dayLabel = Color(0xFF4B5563);
  static const Color blockedBg = Color(0x1FF87171);
  static const Color blockedBorder = Color(0x4DF87171);
  static const Color availableBg = Color(0xFF1E2330);
  static const Color legendText = Color(0xFF474747);

  // Navbar
  static const Color summerCampBlueLight = Color(0xFF5B8FC7);

  // Status — Today's Tasks backgrounds
  static const Color completed  = Color(0xFF1A3A2A);
  static const Color inProgress = Color(0xFF3A2800);
  static const Color dueSoon    = Color(0xFF3A1A1A);
  static const Color toDo       = Color(0xFF1A2A3A);

  // Subject Progress Card Colors
  static const Color greenSheenDark   = Color(0xFF4A9E96);
  static const Color mikadoYellowDark = Color(0xFFD4A200);
  static const Color redDark          = Color(0xFFBF2020);

  static const Color softPurple = Color(0xFFB57BEE);
  static const Color skyCyan    = Color(0xFF56CFE1);
  static const Color pink       = Color(0xFFFF6B9D);
  static const Color lime       = Color(0xFF95D44A);

  // Burnout Bg
  static const darkNavyBlue = Color(0xFF16213E);
  // Glass style

  static const double glassOpacity            = 0.12;
  static const double glassIconOpacity        = 0.15;
  static const double glassBorderOpacity      = 0.20;
  static const double glassBorderRadius       = 20.0;
  static const double glassBadgeOpacity       = 0.20;
  static const double glassDividerOpacity     = 0.15;
  static const double glassTileOpacity        = 0.10;
  static const double glassTileBorderOpacity  = 0.15;
  static const double glassTileBorderRadius   = 14.0;
  static const double glassIconBorderRadius   = 10.0;
  static const double glassBadgeBorderRadius  = 20.0;

  // Outer card — used for main section containers
  static BoxDecoration glassCard({double? borderRadius}) => BoxDecoration(
    color: Colors.white.withValues(alpha: glassOpacity),
    borderRadius: BorderRadius.circular(borderRadius ?? glassBorderRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: glassBorderOpacity),
    ),
  );

  // Icon background pill
  static BoxDecoration glassIcon() => BoxDecoration(
    color: Colors.white.withValues(alpha: glassIconOpacity),
    borderRadius: BorderRadius.circular(glassIconBorderRadius),
  );

  // Small label/count badge
  static BoxDecoration glassBadge() => BoxDecoration(
    color: Colors.white.withValues(alpha: glassBadgeOpacity),
    borderRadius: BorderRadius.circular(glassBadgeBorderRadius),
  );

  // Inner tile — used for list items inside a glass card
  static BoxDecoration glassTile({double? borderRadius}) => BoxDecoration(
    color: Colors.white.withValues(alpha: glassTileOpacity),
    borderRadius: BorderRadius.circular(borderRadius ?? glassTileBorderRadius),
    border: Border.all(
      color: Colors.white.withValues(alpha: glassTileBorderOpacity),
    ),
  );

  // Divider / separator line color
  static Color get glassDivider =>
      Colors.white.withValues(alpha: glassDividerOpacity);
}