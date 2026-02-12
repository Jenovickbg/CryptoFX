import 'package:flutter/material.dart';

/// Palette inspirée du logo CryptoFx : orange vif + fond sombre.
/// Style type Binance : thème sombre, accents nets.
class AppColors {
  AppColors._();

  // ——— Logo : orange vif (Crypto) ———
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8F5C);
  static const Color primaryDark = Color(0xFFE55A2B);

  // ——— Fonds (style Binance) ———
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color card = Color(0xFF242424);
  static const Color cardElevated = Color(0xFF2E2E2E);

  // ——— Texte ———
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  // ——— Marché (convention financière) ———
  static const Color up = Color(0xFF22C55E);
  static const Color down = Color(0xFFEF4444);

  // ——— Utilitaires ———
  static const Color divider = Color(0xFF333333);
  static const Color border = Color(0xFF3D3D3D);
}
