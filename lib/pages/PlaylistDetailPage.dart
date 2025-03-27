import 'package:flutter/material.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart';
import 'package:provider/provider.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistName;
  final List<Song> songs;

  const PlaylistDetailPage({
    super.key,
    required this.playlistName,
    required this.songs,
  });

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  String searchQuery = '';
  List<Song> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = widget.songs;
  }

  void filterSongs(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSongs = widget.songs;
      } else {
        filteredSongs = widget.songs.where((song) {
          return song.songName.toLowerCase().contains(query.toLowerCase()) ||
              song.artistName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Collapsing App Bar with Playlist Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.playlistName,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
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
                child: Center(
                  child: Icon(
                    Icons.playlist_play,
                    size: 100,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade900.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.blue.shade900.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  onChanged: filterSongs,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search songs or artists...',
                    hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.blue.shade900),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          // Songs List
          filteredSongs.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          searchQuery.isEmpty
                              ? Icons.music_off
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No songs in this playlist'
                              : 'No songs found for "$searchQuery"',
                          style: TextStyle(
                            fontSize: 18,
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
                      final song = filteredSongs[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final playlistProvider =
                                Provider.of<PlaylistProvider>(context,
                                    listen: false);
                            playlistProvider.setCurrentPlaylist(
                                widget.playlistName, widget.songs,
                                songIndex: widget.songs.indexOf(song));
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
                                // Play Button
                                IconButton(
                                  icon: Icon(Icons.play_arrow,
                                      color: Colors.blue.shade900),
                                  onPressed: () {
                                    final playlistProvider =
                                        Provider.of<PlaylistProvider>(context,
                                            listen: false);
                                    playlistProvider.setCurrentPlaylist(
                                        widget.playlistName, widget.songs,
                                        songIndex: widget.songs.indexOf(song));
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SongPage()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filteredSongs.length,
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
