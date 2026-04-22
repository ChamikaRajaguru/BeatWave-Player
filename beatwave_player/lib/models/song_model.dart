import 'package:on_audio_query/on_audio_query.dart';

class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? uri;
  final int duration; // milliseconds
  final String? data; // file path
  final int? albumId;
  final int? artistId;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.uri,
    required this.duration,
    this.data,
    this.albumId,
    this.artistId,
  });

  factory Song.fromSongModel(SongModel model) {
    return Song(
      id: model.id,
      title: model.title,
      artist: model.artist ?? 'Unknown Artist',
      album: model.album ?? 'Unknown Album',
      uri: model.uri,
      duration: model.duration ?? 0,
      data: model.data,
      albumId: model.albumId,
      artistId: model.artistId,
    );
  }

  String get durationFormatted {
    final d = Duration(milliseconds: duration);
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'uri': uri,
    'duration': duration,
    'data': data,
    'albumId': albumId,
    'artistId': artistId,
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] as int,
    title: json['title'] as String,
    artist: json['artist'] as String,
    album: json['album'] as String,
    uri: json['uri'] as String?,
    duration: json['duration'] as int,
    data: json['data'] as String?,
    albumId: json['albumId'] as int?,
    artistId: json['artistId'] as int?,
  );
}
