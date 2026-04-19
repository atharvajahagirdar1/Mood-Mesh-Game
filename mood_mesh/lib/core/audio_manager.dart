import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_settings.dart';

class AudioManager {
  static late final AudioPlayer _bgmPlayer;
  static late final AudioPlayer _clickPlayer;
  static late final AudioPlayer _winPlayer;
  static late final List<AudioPlayer> _popPlayers;
  
  static int _popIndex = 0;

  static Future<void> init() async {
    // 1. Create a strictly "No Audio Focus" context
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none, // CRITICAL: NEVER steal focus
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient, // Ambient mixes audio perfectly
        options: const {}, // 🚀 FIX: Empty Set {} resolves type errors for options
      ),
    );

    try {
      // Apply globally
      await AudioPlayer.global.setAudioContext(audioContext);
    } catch (e) {
      debugPrint('Audio init warning: $e');
    }

    // 2. Instantiate players. Removed lowLatency as Standard handles overlap correctly
    _bgmPlayer = AudioPlayer();
    _clickPlayer = AudioPlayer();
    _winPlayer = AudioPlayer();
    _popPlayers = List.generate(10, (_) => AudioPlayer()); 

    // 3. Forcefully inject the "No Focus" context into EVERY individual player
    await _bgmPlayer.setAudioContext(audioContext);
    await _clickPlayer.setAudioContext(audioContext);
    await _winPlayer.setAudioContext(audioContext);
    for (var p in _popPlayers) {
      await p.setAudioContext(audioContext);
    }

    // 4. Preload assets into RAM and prepare them to auto-stop/rewind
    await _clickPlayer.setReleaseMode(ReleaseMode.stop);
    await _clickPlayer.setSource(AssetSource('audio/click.mp3'));
    
    await _winPlayer.setReleaseMode(ReleaseMode.stop);
    await _winPlayer.setSource(AssetSource('audio/win.mp3'));
    
    for (var p in _popPlayers) {
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setSource(AssetSource('audio/pop.mp3'));
    }

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.15); // Set BGM volume globally once
    await _bgmPlayer.setSource(AssetSource('audio/bgm.mp3'));
  }

  static Future<void> playBgm() async {
    if (!GameSettings.musicOn) return;
    try {
      if (_bgmPlayer.state != PlayerState.playing) {
        await _bgmPlayer.resume();
      }
    } catch (e) { /* ignore */ }
  }

  static Future<void> stopBgm() async {
    try { await _bgmPlayer.stop(); } catch (e) { /* ignore */ }
  }

  static Future<void> playPop() async {
    if (!GameSettings.soundOn) return;
    try {
      final player = _popPlayers[_popIndex];
      if (player.state == PlayerState.playing) {
        await player.stop(); 
      }
      await player.resume();
      _popIndex = (_popIndex + 1) % _popPlayers.length;
    } catch (e) { /* ignore */ }
  }

  static Future<void> playClick() async {
    if (!GameSettings.soundOn) return;
    try {
      if (_clickPlayer.state == PlayerState.playing) {
        await _clickPlayer.stop();
      }
      await _clickPlayer.resume();
    } catch (e) { /* ignore */ }
  }

  static Future<void> playWin() async {
    if (!GameSettings.soundOn) return;
    try {
      if (_winPlayer.state == PlayerState.playing) {
        await _winPlayer.stop();
      }
      await _winPlayer.resume();
    } catch (e) { /* ignore */ }
  }
}