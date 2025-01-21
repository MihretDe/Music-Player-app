import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart';
import 'package:music/utility/favourities.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late final List<Song> playlist;

  @override
  void initState() {
    super.initState();
    playlist = Provider.of<PlaylistProvider>(context, listen: false).playlist;
    loadFavorites(playlist);
  }

  // Function to navigate to SongPage
  void goToSong(BuildContext context, int songIndex) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.currentSongIndex = songIndex;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Favorite Songs',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
                    : [Color(0xFF1D2671), Color(0xFFC33764)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main content
          Consumer<PlaylistProvider>(
            builder: (context, value, child) {
              final List<Song>? playlist = value.playlist;

              final List<Map<String, dynamic>> favoriteSongsWithIndices =
                  playlist!
                      .asMap()
                      .entries
                      .where((entry) => entry.value.isFavorite)
                      .map((entry) => {
                            'index':
                                entry.key, 
                            'song': entry.value, 
                          })
                      .toList();
              return favoriteSongsWithIndices.isEmpty
                  ? const Center(
                      child: Text(
                        'No favorite songs yet.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                          top: 80.0), 
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 20.0,
                        ),
                        itemCount: favoriteSongsWithIndices.length,
                        itemBuilder: (context, index) {
                          final songData = favoriteSongsWithIndices[index];
                          final song = songData['song'] as Song;
                          final originalIndex = songData['index'];
                          return Card(
                            color: Colors.white.withOpacity(0.15),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 16.0,
                              ),
                              leading: Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 28,
                              ),
                              title: Text(
                                song.songName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                song.artistName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  goToSong(context, originalIndex);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
