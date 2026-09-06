import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/colors.dart';

class MusicToggleButton extends StatelessWidget {
  final bool showLabel;
  final Color? color;

  const MusicToggleButton({
    super.key,
    this.showLabel = false,
    this.color,
  });

  void _showVolumeSliderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GameColors.skyBlueDark.withValues(alpha: 0.3), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: GameColors.skyBlueDark.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Consumer<AudioService>(
              builder: (context, audioService, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row with Glossy Icon Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Glossy Circle Badge (Sky Blue / Cyan Theme)
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: GameColors.skyGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: GameColors.skyBlueDark,
                                    offset: Offset(0, 2.5),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  audioService.isMusicEnabled
                                      ? Icons.volume_up_rounded
                                      : Icons.volume_off_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Volume Adjuster',
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
                          icon: const Icon(Icons.close_rounded, size: 22, color: GameColors.navyTextSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Music Toggle Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          audioService.isMusicEnabled
                              ? 'Soft Piano: ON 🎵'
                              : 'Soft Piano: MUTED 🔇',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 14,
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

                    const SizedBox(height: 10),

                    // Glossy Volume Slider Bar (Sky Blue Theme)
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
                              trackHeight: 6,
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
                            boxShadow: const [
                              BoxShadow(
                                color: GameColors.skyBlueDark,
                                offset: Offset(0, 1.5),
                                blurRadius: 1,
                              ),
                            ],
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
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, child) {
        final isPlaying = audioService.isMusicEnabled && audioService.isPlaying;

        return Tooltip(
          message: 'Tap to Adjust Volume',
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isPlaying
                  ? GameColors.skyGradient
                  : const LinearGradient(
                      colors: [Color(0xFF94A3B8), Color(0xFF64748B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              boxShadow: [
                BoxShadow(
                  color: isPlaying
                      ? GameColors.skyBlueDark
                      : const Color(0xFF334155),
                  offset: const Offset(0, 3),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _showVolumeSliderDialog(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      // Top Glossy Glass Highlight Effect
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 14,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.45),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                isPlaying
                                    ? Icons.music_note_rounded
                                    : Icons.music_off_rounded,
                                key: ValueKey<bool>(isPlaying),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            if (showLabel) ...[
                              const SizedBox(width: 5),
                              Text(
                                isPlaying ? 'Volume' : 'Muted',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
