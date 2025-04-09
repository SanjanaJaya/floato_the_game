import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isInitialized = false;

  int _lastExplosionTime = 0;
  static const int _explosionThrottleMs = 200; // Minimum ms between explosion sounds

  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;

  // Initialize audio
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('Initializing AudioManager...');
      // Pre-load audio files
      await FlameAudio.audioCache.loadAll([
        'menu_music.wav',
        'crash.wav',
        // 'explosion.wav', - Remove explosion sound from loading
      ]);

      // Configure audio cache for better performance
      FlameAudio.audioCache.prefix = 'assets/audio/';

      _isInitialized = true;
      print('AudioManager initialized successfully');
    } catch (e) {
      print('Error initializing AudioManager: $e');
    }
  }

  // Play background music
  void playBackgroundMusic() {
    if (!_isMuted && !_isPlaying && _isInitialized) {
      try {
        print('Starting background music');
        // Use the standard play method with loop parameter
        FlameAudio.bgm.initialize();
        FlameAudio.bgm.play('menu_music.wav');
        // Enable looping by setting the BGM to repeat
        FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
        _isPlaying = true;
        print('Background music started successfully');
      } catch (e) {
        print('Error playing background music: $e');
      }
    }
  }

  // Stop background music
  void stopBackgroundMusic() {
    if (_isPlaying) {
      try {
        FlameAudio.bgm.stop();
        _isPlaying = false;
        print('Background music stopped');
      } catch (e) {
        print('Error stopping background music: $e');
      }
    }
  }

  // Play a sound effect once
  void playSfx(String fileName) {
    if (!_isMuted && _isInitialized) {
      try {
        print('Playing SFX: $fileName');
        FlameAudio.play(fileName);
      } catch (e) {
        print('Error playing sound effect $fileName: $e');
      }
    }
  }

  // Play crash sound
  void playCrashSound() {
    playSfx('crash.wav');
  }

  // Explosion sound method - now empty to prevent freezing issues
  void playExplosionSound({int currentLevel = 1}) {
    // Method intentionally empty - explosion sounds disabled to prevent freezing
  }

  // Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;
    print('Audio muted: $_isMuted');

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
    if (!_isMuted && !_isPlaying && _isInitialized) {
      playBackgroundMusic();
    }
  }
}