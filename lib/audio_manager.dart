import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  bool _isPlaying = false;

  bool get isMuted => _isMuted;

  // Initialize audio
  Future<void> init() async {
    await FlameAudio.audioCache.load('menu_music.wav');
    await FlameAudio.audioCache.load('crash.wav');
  }

  // Play background music
  void playBackgroundMusic() {
    if (!_isMuted && !_isPlaying) {
      // Use the standard play method with loop parameter
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play('menu_music.wav');
      // Enable looping by setting the BGM to repeat
      FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    }
  }

  // Stop background music
  void stopBackgroundMusic() {
    if (_isPlaying) {
      FlameAudio.bgm.stop();
      _isPlaying = false;
    }
  }

  // Play a sound effect once
  void playSfx(String fileName) {
    if (!_isMuted) {
      FlameAudio.play(fileName);
    }
  }

  // Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;

    if (_isMuted) {
      if (_isPlaying) {
        FlameAudio.bgm.stop();
        _isPlaying = false;
      }
    } else {
      playBackgroundMusic();
    }
  }

  // Resume music if it was playing before
  void resumeBackgroundMusic() {
    if (!_isMuted && !_isPlaying) {
      playBackgroundMusic();
    }
  }
}