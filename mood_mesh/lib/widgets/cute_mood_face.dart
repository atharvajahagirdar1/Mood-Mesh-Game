import 'package:flutter/material.dart';
import '../models/level.dart';

// Draws the beautiful, custom faces perfectly matching the App Icon
class CuteMoodFace extends StatelessWidget {
  final Mood mood;
  const CuteMoodFace({Key? key, required this.mood}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPaint(
        size: Size.infinite,
        painter: FacePainter(mood),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final Mood mood;
  FacePainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintDark = Paint()..color = const Color(0xFF4A3B32)..style = PaintingStyle.fill;
    final paintStroke = Paint()
      ..color = const Color(0xFF4A3B32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    
    final paintCheeks = Paint()..color = Colors.pinkAccent.withOpacity(0.5)..style = PaintingStyle.fill;

    double eyeRadius = size.width * 0.1;
    double eyeOffset = size.width * 0.22;

    if (mood == Mood.happy) {
      // Rosy Cheeks
      canvas.drawCircle(Offset(center.dx - eyeOffset * 1.4, center.dy + size.height * 0.12), eyeRadius * 1.3, paintCheeks);
      canvas.drawCircle(Offset(center.dx + eyeOffset * 1.4, center.dy + size.height * 0.12), eyeRadius * 1.3, paintCheeks);
      
      // Eyes
      canvas.drawCircle(Offset(center.dx - eyeOffset, center.dy - size.height * 0.05), eyeRadius, paintDark);
      canvas.drawCircle(Offset(center.dx + eyeOffset, center.dy - size.height * 0.05), eyeRadius, paintDark);
      
      // Cute Smile
      Path smile = Path();
      smile.moveTo(center.dx - eyeOffset * 0.8, center.dy + size.height * 0.12);
      smile.quadraticBezierTo(center.dx, center.dy + size.height * 0.35, center.dx + eyeOffset * 0.8, center.dy + size.height * 0.12);
      canvas.drawPath(smile, paintStroke);

    } else if (mood == Mood.angry) {
      // Angry Eyes
      canvas.drawCircle(Offset(center.dx - eyeOffset, center.dy + size.height * 0.05), eyeRadius, paintDark);
      canvas.drawCircle(Offset(center.dx + eyeOffset, center.dy + size.height * 0.05), eyeRadius, paintDark);
      
      // Slanted Eyebrows
      canvas.drawLine(Offset(center.dx - eyeOffset * 1.8, center.dy - size.height * 0.15), Offset(center.dx - eyeOffset * 0.4, center.dy - size.height * 0.02), paintStroke);
      canvas.drawLine(Offset(center.dx + eyeOffset * 1.8, center.dy - size.height * 0.15), Offset(center.dx + eyeOffset * 0.4, center.dy - size.height * 0.02), paintStroke);
      
      // Frown
      Path frown = Path();
      frown.moveTo(center.dx - eyeOffset * 0.6, center.dy + size.height * 0.28);
      frown.quadraticBezierTo(center.dx, center.dy + size.height * 0.18, center.dx + eyeOffset * 0.6, center.dy + size.height * 0.28);
      canvas.drawPath(frown, paintStroke);

    } else if (mood == Mood.sleepy) {
      // Closed Curves for Eyes
      Path leftEye = Path();
      leftEye.moveTo(center.dx - eyeOffset * 1.6, center.dy - size.height * 0.05);
      leftEye.quadraticBezierTo(center.dx - eyeOffset, center.dy + size.height * 0.1, center.dx - eyeOffset * 0.4, center.dy - size.height * 0.05);
      canvas.drawPath(leftEye, paintStroke);

      Path rightEye = Path();
      rightEye.moveTo(center.dx + eyeOffset * 0.4, center.dy - size.height * 0.05);
      rightEye.quadraticBezierTo(center.dx + eyeOffset, center.dy + size.height * 0.1, center.dx + eyeOffset * 1.6, center.dy - size.height * 0.05);
      canvas.drawPath(rightEye, paintStroke);

      // Sleepy flat mouth
      canvas.drawLine(Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.2), Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.2), paintStroke);

      // Zzz lines
      _drawZ(canvas, Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.35), size.width * 0.18, paintStroke..strokeWidth = size.width * 0.05);
      _drawZ(canvas, Offset(center.dx + size.width * 0.4, center.dy - size.height * 0.5), size.width * 0.12, paintStroke..strokeWidth = size.width * 0.035);
    }
  }

  void _drawZ(Canvas canvas, Offset pos, double size, Paint paint) {
    canvas.drawLine(pos, Offset(pos.dx + size, pos.dy), paint);
    canvas.drawLine(Offset(pos.dx + size, pos.dy), Offset(pos.dx, pos.dy + size), paint);
    canvas.drawLine(Offset(pos.dx, pos.dy + size), Offset(pos.dx + size, pos.dy + size), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
