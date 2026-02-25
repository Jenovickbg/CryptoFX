import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../services/messaging_service.dart';
import '../screens/convert_screen.dart';
import '../screens/crypto_screen.dart';
import '../screens/home_screen.dart';
import '../screens/analytics_screen.dart';
import '../screens/settings_screen.dart';

/// Coque principale : bottom nav style Binance + FAB central orange (logo).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthController>().user?.uid;
      if (uid != null) MessagingService().saveTokenForUser(uid);
    });
  }

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Analytiques'),
    _NavItem(icon: Icons.add, activeIcon: Icons.add, label: 'Convertir'), // FAB
    _NavItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: 'Crypto'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Paramètres'),
  ];

  void _onTap(int index) {
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ConvertScreen()),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Si on n'est pas sur l'onglet Accueil, revenir à l'accueil
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }
        // Sinon, laisser le système gérer (fermer l'app / revenir à l'écran précédent)
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            AnalyticsScreen(),
            SizedBox.shrink(), // FAB n'a pas d'écran direct
            CryptoScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final item = _navItems[index];
                  final isCenter = index == 2;
                  final isSelected = _currentIndex == index && !isCenter;

                  if (isCenter) {
                    return _FABNavItem(
                      icon: item.activeIcon,
                      onTap: () => _onTap(index),
                    );
                  }

                  return InkWell(
                    onTap: () => _onTap(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? AppColors.primary : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _FABNavItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FABNavItem({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary,
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 28),
      ),
    );
  }
}
