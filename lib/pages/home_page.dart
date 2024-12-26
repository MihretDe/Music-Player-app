import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart';
import 'package:music/pages/favourites.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PlaylistProvider playlistProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
  }

  void goToSong(int songIndex) {
    playlistProvider.currentSongIndex = songIndex;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Music Player',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.black87, Colors.grey.shade800]
                      : [Colors.purple.shade400, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.music_note, size: 100, color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.pop(context),
            ),
            // ListTile(
            //   title: const Text(
            //     'Favorites',
            //     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            //   ),
            //     onTap: () => Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) =>  FavoritesPage()),
            //     ),
            // ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                  CupertinoSwitch(
                    value: Provider.of<ThemeProvider>(context, listen: false)
                        .isDarkMode,
                    onChanged: (value) =>
                        Provider.of<ThemeProvider>(context, listen: false)
                            .toggleTheme(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final List<Song>? playlist = value.playlist;

          if (playlist == null || playlist.isEmpty) {
            return Center(
              child: Text(
                "No songs available",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
            );
          }

          return Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [Colors.black87, Colors.grey.shade800]
                        : [Colors.purple.shade400, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Playlist',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Song List Section
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: playlist.length,
                  itemBuilder: (context, index) {
                    final Song song = playlist[index];
                    return GestureDetector(
                      onTap: () => goToSong(index),
                      child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(8.0),
                            title: Text(
                              song.songName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            subtitle: Text(
                              song.artistName,
                              style: TextStyle(
                                fontSize: 14,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                            trailing: Icon(Icons.play_arrow,
                                color: textColor, size: 28),
                          )),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
