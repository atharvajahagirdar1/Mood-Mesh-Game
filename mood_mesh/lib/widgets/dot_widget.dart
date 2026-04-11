import 'package:flutter/material.dart';
import '../models/level.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';

class DotWidget extends StatelessWidget {
  final Mood mood;
  final bool isInPath;
  final bool isLast;
  final bool isHighlighted;

  const DotWidget({
    Key? key, 
    required this.mood, 
    required this.isInPath, 
    required this.isLast,
    this.isHighlighted = false,
  }) : super(key: key);

  Color get moodColor {
    switch (mood) {
      case Mood.happy: return AppTheme.moodHappy;
      case Mood.angry: return AppTheme.moodAngry;
      case Mood.sleepy: return AppTheme.moodSleepy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isInPath ? 0.85 : (isHighlighted ? 1.1 : 1.0),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: moodColor,
          shape: BoxShape.circle,
          border: isLast 
              ? Border.all(color: Colors.white, width: 5) 
              : null,
          boxShadow: isInPath ? [] : const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
            BoxShadow(color: Colors.white30, blurRadius: 2, offset: Offset(0, -2)) 
          ],
        ),
        child: Center(
          child: Text(
            GameSettings.getEmoji(mood.index),
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
