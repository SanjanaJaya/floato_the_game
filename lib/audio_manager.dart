import 'package:flame_audio/flame_audio.dart';
import 'dart:collection';
import 'dart:async';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isLowPerfMode = false;
  Timer? _performanceCheckTimer;
  int _consecutiveLowPerformanceChecks = 0;

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

  // Dynamic throttling - will increase during performance issues
  final Map<String, int> _dynamicThrottling = {
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

  // Sound pool for reusing players
  final Map<String, List<AudioPool>> _soundPools = {};
  static const int _poolSize = 3; // Number of instances per sound

  // Stats
  int _totalSoundsPlayed = 0;
  int _skippedSounds = 0;
  int _resourceFlushes = 0;
  int _lastPerformanceFlushTime = 0;

  // Performance flags
  bool _needsResourceFlush = false;
  static const int _minTimeBetweenFlushesMs = 30000; // 30 seconds

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
      FlameAudio.audioCache.clearAll(); // Ensure we start with clean state

      // Load all audio files sequentially to avoid overwhelming the system
      for (final file in _audioFiles) {
        try {
          // Skip background music from pooling
          if (file != 'menu_music.ogg') {
            await _initSoundPool(file);
          } else {
            await FlameAudio.audioCache.load(file);
          }
          _preloadedFiles.add(file);
          print('[AudioManager] Successfully preloaded $file');
        } catch (e) {
          print('[AudioManager] Failed to preload $file: $e');
          // Continue with other files even if one fails
        }
      }

      _isInitialized = true;
      print('[AudioManager] Initialization complete. ${_preloadedFiles.length}/${_audioFiles.length} files loaded');

      // Start performance monitoring
      _startPerformanceMonitoring();
    } catch (e) {
      print('[AudioManager] Critical initialization error: $e');
      _isInitialized = true;
      _isLowPerfMode = true;
    }
  }

  // Initialize sound pool for a file
  Future<void> _initSoundPool(String file) async {
    try {
      // Create pool with multiple instances
      List<AudioPool> pools = [];
      for (int i = 0; i < _poolSize; i++) {
        AudioPool pool = await FlameAudio.createPool(
          file,
          maxPlayers: 1, // Each pool instance handles one play at a time
        );
        pools.add(pool);
      }
      _soundPools[file] = pools;
    } catch (e) {
      print('[AudioManager] Error creating pool for $file: $e');
      // Fall back to normal loading
      await FlameAudio.audioCache.load(file);
    }
  }

  // Start periodic performance checks
  void _startPerformanceMonitoring() {
    _performanceCheckTimer?.cancel();
    _performanceCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
          (_) => _checkForPerformanceIssues(),
    );
  }

  // Check if we need to take action due to performance
  void _checkForPerformanceIssues() {
    if (_needsResourceFlush) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastPerformanceFlushTime > _minTimeBetweenFlushesMs) {
        _flushAudioResources();
        _lastPerformanceFlushTime = now;
        _needsResourceFlush = false;
        _resourceFlushes++;
      }
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

    // Skip if in performance recovery mode
    if (_needsResourceFlush) {
      if (_getSoundPriority(fileName) < 9) {
        _skippedSounds++;
        return;
      }
    }

    // Critical sounds bypass the queue and throttling in normal performance mode
    if (!_isLowPerfMode && _getSoundPriority(fileName) >= 10) {
      _playSound(fileName);
      return;
    }

    // Check dynamic throttling
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = _lastSoundTimes[fileName] ?? 0;
    final throttleTime = _dynamicThrottling[fileName] ?? 100;

    if (now - lastTime < throttleTime) {
      _skippedSounds++;
      return; // Skip if too soon
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
        return; // Skip if not high enough priority
      }
    }

    // Process the queue if enough time has passed
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
      final throttleTime = _dynamicThrottling[sound] ?? 100;
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
      } else if (_soundPools.containsKey(fileName)) {
        // Use sound pool for effects
        _playFromPool(fileName, volume);
      } else {
        // Fallback to standard play
        FlameAudio.play(fileName, volume: volume);
      }

      _lastSoundTimes[fileName] = DateTime.now().millisecondsSinceEpoch;
      _totalSoundsPlayed++;
    } catch (e) {
      print('Error playing sound effect $fileName: $e');
      // Mark for potential resource flush if errors accumulate
      _needsResourceFlush = true;
    }
  }

  // Play from sound pool with round-robin selection
  void _playFromPool(String fileName, double volume) {
    List<AudioPool>? pools = _soundPools[fileName];
    if (pools == null || pools.isEmpty) return;

    // Find the next available pool
    for (int i = 0; i < pools.length; i++) {
      try {
        pools[i].start(volume: volume);
        // Rotate this pool to the end for round-robin distribution
        final used = pools.removeAt(i);
        pools.add(used);
        return;
      } catch (e) {
        // Try next pool if this one fails
        print('Pool instance $i failed for $fileName: $e');
      }
    }

    // If all pools failed, try direct play as fallback
    try {
      FlameAudio.play(fileName, volume: volume);
    } catch (e) {
      print('Fallback play also failed for $fileName: $e');
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

  // Set low performance mode with dynamic throttling adjustment
  void setLowPerformanceMode(bool enabled) {
    if (_isLowPerfMode == enabled) return;

    _isLowPerfMode = enabled;
    if (_isLowPerfMode) {
      _soundQueue.clear();
      _adjustDynamicThrottling(true);

      // Track consecutive low perf triggers
      _consecutiveLowPerformanceChecks++;
      if (_consecutiveLowPerformanceChecks >= 3) {
        _needsResourceFlush = true;
      }
    } else {
      _adjustDynamicThrottling(false);
      _consecutiveLowPerformanceChecks = 0;
    }
  }

  // Adjust throttling based on performance
  void _adjustDynamicThrottling(bool increaseLimits) {
    for (final entry in _soundThrottleMs.entries) {
      if (increaseLimits) {
        // Increase throttling times by 50% in low perf mode
        _dynamicThrottling[entry.key] = (entry.value * 1.5).round();
      } else {
        // Reset to standard values
        _dynamicThrottling[entry.key] = entry.value;
      }
    }
  }

  // Flush and recreate audio resources if performance issues persist
  void _flushAudioResources() {
    print('[AudioManager] Flushing audio resources due to performance issues');

    // Stop any playing sounds and clear queues
    _soundQueue.clear();

    try {
      // Force garbage collection by releasing references
      for (final pools in _soundPools.values) {
        for (final pool in pools) {
          pool.dispose();
        }
      }
      _soundPools.clear();

      // Reset BGM
      if (_isPlaying) {
        stopBackgroundMusic();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_isMuted) playBackgroundMusic();
        });
      }

      // Recreate pools for critical sounds only
      Future.delayed(const Duration(seconds: 1), () async {
        try {
          await _initSoundPool('crash.ogg');
          await _initSoundPool('go.ogg');
        } catch (e) {
          print('[AudioManager] Error recreating critical sound pools: $e');
        }
      });

    } catch (e) {
      print('[AudioManager] Error during resource flush: $e');
    }
  }

  // Get audio performance stats
  Map<String, dynamic> getAudioStats() {
    return {
      'totalSoundsPlayed': _totalSoundsPlayed,
      'skippedSounds': _skippedSounds,
      'currentQueueSize': _soundQueue.length,
      'isLowPerfMode': _isLowPerfMode,
      'resourceFlushes': _resourceFlushes,
      'needsResourceFlush': _needsResourceFlush,
    };
  }

  // Pause all audio activity
  void pause() {
    if (_isPlaying) {
      stopBackgroundMusic();
    }
    _soundQueue.clear();
  }

  // Resume audio activity
  void resume() {
    if (!_isMuted && !_isPlaying) {
      playBackgroundMusic();
    }
  }

  // Clear audio caches and properly dispose resources
  void dispose() {
    _performanceCheckTimer?.cancel();
    stopBackgroundMusic();
    _lastSoundTimes.clear();
    _soundQueue.clear();

    try {
      // Dispose all pools
      for (final pools in _soundPools.values) {
        for (final pool in pools) {
          pool.dispose();
        }
      }
      _soundPools.clear();

      FlameAudio.bgm.dispose();
      FlameAudio.audioCache.clearAll();
    } catch (e) {
      print('Error disposing audio resources: $e');
    }
  }
}