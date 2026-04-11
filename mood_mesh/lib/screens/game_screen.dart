import 'package:flutter/material.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/dot_widget.dart';
import '../widgets/path_painter.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';
import 'level_complete_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  final bool isDaily;
  const GameScreen({Key? key, required this.level, this.isDaily = false}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<Mood> grid;
  late int movesLeft;
  List<int> path = [];
  bool isProcessing = false;

  // Neon Hint Path System
  List<int> hintedPath = [];
  bool isHintActive = false;
  late AnimationController _hintPulseController;

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _initLevel();
  }
  
  @override
  void dispose() {
    _hintPulseController.dispose();
    super.dispose();
  }

  void _initLevel() {
    grid = widget.level.initialGrid.map((val) => Mood.values[val]).toList();
    movesLeft = widget.level.maxMoves;
    path = [];
    isProcessing = false;
    isHintActive = false;
    hintedPath.clear();
    setState(() {});
  }

  void _executeHint() {
    List<int> bestPath = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == Mood.happy) {
        List<int> currentPath = [i];
        _dfsFindPath(i, currentPath, bestPath);
        if (bestPath.length >= 3) break; 
      }
    }
    
    if (bestPath.length > 1) {
      setState(() {
        hintedPath = List.from(bestPath);
        isHintActive = true;
      });
    }
  }

  void _dfsFindPath(int current, List<int> currentPath, List<int> bestPath) {
    if (currentPath.length > bestPath.length) {
      bestPath.clear();
      bestPath.addAll(currentPath);
    }
    int r = current ~/ widget.level.cols;
    int c = current % widget.level.cols;
    List<List<int>> dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]];
    
    for (var d in dirs) {
      int nr = r + d[0], nc = c + d[1];
      if (nr >= 0 && nr < widget.level.rows && nc >= 0 && nc < widget.level.cols) {
        int nIdx = nr * widget.level.cols + nc;
        if (grid[nIdx] == Mood.happy && !currentPath.contains(nIdx)) {
          currentPath.add(nIdx);
          _dfsFindPath(nIdx, currentPath, bestPath);
          currentPath.removeLast();
        }
      }
    }
  }

  void _useHint() {
    if (movesLeft <= 0 || isProcessing || isHintActive) return;

    if (GameSettings.availableHints > 0) {
      setState(() => GameSettings.availableHints--);
      _executeHint();
    } else if (GameSettings.totalCoins >= GameSettings.hintCost) {
      setState(() => GameSettings.totalCoins -= GameSettings.hintCost);
      _executeHint();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not enough coins for a hint!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        )
      );
    }
  }

  void _triggerRipple() async {
    if (path.length <= 1) {
      setState(() => path.clear());
      return;
    }

    setState(() => isProcessing = true);
    Set<int> pathSet = path.toSet();
    Set<int> neighborsToChange = {};

    for (int idx in path) {
      int r = idx ~/ widget.level.cols;
      int c = idx % widget.level.cols;
      List<List<int>> potentialNeighbors = [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]];

      for (var n in potentialNeighbors) {
        int nr = n[0], nc = n[1];
        if (nr >= 0 && nr < widget.level.rows && nc >= 0 && nc < widget.level.cols) {
          int nIdx = nr * widget.level.cols + nc;
          if (!pathSet.contains(nIdx)) neighborsToChange.add(nIdx);
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      for (int nIdx in neighborsToChange) {
        if (grid[nIdx] == Mood.happy) grid[nIdx] = Mood.angry;
        else if (grid[nIdx] == Mood.angry) grid[nIdx] = Mood.sleepy;
        else grid[nIdx] = Mood.happy;
      }
      movesLeft--;
      path.clear();
      isProcessing = false;
      _checkWinLoss();
    });
  }

  void _checkWinLoss() {
    bool isWin = grid.every((mood) => mood == Mood.happy);
    if (isWin) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LevelCompleteScreen(level: widget.level, movesLeft: movesLeft, isDaily: widget.isDaily)));
    } else if (movesLeft <= 0) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameOverScreen(level: widget.level, isDaily: widget.isDaily)));
    }
  }

  void _handlePanStart(Offset localPosition, Size boardSize) {
    if (isHintActive) {
      setState(() {
        isHintActive = false;
        hintedPath.clear();
      });
    }
    _handlePanUpdate(localPosition, boardSize);
  }

  void _handlePanUpdate(Offset localPosition, Size boardSize) {
    if (isProcessing) return;

    double cellWidth = boardSize.width / widget.level.cols;
    double cellHeight = boardSize.height / widget.level.rows;
    int c = (localPosition.dx / cellWidth).floor();
    int r = (localPosition.dy / cellHeight).floor();

    if (c < 0 || c >= widget.level.cols || r < 0 || r >= widget.level.rows) return;
    int idx = r * widget.level.cols + c;

    if (path.isEmpty) {
      if (grid[idx] == Mood.happy) setState(() => path.add(idx));
      return;
    }

    if (path.length > 1 && path[path.length - 2] == idx) {
      setState(() => path.removeLast());
      return;
    }

    if (!path.contains(idx)) {
      int lastIdx = path.last;
      int lastR = lastIdx ~/ widget.level.cols;
      int lastC = lastIdx % widget.level.cols;
      bool isAdjacent = (r - lastR).abs() + (c - lastC).abs() == 1;

      if (isAdjacent && grid[idx] == Mood.happy) setState(() => path.add(idx));
    }
  }

  @override
  Widget build(BuildContext context) {
    String topTitle = widget.isDaily ? 'DAILY PUZZLE' : 'LEVEL ${widget.level.id}';
    bool hasFreeHints = GameSettings.availableHints > 0;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GameIconButton(icon: Icons.pause_rounded, color: AppTheme.accent, shadowColor: AppTheme.accentDark, onTap: () => Navigator.pop(context)),
                      Text(topTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      GameIconButton(icon: Icons.refresh_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, onTap: _initLevel),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: AppTheme.gameBoxDecoration,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("MOVES LEFT: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                        Text("$movesLeft", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: movesLeft <= 3 ? AppTheme.accent : AppTheme.secondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: widget.level.cols / widget.level.rows,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onPanStart: (details) => _handlePanStart(details.localPosition, constraints.biggest),
                              onPanUpdate: (details) => _handlePanUpdate(details.localPosition, constraints.biggest),
                              onPanEnd: (_) => _triggerRipple(),
                              child: Container(
                                decoration: AppTheme.gameBoxDecoration,
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    // 1. Neon Pulsing Hint Path (Underneath)
                                    if (isHintActive && hintedPath.isNotEmpty)
                                      AnimatedBuilder(
                                        animation: _hintPulseController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: constraints.biggest,
                                            painter: PathPainter(
                                              path: hintedPath, 
                                              cols: widget.level.cols, 
                                              rows: widget.level.rows,
                                              pathColor: AppTheme.neonBlue, 
                                              strokeWidth: 20.0, 
                                              isNeon: true,
                                              pulseValue: _hintPulseController.value
                                            ),
                                          );
                                        }
                                      ),
                                    
                                    // 2. Solid Player Draw Path
                                    if (path.isNotEmpty)
                                      CustomPaint(
                                        size: constraints.biggest,
                                        painter: PathPainter(
                                          path: path, 
                                          cols: widget.level.cols, 
                                          rows: widget.level.rows,
                                          pathColor: Colors.white, 
                                          strokeWidth: 18.0,
                                          isNeon: false,
                                        ),
                                      ),

                                    // 3. The Grid
                                    GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.level.cols),
                                      itemCount: grid.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DotWidget(
                                            key: ValueKey(index),
                                            mood: grid[index],
                                            isInPath: path.contains(index),
                                            isLast: path.isNotEmpty && path.last == index,
                                            isHighlighted: false, 
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  GameButton(
                    title: hasFreeHints 
                        ? 'USE HINT (${GameSettings.availableHints})' 
                        : 'BUY HINT (${GameSettings.hintCost}🪙)',
                    icon: Icons.lightbulb_rounded,
                    color: hasFreeHints ? AppTheme.primary : AppTheme.coinGold,
                    shadowColor: hasFreeHints ? AppTheme.primaryDark : AppTheme.coinDark,
                    isSmall: true,
                    onTap: _useHint,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
