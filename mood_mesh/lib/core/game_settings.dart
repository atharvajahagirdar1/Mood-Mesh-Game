class GameSettings {
  static String currentTheme = 'classic'; 
  static bool soundOn = true;
  static bool musicOn = true;
  static bool hapticsOn = true;
  
  // Coin & Economy System
  static int totalCoins = 0;
  static int availableHints = 5; // Start with 5 free hints
  static const int hintCost = 20;

  static String getEmoji(int moodIndex) {
    if (currentTheme == 'animals') {
      return ['🐶', '🐯', '🐨'][moodIndex]; 
    } else if (currentTheme == 'fruits') {
      return ['🍎', '🌶️', '🍇'][moodIndex]; 
    }
    return ['😊', '😡', '😴'][moodIndex];
  }
}
