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

  void goToSong(BuildContext context, int songIndex) {
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    playlistProvider.setCurrentPlaylist('Favorites', playlist,
        songIndex: songIndex);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Favorite Songs',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song>? playlist = value.playlist;
          if (playlist == null) {
            return Center(
              child: Text(
                'No playlist available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            );
          }

          final List<Song> favorites =
              playlist.where((song) => song.isFavorite).toList();

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'No favorite songs yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final Song song = favorites[index];
              return GestureDetector(
                onTap: () => goToSong(context, playlist.indexOf(song)),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      song.songName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artistName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow,
                              color: Colors.blue.shade900),
                          onPressed: () =>
                              goToSong(context, playlist.indexOf(song)),
                        ),
                        IconButton(
                          icon:
                              Icon(Icons.favorite, color: Colors.red.shade400),
                          onPressed: () {
                            setState(() {
                              song.isFavorite = false;
                            });
                            saveFavorites(playlist);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
