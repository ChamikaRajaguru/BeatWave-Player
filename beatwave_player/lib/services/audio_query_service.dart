import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';

class AudioQueryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<Song> _cachedSongs = [];

  List<Song> get songs => _cachedSongs;

  Future<List<Song>> querySongs() async {
    final songModels = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    _cachedSongs = songModels
        .where((s) => s.duration != null && s.duration! > 10000)
        .map((s) => Song.fromSongModel(s))
        .toList();

    return _cachedSongs;
  }

  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _cachedSongs;
    final lower = query.toLowerCase();
    return _cachedSongs.where((song) {
      return song.title.toLowerCase().contains(lower) ||
          song.artist.toLowerCase().contains(lower) ||
          song.album.toLowerCase().contains(lower);
    }).toList();
  }

  /// Returns artwork widget for a given song
  static Widget queryArtwork(int id, {double size = 50}) {
    return QueryArtworkWidget(
      id: id,
      type: ArtworkType.AUDIO,
      artworkHeight: size,
      artworkWidth: size,
      artworkBorder: BorderRadius.circular(12),
      nullArtworkWidget: defaultArtwork(size),
      artworkFit: BoxFit.cover,
    );
  }

  static Widget defaultArtwork(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white.withValues(alpha: 0.8),
        size: size * 0.5,
      ),
    );
  }
}
