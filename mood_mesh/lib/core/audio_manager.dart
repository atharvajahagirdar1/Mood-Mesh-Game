import 'package:audioplayers/audioplayers.dart';
import 'game_settings.dart';

class AudioManager {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final AudioPlayer _clickPlayer = AudioPlayer();
  static final AudioPlayer _winPlayer = AudioPlayer();
  
  // Overlapping audio pool for dot connections (Removed deprecated lowLatency mode)
  static final List<AudioPlayer> _popPlayers = List.generate(4, (_) => AudioPlayer());
  static int _popIndex = 0;

  static Future<void> init() async {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static Future<void> playBgm() async {
    if (!GameSettings.musicOn) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'), volume: 0.15);
    } catch (e) {}
  }

  static Future<void> stopBgm() async {
    try { await _bgmPlayer.stop(); } catch (e) {}
  }

  static Future<void> playPop() async {
    if (!GameSettings.soundOn) return;
    try {
      await _popPlayers[_popIndex].play(AssetSource('audio/pop.mp3'));
      _popIndex = (_popIndex + 1) % _popPlayers.length;
    } catch (e) {}
  }

  static Future<void> playClick() async {
    if (!GameSettings.soundOn) return;
    try {
      await _clickPlayer.play(AssetSource('audio/click.mp3'));
    } catch (e) {}
  }

  static Future<void> playWin() async {
    if (!GameSettings.soundOn) return;
    try {
      await _winPlayer.play(AssetSource('audio/win.mp3'));
    } catch (e) {}
  }
}
