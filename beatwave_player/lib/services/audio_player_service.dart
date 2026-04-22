import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

/// Bridges just_audio and audio_service for background playback with
/// notification / lock-screen controls.
class AudioPlayerService {
  late BaseAudioHandler _audioHandler;
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(
    children: [],
  );

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isInitialized = false;

  // ─── Getters ──────────────────────────────────────────────────
  AudioPlayer get player => _player;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  // ─── Streams ──────────────────────────────────────────────────
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;
  Stream<bool> get shuffleModeStream => _player.shuffleModeEnabledStream;

  /// Combined stream for UI: position, duration, buffered
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration?, Duration, PositionData>(
        _player.positionStream,
        _player.durationStream,
        _player.bufferedPositionStream,
        (position, duration, buffered) => PositionData(
          position: position,
          duration: duration ?? Duration.zero,
          buffered: buffered,
        ),
      );

  // ─── Initialization ──────────────────────────────────────────
  Future<void> init() async {
    if (_isInitialized) return;

    _audioHandler = await AudioService.init(
      builder: () => _BeatWaveAudioHandler(_player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.beatwave_player.channel',
        androidNotificationChannelName: 'BeatWave Playback',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    );

    // Listen for index changes from just_audio
    _player.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        _updateMediaItem();
      }
    });

    // Auto-detect when playback completes
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        // handled by loop mode
      }
    });

    _isInitialized = true;
  }

  // ─── Queue Management ────────────────────────────────────────
  Future<void> loadQueue(List<Song> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    _currentIndex = startIndex;

    final sources = songs.map((song) {
      final uri = song.uri ?? song.data ?? '';
      return AudioSource.uri(
        Uri.parse(uri),
        tag: MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: Duration(milliseconds: song.duration),
        ),
      );
    }).toList();

    await _playlist.clear();
    await _playlist.addAll(sources);
    await _player.setAudioSource(_playlist, initialIndex: startIndex);
    _updateMediaItem();
  }

  Future<void> playSong(Song song, List<Song> allSongs) async {
    final index = allSongs.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    await loadQueue(allSongs, startIndex: index);
    await play();
  }

  // ─── Playback Controls ──────────────────────────────────────
  Future<void> play() async => _player.play();
  Future<void> pause() async => _player.pause();
  Future<void> stop() async => _player.stop();

  Future<void> playOrPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
      _currentIndex = _player.currentIndex ?? _currentIndex;
      _updateMediaItem();
    }
  }

  Future<void> previous() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
      _currentIndex = _player.currentIndex ?? _currentIndex;
      _updateMediaItem();
    }
  }

  Future<void> seek(Duration position) async => _player.seek(position);

  // ─── Modes ────────────────────────────────────────────────────
  Future<void> setShuffleMode(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> cycleLoopMode() async {
    final modes = [LoopMode.off, LoopMode.all, LoopMode.one];
    final currentIdx = modes.indexOf(_player.loopMode);
    final nextIdx = (currentIdx + 1) % modes.length;
    await setLoopMode(modes[nextIdx]);
  }

  // ─── Private ──────────────────────────────────────────────────
  void _updateMediaItem() {
    final song = currentSong;
    if (song == null) return;
    _audioHandler.mediaItem.add(
      MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: Duration(milliseconds: song.duration),
      ),
    );
  }

  // ─── Cleanup ──────────────────────────────────────────────────
  Future<void> dispose() async {
    await _player.dispose();
  }

  /// Get the audio session id for equalizer binding
  Future<int?> getAudioSessionId() async {
    return _player.androidAudioSessionId;
  }
}

/// Combined position data for UI
class PositionData {
  final Duration position;
  final Duration duration;
  final Duration buffered;

  PositionData({
    required this.position,
    required this.duration,
    required this.buffered,
  });
}

/// AudioHandler implementation for audio_service (notification controls)
class _BeatWaveAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  _BeatWaveAudioHandler(this._player) {
    // Broadcast state changes to the system
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _mapProcessingState(_player.processingState),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
}
