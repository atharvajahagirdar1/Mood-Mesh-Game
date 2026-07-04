import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/ad_manager.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';

class GameOverScreen extends StatefulWidget {
  final Level level;
  final bool isDaily;
  const GameOverScreen({super.key, required this.level, required this.isDaily});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  void _watchAdForCoins() {
    if (!AdManager.instance.isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad is still loading. Please try again in a moment!')));
      return;
    }
    AdManager.instance.showRewardedAd(() {
      setState(() => GameSettings.totalCoins += 10);
      StorageManager.saveEconomy();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Earned: +10 Coins! Buy hints with them.', style: TextStyle(fontWeight: FontWeight.bold))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💔', style: TextStyle(fontSize: 100)),
                const SizedBox(height: 10),
                const Text('OUT OF MOVES', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.accent)),
                const SizedBox(height: 15),
                const Text('Don\'t give up! Try a different path.', style: TextStyle(fontSize: 18, color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                const SizedBox(height: 60),

                GameButton(title: 'TRY AGAIN', icon: Icons.refresh_rounded, color: AppTheme.accent, shadowColor: AppTheme.accentDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, isDaily: widget.isDaily)))),
                const SizedBox(height: 15),
                GameButton(title: 'HOME', icon: Icons.home_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))),
                const SizedBox(height: 30),
                GameButton(title: 'WATCH AD (+10🪙)', icon: Icons.ondemand_video_rounded, color: AppTheme.success, shadowColor: AppTheme.successDark, isSmall: true, onTap: _watchAdForCoins),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
