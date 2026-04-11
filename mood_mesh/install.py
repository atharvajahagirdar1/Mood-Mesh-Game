import os
import sys

def get_dart_files():
    """Returns a dictionary containing all production-level Dart files and their paths."""
    
    return {
        "lib/main.dart": r"""
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MoodMeshApp());
  });
}

class MoodMeshApp extends StatelessWidget {
  const MoodMeshApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
""",

        "lib/core/app_theme.dart": r"""
import 'package:flutter/material.dart';

class AppTheme {
  // Minimalist, Clean Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundDark = Color(0xFFF0F4F8);  // Very subtle cool grey
  
  // 3D Button Colors - High Contrast
  static const Color primary = Color(0xFFFFB703); // Warm Gold
  static const Color primaryDark = Color(0xFFE89D00); 
  
  static const Color secondary = Color(0xFF4EA8DE); // Bright Cyan
  static const Color secondaryDark = Color(0xFF0077B6);
  
  static const Color accent = Color(0xFFFF595E); // Punchy Red
  static const Color accentDark = Color(0xFFD62828);

  static const Color success = Color(0xFF06D6A0); // Vivid Green
  static const Color successDark = Color(0xFF05B083);
  
  static const Color coinGold = Color(0xFFFFC107);
  static const Color coinDark = Color(0xFFF77F00);

  // Hint Glow Colors
  static const Color neonBlue = Color(0xFF00E5FF);
  
  static const Color textDark = Color(0xFF1D2D44); // Deep Navy Blue for extreme readability
  static const Color textLight = Color(0xFF748A9D);
  static const Color white = Colors.white;

  // Mood Colors
  static const Color moodHappy = Color(0xFFFFB703);
  static const Color moodAngry = Color(0xFFFF595E);
  static const Color moodSleepy = Color(0xFF4EA8DE);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primary,
      fontFamily: 'Nunito', 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        centerTitle: true,
        titleTextStyle: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.w900),
      ),
    );
  }

  static BoxDecoration gameBoxDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 8)), // Softer, modern shadow
    ],
    border: Border.all(color: const Color(0xFFE5E9F0), width: 2), // Clean outline
  );
}
""",

        "lib/core/game_settings.dart": r"""
class GameSettings {
  static String currentTheme = 'classic'; 
  static bool soundOn = true;
  static bool musicOn = true;
  static bool hapticsOn = true;
  
  // Economy & Progression
  static int totalCoins = 0;
  static int availableHints = 5; 
  static const int hintCost = 20;
  static String lastDailyPuzzleDate = ''; // Tracks when the player last completed the daily puzzle

  static String getEmoji(int moodIndex) {
    if (currentTheme == 'animals') return ['🐶', '🐯', '🐨'][moodIndex]; 
    if (currentTheme == 'fruits') return ['🍎', '🌶️', '🍇'][moodIndex]; 
    return ['😊', '😡', '😴'][moodIndex];
  }
}
""",

        "lib/models/level.dart": r"""
enum Mood { happy, angry, sleepy }

class Level {
  final int id;
  final int cols;
  final int rows;
  final int maxMoves;
  final int movesFor3Stars;
  final int movesFor2Stars;
  final List<int> initialGrid;

  Level({
    required this.id,
    required this.cols,
    required this.rows,
    required this.maxMoves,
    required this.movesFor3Stars,
    required this.movesFor2Stars,
    required this.initialGrid,
  });
}
""",

        "lib/core/level_data.dart": r"""
import '../models/level.dart';

class LevelData {
  static int maxUnlockedLevel = 1;
  static Map<int, int> levelStars = {}; // Store highest stars achieved per level

  static final List<Level> allLevels = [
    Level(id: 1, cols: 3, rows: 3, maxMoves: 5, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [2, 2, 2, 0, 0, 0, 2, 2, 2]),
    Level(id: 2, cols: 3, rows: 3, maxMoves: 6, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [1, 1, 1, 0, 0, 0, 1, 1, 1]),
    Level(id: 3, cols: 3, rows: 3, maxMoves: 5, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [0, 2, 0, 0, 2, 0, 0, 2, 0]),
    Level(id: 4, cols: 3, rows: 3, maxMoves: 8, movesFor3Stars: 6, movesFor2Stars: 3, initialGrid: [0, 1, 0, 0, 1, 0, 0, 1, 0]),
    Level(id: 5, cols: 4, rows: 4, maxMoves: 12, movesFor3Stars: 8, movesFor2Stars: 4, initialGrid: [2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0]),
    Level(id: 6, cols: 4, rows: 4, maxMoves: 15, movesFor3Stars: 10, movesFor2Stars: 5, initialGrid: [1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0]),
    Level(id: 7, cols: 5, rows: 5, maxMoves: 20, movesFor3Stars: 15, movesFor2Stars: 8, initialGrid: [2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2]),
    Level(id: 8, cols: 5, rows: 5, maxMoves: 25, movesFor3Stars: 18, movesFor2Stars: 10, initialGrid: [0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0]),
  ];

  static final Level dailyLevel = Level(
    id: 999, cols: 5, rows: 5, maxMoves: 20, movesFor3Stars: 15, movesFor2Stars: 10, 
    initialGrid: [2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2]
  );

  static void unlockNextLevel(int currentLevelId) {
    if (currentLevelId == maxUnlockedLevel && currentLevelId < allLevels.length) {
      maxUnlockedLevel++;
    }
  }

  static void saveStars(int levelId, int stars) {
    if (!levelStars.containsKey(levelId) || stars > levelStars[levelId]!) {
      levelStars[levelId] = stars;
    }
  }

  static Level getLevel(int id) {
    return allLevels.firstWhere((lvl) => lvl.id == id);
  }
}
""",

        "lib/widgets/game_button.dart": r"""
import 'package:flutter/material.dart';

class GameButton extends StatefulWidget {
  final String title;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSmall;

  const GameButton({
    Key? key,
    required this.title,
    required this.color,
    required this.shadowColor,
    required this.onTap,
    this.icon,
    this.isSmall = false,
  }) : super(key: key);

  @override
  _GameButtonState createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.isSmall ? null : 240,
          padding: EdgeInsets.symmetric(vertical: widget.isSmall ? 12 : 18, horizontal: widget.isSmall ? 20 : 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30),
            border: Border(bottom: BorderSide(color: widget.shadowColor, width: 6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.isSmall ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: widget.isSmall ? 20 : 28), const SizedBox(width: 10)],
              Text(
                widget.title,
                style: TextStyle(fontSize: widget.isSmall ? 16 : 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const GameIconButton({Key? key, required this.icon, required this.color, required this.shadowColor, required this.onTap}) : super(key: key);

  @override
  _GameIconButtonState createState() => _GameIconButtonState();
}

class _GameIconButtonState extends State<GameIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) { _controller.reverse(); widget.onTap(); }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, onTapUp: _onTapUp, onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border(bottom: BorderSide(color: widget.shadowColor, width: 4)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
""",

        "lib/widgets/animated_background.dart": r"""
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// Simple, Minimalist Background
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.backgroundLight, AppTheme.backgroundDark],
          stops: [0.3, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -150, right: -150,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.03)),
            ),
          ),
          Positioned(
            bottom: -200, left: -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary.withOpacity(0.03)),
            ),
          ),
        ],
      ),
    );
  }
}
""",

        "lib/screens/splash_screen.dart": r"""
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2500), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(GameSettings.getEmoji(0), style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 20),
                  const Text('Mood Mesh', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2.0)),
                  const SizedBox(height: 10),
                  const Text('Connect the emotions', style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
""",

        "lib/screens/home_screen.dart": r"""
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 10))],
                        ),
                        child: Text(GameSettings.getEmoji(0), style: const TextStyle(fontSize: 120)),
                      ),
                      const SizedBox(height: 20),
                      const Text('Mood Mesh', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: -1.0)),
                      const SizedBox(height: 60),
                      
                      GameButton(
                        title: 'PLAY LEVEL $currentLevel',
                        icon: Icons.play_arrow_rounded,
                        color: AppTheme.primary,
                        shadowColor: AppTheme.primaryDark,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LevelSelectScreen())).then((_) => setState(() {})); 
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      GameButton(
                        title: 'DAILY PUZZLE',
                        icon: Icons.calendar_month_rounded,
                        color: AppTheme.accent,
                        shadowColor: AppTheme.accentDark,
                        onTap: _playDailyPuzzle,
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
""",

        "lib/screens/themes_screen.dart": r"""
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({Key? key}) : super(key: key);

  @override
  _ThemesScreenState createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  final List<Map<String, dynamic>> themes = [
    {'id': 'classic', 'name': 'Classic', 'preview': '😊', 'locked': false},
    {'id': 'animals', 'name': 'Animals', 'preview': '🐶', 'locked': false},
    {'id': 'fruits', 'name': 'Fruits', 'preview': '🍎', 'locked': false},
    {'id': 'soon', 'name': 'Coming Soon', 'preview': '🔒', 'locked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Choose Theme'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final bool isLocked = theme['locked'];
                  final isSelected = !isLocked && GameSettings.currentTheme == theme['id'];

                  return GestureDetector(
                    onTap: isLocked ? null : () => setState(() => GameSettings.currentTheme = theme['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : (isLocked ? Colors.grey.shade300 : AppTheme.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isSelected ? AppTheme.primaryDark : const Color(0xFFE5E9F0), width: isSelected ? 4 : 2),
                        boxShadow: isLocked ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(theme['preview'], style: TextStyle(fontSize: 60, color: isLocked ? Colors.black38 : null)),
                          const SizedBox(height: 10),
                          Text(theme['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isLocked ? Colors.black38 : AppTheme.textDark))),
                        ],
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
""",

        "lib/screens/settings_screen.dart": r"""
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    decoration: AppTheme.gameBoxDecoration,
                    child: Column(
                      children: [
                        _buildToggle('Sound Effects', Icons.volume_up_rounded, GameSettings.soundOn, (val) => setState(() => GameSettings.soundOn = val)),
                        const Divider(height: 1),
                        _buildToggle('Music', Icons.music_note_rounded, GameSettings.musicOn, (val) => setState(() => GameSettings.musicOn = val)),
                        const Divider(height: 1),
                        _buildToggle('Haptics', Icons.vibration_rounded, GameSettings.hapticsOn, (val) => setState(() => GameSettings.hapticsOn = val)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppTheme.primary, size: 28),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      trailing: Switch(value: value, activeColor: AppTheme.primary, onChanged: onChanged),
    );
  }
}
""",

        "lib/screens/level_select_screen.dart": r"""
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
          const AnimatedBackground(), 
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
                  final stars = LevelData.levelStars[level.id] ?? 0;

                  return GestureDetector(
                    onTap: isUnlocked ? () async {
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
                                Center(
                                  child: Text('${level.id}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                                ),
                                if (level.id < LevelData.maxUnlockedLevel || stars > 0)
                                  Positioned(
                                    bottom: 8,
                                    left: 0,
                                    right: 0,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (starIndex) {
                                        return Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: starIndex < stars ? Colors.white : Colors.black12,
                                        );
                                      }),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: Icon(Icons.lock_rounded, color: Colors.black26, size: 36),
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
""",

        "lib/screens/game_screen.dart": r"""
import 'package:flutter/material.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/dot_widget.dart';
import '../widgets/path_painter.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';
import 'level_complete_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  final bool isDaily;
  const GameScreen({Key? key, required this.level, this.isDaily = false}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<Mood> grid;
  late int movesLeft;
  List<int> path = [];
  bool isProcessing = false;

  // Neon Hint Path System
  List<int> hintedPath = [];
  bool isHintActive = false;
  late AnimationController _hintPulseController;

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _initLevel();
  }
  
  @override
  void dispose() {
    _hintPulseController.dispose();
    super.dispose();
  }

  void _initLevel() {
    grid = widget.level.initialGrid.map((val) => Mood.values[val]).toList();
    movesLeft = widget.level.maxMoves;
    path = [];
    isProcessing = false;
    isHintActive = false;
    hintedPath.clear();
    setState(() {});
  }

  void _executeHint() {
    List<int> bestPath = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == Mood.happy) {
        List<int> currentPath = [i];
        _dfsFindPath(i, currentPath, bestPath);
        if (bestPath.length >= 3) break; 
      }
    }
    
    if (bestPath.length > 1) {
      setState(() {
        hintedPath = List.from(bestPath);
        isHintActive = true;
      });
    }
  }

  void _dfsFindPath(int current, List<int> currentPath, List<int> bestPath) {
    if (currentPath.length > bestPath.length) {
      bestPath.clear();
      bestPath.addAll(currentPath);
    }
    int r = current ~/ widget.level.cols;
    int c = current % widget.level.cols;
    List<List<int>> dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    
    for (var d in dirs) {
      int nr = r + d[0], nc = c + d[1];
      if (nr >= 0 && nr < widget.level.rows && nc >= 0 && nc < widget.level.cols) {
        int nIdx = nr * widget.level.cols + nc;
        if (grid[nIdx] == Mood.happy && !currentPath.contains(nIdx)) {
          currentPath.add(nIdx);
          _dfsFindPath(nIdx, currentPath, bestPath);
          currentPath.removeLast();
        }
      }
    }
  }

  void _useHint() {
    if (movesLeft <= 0 || isProcessing || isHintActive) return;

    if (GameSettings.availableHints > 0) {
      setState(() => GameSettings.availableHints--);
      _executeHint();
    } else if (GameSettings.totalCoins >= GameSettings.hintCost) {
      setState(() => GameSettings.totalCoins -= GameSettings.hintCost);
      _executeHint();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough coins for a hint!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        )
      );
    }
  }

  void _triggerRipple() async {
    if (path.length <= 1) {
      setState(() => path.clear());
      return;
    }

    setState(() => isProcessing = true);
    Set<int> pathSet = path.toSet();
    Set<int> neighborsToChange = {};

    for (int idx in path) {
      int r = idx ~/ widget.level.cols;
      int c = idx % widget.level.cols;
      List<List<int>> potentialNeighbors = [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]];

      for (var n in potentialNeighbors) {
        int nr = n[0], nc = n[1];
        if (nr >= 0 && nr < widget.level.rows && nc >= 0 && nc < widget.level.cols) {
          int nIdx = nr * widget.level.cols + nc;
          if (!pathSet.contains(nIdx)) neighborsToChange.add(nIdx);
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      for (int nIdx in neighborsToChange) {
        if (grid[nIdx] == Mood.happy) grid[nIdx] = Mood.angry;
        else if (grid[nIdx] == Mood.angry) grid[nIdx] = Mood.sleepy;
        else grid[nIdx] = Mood.happy;
      }
      movesLeft--;
      path.clear();
      isProcessing = false;
      _checkWinLoss();
    });
  }

  void _checkWinLoss() {
    bool isWin = grid.every((mood) => mood == Mood.happy);
    if (isWin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LevelCompleteScreen(level: widget.level, movesLeft: movesLeft, isDaily: widget.isDaily)));
    } else if (movesLeft <= 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameOverScreen(level: widget.level, isDaily: widget.isDaily)));
    }
  }

  void _handlePanStart(Offset localPosition, Size boardSize) {
    if (isHintActive) {
      setState(() {
        isHintActive = false;
        hintedPath.clear();
      });
    }
    _handlePanUpdate(localPosition, boardSize);
  }

  void _handlePanUpdate(Offset localPosition, Size boardSize) {
    if (isProcessing) return;

    double cellWidth = boardSize.width / widget.level.cols;
    double cellHeight = boardSize.height / widget.level.rows;
    int c = (localPosition.dx / cellWidth).floor();
    int r = (localPosition.dy / cellHeight).floor();

    if (c < 0 || c >= widget.level.cols || r < 0 || r >= widget.level.rows) return;
    int idx = r * widget.level.cols + c;

    if (path.isEmpty) {
      if (grid[idx] == Mood.happy) setState(() => path.add(idx));
      return;
    }

    if (path.length > 1 && path[path.length - 2] == idx) {
      setState(() => path.removeLast());
      return;
    }

    if (!path.contains(idx)) {
      int lastIdx = path.last;
      int lastR = lastIdx ~/ widget.level.cols;
      int lastC = lastIdx % widget.level.cols;
      bool isAdjacent = (r - lastR).abs() + (c - lastC).abs() == 1;

      if (isAdjacent && grid[idx] == Mood.happy) setState(() => path.add(idx));
    }
  }

  @override
  Widget build(BuildContext context) {
    String topTitle = widget.isDaily ? 'DAILY PUZZLE' : 'LEVEL ${widget.level.id}';
    bool hasFreeHints = GameSettings.availableHints > 0;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GameIconButton(icon: Icons.pause_rounded, color: AppTheme.accent, shadowColor: AppTheme.accentDark, onTap: () => Navigator.pop(context)),
                      Text(topTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      GameIconButton(icon: Icons.refresh_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, onTap: _initLevel),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: AppTheme.gameBoxDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("MOVES LEFT: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                        Text("$movesLeft", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: movesLeft <= 3 ? AppTheme.accent : AppTheme.secondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.level.cols / widget.level.rows,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanStart: (details) => _handlePanStart(details.localPosition, constraints.biggest),
                              onPanUpdate: (details) => _handlePanUpdate(details.localPosition, constraints.biggest),
                              onPanEnd: (_) => _triggerRipple(),
                              child: Container(
                                decoration: AppTheme.gameBoxDecoration,
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    // 1. Neon Pulsing Hint Path (Underneath)
                                    if (isHintActive && hintedPath.isNotEmpty)
                                      AnimatedBuilder(
                                        animation: _hintPulseController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: constraints.biggest,
                                            painter: PathPainter(
                                              path: hintedPath, 
                                              cols: widget.level.cols, 
                                              rows: widget.level.rows,
                                              pathColor: AppTheme.neonBlue, 
                                              strokeWidth: 20.0, 
                                              isNeon: true,
                                              pulseValue: _hintPulseController.value
                                            ),
                                          );
                                        }
                                      ),
                                    
                                    // 2. Solid Player Draw Path
                                    if (path.isNotEmpty)
                                      CustomPaint(
                                        size: constraints.biggest,
                                        painter: PathPainter(
                                          path: path, 
                                          cols: widget.level.cols, 
                                          rows: widget.level.rows,
                                          pathColor: Colors.white, 
                                          strokeWidth: 18.0,
                                          isNeon: false,
                                        ),
                                      ),

                                    // 3. The Grid
                                    GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.level.cols),
                                      itemCount: grid.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DotWidget(
                                            key: ValueKey(index),
                                            mood: grid[index],
                                            isInPath: path.contains(index),
                                            isLast: path.isNotEmpty && path.last == index,
                                            isHighlighted: false, 
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  GameButton(
                    title: hasFreeHints 
                        ? 'USE HINT (${GameSettings.availableHints})' 
                        : 'BUY HINT (${GameSettings.hintCost}🪙)',
                    icon: Icons.lightbulb_rounded,
                    color: hasFreeHints ? AppTheme.primary : AppTheme.coinGold,
                    shadowColor: hasFreeHints ? AppTheme.primaryDark : AppTheme.coinDark,
                    isSmall: true,
                    onTap: _useHint,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
""",

        "lib/screens/level_complete_screen.dart": r"""
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
  bool isReplay = false;
  
  double _star1Scale = 0.0;
  double _star2Scale = 0.0;
  double _star3Scale = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Check if player is replaying a previously completed level
    if (!widget.isDaily && widget.level.id < LevelData.maxUnlockedLevel) {
      isReplay = true;
    }

    // Performance-based Stars & Rewards Logic
    if (widget.movesLeft >= widget.level.movesFor3Stars) {
      targetStars = 3;
      coinsEarned = isReplay ? 0 : 30; // 0 coins for replay!
    } else if (widget.movesLeft >= widget.level.movesFor2Stars) {
      targetStars = 2;
      coinsEarned = isReplay ? 0 : 20;
    } else {
      targetStars = 1;
      coinsEarned = isReplay ? 0 : 10;
    }
    
    if (!isReplay && !widget.isDaily) {
      GameSettings.totalCoins += coinsEarned;
      LevelData.unlockNextLevel(widget.level.id);
    } else if (widget.isDaily && targetStars > 0) {
      // Mark daily puzzle as done for today
      GameSettings.lastDailyPuzzleDate = DateTime.now().toIso8601String().split('T')[0];
      GameSettings.totalCoins += coinsEarned;
    }

    if (!widget.isDaily) {
      LevelData.saveStars(widget.level.id, targetStars);
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
          const AnimatedBackground(), 
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
                
                // Staggered Star Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(scale: _star1Scale, duration: const Duration(milliseconds: 500), curve: Curves.elasticOut, child: Icon(Icons.star_rounded, size: 70, color: AppTheme.primary)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0, left: 10, right: 10),
                      child: AnimatedScale(scale: _star2Scale, duration: const Duration(milliseconds: 500), curve: Curves.elasticOut, child: Icon(Icons.star_rounded, size: 90, color: AppTheme.primary)),
                    ),
                    AnimatedScale(scale: _star3Scale, duration: const Duration(milliseconds: 500), curve: Curves.elasticOut, child: Icon(Icons.star_rounded, size: 70, color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 20),

                // Animated Coin Reward System (or Replay Notice)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(color: AppTheme.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))], border: Border.all(color: const Color(0xFFE5E9F0), width: 2)),
                  child: isReplay 
                    ? const Text('REPLAY - NO COINS 🪙', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textLight))
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 36),
                        const SizedBox(width: 10),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: coinsEarned),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            return Text('+$value COINS', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark));
                          }
                        ),
                      ],
                    ),
                ),
                const SizedBox(height: 40),

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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GameButton(title: 'HOME', icon: Icons.home_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, isSmall: true, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))),
                    const SizedBox(width: 15),
                    if (!widget.isDaily) // Replaying daily puzzle instantly might not be wanted if it's once a day
                      GameButton(title: 'REPLAY', icon: Icons.replay_rounded, color: AppTheme.primary, shadowColor: AppTheme.primaryDark, isSmall: true, onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, isDaily: widget.isDaily)))),
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
""",

        "lib/screens/game_over_screen.dart": r"""
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
""",

        "lib/widgets/dot_widget.dart": r"""
import 'package:flutter/material.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';

class DotWidget extends StatelessWidget {
  final Mood mood;
  final bool isInPath;
  final bool isLast;
  final bool isHighlighted;

  const DotWidget({
    Key? key, 
    required this.mood, 
    required this.isInPath, 
    required this.isLast,
    this.isHighlighted = false,
  }) : super(key: key);

  Color get moodColor {
    switch (mood) {
      case Mood.happy: return AppTheme.moodHappy;
      case Mood.angry: return AppTheme.moodAngry;
      case Mood.sleepy: return AppTheme.moodSleepy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isInPath ? 0.85 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: moodColor,
          shape: BoxShape.circle,
          border: isLast ? Border.all(color: Colors.white, width: 5) : Border.all(color: Colors.black.withOpacity(0.05), width: 1),
          boxShadow: isInPath ? [] : const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
            BoxShadow(color: Colors.white30, blurRadius: 2, offset: Offset(0, -2)) 
          ],
        ),
        child: Center(
          child: Text(
            GameSettings.getEmoji(mood.index),
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
""",

        "lib/widgets/path_painter.dart": r"""
import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<int> path;
  final int cols;
  final int rows;
  final Color pathColor;
  final double strokeWidth;
  final bool isNeon;
  final double pulseValue;

  PathPainter({
    required this.path, 
    required this.cols, 
    required this.rows, 
    required this.pathColor,
    required this.strokeWidth,
    this.isNeon = false,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    double cellWidth = size.width / cols;
    double cellHeight = size.height / rows;
    
    // Construct single Path object for clean joints
    Path fullPath = Path();
    for (int i = 0; i < path.length - 1; i++) {
      int p1 = path[i];
      int p2 = path[i + 1];

      Offset start = Offset((p1 % cols) * cellWidth + cellWidth / 2, (p1 ~/ cols) * cellHeight + cellHeight / 2);
      Offset end = Offset((p2 % cols) * cellWidth + cellWidth / 2, (p2 ~/ cols) * cellHeight + cellHeight / 2);

      if (i == 0) fullPath.moveTo(start.dx, start.dy);
      fullPath.lineTo(end.dx, end.dy);
    }

    if (isNeon) {
      // 1. Neon Outer Glow
      final glowPaint = Paint()
        ..color = pathColor.withOpacity(0.4 + (pulseValue * 0.6))
        ..strokeWidth = strokeWidth * 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + (pulseValue * 10));
      canvas.drawPath(fullPath, glowPaint);

      // 2. Bright Neon Core
      final corePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = strokeWidth * 0.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(fullPath, corePaint);
      
    } else {
      // 1. Normal Path Shadow
      final shadowPaint = Paint()
        ..color = Colors.black26
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(fullPath, shadowPaint);

      // 2. Normal Solid Player Line
      final normalPaint = Paint()
        ..color = pathColor
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(fullPath, normalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
"""
    }

def inject_files():
    if not os.path.exists("pubspec.yaml"):
        print("❌ ERROR: pubspec.yaml not found.")
        print("Please place and run this script inside the root directory of your existing Flutter project.")
        sys.exit(1)

    print("\n📦 Injecting PRODUCTION GAME ARCHITECTURE into the current project...")
    
    dart_files = get_dart_files()
    
    for relative_path, content in dart_files.items():
        full_path = relative_path
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(content.strip() + "\n")
            
        print(f"  ✅ Created/Updated: {relative_path}")

    test_file = os.path.join("test", "widget_test.dart")
    if os.path.exists(test_file):
        os.remove(test_file)
        print("  🧹 Cleaned up default test file to prevent compile errors.")

    print("\n🎉 INJECTION COMPLETE! Your game UI is now fully upgraded.")
    print("-" * 50)
    print("To run your game, execute the following command in your terminal:")
    print("  flutter clean && flutter pub get && flutter run")
    print("-" * 50)

if __name__ == "__main__":
    inject_files()