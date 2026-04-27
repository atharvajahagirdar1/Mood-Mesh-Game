import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // List to track which rewards the player has already claimed
  List<String> claimedAchievements = [];

  @override
  void initState() {
    super.initState();
    _loadClaimedAchievements();
  }

  // Load claimed data securely from device storage
  Future<void> _loadClaimedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      claimedAchievements = prefs.getStringList('claimedAchievements') ?? [];
    });
  }

  // Logic to actually give the player their coins and hints!
  Future<void> _claimReward(String id, int coins, int hints) async {
    AudioManager.playClick();
    if (GameSettings.hapticsOn) HapticFeedback.heavyImpact();

    setState(() {
      // Add the rewards
      GameSettings.totalCoins += coins;
      GameSettings.availableHints += hints;
      // Mark as claimed so they can't spam the button
      claimedAchievements.add(id);
    });

    // Save the new economy stats and the claimed badge list
    StorageManager.saveEconomy();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('claimedAchievements', claimedAchievements);

    // Show a happy message!
    if (mounted) {
      String rewardText = coins > 0 ? '+$coins Coins!' : '+$hints Hints!';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward Claimed: $rewardText', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        )
      );
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://sites.google.com/view/moodmeshprivacypolicy/home'); 
    if (!await launchUrl(url)) {
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch Privacy Policy'))); }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalStars = LevelData.levelStars.values.fold(0, (sum, stars) => sum + stars);
    int levelsCleared = LevelData.maxUnlockedLevel > 1 ? LevelData.maxUnlockedLevel - 1 : 0;
    int perfectLevels = LevelData.levelStars.values.where((stars) => stars == 3).length;
    int dailies = GameSettings.dailyPuzzlesSolved;
    int coins = GameSettings.totalCoins;
    int hints = GameSettings.availableHints;

    String today = DateTime.now().toIso8601String().split('T')[0];
    bool isDailySolvedToday = GameSettings.lastDailyPuzzleDate == today;

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
                          opacity: val.clamp(0.0, 1.0),
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
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Perfect Levels', '$perfectLevels', Icons.diamond_rounded, AppTheme.neonBlue)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatCard('Total Dailies', '$dailies', Icons.calendar_month_rounded, AppTheme.secondary)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard("Today's Daily", isDailySolvedToday ? 'Solved' : 'Pending', isDailySolvedToday ? Icons.check_circle_rounded : Icons.help_outline_rounded, isDailySolvedToday ? AppTheme.success : AppTheme.accent)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildStatCard('Hints Left', '$hints', Icons.lightbulb_rounded, AppTheme.primary)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // --- ACHIEVEMENTS ---
                  
                  // TRACK 1: THE JOURNEY (Levels)
                  _buildSectionTitle('The Journey (Progression)'),
                  const SizedBox(height: 15),
                  _buildProgressBadge('prog_journey_10', 'Novice', 'Clear 10 Levels', '🌱', levelsCleared, 10, 50, 0),
                  _buildProgressBadge('prog_journey_50', 'Champion', 'Clear 50 Levels', '🏆', levelsCleared, 50, 200, 0),
                  _buildProgressBadge('prog_journey_100', 'Legend', 'Clear 100 Levels', '🏅', levelsCleared, 100, 500, 0),
                  _buildProgressBadge('prog_journey_200', 'Grandmaster', 'Clear 200 Levels', '🌌', levelsCleared, 200, 1000, 0),
                  
                  const SizedBox(height: 30),

                  // TRACK 2: MASTERY (Stars & Flawless)
                  _buildSectionTitle('Mastery (Skill)'),
                  const SizedBox(height: 15),
                  _buildProgressBadge('prog_master_100', 'Master', 'Collect 100 Stars', '⭐', totalStars, 100, 0, 5),
                  _buildProgressBadge('prog_master_300', 'Superstar', 'Collect 300 Stars', '🌟', totalStars, 300, 0, 15),
                  _buildProgressBadge('prog_flawless_50', 'Flawless', 'Fifty 3-Star Levels', '✨', perfectLevels, 50, 1000, 0),

                  const SizedBox(height: 30),

                  // TRACK 3: DEDICATION & ECONOMY (Habits)
                  _buildSectionTitle('Dedication (Habits)'),
                  const SizedBox(height: 15),
                  _buildProgressBadge('prog_habit_7', 'Dedicated', '7 Daily Puzzles', '📅', dailies, 7, 100, 0),
                  _buildProgressBadge('prog_habit_30', 'Scholar', '30 Daily Puzzles', '📚', dailies, 30, 500, 0),
                  _buildProgressBadge('prog_eco_20', 'Brainiac', 'Save 20 Hints', '🧠', hints, 20, 500, 0),
                  _buildProgressBadge('prog_eco_500', 'Tycoon', 'Hoard 500 Coins', '💰', coins, 500, 0, 10),
                  _buildProgressBadge('prog_eco_1000', 'Hoarder', 'Hoard 1,000 Coins', '🐉', coins, 1000, 0, 25),

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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: AppTheme.gameBoxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title, 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight), 
            textAlign: TextAlign.center, 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Completely rewritten logic to guarantee the Claim Button shows properly!
  Widget _buildProgressBadge(String id, String title, String desc, String emoji, int current, int target, int coinReward, int hintReward) {
    bool isUnlocked = current >= target;
    bool isClaimed = claimedAchievements.contains(id);
    double progressPercent = (current / target).clamp(0.0, 1.0);
    
    String rewardDisplay = coinReward > 0 ? '+$coinReward 🪙' : '+$hintReward 💡';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isClaimed ? Colors.grey.shade50 : (isUnlocked ? Colors.white : AppTheme.backgroundDark.withAlpha(128)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isClaimed ? Colors.grey.shade300 : (isUnlocked ? AppTheme.primary : const Color(0xFFE5E9F0)), width: 2),
        boxShadow: (isUnlocked && !isClaimed) ? const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))] : [],
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(
              color: isUnlocked ? AppTheme.backgroundDark : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 32, color: isUnlocked ? null : Colors.black26))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isUnlocked ? AppTheme.textDark : Colors.black38)),
                    if (!isUnlocked) Text('${(progressPercent * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    if (isClaimed) const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 24),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isUnlocked ? AppTheme.textLight : Colors.black26)),
                const SizedBox(height: 10),
                
                // Progress Bar (Always visible, changes to grey when claimed)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: isClaimed ? 1.0 : progressPercent,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(isClaimed ? Colors.grey.shade400 : (isUnlocked ? AppTheme.success : AppTheme.primary)),
                  ),
                ),
                const SizedBox(height: 10),

                // THE CLAIM BUTTON LOGIC
                if (isClaimed)
                  Text('Claimed: $rewardDisplay', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))
                else if (isUnlocked && !isClaimed)
                  GestureDetector(
                    onTap: () => _claimReward(id, coinReward, hintReward),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                      ),
                      child: Text('CLAIM $rewardDisplay!', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5)),
                    ),
                  )
                else
                  Text('Reward: $rewardDisplay', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDark)),
              ],
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