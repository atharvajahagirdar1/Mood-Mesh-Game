import '../models/level.dart';

class LevelData {
  static int maxUnlockedLevel = 1;
  static Map<int, int> levelStars = {}; // Store highest stars achieved per level

  static final List<Level> allLevels = [
    Level(id: 1, cols: 3, rows: 3, maxMoves: 5, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [2, 2, 2, 0, 0, 0, 2, 2, 2]),
    Level(id: 2, cols: 3, rows: 3, maxMoves: 6, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [1, 1, 1, 0, 0, 0, 1, 1, 1]),
    Level(id: 3, cols: 3, rows: 3, maxMoves: 5, movesFor3Stars: 4, movesFor2Stars: 2, initialGrid: [0, 2, 0, 0, 2, 0, 0, 2, 0]),
    Level(id: 4, cols: 3, rows: 3, maxMoves: 8, movesFor3Stars: 6, movesFor2Stars: 3, initialGrid: [0, 1, 0, 0, 1, 0, 0, 1, 0]),
    Level(id: 5, cols: 4, rows: 4, maxMoves: 12, movesFor3Stars: 8, movesFor2Stars: 4, initialGrid: [2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0]),
    Level(id: 6, cols: 4, rows: 4, maxMoves: 15, movesFor3Stars: 10, movesFor2Stars: 5, initialGrid: [1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0]),
    Level(id: 7, cols: 5, rows: 5, maxMoves: 20, movesFor3Stars: 15, movesFor2Stars: 8, initialGrid: [2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2]),
    Level(id: 8, cols: 5, rows: 5, maxMoves: 25, movesFor3Stars: 18, movesFor2Stars: 10, initialGrid: [0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0, 0, 2, 0, 2, 0]),
  ];

  static final Level dailyLevel = Level(
    id: 999, cols: 5, rows: 5, maxMoves: 20, movesFor3Stars: 15, movesFor2Stars: 10, 
    initialGrid: [2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2]
  );

  static void unlockNextLevel(int currentLevelId) {
    if (currentLevelId == maxUnlockedLevel && currentLevelId < allLevels.length) {
      maxUnlockedLevel++;
    }
  }

  static void saveStars(int levelId, int stars) {
    if (!levelStars.containsKey(levelId) || stars > levelStars[levelId]!) {
      levelStars[levelId] = stars;
    }
  }

  static Level getLevel(int id) {
    return allLevels.firstWhere((lvl) => lvl.id == id);
  }
}
