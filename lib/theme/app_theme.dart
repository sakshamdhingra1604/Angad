import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // ── Dark Theme (Default) ──────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.charcoal,
      colorScheme: const ColorScheme.dark(
        primary:     AppColors.saffron,
        secondary:   AppColors.gold,
        surface:     AppColors.charcoalMid,
        error:       AppColors.threatRed,
        onPrimary:   Colors.white,
        onSecondary: Colors.white,
        onSurface:   AppColors.textPrimary,
      ),

      // ── Typography ──────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
        displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted),
        bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.6),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.5),
        labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        labelMedium:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5),
        labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textHint, letterSpacing: 1.0),
      )),

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.charcoal,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.textMuted),
        centerTitle: false,
      ),

      // ── ElevatedButton ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.saffron,
          side: const BorderSide(color: AppColors.saffron, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── TextField ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.charcoalLight,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── Switch ───────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.saffron : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.saffronDim : AppColors.charcoalLight),
      ),

      // ── Slider ───────────────────────────────────────────────
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.saffron,
        thumbColor: AppColors.saffron,
        overlayColor: AppColors.saffronGlow,
        inactiveTrackColor: AppColors.charcoalLight,
      ),

      // ── BottomSheet ──────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.charcoalMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoalLight,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Light Theme ───────────────────────────────────────────────
  static ThemeData get light {
    const lightBg       = Color(0xFFF7F8FC);
    const lightCard     = Color(0xFFFFFFFF);
    const lightCardAlt  = Color(0xFFEEF0F6);
    const lightBorder   = Color(0xFFE2E6EE);
    const lightTextPrim = Color(0xFF101828);
    const lightTextSec  = Color(0xFF475467);
    const lightTextMute = Color(0xFF667085);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary:     AppColors.saffron,
        secondary:   AppColors.gold,
        surface:     lightCard,
        error:       AppColors.threatRed,
        onPrimary:   Colors.white,
        onSecondary: Colors.white,
        onSurface:   lightTextPrim,
      ),

      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge:  TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: lightTextPrim, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: lightTextPrim, letterSpacing: -0.3),
        displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: lightTextPrim),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: lightTextPrim),
        headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: lightTextPrim),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: lightTextPrim),
        titleLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: lightTextPrim),
        titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: lightTextSec),
        titleSmall:    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: lightTextMute),
        bodyLarge:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: lightTextSec, height: 1.6),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lightTextSec, height: 1.5),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: lightTextMute, height: 1.5),
        labelLarge:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: lightTextPrim),
        labelMedium:   TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: lightTextMute, letterSpacing: 0.5),
        labelSmall:    TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: lightTextMute, letterSpacing: 1.0),
      )),

      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightTextPrim,
        ),
        iconTheme: const IconThemeData(color: lightTextPrim),
        actionsIconTheme: const IconThemeData(color: lightTextMute),
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.saffron,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.saffron,
          side: const BorderSide(color: AppColors.saffron, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        hintStyle: const TextStyle(color: lightTextMute, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.saffron : lightTextMute),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.saffronLight.withValues(alpha: 0.4) : lightCardAlt),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightCardAlt,
        contentTextStyle: const TextStyle(color: lightTextPrim),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Glassmorphic Card Decoration ────────────────────────────
  static BoxDecoration glassDecoration({Color? borderColor, double radius = 16}) {
    return BoxDecoration(
      color: AppColors.charcoalMid,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
    );
  }

  static BoxDecoration accentCardDecoration(Color accent, {double radius = 16}) {
    return BoxDecoration(
      color: AppColors.charcoalMid,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.3)),
    );
  }
}
