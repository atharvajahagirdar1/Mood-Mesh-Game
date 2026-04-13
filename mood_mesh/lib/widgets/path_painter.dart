import 'package:flutter/material.dart';

class PathPainter extends CustomPainter {
  final List<int> path; final int cols; final int rows; final Color pathColor; final double strokeWidth; final bool isNeon; final double pulseValue;
  PathPainter({required this.path, required this.cols, required this.rows, required this.pathColor, required this.strokeWidth, this.isNeon = false, this.pulseValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;
    double cellWidth = size.width / cols; double cellHeight = size.height / rows;
    Path fullPath = Path();
    for (int i = 0; i < path.length - 1; i++) {
      int p1 = path[i]; int p2 = path[i + 1];
      Offset start = Offset((p1 % cols) * cellWidth + cellWidth / 2, (p1 ~/ cols) * cellHeight + cellHeight / 2);
      Offset end = Offset((p2 % cols) * cellWidth + cellWidth / 2, (p2 ~/ cols) * cellHeight + cellHeight / 2);
      if (i == 0) fullPath.moveTo(start.dx, start.dy);
      fullPath.lineTo(end.dx, end.dy);
    }
    if (isNeon) {
      final glowPaint = Paint()..color = pathColor.withOpacity(0.4 + (pulseValue * 0.6))..strokeWidth = strokeWidth * 1.5..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + (pulseValue * 10));
      canvas.drawPath(fullPath, glowPaint);
      final corePaint = Paint()..color = Colors.white..strokeWidth = strokeWidth * 0.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      canvas.drawPath(fullPath, corePaint);
    } else {
      final shadowPaint = Paint()..color = Colors.black26..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawPath(fullPath, shadowPaint);
      final normalPaint = Paint()..color = pathColor..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..style = PaintingStyle.stroke;
      canvas.drawPath(fullPath, normalPaint);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
