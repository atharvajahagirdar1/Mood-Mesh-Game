import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'firebase_options.dart'; 

import 'core/app_theme.dart';
import 'core/game_settings.dart';
import 'core/storage_manager.dart';
import 'core/audio_manager.dart';
import 'core/ad_manager.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Firebase SAFELY (Prevents crashes if config is missing or invalid)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Only link Crashlytics if Firebase initialized successfully
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  } catch (e) {
    debugPrint("⚠️ Firebase initialization failed: $e");
    debugPrint("⚠️ Make sure you ran 'flutterfire configure' after changing your package name!");
  }

  // 2. Initialize local storage first
  await StorageManager.init();
  
  // 3. Initialize AdMob asynchronously to prevent startup freezing
  MobileAds.instance.initialize().then((_) async {
    // Dynamic COPPA Compliance for AdMob
    bool isChild = !GameSettings.isAgeVerified || GameSettings.playerAge < 13;
    RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: isChild ? TagForChildDirectedTreatment.yes : TagForChildDirectedTreatment.no,
    );
    await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  });
  
  // 4. Initialize Audio and pre-load Ad units
  await AudioManager.init();
  AdManager.instance.loadRewardedAd();
  AdManager.instance.loadInterstitialAd();
  
  // 5. Lock orientation and launch the app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const MoodMeshApp());
  });
}

class MoodMeshApp extends StatelessWidget {
  const MoodMeshApp({super.key});

  // Safely get Analytics observer ONLY if Firebase is active and running
  static List<NavigatorObserver> getObservers() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)];
      }
    } catch (e) {
      debugPrint("⚠️ Analytics skipped: Firebase not ready.");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Mesh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      // Automatically track which screens users visit (failsafe applied)
      navigatorObservers: getObservers(), 
    );
  }
}