import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O sqflite só funciona em Android, iOS e macOS. No Windows e Linux usa-se
  // o mesmo SQLite através do sqflite_common_ffi.
  if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    await NotificationService.instance.init();
  } catch (e) {
    // A app funciona sem notificações; apenas regista o erro.
    debugPrint('Notificações indisponíveis: $e');
  }

  final loggedIn = await AuthService().isLoggedIn();
  runApp(PetCareApp(isLoggedIn: loggedIn));
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare 360',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('pt', 'PT'),
      supportedLocales: const [Locale('pt', 'PT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}
