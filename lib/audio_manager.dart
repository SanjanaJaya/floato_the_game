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
  bool _isLowPerfMode = false; // For automatic performance management

  // Sound throttling maps for various sounds
  final Map<String, int> _lastSoundTimes = {};
  static const Map<String, int> _soundThrottleMs = {
    'crash.ogg': 500,
    'ability_collected.ogg': 300,
    'coin_collect.ogg': 150, // Increased from 100ms to reduce frequency
    'explosion.ogg': 200,
    'go.ogg': 0, // Critical sound - no throttling
  };

  // Audio priority levels (higher number = higher priority)
  static const Map<String, int> _soundPriority = {
    'crash.ogg': 10,
    'ability_collected.ogg': 8,
    'coin_collect.ogg': 3,
    'explosion.ogg': 7,
    'go.ogg': 10,
  };

  // Cache for preloaded audio files
  final List<String> _preloadedFiles = [];

  // Sound request queue for batching audio events
  final Queue<String> _soundQueue = Queue<String>();
  int _lastSoundProcessingTime = 0;
  static const int _soundBatchingIntervalMs = 50; // Process sounds in batches
  static const int _maxQueuedSounds = 5; // Limit queue size

  // Counters for analytics
  int _totalSoundsPlayed = 0;
  int _skippedSounds = 0;

  bool get isMuted => _isMuted;
  bool get isInitialized => _isInitialized;
  bool get isLowPerfMode => _isLowPerfMode;

  // Initialize audio
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      print('Initializing AudioManager...');

      // List of audio files to preload
      final audioFiles = [
        'menu_music.ogg',
        'crash.ogg',
        'ability_collected.ogg',
        'coin_collect.ogg',
        'go.ogg',
        'explosion.ogg' // Added to preload list
      ];

      // Configure audio cache for better performance
      FlameAudio.audioCache.prefix = 'assets/audio/';


      // Load audio files one by one to avoid overloading
      for (final file in audioFiles) {
        try {
          await FlameAudio.audioCache.load(file);
          _preloadedFiles.add(file);
        } catch (e) {
          print('Failed to preload $file: $e');
        }
      }

      _isInitialized = true;
      print('AudioManager initialized successfully with ${_preloadedFiles.length} audio files');
    } catch (e) {
      print('Error initializing AudioManager: $e');
      // Fallback to basic mode if initialization fails
      _isInitialized = true;
      _isLowPerfMode = true;
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
      print('Background music started successfully');
    } catch (e) {
      print('Error playing background music: $e');
      // Try again after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (!_isPlaying && !_isMuted) {
          try {
            FlameAudio.bgm.play('menu_music.ogg', volume: 0.6);
            _isPlaying = true;
          } catch (_) {} // Silently fail on second attempt
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
      // Force reset the playing state to avoid getting stuck
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
      } else {
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
      } else {
        _skippedSounds++;
      }
    }

    // Clear remaining queue in low performance mode
    if (_isLowPerfMode) {
      _soundQueue.clear();
    }
  }

  // Actually play the sound
  void _playSound(String fileName) {
    if (!_preloadedFiles.contains(fileName)) {
      return; // Skip non-preloaded sounds
    }

    try {
      final volume = _isLowPerfMode ? 0.6 : 0.8;
      FlameAudio.play(fileName, volume: volume);
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

  // Toggle mute/unmute
  void toggleMute() {
    _isMuted = !_isMuted;

    if (_isMuted) {
      if (_isPlaying) {
        FlameAudio.bgm.stop();
        _isPlaying = false;
      }
      // Clear any pending sound effects
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
      // Clear pending sounds when switching to low perf mode
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

  // Clear audio caches - call this when game is exited or paused for a long time
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