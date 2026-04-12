import 'package:audioplayers/audioplayers.dart';
import 'game_settings.dart';

class AudioManager {
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  static void init() {
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static Future<void> playBgm() async {
    if (!GameSettings.musicOn) return;
    try {
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'), volume: 0.5);
    } catch (e) {
      // Safe catch: App won't crash if bgm.mp3 is missing
    }
  }

  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {}
  }

  static Future<void> playPop() async {
    if (!GameSettings.soundOn) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/pop.mp3'), mode: PlayerMode.lowLatency);
    } catch (e) {}
  }

  static Future<void> playWin() async {
    if (!GameSettings.soundOn) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/win.mp3'));
    } catch (e) {}
  }
}
