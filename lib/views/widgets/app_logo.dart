import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Logo CryptoFx (asset ou texte de secours).
class AppLogo extends StatelessWidget {
  final double height;
  final bool showFallbackHint;

  const AppLogo({
    super.key,
    this.height = 100,
    this.showFallbackHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _Fallback(showHint: showFallbackHint),
    );
  }
}

class _Fallback extends StatelessWidget {
  final bool showHint;

  const _Fallback({this.showHint = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'CryptoFx',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        if (showHint)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'assets/images/logo.png',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Petit logo pour l'AppBar (icône).
class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.currency_exchange,
        size: size,
        color: AppColors.primary,
      ),
    );
  }
}
