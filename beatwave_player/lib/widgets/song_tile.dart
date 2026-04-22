import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';
import '../providers/audio_provider.dart';
import '../providers/song_provider.dart';
import '../services/audio_query_service.dart';
import '../core/constants.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final List<Song> songList;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onMorePressed;

  const SongTile({
    super.key,
    required this.song,
    required this.songList,
    this.isPlaying = false,
    this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songProvider = context.watch<SongProvider>();
    final isFav = songProvider.isFavorite(song.id);

    return AnimatedContainer(
      duration: AppConstants.animFast,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: isPlaying
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.lightImpact();
            if (onTap != null) {
              onTap!();
            } else {
              context.read<AudioProvider>().playSong(song, songList);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Album Art
                Hero(
                  tag: 'artwork_${song.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 52,
                      artworkWidth: 52,
                      artworkBorder: BorderRadius.circular(12),
                      nullArtworkWidget: AudioQueryService.defaultArtwork(52),
                      artworkFit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Song Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isPlaying
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                          fontWeight: isPlaying
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${song.artist}  •  ${song.durationFormatted}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isPlaying
                              ? theme.colorScheme.primary.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Playing indicator
                if (isPlaying)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    child: _PlayingIndicator(color: theme.colorScheme.primary),
                  ),
                // Favorite button
                IconButton(
                  icon: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFav
                        ? AppColors.accentSecondary
                        : theme.iconTheme.color,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    songProvider.toggleFavorite(song.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated playing indicator (3 bars)
class _PlayingIndicator extends StatefulWidget {
  final Color color;
  const _PlayingIndicator({required this.color});

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 150),
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, child) {
            return Container(
              width: 3,
              height: 8 + _controllers[i].value * 10,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }),
    );
  }
}
