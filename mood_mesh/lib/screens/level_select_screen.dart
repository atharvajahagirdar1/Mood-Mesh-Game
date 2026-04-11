import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../core/app_theme.dart';
import '../core/level_data.dart';
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
          const AnimatedBackground(), // Enhanced UI with animated background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: LevelData.allLevels.length,
                itemBuilder: (context, index) {
                  final level = LevelData.allLevels[index];
                  final isUnlocked = level.id <= LevelData.maxUnlockedLevel;

                  return GestureDetector(
                    onTap: isUnlocked ? () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GameScreen(level: level, isDaily: false)),
                      );
                      setState(() {}); 
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUnlocked ? AppTheme.primary : AppTheme.textLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        // 3D attractive card look
                        border: Border(bottom: BorderSide(
                          color: isUnlocked ? AppTheme.primaryDark : Colors.grey.withOpacity(0.5), 
                          width: 6
                        )),
                        boxShadow: isUnlocked ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))] : [],
                      ),
                      child: Center(
                        child: isUnlocked 
                            ? Text('${level.id}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))
                            : const Icon(Icons.lock_rounded, color: Colors.white70, size: 36),
                      ),
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
