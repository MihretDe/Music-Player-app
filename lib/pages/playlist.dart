import 'package:flutter/material.dart';
import 'package:music/models/song.dart';
import 'package:music/pages/PlaylistDetailPage.dart';
import 'package:music/utility/playlist.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  List<String> playlistNames = [];

  @override
  void initState() {
    super.initState();
    loadPlaylists();
  }

  // Function to load all playlist names

  // Function to load playlists
  Future<void> loadPlaylists() async {
    List<String> loadedPlaylistNames = await loadAllPlaylistNames();
    setState(() {
      playlistNames = loadedPlaylistNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Playlists',
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
      body: playlistNames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.playlist_remove,
                      size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'No playlists available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: playlistNames.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    List<Song> songs = await loadPlaylist(playlistNames[index]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaylistDetailPage(
                          playlistName: playlistNames[index],
                          songs: songs,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Playlist'),
                        content: Text(
                            'Are you sure you want to delete "${playlistNames[index]}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Remove from SharedPreferences
                              await deletePlaylist(playlistNames[index]);
                              // Update the list
                              setState(() {
                                playlistNames.removeAt(index);
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Playlist deleted successfully'),
                                  backgroundColor: Colors.blue.shade900,
                                ),
                              );
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade900,
                              Colors.blue.shade800,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.playlist_play,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      title: Text(
                        playlistNames[index],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue.shade900,
                        size: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreatePlaylistDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Dialog to create a new playlist
  void showCreatePlaylistDialog(BuildContext context) {
    TextEditingController playlistController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create New Playlist',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: playlistController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon:
                    Icon(Icons.playlist_play, color: Colors.blue.shade900),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade900, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    String newPlaylist = playlistController.text.trim();
                    if (newPlaylist.isNotEmpty) {
                      // Save new playlist
                      List<Song> emptySongs = [];
                      await savePlaylist(newPlaylist, emptySongs);

                      // Update playlist list
                      playlistNames.add(newPlaylist);
                      await saveAllPlaylistNames(playlistNames);

                      setState(() {}); // Refresh the UI
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Playlist "$newPlaylist" created successfully'),
                          backgroundColor: Colors.blue.shade900,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
