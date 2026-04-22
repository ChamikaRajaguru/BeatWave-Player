import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'services/audio_player_service.dart';
import 'services/audio_query_service.dart';
import 'services/equalizer_service.dart';
import 'services/storage_service.dart';
import 'providers/audio_provider.dart';
import 'providers/song_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/equalizer_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/home_screen.dart';
import 'screens/equalizer_screen.dart';

import 'dart:ui';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers to prevent silent crashes
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services with error handling
  final storageService = StorageService();
  await storageService.init();

  AudioPlayerService? audioPlayerService;
  try {
    audioPlayerService = AudioPlayerService();
    await audioPlayerService.init();
  } catch (e) {
    debugPrint('AudioPlayerService init failed: $e');
    audioPlayerService = AudioPlayerService();
  }

  final audioQueryService = AudioQueryService();
  final equalizerService = EqualizerService();

  runApp(
    BeatWaveApp(
      storageService: storageService,
      audioPlayerService: audioPlayerService,
      audioQueryService: audioQueryService,
      equalizerService: equalizerService,
    ),
  );
}

class BeatWaveApp extends StatelessWidget {
  final StorageService storageService;
  final AudioPlayerService audioPlayerService;
  final AudioQueryService audioQueryService;
  final EqualizerService equalizerService;

  const BeatWaveApp({
    super.key,
    required this.storageService,
    required this.audioPlayerService,
    required this.audioQueryService,
    required this.equalizerService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioPlayerService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SongProvider(audioQueryService, storageService),
        ),
        ChangeNotifierProvider(create: (_) => PlaylistProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => EqualizerProvider(equalizerService, storageService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'BeatWave',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/permission': (context) => const PermissionScreen(),
              '/home': (context) => const HomeScreen(),
              '/equalizer': (context) => const EqualizerScreen(),
            },
          );
        },
      ),
    );
  }
}
