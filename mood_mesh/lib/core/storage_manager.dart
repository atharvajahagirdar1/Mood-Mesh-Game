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
      if (stars != null) LevelData.levelStars[i] = stars;
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
  }

  static Future<void> saveProgress(int levelId, int stars) async {
    await _prefs.setInt('max_level', LevelData.maxUnlockedLevel);
    await _prefs.setInt('stars_$levelId', stars);
  }
}
