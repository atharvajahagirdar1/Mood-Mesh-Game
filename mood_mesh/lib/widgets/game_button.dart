import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/game_settings.dart';

class GameButton extends StatefulWidget {
  final String title;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isSmall;

  const GameButton({
    Key? key,
    required this.title,
    required this.color,
    required this.shadowColor,
    required this.onTap,
    this.icon,
    this.isSmall = false,
  }) : super(key: key);

  @override
  _GameButtonState createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (GameSettings.hapticsOn) HapticFeedback.lightImpact();
    _controller.forward();
  }
  
  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }
  
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.isSmall ? null : 240,
          padding: EdgeInsets.symmetric(vertical: widget.isSmall ? 12 : 18, horizontal: widget.isSmall ? 20 : 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30),
            border: Border(bottom: BorderSide(color: widget.shadowColor, width: 6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.isSmall ? MainAxisSize.min : MainAxisSize.max,
            children: [
              if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: widget.isSmall ? 20 : 28), const SizedBox(width: 10)],
              Text(
                widget.title,
                style: TextStyle(fontSize: widget.isSmall ? 16 : 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const GameIconButton({Key? key, required this.icon, required this.color, required this.shadowColor, required this.onTap}) : super(key: key);

  @override
  _GameIconButtonState createState() => _GameIconButtonState();
}

class _GameIconButtonState extends State<GameIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (GameSettings.hapticsOn) HapticFeedback.lightImpact();
    _controller.forward();
  }
  void _onTapUp(TapUpDetails details) { _controller.reverse(); widget.onTap(); }
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, onTapUp: _onTapUp, onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            border: Border(bottom: BorderSide(color: widget.shadowColor, width: 4)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}
