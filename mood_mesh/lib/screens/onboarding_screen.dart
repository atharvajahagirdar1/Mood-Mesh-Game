import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'home_screen.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../core/storage_manager.dart';
import '../core/audio_manager.dart';
import '../widgets/animated_background.dart';
import '../widgets/game_button.dart';
import '../widgets/game_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final TextEditingController _nameController = TextEditingController();
  String _selectedAvatar = '😊';
  final List<String> _avatars = ['😊', '🐶', '🍎', '🐱', '🍇', '😎'];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 2 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a player name!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.accent),
      );
      return;
    }
    
    AudioManager.playClick();
    
    if (_currentPage == 2) {
      _confettiController.play();
      AudioManager.playWin();
    }
    
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _finishOnboarding() async {
    AudioManager.playClick();
    GameSettings.isFirstTime = false;
    GameSettings.playerName = _nameController.text.trim();
    GameSettings.avatar = _selectedAvatar;
    
    GameSettings.totalCoins += 50;
    GameSettings.availableHints = 10; 
    
    await StorageManager.saveProfile();
    await StorageManager.saveEconomy();

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (int page) => setState(() => _currentPage = page),
              children: [
                _buildWelcomePage(),
                _buildTutorialPage(),
                _buildProfilePage(),
                _buildGiftPage(),
              ],
            ),
          ),
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: _currentPage == index ? 24 : 10,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primary : Colors.black12,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const GameLogoWidget(size: 220),
        const SizedBox(height: 40),
        const Text('Welcome to\nMood Mesh!', textAlign: TextAlign.center, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.textDark, height: 1.1)),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text('Your goal is to spread happiness and connect the emotions.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 50),
        GameButton(title: 'NEXT', icon: Icons.arrow_forward_rounded, color: AppTheme.primary, shadowColor: AppTheme.primaryDark, onTap: _nextPage),
      ],
    );
  }

  Widget _buildTutorialPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.gameBoxDecoration,
          child: const Column(
            children: [
              Text('😊 ➡️ 😡', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text('😡 ➡️ 😴', style: TextStyle(fontSize: 40)),
              SizedBox(height: 10),
              Text('😴 ➡️ 😊', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Text('How to Play', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text('Drag a line through the Happy dots to calm down the Angry and Sleepy ones around them!', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 50),
        GameButton(title: 'GOT IT', icon: Icons.thumb_up_rounded, color: AppTheme.secondary, shadowColor: AppTheme.secondaryDark, onTap: _nextPage),
      ],
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15, left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Create Profile', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            const SizedBox(height: 10),
            const Text('Who is playing today?', style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            
            Container(
              decoration: AppTheme.gameBoxDecoration,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Enter Player Name',
                      hintStyle: const TextStyle(color: Colors.black26),
                      filled: true,
                      fillColor: AppTheme.backgroundDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Choose Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                  const SizedBox(height: 15),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 15,
                    runSpacing: 15,
                    children: _avatars.map((avatar) {
                      bool isSelected = _selectedAvatar == avatar;
                      return GestureDetector(
                        onTap: () {
                          AudioManager.playClick();
                          setState(() => _selectedAvatar = avatar);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : AppTheme.backgroundDark,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: AppTheme.primaryDark, width: 3) : null,
                            boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))] : [],
                          ),
                          child: Text(avatar, style: const TextStyle(fontSize: 36)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GameButton(title: 'SAVE', icon: Icons.check_rounded, color: AppTheme.primary, shadowColor: AppTheme.primaryDark, onTap: _nextPage),
            const SizedBox(height: 50), 
          ],
        ),
      ),
    );
  }

  Widget _buildGiftPage() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController, blastDirectionality: BlastDirectionality.explosive, emissionFrequency: 0.05, numberOfParticles: 30, maxBlastForce: 100, minBlastForce: 80, gravity: 0.1, colors: const [AppTheme.primary, AppTheme.secondary, AppTheme.accent, AppTheme.success],
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 20),
              const Text('Welcome Gift!', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.success)),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text('Here is something to help you on your puzzle journey.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppTheme.textLight, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                decoration: AppTheme.gameBoxDecoration,
                child: const Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on_rounded, color: AppTheme.coinGold, size: 36),
                        SizedBox(width: 10),
                        Text('+50 COINS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lightbulb_rounded, color: AppTheme.primary, size: 36),
                        SizedBox(width: 10),
                        Text('+5 HINTS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              GameButton(title: "LET'S PLAY!", icon: Icons.play_arrow_rounded, color: AppTheme.success, shadowColor: AppTheme.successDark, onTap: _finishOnboarding),
            ],
          ),
        ),
      ],
    );
  }
}
