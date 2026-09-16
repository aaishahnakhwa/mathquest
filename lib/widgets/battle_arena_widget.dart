import 'package:flutter/material.dart';

import '../models/player_model.dart';
import '../models/monster_model.dart';
import '../theme/colors.dart';
import 'avatar_widget.dart';

class BattleArenaWidget extends StatefulWidget {
  static const double worldTwoArenaHeight = 190;
  static const double worldTwoMonsterHeight = 130;
  static const double worldThreeArenaHeight = 190;
  static const double worldThreeMonsterHeight = 130;
  static const mathExplorerStandingAsset = 'assets/images/wizard.png';
  static const mathExplorerAttackAsset = 'assets/images/wizard_attack.png';
  static const mathExplorerHurtAsset = 'assets/images/wizard_hurt.png';
  static const femaleWizardStandingAsset = 'assets/images/female_wizard.png';
  static const femaleWizardAttackAsset =
      'assets/images/female_wizard_attack.png';
  static const femaleWizardHurtAsset = 'assets/images/female_wizard_hurt.png';
  static const meadowBackgroundAsset = 'assets/images/battle_bg_meadow.jpg';
  static const worldTwoBackgroundAsset = 'assets/images/battle_bg_snowy.png';
  static const worldThreeBackgroundAsset =
      'assets/images/battle_bg_puzzle_peak.png';
  static const worldTwoMonsterStandingAsset =
      'assets/images/world_2_veyr_standing.png';
  static const worldTwoMonsterAttackAsset =
      'assets/images/world_2_veyr_attack.png';
  static const worldTwoMonsterHurtAsset = 'assets/images/world_2_veyr_hurt.png';
  static const worldTwoMonsterProjectileAsset =
      'assets/images/world_2_veyr_ice_projectile.png';
  static const worldThreeMonsterStandingAsset =
      'assets/images/world_3_zarek_standing.png';
  static const worldThreeMonsterAttackAsset =
      'assets/images/world_3_zarek_attack.png';
  static const worldThreeMonsterHurtAsset =
      'assets/images/world_3_zarek_hurt.png';
  static const worldThreeMonsterProjectileAsset =
      'assets/images/world_3_zarek_crimson_beam.png';

  static String backgroundAssetForWorld(String worldId) {
    if (worldId == 'world_3') return worldThreeBackgroundAsset;
    return worldId == 'world_2'
        ? worldTwoBackgroundAsset
        : meadowBackgroundAsset;
  }

  static String monsterAssetForState({
    required String worldId,
    required bool isSubmitted,
    required bool isCorrect,
    required double impactProgress,
    required int hitCount,
  }) {
    if (worldId == 'world_3') {
      if (!isSubmitted || (isCorrect && impactProgress <= 0)) {
        return worldThreeMonsterStandingAsset;
      }
      return isCorrect
          ? worldThreeMonsterHurtAsset
          : worldThreeMonsterAttackAsset;
    }

    if (worldId == 'world_2') {
      if (!isSubmitted || (isCorrect && impactProgress <= 0)) {
        return worldTwoMonsterStandingAsset;
      }
      return isCorrect ? worldTwoMonsterHurtAsset : worldTwoMonsterAttackAsset;
    }

    if (!isSubmitted) return 'assets/images/meadow_monster.png';
    if (!isCorrect) return 'assets/images/meadow_monster_attack.png';
    if (impactProgress <= 0) return 'assets/images/meadow_monster.png';
    return hitCount >= 2
        ? 'assets/images/meadow_monster_defeated.png'
        : 'assets/images/meadow_monster_hit.png';
  }

  static String monsterProjectileAssetForWorld(String worldId) {
    if (worldId == 'world_3') return worldThreeMonsterProjectileAsset;
    return worldId == 'world_2'
        ? worldTwoMonsterProjectileAsset
        : 'assets/images/monster_attack_effect.png';
  }

  static String? playerAssetForState({
    required String worldId,
    required String avatarId,
    required bool isSubmitted,
    required bool isCorrect,
  }) {
    final isFemaleWizard = AvatarWidget.isFemaleWizard(avatarId);
    final usesIllustratedHero =
        isFemaleWizard ||
        avatarId == AvatarWidget.maleWizardId ||
        (avatarId == 'owl_guide' && worldId == 'world_3');
    if (!usesIllustratedHero) return null;

    if (isFemaleWizard) {
      if (!isSubmitted) return femaleWizardStandingAsset;
      return isCorrect ? femaleWizardAttackAsset : femaleWizardHurtAsset;
    }

    if (!isSubmitted) return mathExplorerStandingAsset;
    return isCorrect ? mathExplorerAttackAsset : mathExplorerHurtAsset;
  }

  final String worldId;
  final PlayerModel player;
  final MonsterModel monster;
  final bool isSubmitted;
  final bool isCorrect;
  final int heartsLeft;
  final int hitCount;
  final int totalQuestions;

  const BattleArenaWidget({
    super.key,
    this.worldId = 'world_1',
    required this.player,
    required this.monster,
    required this.isSubmitted,
    required this.isCorrect,
    this.heartsLeft = 3,
    this.hitCount = 0,
    this.totalQuestions = 5,
  });

  @override
  State<BattleArenaWidget> createState() => _BattleArenaWidgetState();
}

class _BattleArenaWidgetState extends State<BattleArenaWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _attackController;

  @override
  void initState() {
    super.initState();
    _attackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all battle image assets to eliminate first-attack visual stutter/flicker
    precacheImage(
      const AssetImage(BattleArenaWidget.mathExplorerStandingAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.mathExplorerAttackAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.mathExplorerHurtAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.femaleWizardStandingAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.femaleWizardAttackAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.femaleWizardHurtAsset),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/meadow_monster.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/meadow_monster_attack.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/meadow_monster_hit.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/meadow_monster_hurt.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/meadow_monster_defeated.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/magic_attack_effect.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/images/monster_attack_effect.png'),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldTwoMonsterStandingAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldTwoMonsterAttackAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldTwoMonsterHurtAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldTwoMonsterProjectileAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldThreeMonsterStandingAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldThreeMonsterAttackAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldThreeMonsterHurtAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldThreeMonsterProjectileAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.meadowBackgroundAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldTwoBackgroundAsset),
      context,
    );
    precacheImage(
      const AssetImage(BattleArenaWidget.worldThreeBackgroundAsset),
      context,
    );
  }

  @override
  void didUpdateWidget(covariant BattleArenaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSubmitted && !oldWidget.isSubmitted) {
      _attackController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _attackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalQ = widget.totalQuestions > 0 ? widget.totalQuestions : 5;
    final double monsterHpRatio = (1.0 - (widget.hitCount / totalQ)).clamp(
      0.0,
      1.0,
    );

    final playerBattleAsset = BattleArenaWidget.playerAssetForState(
      worldId: widget.worldId,
      avatarId: widget.player.avatarId,
      isSubmitted: widget.isSubmitted,
      isCorrect: widget.isCorrect,
    );

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: switch (widget.worldId) {
          'world_2' => BattleArenaWidget.worldTwoArenaHeight,
          'world_3' => BattleArenaWidget.worldThreeArenaHeight,
          _ => 155,
        },
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0284C7), width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            children: [
              // World-specific battleground image
              Positioned.fill(
                child: Image.asset(
                  BattleArenaWidget.backgroundAssetForWorld(widget.worldId),
                  key: ValueKey('battle-background-${widget.worldId}'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final totalWidth = constraints.maxWidth;

                    return AnimatedBuilder(
                      animation: _attackController,
                      builder: (context, child) {
                        final attackProgress = _attackController.value;
                        final double impactProgress = attackProgress > 0.6
                            ? ((attackProgress - 0.6) / 0.4)
                                  .clamp(0.0, 1.0)
                                  .toDouble()
                            : 0.0;
                        final monsterAsset =
                            BattleArenaWidget.monsterAssetForState(
                              worldId: widget.worldId,
                              isSubmitted: widget.isSubmitted,
                              isCorrect: widget.isCorrect,
                              impactProgress: impactProgress,
                              hitCount: widget.hitCount,
                            );
                        final isWorldTwo = widget.worldId == 'world_2';
                        final isWorldThree = widget.worldId == 'world_3';

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Top HP Boxes (Left Player Hero HP & Right Monster HP)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Player Hero HP Box
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 110,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E3A8A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFF3B82F6),
                                            width: 1.5,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              widget.player.name,
                                              style: const TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Stack(
                                                alignment: Alignment.centerLeft,
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: double.infinity,
                                                    color: const Color(
                                                      0xFF0F172A,
                                                    ),
                                                  ),
                                                  AnimatedFractionallySizedBox(
                                                    duration: const Duration(
                                                      milliseconds: 400,
                                                    ),
                                                    widthFactor:
                                                        (widget.heartsLeft / 3)
                                                            .clamp(0.0, 1.0),
                                                    child: Container(
                                                      height: 12,
                                                      decoration:
                                                          const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF4ADE80,
                                                                    ),
                                                                    Color(
                                                                      0xFF16A34A,
                                                                    ),
                                                                  ],
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '${((widget.heartsLeft / 3) * 100).round().clamp(0, 100)}/100',
                                                      style: const TextStyle(
                                                        fontFamily: 'Fredoka',
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Right Monster HP Box
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 110,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF991B1B),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFEF4444),
                                            width: 1.5,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              widget.monster.name,
                                              style: const TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Stack(
                                                alignment: Alignment.centerLeft,
                                                children: [
                                                  Container(
                                                    height: 12,
                                                    width: double.infinity,
                                                    color: const Color(
                                                      0xFF0F172A,
                                                    ),
                                                  ),
                                                  AnimatedFractionallySizedBox(
                                                    duration: const Duration(
                                                      milliseconds: 400,
                                                    ),
                                                    widthFactor: monsterHpRatio,
                                                    child: Container(
                                                      height: 12,
                                                      decoration:
                                                          const BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFFEF4444,
                                                                    ),
                                                                    Color(
                                                                      0xFFDC2626,
                                                                    ),
                                                                  ],
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      '${(monsterHpRatio * 100).round().clamp(0, 100)}/100',
                                                      style: const TextStyle(
                                                        fontFamily: 'Fredoka',
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // HERO ADVENTURER (LEFT FLANK - PLAYER WIZARD HERO)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: 85,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: playerBattleAsset != null
                                            ? AnimatedSwitcher(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                child: Image.asset(
                                                  playerBattleAsset,
                                                  key: ValueKey<String>(
                                                    playerBattleAsset,
                                                  ),
                                                  height: 85,
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            : AvatarWidget(
                                                avatarId:
                                                    widget.player.avatarId,
                                                equippedHatId:
                                                    widget.player.equippedHatId,
                                                size: 60,
                                              ),
                                      ),
                                    ),
                                    // Grassy Battle Mound Base
                                    Container(
                                      width: 68,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.elliptical(27, 4),
                                        ),
                                        color: const Color(0xFF22C55E)
                                            .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),

                                // VS EMBLEM / ATTACK EFFECT IN CENTER
                                if (!widget.isSubmitted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: GameColors.coral,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                // MONSTER FOE / OPPONENT (RIGHT FLANK)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      height: isWorldThree
                                          ? BattleArenaWidget
                                                .worldThreeMonsterHeight
                                          : isWorldTwo
                                          ? BattleArenaWidget
                                                .worldTwoMonsterHeight
                                          : 85,
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          switchInCurve: Curves.easeOut,
                                          switchOutCurve: Curves.easeIn,
                                          child: Image.asset(
                                            monsterAsset,
                                            key: ValueKey<String>(monsterAsset),
                                            height: isWorldThree
                                                ? BattleArenaWidget
                                                      .worldThreeMonsterHeight
                                                : isWorldTwo
                                                ? BattleArenaWidget
                                                      .worldTwoMonsterHeight
                                                : 85,
                                            fit: BoxFit.contain,
                                            filterQuality: FilterQuality.medium,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Stone Battle Mound Base
                                    Container(
                                      width: 68,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                          Radius.elliptical(27, 4),
                                        ),
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // 1. FLYING MAGIC ENERGY FIREBALL PROJECTILE ⚡🔥
                            if (widget.isSubmitted &&
                                widget.isCorrect &&
                                attackProgress > 0 &&
                                attackProgress < 0.8)
                              Positioned(
                                left:
                                    45.0 +
                                    ((attackProgress / 0.8) *
                                        (totalWidth - 115.0)),
                                top: 30.0 + ((attackProgress / 0.8) * 24.0),
                                child: SizedBox(
                                  width: 65,
                                  height: 44,
                                  child: Image.asset(
                                    'assets/images/magic_attack_effect.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                            // 2. REALISTIC SLIME IMPACT BLAST & FLARE BURST 💥✨ (FADES OUT & DISAPPEARS AFTER ATTACK)
                            if (widget.isSubmitted &&
                                widget.isCorrect &&
                                _attackController.isAnimating &&
                                impactProgress > 0 &&
                                impactProgress < 0.95)
                              Positioned(
                                left: totalWidth - 78,
                                top: 52,
                                child: Transform.scale(
                                  scale: 0.6 + (impactProgress * 0.7),
                                  child: Opacity(
                                    opacity: ((0.95 - impactProgress) / 0.35)
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: 55,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white,
                                            const Color(0xFF38BDF8)
                                                .withValues(alpha: 0.95),
                                            const Color(0xFF0284C7)
                                                .withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '💥✨',
                                          style: TextStyle(fontSize: 26),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // 3. MONSTER COUNTER ATTACK FLYING SLIME BEAM PROJECTILE 🟢⚡
                            if (widget.isSubmitted &&
                                !widget.isCorrect &&
                                _attackController.isAnimating &&
                                attackProgress > 0 &&
                                attackProgress < 0.85)
                              Positioned(
                                left: isWorldThree
                                    ? (totalWidth - 175.0) -
                                          ((attackProgress / 0.85) *
                                              (totalWidth - 195.0))
                                    : isWorldTwo
                                    ? (totalWidth - 215.0) -
                                          ((attackProgress / 0.85) *
                                              (totalWidth - 227.0))
                                    : (totalWidth - 110.0) -
                                          ((attackProgress / 0.85) *
                                              (totalWidth - 145.0)),
                                top: 22.0 + ((attackProgress / 0.85) * 18.0),
                                child: SizedBox(
                                  width: isWorldThree
                                      ? 150
                                      : isWorldTwo
                                      ? 110
                                      : 95,
                                  height: 55,
                                  child: Transform.flip(
                                    flipX: isWorldThree,
                                    child: Image.asset(
                                      BattleArenaWidget.monsterProjectileAssetForWorld(
                                        widget.worldId,
                                      ),
                                      key: ValueKey(
                                        'monster-projectile-${widget.worldId}',
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),

                            // 4. MONSTER COUNTER ATTACK IMPACT BURST ON WIZARD 💥💔 (FADES OUT & DISAPPEARS AFTER ATTACK)
                            if (widget.isSubmitted &&
                                !widget.isCorrect &&
                                _attackController.isAnimating &&
                                attackProgress > 0.5 &&
                                attackProgress < 0.95)
                              Positioned(
                                left: 20,
                                top: 45,
                                child: Opacity(
                                  opacity: ((0.95 - attackProgress) / 0.45)
                                      .clamp(0.0, 1.0),
                                  child: Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white,
                                          const Color(0xFF84CC16)
                                              .withValues(alpha: 0.95),
                                          const Color(0xFF4D7C0F)
                                              .withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '💥🟢',
                                        style: TextStyle(fontSize: 26),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
