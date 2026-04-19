import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/app_theme.dart';
import 'core/game_settings.dart';
import 'core/storage_manager.dart';
import 'core/audio_manager.dart';
import 'core/ad_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StorageManager.init();
  await MobileAds.instance.initialize();
  
  bool isChild = !GameSettings.isAgeVerified || GameSettings.playerAge < 13;
  RequestConfiguration requestConfiguration = RequestConfiguration(
    tagForChildDirectedTreatment: isChild ? TagForChildDirectedTreatment.yes : TagForChildDirectedTreatment.no,
  );
  await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  
  await AudioManager.init();
  
  AdManager.instance.loadRewardedAd();
  AdManager.instance.loadInterstitialAd();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MoodMeshApp());
  });
}

class MoodMeshApp extends StatelessWidget {
  const MoodMeshApp({super.key});

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
