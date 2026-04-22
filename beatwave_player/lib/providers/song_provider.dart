import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/audio_query_service.dart';
import '../services/storage_service.dart';

class SongProvider extends ChangeNotifier {
  final AudioQueryService _queryService;
  final StorageService _storageService;

  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  List<int> _favorites = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;

  SongProvider(this._queryService, this._storageService) {
    _favorites = _storageService.favorites;
  }

  // ─── Getters ──────────────────────────────────────────────────
  List<Song> get songs =>
      _filteredSongs.isEmpty && _searchQuery.isEmpty ? _songs : _filteredSongs;
  List<Song> get allSongs => _songs;
  List<int> get favoriteIds => _favorites;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  List<Song> get favoriteSongs =>
      _songs.where((s) => _favorites.contains(s.id)).toList();

  bool isFavorite(int songId) => _favorites.contains(songId);

  // ─── Load Songs ──────────────────────────────────────────────
  Future<void> loadSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _songs = await _queryService.querySongs();
      _filteredSongs = [];
      _searchQuery = '';
    } catch (e) {
      _error = 'Failed to load songs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Search ──────────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredSongs = [];
    } else {
      _filteredSongs = _queryService.searchSongs(query);
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSongs = [];
    notifyListeners();
  }

  // ─── Favorites ────────────────────────────────────────────────
  Future<void> toggleFavorite(int songId) async {
    await _storageService.toggleFavorite(songId);
    _favorites = _storageService.favorites;
    notifyListeners();
  }
}
