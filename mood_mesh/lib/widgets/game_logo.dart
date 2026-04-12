import 'package:flutter/material.dart';
import '../models/level.dart';
import 'dot_widget.dart';
import '../core/app_theme.dart';

class GameLogoWidget extends StatelessWidget {
  final double size;
  const GameLogoWidget({Key? key, this.size = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.65,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: size * 0.2, top: size * 0.25,
            child: Container(
              width: size * 0.6, height: size * 0.15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: AppTheme.neonBlue, blurRadius: 15, spreadRadius: 2)],
              ),
            ),
          ),
          Positioned(
            left: 0, bottom: 0,
            child: SizedBox(width: size*0.42, height: size*0.42, child: const DotWidget(mood: Mood.happy, isInPath: false, isLast: false)),
          ),
          Positioned(
            left: size * 0.29, top: 0,
            child: SizedBox(width: size*0.42, height: size*0.42, child: const DotWidget(mood: Mood.angry, isInPath: false, isLast: false)),
          ),
          Positioned(
            right: 0, bottom: size * 0.05,
            child: SizedBox(width: size*0.42, height: size*0.42, child: const DotWidget(mood: Mood.sleepy, isInPath: false, isLast: false)),
          ),
        ],
      ),
    );
  }
}
