import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';

class PlaylistProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Playlist> _playlists = [];

  PlaylistProvider(this._storageService) {
    _playlists = _storageService.playlists;
  }

  List<Playlist> get playlists => _playlists;

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    _playlists.add(playlist);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _storageService.savePlaylists(_playlists);
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index].name = newName;
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1 && !_playlists[index].songIds.contains(songId)) {
      _playlists[index].songIds.add(songId);
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, int songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songIds.remove(songId);
      await _storageService.savePlaylists(_playlists);
      notifyListeners();
    }
  }

  Playlist? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
