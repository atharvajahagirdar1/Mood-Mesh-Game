import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'themes_screen.dart';
import 'level_select_screen.dart';
import '../core/app_theme.dart';
import '../core/level_data.dart';
import '../widgets/game_button.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/ad_manager.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _playDailyPuzzle() {
    String today = DateTime.now().toIso8601String().split('T')[0];
    
    if (GameSettings.lastDailyPuzzleDate == today) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('🌟 All Done!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primary, fontSize: 26)),
          content: const Text(
            'You have already conquered today\'s daily puzzle.\n\nCome back tomorrow for a brand new challenge!', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 18, color: AppTheme.textDark, fontWeight: FontWeight.w600)
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            GameButton(title: 'GOT IT', color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, isSmall: true, onTap: () => Navigator.pop(context))
          ],
        )
      );
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(level: LevelData.dailyLevel, isDaily: true))).then((_) => setState(() {})); 
    }
  }

  void _watchAdForCoins() {
    if (!AdManager.instance.isAdLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ad is still loading. Please try again in a moment!')));
      return;
    }
    
    AdManager.instance.showRewardedAd(() {
      setState(() {
        GameSettings.totalCoins += 50;
      });
      StorageManager.saveEconomy();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reward Earned: +50 Coins!', style: TextStyle(fontWeight: FontWeight.bold))));
    });
  }

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
                Positioned(
                  top: 20, right: 20, left: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(Icons.palette_rounded, AppTheme.secondary, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemesScreen())).then((_) => setState(() {}));
                      }),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                          border: Border.all(color: const Color(0xFFE5E9F0), width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 28),
                            const SizedBox(width: 8),
                            Text('${GameSettings.totalCoins}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                          ],
                        ),
                      ),

                      _buildIconButton(Icons.settings_rounded, AppTheme.textLight, () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {}));
                      }),
                    ],
                  ),
                ),
                
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const GameLogoWidget(size: 180), 
                      const SizedBox(height: 30),
                      const Text('Mood Mesh', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -1.0)),
                      const SizedBox(height: 50),
                      
                      GameButton(
                        title: 'PLAY LEVEL $currentLevel',
                        icon: Icons.play_arrow_rounded,
                        color: AppTheme.primary,
                        shadowColor: AppTheme.primaryDark,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectScreen())).then((_) => setState(() {})); 
                        },
                      ),
                      const SizedBox(height: 15),
                      
                      GameButton(
                        title: 'DAILY PUZZLE',
                        icon: Icons.calendar_month_rounded,
                        color: AppTheme.accent,
                        shadowColor: AppTheme.accentDark,
                        onTap: _playDailyPuzzle,
                      ),
                      const SizedBox(height: 15),
                      
                      GameButton(
                        title: 'WATCH AD (+50🪙)',
                        icon: Icons.ondemand_video_rounded,
                        color: AppTheme.success,
                        shadowColor: AppTheme.successDark,
                        isSmall: true,
                        onTap: _watchAdForCoins,
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
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          border: Border.all(color: const Color(0xFFE5E9F0), width: 2),
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
