import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart'; 
import 'package:music/componenets/box.dart'; 

class FavoritesPage extends StatelessWidget {

  // Function to navigate to SongPage
  void goToSong(BuildContext context, int songIndex) {
    // Access PlaylistProvider to set the current song index
    final playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.currentSongIndex = songIndex;

    // Navigate to SongPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Songs')),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song>? playlist = value.playlist; // Access the playlist

          // Filter the playlist to get only favorite songs
          final List<Song> favoriteSongs = playlist!.where((song) => song.isFavorite).toList();

          return favoriteSongs.isEmpty
              ? const Center(child: Text('No favorite songs yet.'))
              : ListView.builder(
                  itemCount: favoriteSongs.length,
                  itemBuilder: (context, index) {
                    final song = favoriteSongs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Heart icon (disabled)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red.withOpacity(0.6), // Disabled appearance
                              size: 28,
                            ),
                          ),
                          
                          // Song name and artist
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.songName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  song.artistName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Play button
                          GestureDetector(
                            onTap: () {
                              goToSong(context, index); // Navigate to the song page
                            },
                            child: Box(
                              child: Icon(
                                Icons.play_arrow,
                                size: 32,
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
