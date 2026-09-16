import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/level_cheat_codes.dart';
import '../models/level_model.dart';
import '../providers/game_provider.dart';
import '../screens/gameplay_screen.dart';
import '../theme/colors.dart';

class CheatCodeAccessButton extends StatelessWidget {
  const CheatCodeAccessButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!LevelCheatCodes.isEnabled) return const SizedBox.shrink();

    return FloatingActionButton.small(
      key: const ValueKey('cheat-code-access-button'),
      heroTag: null,
      tooltip: 'Open test-level cheat console',
      backgroundColor: const Color(0xFF312E81),
      foregroundColor: Colors.white,
      onPressed: () => _openConsole(context),
      child: const Icon(Icons.science_rounded),
    );
  }

  Future<void> _openConsole(BuildContext context) async {
    final provider = context.read<GameProvider>();
    final target = await showDialog<LevelModel>(
      context: context,
      builder: (dialogContext) => _CheatCodeDialog(worldsProvider: provider),
    );
    if (target == null || !context.mounted) return;

    provider.startTestLevel(target);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameplayScreen()),
    );
    if (provider.isTestMode && !provider.isLevelCompleted) {
      provider.endTestSession();
    }
  }
}

class _CheatCodeDialog extends StatefulWidget {
  final GameProvider worldsProvider;

  const _CheatCodeDialog({required this.worldsProvider});

  @override
  State<_CheatCodeDialog> createState() => _CheatCodeDialogState();
}

class _CheatCodeDialogState extends State<_CheatCodeDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _activate() {
    final level = LevelCheatCodes.resolveLevel(
      _controller.text,
      widget.worldsProvider.worlds,
    );
    if (level == null) {
      setState(() => _errorText = 'Invalid cheat code');
      return;
    }
    Navigator.pop(context, level);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: const ValueKey('cheat-code-dialog'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: GameColors.surfaceWarm,
      title: const Row(
        children: [
          Icon(Icons.science_rounded, color: Color(0xFF4338CA)),
          SizedBox(width: 8),
          Text(
            'TEST LEVEL',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.bold,
              color: GameColors.navyText,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter a level cheat code. This opens an isolated test session—your progress, rewards, and unlocks will not be saved.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: GameColors.navyTextSecondary,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            key: const ValueKey('cheat-code-input'),
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            enableSuggestions: false,
            onSubmitted: (_) => _activate(),
            decoration: InputDecoration(
              labelText: 'Cheat code',
              hintText: 'MQ-LVL-06',
              errorText: _errorText,
              prefixIcon: const Icon(Icons.key_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton.icon(
          key: const ValueKey('activate-cheat-code'),
          onPressed: _activate,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('START TEST'),
        ),
      ],
    );
  }
}
