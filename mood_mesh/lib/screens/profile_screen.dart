import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/audio_manager.dart';
import '../core/level_data.dart';
import '../widgets/animated_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://policies.google.com/privacy'); 
    if (!await launchUrl(url)) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Privacy Policy'))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalStars = LevelData.levelStars.values.fold(0, (sum, stars) => sum + stars);
    int levelsCleared = LevelData.maxUnlockedLevel > 1 ? LevelData.maxUnlockedLevel - 1 : 0;
    
    bool isNovice = levelsCleared >= 10;
    bool isMaster = totalStars >= 100;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Player Profile'), 
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile Header
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    builder: (context, val, child) {
                      return Transform.scale(
                        scale: val,
                        child: Opacity(
                          opacity: val.clamp(0.0, 1.0), // 🚀 FIX: Clamp prevents the Red Screen crash!
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white, shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primary, width: 4),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8))],
                                ),
                                child: Text(GameSettings.avatar, style: const TextStyle(fontSize: 60)),
                              ),
                              const SizedBox(height: 15),
                              Text(GameSettings.playerName, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 30),
                  
                  // Stats Dashboard
                  _buildSectionTitle('Stats Dashboard'),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Stars', '$totalStars', Icons.star_rounded, AppTheme.primary)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatCard('Cleared', '$levelsCleared / 200', Icons.check_circle_rounded, AppTheme.success)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildStatCard('Daily Puzzles Solved', '${GameSettings.dailyPuzzlesSolved}', Icons.calendar_month_rounded, AppTheme.secondary, isFullWidth: true),
                  
                  const SizedBox(height: 30),
                  
                  // Achievements
                  _buildSectionTitle('Achievements'),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildBadge('Novice', 'Clear 10 Levels', '🌱', isNovice)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildBadge('Master', 'Collect 100 Stars', '👑', isMaster)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Settings
                  _buildSectionTitle('Settings'),
                  const SizedBox(height: 15),
                  Container(
                    decoration: AppTheme.gameBoxDecoration,
                    child: Column(
                      children: [
                        _buildToggle('Sound Effects', Icons.volume_up_rounded, GameSettings.soundOn, (val) {
                          AudioManager.playClick();
                          setState(() => GameSettings.soundOn = val);
                          StorageManager.saveSettings();
                        }),
                        const Divider(height: 1),
                        _buildToggle('Music', Icons.music_note_rounded, GameSettings.musicOn, (val) {
                          AudioManager.playClick();
                          setState(() => GameSettings.musicOn = val);
                          StorageManager.saveSettings();
                          val ? AudioManager.playBgm() : AudioManager.stopBgm();
                        }),
                        const Divider(height: 1),
                        _buildToggle('Haptics', Icons.vibration_rounded, GameSettings.hapticsOn, (val) {
                          AudioManager.playClick();
                          setState(() => GameSettings.hapticsOn = val);
                          StorageManager.saveSettings();
                        }),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          leading: const Icon(Icons.privacy_tip_rounded, color: AppTheme.primary, size: 28),
                          title: const Text('Privacy Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textLight),
                          onTap: () {
                            AudioManager.playClick();
                            _launchPrivacyPolicy();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.gameBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isFullWidth ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              if (isFullWidth) const SizedBox(width: 10),
              if (isFullWidth) Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
            ],
          ),
          SizedBox(height: isFullWidth ? 5 : 10),
          if (!isFullWidth) Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight), textAlign: TextAlign.center),
          if (!isFullWidth) const SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildBadge(String title, String desc, String emoji, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isUnlocked ? AppTheme.primary : const Color(0xFFE5E9F0), width: 2),
        boxShadow: isUnlocked ? const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))] : [],
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 40, color: isUnlocked ? null : Colors.black26)),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isUnlocked ? AppTheme.textDark : Colors.black38)),
          const SizedBox(height: 5),
          Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? AppTheme.textLight : Colors.black26)),
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
