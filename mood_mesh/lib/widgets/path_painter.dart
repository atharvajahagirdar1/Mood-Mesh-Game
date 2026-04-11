import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<int> path;
  final int cols;
  final int rows;
  final Color pathColor;
  final double strokeWidth;

  PathPainter({
    required this.path, 
    required this.cols, 
    required this.rows, 
    required this.pathColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = pathColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    double cellWidth = size.width / cols;
    double cellHeight = size.height / rows;

    for (int i = 0; i < path.length - 1; i++) {
      int p1 = path[i];
      int p2 = path[i + 1];

      Offset start = Offset(
        (p1 % cols) * cellWidth + cellWidth / 2,
        (p1 ~/ cols) * cellHeight + cellHeight / 2,
      );

      Offset end = Offset(
        (p2 % cols) * cellWidth + cellWidth / 2,
        (p2 ~/ cols) * cellHeight + cellHeight / 2,
      );

      // Main line
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
