import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/song_provider.dart';
import '../widgets/song_tile.dart';
import '../core/constants.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<PlaylistProvider, SongProvider, AudioProvider>(
      builder: (context, playlistProvider, songProvider, audioProvider, _) {
        final playlist = playlistProvider.getPlaylist(playlistId);
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Playlist')),
            body: const Center(child: Text('Playlist not found')),
          );
        }

        final songs = songProvider.allSongs
            .where((s) => playlist.songIds.contains(s.id))
            .toList();

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 22,
                          ),
                          color: Colors.white70,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Text(
                          playlist.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 24),
                          color: AppColors.accent,
                          onPressed: () => _showAddSongsSheet(
                            context,
                            playlist.id,
                            songProvider,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Playlist info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.playlist_play_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${songs.length} songs',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (songs.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (songs.isNotEmpty) {
                                  audioProvider.playSong(songs.first, songs);
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Song list
                  Expanded(
                    child: songs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.music_off_rounded,
                                  size: 48,
                                  color: Colors.white24,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No songs in this playlist',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white38,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text('Add Songs'),
                                  onPressed: () => _showAddSongsSheet(
                                    context,
                                    playlist.id,
                                    songProvider,
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 20),
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              final isPlaying =
                                  audioProvider.currentSong?.id == song.id;
                              return Dismissible(
                                key: ValueKey(song.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24),
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                onDismissed: (_) {
                                  playlistProvider.removeSongFromPlaylist(
                                    playlist.id,
                                    song.id,
                                  );
                                },
                                child: SongTile(
                                  song: song,
                                  songList: songs,
                                  isPlaying: isPlaying,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddSongsSheet(
    BuildContext context,
    String playlistId,
    SongProvider songProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            final allSongs = songProvider.allSongs;
            return Column(
              children: [
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
                    'Add Songs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: allSongs.length,
                    itemBuilder: (_, index) {
                      final song = allSongs[index];
                      return ListTile(
                        title: Text(
                          song.title,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          song.artist,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.accent,
                          ),
                          onPressed: () {
                            context.read<PlaylistProvider>().addSongToPlaylist(
                              playlistId,
                              song.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${song.title}"'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
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
