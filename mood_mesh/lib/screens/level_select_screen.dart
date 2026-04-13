import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game_screen.dart';
import '../core/app_theme.dart';
import '../core/level_data.dart';
import '../core/game_settings.dart';
import '../core/audio_manager.dart';
import '../widgets/animated_background.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({Key? key}) : super(key: key);

  @override
  _LevelSelectScreenState createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Select Level'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          const AnimatedBackground(), 
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: LevelData.allLevels.length, 
                itemBuilder: (context, index) {
                  final level = LevelData.allLevels[index];
                  final isUnlocked = level.id <= LevelData.maxUnlockedLevel;
                  final stars = LevelData.levelStars[level.id] ?? 0;

                  return GestureDetector(
                    onTap: isUnlocked ? () async {
                      if (GameSettings.hapticsOn) HapticFeedback.lightImpact();
                      AudioManager.playClick();
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(level: level, isDaily: false)));
                      setState(() {}); 
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppTheme.primary : AppTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border(bottom: BorderSide(color: isUnlocked ? AppTheme.primaryDark : const Color(0xFFD0D6E0), width: 6)),
                        boxShadow: isUnlocked ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))] : [],
                      ),
                      child: isUnlocked 
                          ? Stack(
                              children: [
                                Center(child: Text('${level.id}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))),
                                if (level.id < LevelData.maxUnlockedLevel || stars > 0)
                                  Positioned(
                                    bottom: 8, left: 0, right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (starIndex) => Icon(Icons.star_rounded, size: 16, color: starIndex < stars ? Colors.white : Colors.black12)),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(child: Icon(Icons.lock_rounded, color: Colors.black26, size: 36)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
