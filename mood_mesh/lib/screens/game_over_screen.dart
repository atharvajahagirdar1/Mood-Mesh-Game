import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'home_screen.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';

class GameOverScreen extends StatelessWidget {
  final Level level;
  final bool isDaily;
  const GameOverScreen({Key? key, required this.level, required this.isDaily}) : super(key: key);

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

                GameButton(
                  title: 'TRY AGAIN', icon: Icons.refresh_rounded, color: AppTheme.accent, shadowColor: AppTheme.accentDark,
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: level, isDaily: isDaily))),
                ),
                const SizedBox(height: 20),
                
                GameButton(
                  title: 'HOME', icon: Icons.home_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark,
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
