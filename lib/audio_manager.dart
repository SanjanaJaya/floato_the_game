import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isInitialized = false;

  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;

  // Initialize audio
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('Initializing AudioManager...');
      await FlameAudio.audioCache.loadAll([
        'menu_music.wav',
        'crash.wav',
        'button_click.wav',
        'explosion.wav',
        'missile_sound1.wav',
        'missile_sound2.wav',
        'missile_sound3.wav',
        'missile_sound4.wav'
      ]);
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

  // Play button click sound
  void playButtonClick() {
    playSfx('button_click.wav');
  }

  // Play missile launch sound based on rocket type
  void playMissileSound(int rocketType) {
    // Rocket 1 (type 0) doesn't have missiles
    if (rocketType <= 0) return;

    // Play the appropriate missile sound for this rocket type
    // Rocket types 1-4 correspond to missile sounds 1-4
    final soundIndex = rocketType;
    print('Playing missile sound for rocket type $rocketType: missile_sound$soundIndex.wav');
    playSfx('missile_sound$soundIndex.wav');
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