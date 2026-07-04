import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'age_gate_screen.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_logo.dart';
import '../core/audio_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    AudioManager.playBgm();
    
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (!GameSettings.isAgeVerified) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AgeGateScreen()));
        } 
        else if (GameSettings.isFirstTime) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
        } 
        else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GameLogoWidget(size: 260), 
                  SizedBox(height: 30),
                  Text('Mood Mesh', style: TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2.0)),
                  SizedBox(height: 10),
                  Text('Connect the emotions', style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
