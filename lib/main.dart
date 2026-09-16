import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'services/audio_service.dart';
import 'theme/game_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell_screen.dart';
import 'widgets/fixed_phone_viewport.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MathQuestApp());
}

class MathQuestApp extends StatefulWidget {
  const MathQuestApp({super.key});

  @override
  State<MathQuestApp> createState() => _MathQuestAppState();
}

class _MathQuestAppState extends State<MathQuestApp> {
  @override
  void initState() {
    super.initState();
    AudioService().init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider.value(value: AudioService()),
      ],
      child: MaterialApp(
        title: 'Math Quest',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.themeData,
        builder: (context, child) =>
            FixedPhoneViewport(child: child ?? const SizedBox.shrink()),
        home: Consumer<GameProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Route to Onboarding if new player, else directly to Main Shell
            if (!provider.player.onboardingCompleted) {
              return const OnboardingScreen();
            }
            return const MainShellScreen();
          },
        ),
      ),
    );
  }
}
