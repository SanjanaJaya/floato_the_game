import 'package:flame_audio/flame_audio.dart';
import 'dart:collection';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLowPerfMode = false;

  // List of all audio files to preload
  static const List<String> _audioFiles = [
    'menu_music.ogg',
    'crash.ogg',
    'ability_collected.ogg',
    'coin_collect.ogg',
    'go.ogg',
    'explosion.ogg'
  ];

  // Sound throttling and priority maps
  final Map<String, int> _lastSoundTimes = {};
  static const Map<String, int> _soundThrottleMs = {
    'crash.ogg': 500,
    'ability_collected.ogg': 300,
    'coin_collect.ogg': 150,
    'explosion.ogg': 200,
    'go.ogg': 0,
  };

  static const Map<String, int> _soundPriority = {
    'crash.ogg': 10,
    'ability_collected.ogg': 8,
    'coin_collect.ogg': 3,
    'explosion.ogg': 7,
    'go.ogg': 10,
  };

  // Cache for preloaded audio files
  final List<String> _preloadedFiles = [];
  final Queue<String> _soundQueue = Queue<String>();
  int _lastSoundProcessingTime = 0;
  static const int _soundBatchingIntervalMs = 50;
  static const int _maxQueuedSounds = 5;

  // Stats
  int _totalSoundsPlayed = 0;
  int _skippedSounds = 0;

  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
  bool get isLowPerfMode => _isLowPerfMode;
  List<String> get preloadedFiles => List.unmodifiable(_preloadedFiles);

  // Initialize audio with all files
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('[AudioManager] Initializing with ${_audioFiles.length} audio files...');
      FlameAudio.audioCache.prefix = 'assets/audio/';

      // Load all audio files sequentially to avoid overwhelming the system
      for (final file in _audioFiles) {
        try {
          await FlameAudio.audioCache.load(file);
          _preloadedFiles.add(file);
          print('[AudioManager] Successfully preloaded $file');
        } catch (e) {
          print('[AudioManager] Failed to preload $file: $e');
          // Continue with other files even if one fails
        }
      }

      _isInitialized = true;
      print('[AudioManager] Initialization complete. ${_preloadedFiles.length}/${_audioFiles.length} files loaded');
    } catch (e) {
      print('[AudioManager] Critical initialization error: $e');
      _isInitialized = true;
      _isLowPerfMode = true;
    }
  }

  // NEW METHOD: Play all preloaded sounds (for testing)
  Future<void> playAllPreloadedSounds() async {
    if (!_isInitialized) {
      print('[AudioManager] Not initialized yet');
      return;
    }

    print('[AudioManager] Playing all preloaded sounds...');

    // Play each sound with a small delay between them
    for (final file in _preloadedFiles) {
      if (file == 'menu_music.ogg') continue; // Skip background music

      print('[AudioManager] Playing $file');
      _playSound(file);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // Play background music with error handling
  void playBackgroundMusic() {
    if (_isMuted || _isPlaying || !_isInitialized) return;

    try {
      FlameAudio.bgm.initialize();
      FlameAudio.bgm.play('menu_music.ogg', volume: 0.7);
      FlameAudio.bgm.audioPlayer.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    } catch (e) {
      print('Error playing background music: $e');
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isPlaying && !_isMuted) {
          try {
            FlameAudio.bgm.play('menu_music.ogg', volume: 0.6);
            _isPlaying = true;
          } catch (_) {}
        }
      });
    }
  }

  // Stop background music with error handling
  void stopBackgroundMusic() {
    if (!_isPlaying) return;

    try {
      FlameAudio.bgm.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping background music: $e');
      _isPlaying = false;
    }
  }

  // Queue a sound effect to be played with throttling and batching
  void playSfx(String fileName) {
    if (_isMuted || !_isInitialized) return;

    // Critical sounds bypass the queue and throttling in normal performance mode
    if (!_isLowPerfMode && _getSoundPriority(fileName) >= 10) {
      _playSound(fileName);
      return;
    }

    // Add to queue for batch processing
    if (_soundQueue.length < _maxQueuedSounds) {
      _soundQueue.add(fileName);
    } else {
      // Queue full, prioritize higher priority sounds
      final lowestPrioritySound = _findLowestPrioritySound();
      if (_getSoundPriority(fileName) > _getSoundPriority(lowestPrioritySound)) {
        _soundQueue.remove(lowestPrioritySound);
        _soundQueue.add(fileName);
        _skippedSounds++;
      }
    }

    // Process the queue if enough time has passed
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastSoundProcessingTime >= _soundBatchingIntervalMs) {
      processSoundQueue();
    }
  }

  // Process queued sounds based on priority and throttling
  void processSoundQueue() {
    if (_soundQueue.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    _lastSoundProcessingTime = now;

    // Sort sounds by priority if there are multiple sounds in the queue
    if (_soundQueue.length > 1) {
      final sortedSounds = _soundQueue.toList()
        ..sort((a, b) => _getSoundPriority(b).compareTo(_getSoundPriority(a)));
      _soundQueue.clear();
      _soundQueue.addAll(sortedSounds);
    }

    // Process the top sounds (limited number in low performance mode)
    final processLimit = _isLowPerfMode ? 1 : 3;
    int processed = 0;

    while (_soundQueue.isNotEmpty && processed < processLimit) {
      final sound = _soundQueue.removeFirst();
      final throttleTime = _soundThrottleMs[sound] ?? 100;
      final lastTime = _lastSoundTimes[sound] ?? 0;

      if (now - lastTime >= throttleTime) {
        _playSound(sound);
        processed++;
      }
    }

    // Clear remaining queue in low performance mode
    if (_isLowPerfMode) {
      _soundQueue.clear();
    }
  }

  // Actually play the sound
  void _playSound(String fileName) {
    if (!_preloadedFiles.contains(fileName)) return;

    try {
      final volume = _isLowPerfMode ? 0.6 : 0.8;
      if (fileName == 'menu_music.ogg') {
        // Handle background music differently
        FlameAudio.bgm.play(fileName, volume: volume);
      } else {
        FlameAudio.play(fileName, volume: volume);
      }
      _lastSoundTimes[fileName] = DateTime.now().millisecondsSinceEpoch;
      _totalSoundsPlayed++;
    } catch (e) {
      print('Error playing sound effect $fileName: $e');
    }
  }

  // Find the lowest priority sound in the queue
  String _findLowestPrioritySound() {
    String lowestSound = _soundQueue.first;
    int lowestPriority = _getSoundPriority(lowestSound);

    for (final sound in _soundQueue) {
      final priority = _getSoundPriority(sound);
      if (priority < lowestPriority) {
        lowestPriority = priority;
        lowestSound = sound;
      }
    }

    return lowestSound;
  }

  // Get priority for a sound
  int _getSoundPriority(String fileName) {
    return _soundPriority[fileName] ?? 5;
  }

  // Play crash sound with throttling
  void playCrashSound() {
    playSfx('crash.ogg');
  }

  // Play ability collected sound
  void playAbilityCollectedSound() {
    playSfx('ability_collected.ogg');
  }

  // Play coin collect sound
  void playCoinCollectSound() {
    playSfx('coin_collect.ogg');
  }

  // Play explosion sound
  void playExplosionSound() {
    playSfx('explosion.ogg');
  }

  // Play go sound
  void playGoSound() {
    playSfx('go.ogg');
  }

  // Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;

    if (_isMuted) {
      if (_isPlaying) {
        FlameAudio.bgm.stop();
        _isPlaying = false;
      }
      _soundQueue.clear();
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

  // Enable low performance mode
  void setLowPerformanceMode(bool enabled) {
    _isLowPerfMode = enabled;
    if (_isLowPerfMode) {
      _soundQueue.clear();
    }
  }

  // Get audio performance stats
  Map<String, dynamic> getAudioStats() {
    return {
      'totalSoundsPlayed': _totalSoundsPlayed,
      'skippedSounds': _skippedSounds,
      'currentQueueSize': _soundQueue.length,
      'isLowPerfMode': _isLowPerfMode,
    };
  }

  // Clear audio caches
  void dispose() {
    stopBackgroundMusic();
    _lastSoundTimes.clear();
    _soundQueue.clear();

    try {
      FlameAudio.bgm.dispose();
      FlameAudio.audioCache.clearAll();
    } catch (e) {
      print('Error disposing audio resources: $e');
    }
  }
}