import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/app_theme.dart';
import 'core/storage_manager.dart';
import 'core/audio_manager.dart';
import 'core/ad_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Core Services
  await StorageManager.init();
  await MobileAds.instance.initialize();
  AudioManager.init();
  AdManager.instance.loadRewardedAd();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MoodMeshApp());
  });
}

class MoodMeshApp extends StatelessWidget {
  const MoodMeshApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
