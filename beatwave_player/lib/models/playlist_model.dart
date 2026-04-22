import 'dart:convert';

class Playlist {
  final String id;
  String name;
  final List<int> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songIds': songIds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] as String,
    name: json['name'] as String,
    songIds: (json['songIds'] as List).cast<int>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  String encode() => jsonEncode(toJson());

  factory Playlist.decode(String source) =>
      Playlist.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
