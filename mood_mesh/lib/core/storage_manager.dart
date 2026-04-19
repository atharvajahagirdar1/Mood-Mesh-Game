import 'package:shared_preferences/shared_preferences.dart';
import 'game_settings.dart';
import 'level_data.dart';

class StorageManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadData();
  }

  static void _loadData() {
    GameSettings.isFirstTime = _prefs.getBool('is_first_time') ?? true;
    GameSettings.isAgeVerified = _prefs.getBool('is_age_verified') ?? false;
    GameSettings.playerAge = _prefs.getInt('player_age') ?? 0;
    GameSettings.playerName = _prefs.getString('player_name') ?? 'Player';
    GameSettings.avatar = _prefs.getString('avatar') ?? '😊';
    GameSettings.dailyPuzzlesSolved = _prefs.getInt('daily_solved') ?? 0;

    GameSettings.totalCoins = _prefs.getInt('coins') ?? 0;
    GameSettings.availableHints = _prefs.getInt('hints') ?? 5;
    GameSettings.currentTheme = _prefs.getString('theme') ?? 'classic';
    GameSettings.soundOn = _prefs.getBool('sound') ?? true;
    GameSettings.musicOn = _prefs.getBool('music') ?? true;
    GameSettings.hapticsOn = _prefs.getBool('haptics') ?? true;
    GameSettings.lastDailyPuzzleDate = _prefs.getString('last_daily') ?? '';
    LevelData.maxUnlockedLevel = _prefs.getInt('max_level') ?? 1;

    for (int i = 1; i <= 200; i++) {
      int? stars = _prefs.getInt('stars_$i');
      if (stars != null) {
        LevelData.levelStars[i] = stars;
      }
    }
  }

  static Future<void> saveSettings() async {
    await _prefs.setString('theme', GameSettings.currentTheme);
    await _prefs.setBool('sound', GameSettings.soundOn);
    await _prefs.setBool('music', GameSettings.musicOn);
    await _prefs.setBool('haptics', GameSettings.hapticsOn);
  }

  static Future<void> saveEconomy() async {
    await _prefs.setInt('coins', GameSettings.totalCoins);
    await _prefs.setInt('hints', GameSettings.availableHints);
    await _prefs.setString('last_daily', GameSettings.lastDailyPuzzleDate);
    await _prefs.setInt('daily_solved', GameSettings.dailyPuzzlesSolved);
  }

  static Future<void> saveProfile() async {
    await _prefs.setBool('is_first_time', GameSettings.isFirstTime);
    await _prefs.setBool('is_age_verified', GameSettings.isAgeVerified);
    await _prefs.setInt('player_age', GameSettings.playerAge);
    await _prefs.setString('player_name', GameSettings.playerName);
    await _prefs.setString('avatar', GameSettings.avatar);
  }

  static Future<void> saveProgress(int levelId, int stars) async {
    await _prefs.setInt('max_level', LevelData.maxUnlockedLevel);
    await _prefs.setInt('stars_$levelId', stars);
  }
}
