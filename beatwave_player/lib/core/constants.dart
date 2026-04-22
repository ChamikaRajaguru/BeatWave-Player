import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'BeatWave';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFavorites = 'favorites';
  static const String keyPlaylists = 'playlists';
  static const String keyEqPresets = 'eq_presets';
  static const String keyLastEqPreset = 'last_eq_preset';
  static const String keyLastSong = 'last_song';
  static const String keyShuffleMode = 'shuffle_mode';
  static const String keyRepeatMode = 'repeat_mode';

  // Equalizer
  static const int eqBandCount = 5;
  static const double eqMinLevel = -15.0;
  static const double eqMaxLevel = 15.0;
  static const double bassBoostMax = 1000.0;
  static const double virtualizerMax = 1000.0;

  // EQ Band center frequencies (Hz)
  static const List<String> eqBandLabels = [
    '60Hz',
    '230Hz',
    '910Hz',
    '3.6kHz',
    '14kHz',
  ];

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);
}

class EqPresets {
  EqPresets._();

  static const Map<String, List<double>> builtIn = {
    'Normal': [0, 0, 0, 0, 0],
    'Pop': [1, 4, 7, 4, 1],
    'Rock': [5, 3, 0, 3, 5],
    'Jazz': [4, 2, -2, 2, 5],
    'Bass Boost': [10, 7, 0, 0, 0],
    'Classical': [5, 3, -2, 4, 5],
    'Hip Hop': [7, 5, 0, 3, 3],
    'Electronic': [5, 4, 0, 2, 5],
    'Vocal': [-2, 0, 5, 3, 0],
    'Flat': [0, 0, 0, 0, 0],
  };
}

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primaryDark = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentSecondary = Color(0xFFFF6584);

  // Dark theme
  static const Color darkBg = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);
  static const Color darkElevated = Color(0xFF1F2940);

  // Light theme
  static const Color lightBg = Color(0xFFF5F5FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient playerGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
