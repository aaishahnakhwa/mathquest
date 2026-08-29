import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/avatar_widget.dart';
import 'main_shell_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  final _nameController = TextEditingController(text: 'Math Hero');
  String _selectedAvatarId = 'hero_wizard';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      final provider = Provider.of<GameProvider>(context, listen: false);
      provider.updatePlayerAvatar(
        name: _nameController.text.trim().isEmpty
            ? 'Math Hero'
            : _nameController.text.trim(),
        avatarId: _selectedAvatarId,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainShellScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header Title Banner
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 8),
                  Text(
                    'MATH QUEST',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: GameColors.skyBlueDark,
                      shadows: [
                        Shadow(
                          color: GameColors.navyText.withOpacity(0.15),
                          offset: const Offset(0, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Text(
                'LEARN • PLAY • LEVEL UP',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GameColors.yellowDark,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 30),

              // Step Content Area
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(),
                ),
              ),

              // Bottom Navigation Action
              const SizedBox(height: 20),
              GameButton(
                text: _step == 2 ? 'ENTER MATH QUEST!' : 'CONTINUE',
                backgroundColor: GameColors.sunnyYellow,
                shadowColor: GameColors.yellowDark,
                textColor: GameColors.navyText,
                onPressed: _nextStep,
                height: 58,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.surfaceWarm,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: GameColors.skyBlue, width: 3),
              ),
              child: Column(
                children: [
                  const Text('🦉', style: TextStyle(fontSize: 70)),
                  const SizedBox(height: 12),
                  const Text(
                    'WELCOME EXPLORER!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Step into a world where mathematics gives you magic powers to conquer levels, collect treasures, and level up!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GameColors.navyTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CHOOSE YOUR HERO',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
            const SizedBox(height: 12),

            // Large Hero Portrait Showcase Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFFD97706),
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AvatarWidget(
                    avatarId: _selectedAvatarId,
                    size: 110,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _nameController.text.isEmpty ? 'Math Hero' : _nameController.text,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Enter Hero Name',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                      color: GameColors.skyBlue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarChoice('hero_wizard', 'Wizard 🧙‍♂️'),
                _buildAvatarChoice('hero_boy', 'Knight 👦'),
                _buildAvatarChoice('hero_girl', 'Ranger 👧'),
              ],
            ),
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.freshGreenLight,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: GameColors.freshGreen, width: 3),
              ),
              child: Column(
                children: [
                  const Text('🎁', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 12),
                  const Text(
                    'STARTER GIFT CLAIMED!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: GameColors.freshGreenDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('💰 +150 Coins  ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('💎 +15 Gems', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your adventure map in Sunny Meadows awaits!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: GameColors.navyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAvatarChoice(String id, String label) {
    final isSelected = _selectedAvatarId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatarId = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? GameColors.skyBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? GameColors.skyBlue : GameColors.cardBorder,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GameColors.skyBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            AvatarWidget(
              avatarId: id,
              size: 64,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? GameColors.skyBlueDark : GameColors.navyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
