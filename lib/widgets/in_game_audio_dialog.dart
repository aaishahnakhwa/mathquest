import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/colors.dart';

class InGameAudioDialog extends StatelessWidget {
  const InGameAudioDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const InGameAudioDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: GameColors.skyBlueDark.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: GameColors.skyBlueDark.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Consumer<AudioService>(
        builder: (context, audioService, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: GameColors.skyGradient,
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.skyBlueDark,
                              offset: Offset(0, 2),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Soft Piano Volume',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameColors.navyText,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    audioService.isMusicEnabled ? 'Music: ON 🎵' : 'Music: MUTED 🔇',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: audioService.isMusicEnabled
                          ? GameColors.skyBlueDark
                          : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: audioService.isMusicEnabled,
                    activeThumbColor: GameColors.skyBlueDark,
                    activeTrackColor: GameColors.skyBlue.withValues(alpha: 0.3),
                    onChanged: (val) => audioService.toggleMusic(),
                  ),
                ],
              ),

              if (audioService.isMusicEnabled) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.volume_down_rounded,
                        size: 20, color: Colors.grey),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: GameColors.skyBlueDark,
                          inactiveTrackColor: GameColors.skyBlue.withValues(alpha: 0.2),
                          thumbColor: GameColors.skyBlueDark,
                          overlayColor: GameColors.skyBlue.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: audioService.musicVolume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (val) => audioService.setMusicVolume(val),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: GameColors.skyGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(audioService.musicVolume * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
