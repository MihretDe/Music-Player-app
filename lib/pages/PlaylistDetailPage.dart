import 'package:flutter/material.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart';
import 'package:provider/provider.dart';

class PlaylistDetailPage extends StatelessWidget {
  final String playlistName;
  final List<Song> songs;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsing App Bar with Playlist Image
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              title: Text(
                playlistName,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade900,
                          Colors.blue.shade800,
                          Colors.blue.shade700,
                        ],
                      ),
                    ),
                  ),
                  // Animated background pattern
                  CustomPaint(
                    painter: MusicPatternPainter(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  // Music note icon with animation
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(
                            Icons.music_note,
                            size: 100,
                            color: Colors.white24,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Playlist Info Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade900.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blue.shade900.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 16,
                              color: Colors.blue.shade900,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${songs.length} songs',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Shuffle Play Button
                      IconButton(
                        onPressed: () {
                          // Implement shuffle play functionality
                        },
                        icon: Icon(
                          Icons.shuffle,
                          color: Colors.blue.shade900,
                        ),
                        tooltip: 'Shuffle Play',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ),

          // Songs List
          songs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                Icons.music_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No songs in this playlist!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final playlistProvider =
                                Provider.of<PlaylistProvider>(context,
                                    listen: false);
                            playlistProvider.setCurrentPlaylist(
                                playlistName, songs,
                                songIndex: index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SongPage()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              children: [
                                // Song Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.songName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artistName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Play Button with animation
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: Duration(
                                      milliseconds: 300 + (index * 100)),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue.shade900
                                              .withOpacity(0.1),
                                          border: Border.all(
                                            color: Colors.blue.shade900
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
        ],
      ),
    );
  }
}

// Custom painter for the background pattern
class MusicPatternPainter extends CustomPainter {
  final Color color;

  MusicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 30.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      for (var j = 0.0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          2.0,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
