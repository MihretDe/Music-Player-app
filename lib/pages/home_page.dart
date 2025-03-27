import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:music/pages/playlist.dart';
import 'package:provider/provider.dart';
import 'package:music/themes/theme_provider.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/song_page.dart';
import 'package:music/pages/favourites.dart';
import 'package:music/utility/playlist.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PlaylistProvider playlistProvider;
  bool isPlaying = false;
  String searchQuery = '';
  List<Song> filteredSongs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
    filteredSongs = playlistProvider.playlist;
  }

  void goToSong(int songIndex) {
    playlistProvider.setCurrentPlaylist('All Songs', playlistProvider.playlist,
        songIndex: songIndex);
    playlistProvider.play(); // Start playing automatically
    setState(() {
      isPlaying = true;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SongPage()),
    );
  }

  Future<void> createNewPlaylist(String playlistName, List<Song> songs) async {
    await savePlaylist(playlistName, songs);
    List<String> playlistNames = await loadAllPlaylistNames();
    if (!playlistNames.contains(playlistName)) {
      playlistNames.add(playlistName);
      await saveAllPlaylistNames(playlistNames);
    }
    setState(() {});
  }

  Future<void> addToExistingPlaylist(String playlistName, Song song) async {
    List<Song> playlistSongs = await loadPlaylist(playlistName);
    playlistSongs.add(song);
    await savePlaylist(playlistName, playlistSongs);
    setState(() {});
  }

  void showPlaylistBottomSheet(BuildContext context, Song song) {
    TextEditingController playlistController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add to Playlist',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                SizedBox(height: 15),
                FutureBuilder<List<String>>(
                  future: loadAllPlaylistNames(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError || snapshot.data?.isEmpty == true) {
                      return Text('No playlists available. Create one below.');
                    }

                    final playlists = snapshot.data!;
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(playlists[index]),
                            leading: Icon(Icons.playlist_play,
                                color: Colors.blue.shade900),
                            onTap: () async {
                              await addToExistingPlaylist(
                                  playlists[index], song);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                Divider(),
                TextField(
                  controller: playlistController,
                  decoration: InputDecoration(
                    labelText: 'New Playlist Name',
                    labelStyle: TextStyle(color: Colors.blue.shade900),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.blue.shade900)),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newPlaylistName = playlistController.text.trim();
                        if (newPlaylistName.isNotEmpty) {
                          await createNewPlaylist(newPlaylistName, [song]);
                          playlistController.clear();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Playlist "$newPlaylistName" created successfully'),
                              backgroundColor: Colors.blue.shade900,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void filterSongs(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSongs = playlistProvider.playlist;
      } else {
        filteredSongs = playlistProvider.playlist.where((song) {
          return song.songName.toLowerCase().contains(query.toLowerCase()) ||
              song.artistName.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Music Player',
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
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
                child: Icon(Icons.music_note, size: 100, color: Colors.white24),
              ),
            ),
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              leading: Icon(Icons.home, color: Colors.blue.shade900),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: Text(
                'Favorites',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              leading: Icon(Icons.favorite, color: Colors.blue.shade900),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              ),
            ),
            ListTile(
              title: Text(
                'Playlists',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              leading: Icon(Icons.playlist_play, color: Colors.blue.shade900),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PlaylistPage()),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Dark Mode', style: TextStyle(fontSize: 16)),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Songs List
          Expanded(
            child: Consumer<PlaylistProvider>(
              builder: (context, value, child) {
                final playlist = value.playlist;

                if (playlist.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.music_off,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          "No songs available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (filteredSongs.isEmpty && searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          'No songs found for "$searchQuery"',
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
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final Song song = filteredSongs[index];
                    return GestureDetector(
                      onTap: () => goToSong(playlist.indexOf(song)),
                      child: Card(
                        elevation: 2,
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
                                    goToSong(playlist.indexOf(song)),
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
          ),
        ],
      ),
      bottomNavigationBar: Consumer<PlaylistProvider>(
        builder: (context, value, child) {
          final currentSongIndex = playlistProvider.currentSongIndex;
          if (currentSongIndex == null || currentSongIndex < 0) {
            return const SizedBox.shrink();
          }

          final currentSong = playlistProvider.playlist[currentSongIndex];

          return BottomAppBar(
            color: Colors.blue.shade900,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SongPage()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.songName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentSong.artistName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: value.playOrPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      playlistProvider.currentSongIndex = null;
                      value.stopCurrentSong();
                      setState(() {
                        isPlaying = false;
                      });
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
