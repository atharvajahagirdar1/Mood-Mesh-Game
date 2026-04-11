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
