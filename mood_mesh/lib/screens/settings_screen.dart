import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/game_settings.dart';
import '../widgets/animated_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    decoration: AppTheme.gameBoxDecoration,
                    child: Column(
                      children: [
                        _buildToggle('Sound Effects', Icons.volume_up_rounded, GameSettings.soundOn, (val) => setState(() => GameSettings.soundOn = val)),
                        const Divider(height: 1),
                        _buildToggle('Music', Icons.music_note_rounded, GameSettings.musicOn, (val) => setState(() => GameSettings.musicOn = val)),
                        const Divider(height: 1),
                        _buildToggle('Haptics', Icons.vibration_rounded, GameSettings.hapticsOn, (val) => setState(() => GameSettings.hapticsOn = val)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: AppTheme.primary, size: 28),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      trailing: Switch(value: value, activeColor: AppTheme.primary, onChanged: onChanged),
    );
  }
}
