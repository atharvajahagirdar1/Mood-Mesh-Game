import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/level_data.dart';
import '../core/game_settings.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';

class LevelCompleteScreen extends StatefulWidget {
  final Level level;
  final int movesLeft;
  final bool isDaily;
  const LevelCompleteScreen({Key? key, required this.level, required this.movesLeft, required this.isDaily}) : super(key: key);

  @override
  _LevelCompleteScreenState createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen> {
  int targetStars = 1;
  int coinsEarned = 0;
  
  double _star1Scale = 0.0;
  double _star2Scale = 0.0;
  double _star3Scale = 0.0;

  @override
  void initState() {
    super.initState();
    // Calculate Stars & Coin Rewards
    if (widget.movesLeft >= widget.level.movesFor3Stars) {
      targetStars = 3;
      coinsEarned = 30;
    } else if (widget.movesLeft >= widget.level.movesFor2Stars) {
      targetStars = 2;
      coinsEarned = 20;
    } else {
      targetStars = 1;
      coinsEarned = 10;
    }
    
    GameSettings.totalCoins += coinsEarned;
    
    if (!widget.isDaily) {
      LevelData.unlockNextLevel(widget.level.id);
    }

    _animateStars();
  }

  void _animateStars() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted && targetStars >= 1) setState(() => _star1Scale = 1.0);
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted && targetStars >= 2) setState(() => _star2Scale = 1.0);
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted && targetStars >= 3) setState(() => _star3Scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(), // Enhanced UI Background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 100)),
                const SizedBox(height: 10),
                Text(
                  widget.isDaily ? 'DAILY PUZZLE DONE!' : 'LEVEL CLEARED!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.success),
                ),
                const SizedBox(height: 30),
                
                // Enhanced Staggered Star Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: _star1Scale,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      child: Icon(Icons.star_rounded, size: 70, color: AppTheme.primary),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0, left: 10, right: 10),
                      child: AnimatedScale(
                        scale: _star2Scale,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        child: Icon(Icons.star_rounded, size: 90, color: AppTheme.primary),
                      ),
                    ),
                    AnimatedScale(
                      scale: _star3Scale,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      child: Icon(Icons.star_rounded, size: 70, color: AppTheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Animated Coin Reward System
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 36),
                      const SizedBox(width: 10),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: coinsEarned),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutQuart,
                        builder: (context, value, child) {
                          return Text(
                            '+$value COINS', 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)
                          );
                        }
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Next Level Button (Hidden if Daily)
                if (!widget.isDaily) ...[
                  GameButton(
                    title: 'NEXT LEVEL',
                    icon: Icons.fast_forward_rounded,
                    color: AppTheme.success,
                    shadowColor: AppTheme.successDark,
                    onTap: () {
                      int nextId = widget.level.id + 1;
                      if (nextId <= LevelData.allLevels.length) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: LevelData.getLevel(nextId))));
                      } else {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Home / Replay row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton(
                      title: 'HOME',
                      icon: Icons.home_rounded,
                      color: AppTheme.secondary,
                      shadowColor: AppTheme.secondaryDark,
                      isSmall: true,
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                    ),
                    const SizedBox(width: 15),
                    GameButton(
                      title: 'REPLAY',
                      icon: Icons.replay_rounded,
                      color: AppTheme.primary,
                      shadowColor: AppTheme.primaryDark,
                      isSmall: true,
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, isDaily: widget.isDaily))),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
