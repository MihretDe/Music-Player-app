import 'package:flutter/material.dart';
import 'package:music/componenets/box.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:music/models/song.dart';
import 'package:music/utility/favourities.dart';
import 'package:music/utility/playlist.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late List<Song> playlist;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    playlist = playlistProvider.currentPlaylist;
    loadFavorites(playlist);
  }

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inMinutes}:$twoDigitSeconds";
  }

  void toggleFavorite(Song song) {
    setState(() {
      song.isFavorite = !song.isFavorite;
    });
    saveFavorites(playlist);
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
                SizedBox(height: 15),
                TextField(
                  controller: playlistController,
                  decoration: InputDecoration(
                    labelText: 'New Playlist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
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
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final currentSong = value.currentSong;
        if (currentSong == null) {
          return Scaffold(
            body: Center(
              child: Text('No song selected'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Now Playing',
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
          body: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Album Art with Classic Frame
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
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/image/songBg.jpg',
                      fit: BoxFit.cover,
                      width: 250,
                      height: 250,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Song & Artist Name
                Text(
                  currentSong.songName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                Text(
                  currentSong.artistName,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color
                        ?.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Time and Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatTime(value.currentDuration),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Icon(
                        Icons.shuffle,
                        color: Colors.blue.shade900,
                      ),
                      Icon(
                        Icons.repeat,
                        color: Colors.blue.shade900,
                      ),
                      Text(
                        formatTime(value.totalDuration),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue.shade900,
                    inactiveTrackColor: Colors.blue.shade900.withOpacity(0.2),
                    thumbColor: Colors.blue.shade900,
                    overlayColor: Colors.blue.shade900.withOpacity(0.1),
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: value.currentDuration.inSeconds.toDouble(),
                    max: value.totalDuration.inSeconds.toDouble(),
                    onChanged: (double newValue) {
                      final newDuration = Duration(seconds: newValue.toInt());
                      value.seek(newDuration);
                    },
                  ),
                ),

                // Playback Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _classicButton(
                      currentSong.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      () => toggleFavorite(currentSong),
                      Colors.red.shade400,
                    ),
                    const SizedBox(width: 20),
                    _classicButton(
                      Icons.skip_previous,
                      () => value.playPrevious(),
                      Colors.blue.shade900,
                    ),
                    const SizedBox(width: 20),
                    _classicButton(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                      () => value.playOrPause(),
                      Colors.blue.shade900,
                      isLarge: true,
                    ),
                    const SizedBox(width: 20),
                    _classicButton(
                      Icons.skip_next,
                      () => value.playNext(),
                      Colors.blue.shade900,
                    ),
                    const SizedBox(width: 20),
                    _classicButton(
                      Icons.add,
                      () {
                        final playlistProvider = Provider.of<PlaylistProvider>(
                            context,
                            listen: false);
                        final currentSong = playlistProvider.playlists[
                                playlistProvider.currentPlaylistName!]![
                            playlistProvider.currentSongIndex!];
                        showPlaylistBottomSheet(context, currentSong);
                      },
                      Colors.blue.shade900,
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _classicButton(
    IconData icon,
    VoidCallback onPressed,
    Color color, {
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: isLarge ? 36 : 28,
          color: color,
        ),
      ),
    );
  }
}
