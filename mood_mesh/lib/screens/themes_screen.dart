import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/audio_manager.dart';
import '../core/review_manager.dart'; // 🚀 NEW: IMPORT REVIEW MANAGER
import '../widgets/animated_background.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  // Tracks which themes the user has purchased
  List<String> unlockedThemes = ['classic'];

  // 🚀 EXPANDED THEME LIST
  final List<Map<String, dynamic>> themes = [
    {'id': 'classic', 'name': 'Classic', 'preview': '😊', 'price': 0},
    {'id': 'animals', 'name': 'Animals', 'preview': '🐶', 'price': 300},
    {'id': 'fruits', 'name': 'Fruits', 'preview': '🍎', 'price': 600},
    {'id': 'space', 'name': 'Space', 'preview': '👽', 'price': 1000},
    {'id': 'ocean', 'name': 'Ocean', 'preview': '🐠', 'price': 1500},
    {'id': 'spooky', 'name': 'Spooky', 'preview': '🎃', 'price': 2000},
    {'id': 'soon', 'name': 'More Soon', 'preview': '🔒', 'price': -1}, // -1 means unbuyable
  ];

  @override
  void initState() {
    super.initState();
    _loadUnlockedThemes();
  }

  // Load the purchased themes from local storage
  Future<void> _loadUnlockedThemes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      unlockedThemes = prefs.getStringList('unlockedThemes') ?? ['classic'];
    });
  }

  // Handle the actual transaction
  Future<void> _buyTheme(Map<String, dynamic> theme) async {
    if (GameSettings.totalCoins >= theme['price']) {
      AudioManager.playWin(); // Happy sound for a purchase!
      if (GameSettings.hapticsOn) HapticFeedback.heavyImpact();

      setState(() {
        // Deduct coins, unlock the theme, and equip it instantly
        GameSettings.totalCoins -= theme['price'] as int;
        unlockedThemes.add(theme['id']);
        GameSettings.currentTheme = theme['id'];
      });

      // Save everything to permanent storage
      StorageManager.saveEconomy();
      StorageManager.saveSettings();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('unlockedThemes', unlockedThemes);

      if (mounted) {
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${theme['name']} Theme Unlocked!', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );

        // 🚀 GOLDEN RULE: Ask for a review right after they buy a theme!
        Future.delayed(const Duration(seconds: 1), () {
          ReviewManager.triggerReview();
        });
      }
    } else {
      AudioManager.playClick();
      if (GameSettings.hapticsOn) HapticFeedback.vibrate();
      Navigator.pop(context); // Close the dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough coins!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), 
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      );
    }
  }

  // Show the confirmation popup
  void _showPurchaseDialog(Map<String, dynamic> theme) {
    AudioManager.playClick();
    if (GameSettings.hapticsOn) HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(theme['preview'], style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 10),
              Text('Unlock ${theme['name']}?', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 10),
              const Text('Do you want to permanently unlock this theme?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 28),
                  const SizedBox(width: 8),
                  Text('${theme['price']}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () { AudioManager.playClick(); Navigator.pop(context); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(15)),
                        child: const Center(child: Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _buyTheme(theme),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary, 
                          borderRadius: BorderRadius.circular(15), 
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                          border: const Border(bottom: BorderSide(color: AppTheme.primaryDark, width: 4))
                        ),
                        child: const Center(child: Text('BUY', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16))),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Theme Shop'), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        // Live Coin Counter in the top right!
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.white, 
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              border: Border.all(color: const Color(0xFFE5E9F0), width: 2),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 20),
                const SizedBox(width: 6),
                Text('${GameSettings.totalCoins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.85
                ),
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final bool isLocked = !unlockedThemes.contains(theme['id']);
                  final bool isComingSoon = theme['price'] == -1;
                  final isSelected = !isLocked && GameSettings.currentTheme == theme['id'];

                  return GestureDetector(
                    onTap: () {
                      if (isComingSoon) return;
                      
                      if (isLocked) {
                        _showPurchaseDialog(theme); // Trigger Shop Popup
                      } else {
                        // Equip unlocked theme
                        if (GameSettings.hapticsOn) HapticFeedback.selectionClick();
                        AudioManager.playPop();
                        setState(() => GameSettings.currentTheme = theme['id']);
                        StorageManager.saveSettings();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : (isLocked ? Colors.white.withValues(alpha: 0.6) : AppTheme.white),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryDark : (isLocked ? Colors.grey.shade300 : const Color(0xFFE5E9F0)), 
                          width: isSelected ? 4 : 2 
                        ),
                        boxShadow: isLocked ? [] : const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(theme['preview'], style: TextStyle(fontSize: 60, color: isLocked ? Colors.black38 : null)),
                          const SizedBox(height: 10),
                          Text(theme['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : (isLocked ? Colors.black45 : AppTheme.textDark))),
                          
                          if (isComingSoon)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('LOCKED', style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 14)),
                            )
                          else if (isLocked)
                            // Display Price Tag
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.lock_rounded, color: AppTheme.coinGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${theme['price']}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.coinDark, fontSize: 16)),
                                ],
                              ),
                            )
                          else if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
                            )
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