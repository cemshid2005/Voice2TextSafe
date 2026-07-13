import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/transcription_provider.dart';
import 'screens/splash_screen.dart';
import 'services/share_intent_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Best-effort cleanup of any cached audio left behind by a previous,
  // abnormally terminated session. Nothing here is ever sent anywhere.
  ShareIntentService.clearCache();
  runApp(const Voice2TextSafeApp());
}

class Voice2TextSafeApp extends StatelessWidget {
  const Voice2TextSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => TranscriptionProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Voice2TextSafe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
