import 'package:shared_preferences/shared_preferences.dart';
import 'package:music/models/song.dart';

Future<void> saveFavorites(List<Song> playlist) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> favoriteSongs = playlist.where((song) => song.isFavorite).map((song) => song.songName).toList();
  prefs.setStringList('favorite_songs', favoriteSongs);
}

Future<void> loadFavorites(List<Song> playlist) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? favoriteSongs = prefs.getStringList('favorite_songs');
  if (favoriteSongs != null) {
    for (var song in playlist) {
      song.isFavorite = favoriteSongs.contains(song.songName);
    }
  }
}
