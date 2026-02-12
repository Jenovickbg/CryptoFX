import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'login_screen.dart';

/// Première page : onboarding / accueil avec logo, titre, sous-titre et CTA.
/// Style inspiré d'une welcome screen moderne (fond sombre, dégradé, bouton).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0F08),
              AppColors.background,
              AppColors.background,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Logo en haut
                _LogoSection(),
                const Spacer(),
                // Titre
                const Text(
                  'Suivi financier international',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Convertissez devises et crypto en temps réel, '
                  'consultez les taux et définissez vos alertes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 48),
                // Bouton Commencer
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Commencer', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        height: 140,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _LogoFallback(),
      ),
    );
  }
}

/// Si le fichier logo.png est absent, on affiche le nom en style logo.
class _LogoFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'CryptoFx',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Collez logo.png dans assets/images/',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
