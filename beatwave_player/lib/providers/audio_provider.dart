import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/storage_service.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayerService _playerService;
  final StorageService _storageService;

  Song? _currentSong;
  List<Song> _queue = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  LoopMode _loopMode = LoopMode.off;
  bool _shuffleEnabled = false;

  AudioProvider(this._playerService, this._storageService) {
    _initListeners();
    _loadSavedState();
  }

  // ─── Getters ──────────────────────────────────────────────────
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get buffered => _buffered;
  LoopMode get loopMode => _loopMode;
  bool get shuffleEnabled => _shuffleEnabled;
  bool get hasSong => _currentSong != null;
  AudioPlayerService get playerService => _playerService;

  // ─── Listeners ────────────────────────────────────────────────
  void _initListeners() {
    _playerService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    _playerService.positionDataStream.listen((data) {
      _position = data.position;
      _duration = data.duration;
      _buffered = data.buffered;
      notifyListeners();
    });

    _playerService.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length) {
        _currentSong = _queue[index];
        _storageService.setLastSongId(_currentSong!.id);
        notifyListeners();
      }
    });

    _playerService.loopModeStream.listen((mode) {
      _loopMode = mode;
      notifyListeners();
    });

    _playerService.shuffleModeStream.listen((enabled) {
      _shuffleEnabled = enabled;
      notifyListeners();
    });
  }

  void _loadSavedState() {
    _shuffleEnabled = _storageService.shuffleMode;
    final repeatIdx = _storageService.repeatMode;
    _loopMode = LoopMode.values[repeatIdx.clamp(0, 2)];
  }

  // ─── Playback ─────────────────────────────────────────────────
  Future<void> playSong(Song song, List<Song> allSongs) async {
    _queue = List.from(allSongs);
    _currentSong = song;
    notifyListeners();
    await _playerService.playSong(song, allSongs);
  }

  Future<void> playOrPause() async => _playerService.playOrPause();
  Future<void> play() async => _playerService.play();
  Future<void> pause() async => _playerService.pause();
  Future<void> next() async => _playerService.next();
  Future<void> previous() async => _playerService.previous();
  Future<void> seek(Duration position) async => _playerService.seek(position);

  // ─── Modes ────────────────────────────────────────────────────
  Future<void> toggleShuffle() async {
    final newValue = !_shuffleEnabled;
    await _playerService.setShuffleMode(newValue);
    await _storageService.setShuffleMode(newValue);
  }

  Future<void> cycleLoopMode() async {
    await _playerService.cycleLoopMode();
    await _storageService.setRepeatMode(_loopMode.index);
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }
}
