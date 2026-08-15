import 'package:flutter/material.dart';

class AppColors {
  // ── Base Canvas (Deep Clean Midnight Dark) ───────────────────
  static const Color charcoal      = Color(0xFF0D0D11);
  static const Color charcoalMid   = Color(0xFF16161C);
  static const Color charcoalLight = Color(0xFF202028);
  static const Color charcoalBright= Color(0xFF2C2C36);
  static const Color surface       = Color(0xFF1A1A22);
  static const Color surfaceLight  = Color(0xFF242430);

  // ── Saffron (Vibrant Primary — Angad's Energy) ───────────────
  static const Color saffron       = Color(0xFFFF9036);
  static const Color saffronLight  = Color(0xFFFFAB66);
  static const Color saffronDim    = Color(0x28FF9036);
  static const Color saffronGlow   = Color(0x40FF9036);

  // ── Gold (Secondary Accent) ───────────────────────────────────
  static const Color gold          = Color(0xFFC9A84C);
  static const Color goldLight     = Color(0xFFE8C96A);
  static const Color goldDim       = Color(0xFF2C2000);
  static const Color goldGlow      = Color(0x44C9A84C);

  // ── Threat Red (muted, not neon) ─────────────────────────────
  static const Color threatRed     = Color(0xFFC0392B);
  static const Color threatRedDim  = Color(0xFF3B0A0A);
  static const Color threatRedGlow = Color(0x40C0392B);

  // ── Safe Green (natural) ──────────────────────────────────────
  static const Color safeGreen     = Color(0xFF27AE60);
  static const Color safeGreenDim  = Color(0xFF0A2E18);
  static const Color safeGreenGlow = Color(0x4027AE60);

  // ── Info Blue (muted) ─────────────────────────────────────────
  static const Color infoBlue      = Color(0xFF2980B9);
  static const Color infoBlueDim   = Color(0xFF0A1E2E);

  // ── Warning Amber ─────────────────────────────────────────────
  static const Color amber         = Color(0xFFE67E22);
  static const Color amberDim      = Color(0xFF2E1A00);

  // ── Text (High Contrast & Clear Readability) ────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFE2E4E9);
  static const Color textMuted     = Color(0xFFA6ABB6);
  static const Color textHint      = Color(0xFF767B88);

  // ── Borders / Dividers ────────────────────────────────────────
  static const Color border        = Color(0xFF272732);
  static const Color borderAccent  = Color(0xFF3B3B4A);
  static const Color overlayDark   = Color(0xEE0D0D11);

  // ── Category Colors (for threat type) ────────────────────────
  static const Color safe          = safeGreen;
  static const Color phishing      = threatRed;
  static const Color malware       = Color(0xFFE74C3C);
  static const Color dataLeak      = amber;
  static const Color scam          = Color(0xFF8E44AD);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient saffronGradient = LinearGradient(
    colors: [saffronLight, saffron],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient threatGradient = LinearGradient(
    colors: [threatRed, Color(0xFF922B21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [charcoal, charcoalMid],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Legacy aliases (for backward compatibility during refactor) ─
  static const Color obsidian      = charcoal;
  static const Color obsidianMid   = charcoalMid;
  static const Color neonGreen     = safeGreen;
  static const Color neonGreenMid  = safeGreen;
  static const Color neonGreenDim  = safeGreenDim;
  static const Color neonGreenGlow = safeGreenGlow;
  static const Color cyberBlue     = infoBlue;
  static const Color cyberBlueDim  = infoBlueDim;
  static const Color cyberBlueGlow = Color(0x402980B9);
  static const Color glassBorder   = border;
  static const Color glassWhite    = Color(0x0DFFFFFF);
  static const Color cryptoPurple  = Color(0xFF8E44AD);
  static const Color cryptoPurpleDim = Color(0xFF1E0A2E);
}
