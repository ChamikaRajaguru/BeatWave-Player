import 'package:shared_preferences/shared_preferences.dart';
import '../models/playlist_model.dart';
import '../models/eq_preset_model.dart';
import '../core/constants.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Theme ────────────────────────────────────────────────────
  bool get isDarkMode => _prefs.getBool(AppConstants.keyThemeMode) ?? true;
  Future<void> setDarkMode(bool value) =>
      _prefs.setBool(AppConstants.keyThemeMode, value);

  // ─── Favorites ────────────────────────────────────────────────
  List<int> get favorites {
    final data = _prefs.getStringList(AppConstants.keyFavorites);
    return data?.map((e) => int.parse(e)).toList() ?? [];
  }

  Future<void> setFavorites(List<int> ids) => _prefs.setStringList(
    AppConstants.keyFavorites,
    ids.map((e) => e.toString()).toList(),
  );

  Future<void> toggleFavorite(int songId) async {
    final fav = favorites;
    if (fav.contains(songId)) {
      fav.remove(songId);
    } else {
      fav.add(songId);
    }
    await setFavorites(fav);
  }

  bool isFavorite(int songId) => favorites.contains(songId);

  // ─── Playlists ────────────────────────────────────────────────
  List<Playlist> get playlists {
    final data = _prefs.getStringList(AppConstants.keyPlaylists);
    if (data == null) return [];
    return data.map((e) => Playlist.decode(e)).toList();
  }

  Future<void> savePlaylists(List<Playlist> lists) => _prefs.setStringList(
    AppConstants.keyPlaylists,
    lists.map((e) => e.encode()).toList(),
  );

  // ─── EQ Custom Presets ────────────────────────────────────────
  List<EqPreset> get customEqPresets {
    final data = _prefs.getStringList(AppConstants.keyEqPresets);
    if (data == null) return [];
    return data.map((e) => EqPreset.decode(e)).toList();
  }

  Future<void> saveCustomEqPresets(List<EqPreset> presets) =>
      _prefs.setStringList(
        AppConstants.keyEqPresets,
        presets.map((e) => e.encode()).toList(),
      );

  // ─── Last EQ Preset ──────────────────────────────────────────
  String? get lastEqPreset => _prefs.getString(AppConstants.keyLastEqPreset);
  Future<void> setLastEqPreset(String name) =>
      _prefs.setString(AppConstants.keyLastEqPreset, name);

  // ─── Shuffle / Repeat ─────────────────────────────────────────
  bool get shuffleMode => _prefs.getBool(AppConstants.keyShuffleMode) ?? false;
  Future<void> setShuffleMode(bool value) =>
      _prefs.setBool(AppConstants.keyShuffleMode, value);

  int get repeatMode => _prefs.getInt(AppConstants.keyRepeatMode) ?? 0;
  Future<void> setRepeatMode(int value) =>
      _prefs.setInt(AppConstants.keyRepeatMode, value);

  // ─── Last Song ────────────────────────────────────────────────
  int? get lastSongId {
    final val = _prefs.getInt(AppConstants.keyLastSong);
    return val;
  }

  Future<void> setLastSongId(int id) =>
      _prefs.setInt(AppConstants.keyLastSong, id);
}
