import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controllers/alerts_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/chart_controller.dart';
import 'controllers/rates_controller.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'services/messaging_service.dart';
import 'views/screens/welcome_screen.dart';
import 'views/widgets/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MessagingService.initBackground();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  runApp(const CryptoFxApp());
}

class CryptoFxApp extends StatelessWidget {
  const CryptoFxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => RatesController()..loadRates()),
        ChangeNotifierProvider(create: (_) => AlertsController()),
        ChangeNotifierProvider(create: (_) => ChartController()),
      ],
      child: MaterialApp(
        title: 'CryptoFx',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: Consumer<AuthController>(
          builder: (context, auth, _) {
            if (auth.isLoggedIn) return const MainShell();
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
