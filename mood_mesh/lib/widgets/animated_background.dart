import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppTheme.backgroundLight, AppTheme.backgroundDark], stops: [0.3, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -150, right: -150, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withValues(alpha: 0.03)))),
          Positioned(bottom: -200, left: -100, child: Container(width: 500, height: 500, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary.withValues(alpha: 0.03)))),
        ],
      ),
    );
  }
}
