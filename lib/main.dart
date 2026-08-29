import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'theme/game_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MathQuestApp());
}

class MathQuestApp extends StatelessWidget {
  const MathQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: MaterialApp(
        title: 'Math Quest',
        debugShowCheckedModeBanner: false,
        theme: GameTheme.themeData,
        home: Consumer<GameProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Route to Onboarding if new player, else directly to Main Shell
            if (provider.player.questionsSolved == 0 &&
                provider.player.totalStars == 0) {
              return const OnboardingScreen();
            }
            return const MainShellScreen();
          },
        ),
      ),
    );
  }
}
