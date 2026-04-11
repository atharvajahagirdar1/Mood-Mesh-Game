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
