import 'package:flutter/material.dart';
import 'package:music/componenets/box.dart';
import 'package:music/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:music/models/song.dart';
import 'package:music/utility/favourities.dart';

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  late List<Song> playlist;

  @override
  void initState() {
    super.initState();
    playlist = Provider.of<PlaylistProvider>(context, listen: false).playlist;
    loadFavorites(playlist); // Use the class-level playlist
  }

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${duration.inMinutes}:${twoDigitSeconds}";
  }

  void toggleFavorite(Song song) {
    setState(() {
      song.isFavorite = !song.isFavorite;
    });
    // Save the updated favorites to SharedPreferences
    saveFavorites(playlist);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = isDarkMode
        ? [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
        : [Color(0xFF1D2671), Color(0xFFC33764)];

    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final iconColor = isDarkMode ? Colors.white : Colors.black54;

    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        final playlist = value.playlist;
        final currentSong = playlist[value.currentSongIndex ?? 0];

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Now Playing',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundGradient,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80), // Offset for AppBar
                  // Album Art with Shadow
                  Box(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child:
                          Image(image: AssetImage('assets/image/songBg.jpg')),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Song and Artist Name
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          currentSong.songName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          currentSong.artistName,
                          style: TextStyle(
                            fontSize: 18,
                            color: textColor.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Timer and Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(value.currentDuration),
                          style: TextStyle(color: textColor),
                        ),
                        Icon(Icons.shuffle, color: iconColor),
                        Icon(Icons.repeat, color: iconColor),
                        Text(
                          formatTime(value.totalDuration),
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor:
                          isDarkMode ? Colors.greenAccent : Colors.green,
                      inactiveTrackColor: textColor.withOpacity(0.5),
                      thumbColor:
                          isDarkMode ? Colors.greenAccent : Colors.green,
                      overlayColor: isDarkMode
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 8),
                    ),
                    child: Slider(
                      min: 0,
                      max: value.totalDuration.inSeconds.toDouble(),
                      value: value.currentDuration.inSeconds.toDouble(),
                      onChanged: (newValue) {},
                      onChangeEnd: (newValue) {
                        value.seek(Duration(seconds: newValue.toInt()));
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Playback Controls
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: value.playPrevious,
                          child: Box(
                            child: const Icon(
                              Icons.skip_previous,
                              size: 32,
                              color: Colors.white,
                            ),
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.purple.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: value.playOrPause,
                          child: Box(
                            child: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40,
                              color: Colors.white,
                            ),
                            backgroundColor: isDarkMode
                                ? Colors.green.shade800
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: value.playNext,
                          child: Box(
                            child: const Icon(
                              Icons.skip_next,
                              size: 32,
                              color: Colors.white,
                            ),
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.purple.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Add Favorite Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              currentSong.isFavorite =
                                  !currentSong.isFavorite; // Toggle favorite
                            });
                          },
                          child: Box(
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.purple.shade700,
                            child: IconButton(
                              icon: Icon(
                                currentSong.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: currentSong.isFavorite
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                toggleFavorite(currentSong);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
