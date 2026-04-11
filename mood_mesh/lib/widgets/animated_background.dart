import 'package:flutter/material.dart';
import '../core/app_theme.dart';

// Reusable animated attractive background for Home and Menus
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppTheme.background),
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.15)),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary.withOpacity(0.15)),
          ),
        ),
        Positioned(
          top: 200,
          left: -40,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.accent.withOpacity(0.1)),
          ),
        ),
      ],
    );
  }
}
