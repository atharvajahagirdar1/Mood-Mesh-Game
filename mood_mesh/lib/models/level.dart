enum Mood { happy, angry, sleepy }

class Level {
  final int id;
  final int cols;
  final int rows;
  final int maxMoves;
  final int movesFor3Stars;
  final int movesFor2Stars;
  final List<int> initialGrid;

  Level({
    required this.id,
    required this.cols,
    required this.rows,
    required this.maxMoves,
    required this.movesFor3Stars,
    required this.movesFor2Stars,
    required this.initialGrid,
  });
}
