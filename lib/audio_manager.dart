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
    await FlameAudio.audioCache.load('button_click.wav');
    await FlameAudio.audioCache.load('explosion.wav');

    // Load missile sounds for each rocket type
    await FlameAudio.audioCache.load('missile_sound1.wav');
    await FlameAudio.audioCache.load('missile_sound2.wav');
    await FlameAudio.audioCache.load('missile_sound3.wav');
    await FlameAudio.audioCache.load('missile_sound4.wav');
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

  // Play button click sound
  void playButtonClick() {
    playSfx('button_click.wav');
  }

  // Play missile launch sound based on rocket type
  void playMissileSound(int rocketType) {
    // Rocket 1 doesn't have missiles
    if (rocketType <= 1) return;

    // Play the appropriate missile sound for this rocket type
    // Rocket types 2-5 correspond to missile sounds 1-4
    final soundIndex = rocketType - 1;
    playSfx('missile_sound$soundIndex.wav');
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