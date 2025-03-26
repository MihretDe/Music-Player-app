import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:music/models/song.dart';

Future<void> savePlaylist(String playlistName, List<Song> songs) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert the songs list to JSON
  List<Map<String, dynamic>> songList = songs
      .map((song) => {
            'songName': song.songName,
            'artistName': song.artistName,
            'audioPath': song.audioPath,
          })
      .toList();

  // Save the playlist as a JSON string
  await prefs.setString(playlistName, jsonEncode(songList));
}

Future<List<Song>> loadPlaylist(String playlistName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get the JSON string for the playlist
  String? playlistJson = prefs.getString(playlistName);
  if (playlistJson == null) return [];

  // Convert the JSON string back into a list of songs
  List<dynamic> songList = jsonDecode(playlistJson);
  return songList.map((song) {
    // Extract artist name from the song name if it contains " - "
    String artistName = 'Unknown';
    String songName = song['songName'];

    if (songName.contains(' - ')) {
      List<String> parts = songName.split(' - ');
      artistName = parts[0];
      songName = parts[1];
    }

    return Song(
      songName: songName,
      artistName: song['artistName'] ??
          artistName, // Use stored artist name or extracted one
      audioPath: song['audioPath'],
    );
  }).toList();
}

Future<void> saveAllPlaylistNames(List<String> playlistNames) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('allPlaylists', playlistNames);
}

Future<List<String>> loadAllPlaylistNames() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('allPlaylists') ?? [];
}

Future<void> deletePlaylist(String playlistName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Remove the playlist data
  await prefs.remove(playlistName);

  // Update the playlist names list
  List<String> playlistNames = await loadAllPlaylistNames();
  playlistNames.remove(playlistName);
  await saveAllPlaylistNames(playlistNames);
}
