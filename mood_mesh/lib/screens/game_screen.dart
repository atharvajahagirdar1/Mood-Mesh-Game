import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/audio_manager.dart';
import '../core/ad_manager.dart';
import '../widgets/dot_widget.dart';
import '../widgets/path_painter.dart';
import '../widgets/game_button.dart';
import '../widgets/animated_background.dart';
import 'level_complete_screen.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  final bool isDaily;
  const GameScreen({super.key, required this.level, this.isDaily = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late List<Mood> grid;
  late int movesLeft;
  List<int> path = [];
  bool isProcessing = false;

  List<int> hintedPath = [];
  bool isHintActive = false;
  late AnimationController _hintPulseController;

  // 🚀 UPGRADED Tutorial Variables
  final GlobalKey boardKey = GlobalKey(); 
  late TutorialCoachMark tutorialCoachMark;
  List<int> tutorialPath = []; 
  bool isTutorialActive = false; 

  @override
  void initState() {
    super.initState();
    _hintPulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _initLevel();

    if (widget.level.id == 1 && !widget.isDaily) {
      _safeLaunchTutorial();
    }
  }

  void _safeLaunchTutorial() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        
        if (tutorialPath.length >= 3 && boardKey.currentContext != null) {
          showTutorial();
        } else if (tutorialPath.length >= 3) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && boardKey.currentContext != null) {
              showTutorial();
            }
          });
        }
      });
    });
  }
  
  @override
  void dispose() {
    _hintPulseController.dispose();
    super.dispose();
  }

  void _initLevel() {
    grid = widget.level.initialGrid.map((val) => Mood.values[val]).toList();
    
    tutorialPath.clear();
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == Mood.happy) {
        List<int> currentPath = [i];
        _dfsFindPath(i, currentPath, tutorialPath);
        if (tutorialPath.length >= 3) break;
      }
    }

    movesLeft = widget.level.maxMoves;
    path = [];
    isProcessing = false;
    isHintActive = false;
    isTutorialActive = false;
    hintedPath.clear();
    setState(() {});
  }

  void showTutorial() {
    setState(() {
      isTutorialActive = true;
      hintedPath = List.from(tutorialPath);
      isHintActive = true; 
    });

    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: const Color(0xFF11111B), 
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.85, 
      onFinish: () {
        if (mounted) {
          setState(() {
            isTutorialActive = false;
            isHintActive = false;
            hintedPath.clear();
          });
        }
      },
      onSkip: () { 
        if (mounted) {
          setState(() {
            isTutorialActive = false;
            isHintActive = false;
            hintedPath.clear();
          });
        }
        return true;
      },
    )..show(context: context);
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "BoardTarget",
        keyTarget: boardKey, 
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect, 
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top, 
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Follow the Finger!",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Touch, drag, and connect all the Happy (😊) emojis to send a ripple and flip the board!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  void _executeHint() {
    List<int> bestPath = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == Mood.happy) {
        List<int> currentPath = [i];
        _dfsFindPath(i, currentPath, bestPath);
        if (bestPath.length >= 3) { break; } 
      }
    }
    
    if (bestPath.length > 1) {
      AudioManager.playClick();
      setState(() { hintedPath = List.from(bestPath); isHintActive = true; });
      StorageManager.saveEconomy(); 
    }
  }

  void _dfsFindPath(int current, List<int> currentPath, List<int> bestPath) {
    if (currentPath.length > bestPath.length) { bestPath.clear(); bestPath.addAll(currentPath); }
    int r = current ~/ widget.level.cols; int c = current % widget.level.cols;
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
    if (movesLeft <= 0 || isProcessing || isHintActive) { return; }
    if (GameSettings.availableHints > 0) {
      setState(() => GameSettings.availableHints--); _executeHint();
    } else if (GameSettings.totalCoins >= GameSettings.hintCost) {
      setState(() => GameSettings.totalCoins -= GameSettings.hintCost); _executeHint();
    } else {
      if (GameSettings.hapticsOn) { HapticFeedback.heavyImpact(); }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Not enough coins for a hint!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.accent, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))));
    }
  }

  void _triggerRipple() async {
    if (path.length <= 1) { setState(() => path.clear()); return; }

    if (GameSettings.hapticsOn) { HapticFeedback.mediumImpact(); }
    setState(() => isProcessing = true);
    
    Set<int> pathSet = path.toSet(); Set<int> neighborsToChange = {};
    for (int idx in path) {
      int r = idx ~/ widget.level.cols; int c = idx % widget.level.cols;
      List<List<int>> potentialNeighbors = [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]];
      for (var n in potentialNeighbors) {
        int nr = n[0], nc = n[1];
        if (nr >= 0 && nr < widget.level.rows && nc >= 0 && nc < widget.level.cols) {
          int nIdx = nr * widget.level.cols + nc;
          if (!pathSet.contains(nIdx)) { neighborsToChange.add(nIdx); }
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    setState(() {
      for (int nIdx in neighborsToChange) {
        if (grid[nIdx] == Mood.happy) {
          grid[nIdx] = Mood.angry;
        } else if (grid[nIdx] == Mood.angry) {
          grid[nIdx] = Mood.sleepy;
        } else {
          grid[nIdx] = Mood.happy;
        }
      }
      movesLeft--; path.clear(); isProcessing = false; _checkWinLoss();
    });
  }

  // 🚀 RESTORED: The Win/Loss check function!
  void _checkWinLoss() {
    bool isWin = grid.every((mood) => mood == Mood.happy);
    if (isWin) {
      if (widget.isDaily) {
        GameSettings.lastDailyPuzzleDate = DateTime.now().toIso8601String().split('T')[0];
        GameSettings.dailyPuzzlesSolved += 1;
        StorageManager.saveEconomy();
      }
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LevelCompleteScreen(level: widget.level, movesLeft: movesLeft, isDaily: widget.isDaily)));
    } else if (movesLeft <= 0) {
      if (GameSettings.hapticsOn) { HapticFeedback.heavyImpact(); }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameOverScreen(level: widget.level, isDaily: widget.isDaily)));
    }
  }

  void _handlePanStart(Offset localPosition, Size boardSize) {
    if (isHintActive) { setState(() { isHintActive = false; hintedPath.clear(); }); }
    _handlePanUpdate(localPosition, boardSize);
  }

  void _handlePanUpdate(Offset localPosition, Size boardSize) {
    if (isProcessing) { return; }
    double cellWidth = boardSize.width / widget.level.cols; double cellHeight = boardSize.height / widget.level.rows;
    int c = (localPosition.dx / cellWidth).floor(); int r = (localPosition.dy / cellHeight).floor();
    if (c < 0 || c >= widget.level.cols || r < 0 || r >= widget.level.rows) { return; }
    int idx = r * widget.level.cols + c;
    
    if (path.isNotEmpty && path.last == idx) { return; }

    if (path.isEmpty) {
      if (grid[idx] == Mood.happy) {
        setState(() => path.add(idx));
        if (GameSettings.hapticsOn) { HapticFeedback.selectionClick(); }
        AudioManager.playPop(); 
      }
      return;
    }

    if (path.length > 1 && path[path.length - 2] == idx) {
      setState(() => path.removeLast());
      if (GameSettings.hapticsOn) { HapticFeedback.selectionClick(); }
      return;
    }

    if (!path.contains(idx)) {
      int lastIdx = path.last; int lastR = lastIdx ~/ widget.level.cols; int lastC = lastIdx % widget.level.cols;
      bool isAdjacent = (r - lastR).abs() + (c - lastC).abs() == 1;

      if (isAdjacent && grid[idx] == Mood.happy) {
        setState(() => path.add(idx));
        if (GameSettings.hapticsOn) { HapticFeedback.selectionClick(); }
        AudioManager.playPop(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String topTitle = widget.isDaily ? 'DAILY PUZZLE' : 'LEVEL ${widget.level.id}';
    bool hasFreeHints = GameSettings.availableHints > 0;

    return Scaffold(
      bottomNavigationBar: const BannerAdWidget(), 
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
                                key: boardKey, 
                                decoration: AppTheme.gameBoxDecoration,
                                padding: const EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    if (isHintActive && hintedPath.isNotEmpty)
                                      AnimatedBuilder(
                                        animation: _hintPulseController,
                                        builder: (context, child) {
                                          return CustomPaint(size: constraints.biggest, painter: PathPainter(path: hintedPath, cols: widget.level.cols, rows: widget.level.rows, pathColor: AppTheme.neonBlue, strokeWidth: 20.0, isNeon: true, pulseValue: _hintPulseController.value));
                                        }
                                      ),
                                    if (path.isNotEmpty)
                                      CustomPaint(size: constraints.biggest, painter: PathPainter(path: path, cols: widget.level.cols, rows: widget.level.rows, pathColor: Colors.white, strokeWidth: 18.0, isNeon: false)),

                                    GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: widget.level.cols),
                                      itemCount: grid.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DotWidget(mood: grid[index], isInPath: path.contains(index), isLast: path.isNotEmpty && path.last == index, isHighlighted: false),
                                        );
                                      },
                                    ),

                                    // 🚀 The Animated Dragging Finger!
                                    if (isTutorialActive && tutorialPath.isNotEmpty)
                                      AnimatedFingerDrag(
                                        path: tutorialPath,
                                        cols: widget.level.cols,
                                        rows: widget.level.rows,
                                        cellWidth: (constraints.biggest.width - 20) / widget.level.cols,
                                        cellHeight: (constraints.biggest.height - 20) / widget.level.rows,
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
                    title: hasFreeHints ? 'USE HINT (${GameSettings.availableHints})' : 'BUY HINT (${GameSettings.hintCost}🪙)',
                    icon: Icons.lightbulb_rounded, color: hasFreeHints ? AppTheme.primary : AppTheme.coinGold, shadowColor: hasFreeHints ? AppTheme.primaryDark : AppTheme.coinDark, isSmall: true, onTap: _useHint,
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

class AnimatedFingerDrag extends StatefulWidget {
  final List<int> path;
  final int cols;
  final int rows;
  final double cellWidth;
  final double cellHeight;

  const AnimatedFingerDrag({
    super.key,
    required this.path,
    required this.cols,
    required this.rows,
    required this.cellWidth,
    required this.cellHeight,
  });

  @override
  State<AnimatedFingerDrag> createState() => _AnimatedFingerDragState();
}

class _AnimatedFingerDragState extends State<AnimatedFingerDrag> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
    
    _animation = Tween<double>(begin: 0, end: (widget.path.length - 1).toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.path.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double progress = _animation.value;
        int currentIndex = progress.floor();
        int nextIndex = (currentIndex + 1 < widget.path.length) ? currentIndex + 1 : currentIndex;
        double localProgress = progress - currentIndex;

        int c1 = widget.path[currentIndex] % widget.cols;
        int r1 = widget.path[currentIndex] ~/ widget.cols;
        int c2 = widget.path[nextIndex] % widget.cols;
        int r2 = widget.path[nextIndex] ~/ widget.cols;

        double x = (c1 + (c2 - c1) * localProgress) * widget.cellWidth + (widget.cellWidth / 2) - 30; 
        double y = (r1 + (r2 - r1) * localProgress) * widget.cellHeight + (widget.cellHeight / 2) - 10; 

        return Positioned(
          left: x,
          top: y,
          child: const Icon(
            Icons.touch_app, 
            color: Colors.white, 
            size: 65, 
            shadows: [Shadow(color: Colors.black87, blurRadius: 15)]
          ),
        );
      },
    );
  }
}