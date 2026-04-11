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
  final List<Map<String, String>> themes = [
    {'id': 'classic', 'name': 'Classic', 'preview': '😊'},
    {'id': 'animals', 'name': 'Animals', 'preview': '🐶'},
    {'id': 'fruits', 'name': 'Fruits', 'preview': '🍎'},
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = GameSettings.currentTheme == theme['id']!;

                  return GestureDetector(
                    onTap: () {
                      setState(() => GameSettings.currentTheme = theme['id']!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border(bottom: BorderSide(color: isSelected ? AppTheme.primaryDark : Colors.black12, width: 6)),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(theme['preview']!, style: const TextStyle(fontSize: 60)),
                          const SizedBox(height: 10),
                          Text(
                            theme['name']!, 
                            style: TextStyle(
                              fontSize: 20, 
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppTheme.textDark
                            )
                          ),
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
