class GameSettings {
  static bool isFirstTime = true;
  static bool isAgeVerified = false; 
  static int playerAge = 0;
  static String playerName = 'Player';
  static String avatar = '😊';
  static int dailyPuzzlesSolved = 0;

  static String currentTheme = 'classic'; 
  static bool soundOn = true;
  static bool musicOn = true;
  static bool hapticsOn = true;
  
  static int totalCoins = 0;
  static int availableHints = 5; 
  static const int hintCost = 20;
  static String lastDailyPuzzleDate = ''; 

  static String getEmoji(int moodIndex) {

    if (currentTheme == 'animals') { return ['🐶', '🐯', '🐨'][moodIndex]; }
    if (currentTheme == 'fruits') { return ['🍎', '🌶️', '🍇'][moodIndex]; }
    if (currentTheme == 'space') { return ['👽', '👾', '🚀'][moodIndex]; }
    if (currentTheme == 'ocean') { return ['🐠', '🐡', '🐙'][moodIndex]; }
    if (currentTheme == 'spooky') { return ['🎃', '👻', '💀'][moodIndex]; }
    // Default classic fallback
    return ['😊', '😡', '😴'][moodIndex];
  }
  
}
