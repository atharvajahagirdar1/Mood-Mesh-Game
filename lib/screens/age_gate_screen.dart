import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'onboarding_screen.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/audio_manager.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_button.dart';
import '../widgets/game_logo.dart';

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  final TextEditingController _ageController = TextEditingController();

  void _submitAge() async {
    String ageText = _ageController.text.trim();
    if (ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your age.', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.accent));
      return;
    }

    int? age = int.tryParse(ageText);
    if (age == null || age <= 0 || age > 120) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid age.', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.accent));
      return;
    }

    AudioManager.playClick();

    GameSettings.isAgeVerified = true;
    GameSettings.playerAge = age;
    await StorageManager.saveProfile();

    bool isChild = age < 13;
    RequestConfiguration requestConfiguration = RequestConfiguration(
      tagForChildDirectedTreatment: isChild ? TagForChildDirectedTreatment.yes : TagForChildDirectedTreatment.no,
    );
    await MobileAds.instance.updateRequestConfiguration(requestConfiguration);

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const GameLogoWidget(size: 160),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: AppTheme.gameBoxDecoration,
                      child: Column(
                        children: [
                          const Text('Welcome!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                          const SizedBox(height: 10),
                          const Text('Please enter your age to continue.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Age',
                              hintStyle: const TextStyle(color: Colors.black26),
                              filled: true,
                              fillColor: AppTheme.backgroundDark,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GameButton(title: 'CONTINUE', icon: Icons.check_circle_rounded, color: AppTheme.primary, shadowColor: AppTheme.primaryDark, onTap: _submitAge),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
