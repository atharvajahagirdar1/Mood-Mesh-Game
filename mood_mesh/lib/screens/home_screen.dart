import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'themes_screen.dart';
import 'level_select_screen.dart';
import '../core/app_theme.dart';
import '../core/level_data.dart';
import '../widgets/game_button.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    int currentLevel = LevelData.maxUnlockedLevel;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Stack(
              children: [
                // Top Action Bar
                Positioned(
                  top: 20, right: 20, left: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(Icons.palette_rounded, AppTheme.secondary, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemesScreen())).then((_) {
                          setState(() {}); 
                        });
                      }),
                      
                      // Central Score Tab (Coin Counter)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              '${GameSettings.totalCoins}', 
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)
                            ),
                          ],
                        ),
                      ),

                      _buildIconButton(Icons.settings_rounded, AppTheme.textLight, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      }),
                    ],
                  ),
                ),
                
                // Main Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Text(GameSettings.getEmoji(0), style: const TextStyle(fontSize: 120)),
                      ),
                      const SizedBox(height: 10),
                      const Text('Mood Mesh', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      const SizedBox(height: 60),
                      
                      // Main Play Button
                      GameButton(
                        title: 'PLAY LEVEL $currentLevel',
                        icon: Icons.play_arrow_rounded,
                        color: AppTheme.primary,
                        shadowColor: AppTheme.primaryDark,
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => const LevelSelectScreen())
                          ).then((_) => setState(() {})); 
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Daily Puzzle Button
                      GameButton(
                        title: 'DAILY PUZZLE',
                        icon: Icons.calendar_month_rounded,
                        color: AppTheme.accent,
                        shadowColor: AppTheme.accentDark,
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => GameScreen(level: LevelData.dailyLevel, isDaily: true))
                          ).then((_) => setState(() {})); 
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
