import 'dart:math';
import '../models/level.dart';

class LevelData {
  static int maxUnlockedLevel = 1;
  static Map<int, int> levelStars = {}; 

  static final List<Level> allLevels = List.generate(200, (index) => _generateLevel(index + 1));

  static Level _generateLevel(int levelSeed, {int? overrideId, bool forceDaily = false}) {
    Random rand = Random(levelSeed + 1000); 

    int cols = 3, rows = 3;
    if (forceDaily) {
      cols = 5; rows = 5;
    } else {
      if (levelSeed > 10) { cols = 4; rows = 4; }
      if (levelSeed > 50) { cols = 5; rows = 5; }
      if (levelSeed > 120) { cols = 6; rows = 6; }
    }

    int chapter = forceDaily ? 10 : (levelSeed - 1) ~/ 10;
    int levelInChapter = forceDaily ? 8 : (levelSeed - 1) % 10;
    
    int baseMoves = forceDaily ? 8 : 2 + (chapter * 0.7).toInt(); 
    List<int> sawtooth = [0, 1, 1, 2, 2, 3, 4, 5, 6, -1]; 
    int requiredMoves = baseMoves + sawtooth[levelInChapter];
    if (requiredMoves < 1) requiredMoves = 1;

    List<int> grid = List.filled(cols * rows, 0);

    for (int m = 0; m < requiredMoves; m++) {
      int pathLen = rand.nextInt(2) + 1; 
      List<int> path = [];

      List<int> happyDots = [];
      for (int i = 0; i < grid.length; i++) {
        if (grid[i] == 0) happyDots.add(i);
      }
      if (happyDots.isEmpty) break; 
      
      int startDot = happyDots[rand.nextInt(happyDots.length)];
      path.add(startDot);

      if (pathLen == 2) {
        int r = startDot ~/ cols;
        int c = startDot % cols;
        List<int> neighbors = [];
        if (r > 0) neighbors.add(startDot - cols);
        if (r < rows - 1) neighbors.add(startDot + cols);
        if (c > 0) neighbors.add(startDot - 1);
        if (c < cols - 1) neighbors.add(startDot + 1);

        List<int> happyNeighbors = neighbors.where((n) => grid[n] == 0).toList();
        if (happyNeighbors.isNotEmpty) {
          path.add(happyNeighbors[rand.nextInt(happyNeighbors.length)]);
        }
      }

      Set<int> pathSet = path.toSet();
      Set<int> neighborsToChange = {};

      for (int idx in path) {
        int r = idx ~/ cols;
        int c = idx % cols;
        List<List<int>> dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
        for (var d in dirs) {
          int nr = r + d[0], nc = c + d[1];
          if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
            int nIdx = nr * cols + nc;
            if (!pathSet.contains(nIdx)) neighborsToChange.add(nIdx);
          }
        }
      }

      for (int nIdx in neighborsToChange) {
        grid[nIdx] = (grid[nIdx] + 2) % 3;
      }
    }

    int maxMoves = forceDaily 
        ? requiredMoves + 6 
        : requiredMoves + 4 + (levelSeed ~/ 15); 
    
    if (levelSeed == 1 && !forceDaily) {
      grid = [2, 2, 2, 0, 0, 0, 2, 2, 2];
      requiredMoves = 1;
      maxMoves = 5;
    }

    return Level(
      id: overrideId ?? levelSeed,
      cols: cols,
      rows: rows,
      maxMoves: maxMoves,
      movesFor3Stars: requiredMoves,
      movesFor2Stars: requiredMoves + (maxMoves - requiredMoves) ~/ 2,
      initialGrid: grid,
    );
  }

  static Level get dailyLevel {
    DateTime now = DateTime.now();
    int seed = now.year * 10000 + now.month * 100 + now.day;
    return _generateLevel(seed, overrideId: 999, forceDaily: true);
  }

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
    if (id == 999) return dailyLevel;
    return allLevels.firstWhere((lvl) => lvl.id == id);
  }
}
