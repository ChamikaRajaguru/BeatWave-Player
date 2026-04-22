import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/song_provider.dart';
import '../widgets/waveform_visualizer.dart';
import '../core/constants.dart';
import 'equalizer_screen.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Consumer2<AudioProvider, SongProvider>(
      builder: (context, audio, songProvider, _) {
        final song = audio.currentSong;
        if (song == null) {
          return Scaffold(
            body: Center(
              child: Text(
                'No song playing',
                style: theme.textTheme.titleMedium,
              ),
            ),
          );
        }

        final isFav = songProvider.isFavorite(song.id);

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.playerGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // ─── Top Bar ──────────────────────────────
                  _buildTopBar(theme),
                  const SizedBox(height: 12),
                  // ─── Album Art ────────────────────────────
                  Expanded(
                    flex: 5,
                    child: _buildAlbumArt(song, size, audio.isPlaying),
                  ),
                  // ─── Waveform ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: WaveformVisualizer(
                      isPlaying: audio.isPlaying,
                      color: AppColors.accent,
                      barCount: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ─── Song Info ────────────────────────────
                  _buildSongInfo(theme, song, isFav, songProvider),
                  const SizedBox(height: 16),
                  // ─── Seek Bar ─────────────────────────────
                  _buildSeekBar(theme, audio),
                  const SizedBox(height: 8),
                  // ─── Controls ─────────────────────────────
                  _buildControls(theme, audio),
                  const SizedBox(height: 8),
                  // ─── Extra Controls ───────────────────────
                  _buildExtraControls(theme, audio),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            color: Colors.white70,
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'NOW PLAYING',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.equalizer_rounded, size: 24),
            color: AppColors.accent,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EqualizerScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(dynamic song, Size size, bool isPlaying) {
    final artSize = size.width * 0.7;

    return Center(
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Transform.rotate(
            angle: isPlaying ? _animController.value * 2 * 3.14159 : 0,
            child: child,
          );
        },
        child: Container(
          width: artSize,
          height: artSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.1),
                blurRadius: 60,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Album artwork
                QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: artSize,
                  artworkWidth: artSize,
                  artworkBorder: BorderRadius.circular(artSize / 2),
                  nullArtworkWidget: Container(
                    width: artSize,
                    height: artSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: artSize * 0.35,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  artworkFit: BoxFit.cover,
                ),
                // Center hole (vinyl effect)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.darkBg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                // Ring overlay
                Container(
                  width: artSize,
                  height: artSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(
    ThemeData theme,
    dynamic song,
    bool isFav,
    SongProvider songProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${song.artist}  •  ${song.album}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.accentSecondary : Colors.white54,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              songProvider.toggleFavorite(song.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSeekBar(ThemeData theme, AudioProvider audio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: audio.duration.inMilliseconds > 0
                  ? audio.position.inMilliseconds.toDouble().clamp(
                      0,
                      audio.duration.inMilliseconds.toDouble(),
                    )
                  : 0,
              max: audio.duration.inMilliseconds > 0
                  ? audio.duration.inMilliseconds.toDouble()
                  : 1.0,
              onChanged: (value) {
                audio.seek(Duration(milliseconds: value.round()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(audio.position),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                  ),
                ),
                Text(
                  _formatDuration(audio.duration),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme, AudioProvider audio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          IconButton(
            icon: Icon(
              Icons.shuffle_rounded,
              color: audio.shuffleEnabled ? AppColors.accent : Colors.white38,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              audio.toggleShuffle();
            },
          ),
          // Previous
          IconButton(
            icon: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 36,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              audio.previous();
            },
          ),
          // Play/Pause
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              audio.playOrPause();
            },
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                audio.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
          // Next
          IconButton(
            icon: const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 36,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              audio.next();
            },
          ),
          // Repeat
          IconButton(
            icon: Icon(
              audio.loopMode == LoopMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: audio.loopMode != LoopMode.off
                  ? AppColors.accent
                  : Colors.white38,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              audio.cycleLoopMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtraControls(ThemeData theme, AudioProvider audio) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.playlist_play_rounded),
            color: Colors.white38,
            iconSize: 24,
            onPressed: () {
              _showQueueBottomSheet(context, audio);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            color: Colors.white38,
            iconSize: 20,
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
    );
  }

  void _showQueueBottomSheet(BuildContext context, AudioProvider audio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Queue (${audio.queue.length} songs)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: audio.queue.length,
                    itemBuilder: (_, index) {
                      final song = audio.queue[index];
                      final isCurrentSong = audio.currentSong?.id == song.id;
                      return ListTile(
                        leading: isCurrentSong
                            ? const Icon(
                                Icons.graphic_eq_rounded,
                                color: AppColors.accent,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white38),
                              ),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            color: isCurrentSong
                                ? AppColors.accent
                                : Colors.white,
                            fontWeight: isCurrentSong
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        onTap: () {
                          audio.playSong(song, audio.queue);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
