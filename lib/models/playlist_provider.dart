import 'package:flutter/material.dart';
import 'package:music/models/song.dart';
import 'package:audioplayers/audioplayers.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [
    Song(
      songName: 'Song 1',
      artistName: 'Artist 1',
      albumArtImagePath: 'assets/image/dawit.jpg',
      audioPath: 'audio/እንግዳ_ነኝ_እኔ_ስኖር_በዚህች_አለም.ogg',
    ),
    Song(
      songName: 'Song 2',
      artistName: 'Artist 2',
      albumArtImagePath: 'assets/image/dawit.jpg',
      audioPath: 'audio/4. Zema 4 Christ - Nuro Kegeta Keyesus Gare (128).mp3',
    ),
    Song(
      songName: 'Song 3',
      artistName: 'Artist 3',
      albumArtImagePath: 'assets/image/dawit.jpg',
      audioPath:
          'audio/Bemaebel_Wust_በማዕበል_ውስጥ_Dawit_Getachew_live_at_Addis_Ababa_N.m4a',
    ),
  ];
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  //constructor
  PlaylistProvider() {
    listenToDuration();
  }
  // initially not playing
  bool _isPlaying = false;
  //play the song
  void play() async {
    final String path = _playlist[_currentSongIndex!].audioPath;
    print('$path path');
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  //pause current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  //resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  //pause or resume
  void playOrPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  //seek to a specific position
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  //play previous song
  void playPrevious() {
    if (_currentSongIndex == 0) {
      _currentSongIndex = _playlist.length - 1;
    } else {
      _currentSongIndex = _currentSongIndex! - 1;
    }
    play();
  }

  //play next song
  void playNext() {
    if (_currentSongIndex == _playlist.length - 1) {
      _currentSongIndex = 0;
    } else {
      _currentSongIndex = _currentSongIndex! + 1;
    }
    play();
  }

  //listen to duration
  void listenToDuration() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      _totalDuration = newDuration;
      notifyListeners();
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      _currentDuration = newPosition;
      notifyListeners();
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      playNext();
    });
  }
  //dispose of the audio player

  List<Song> get playlist => _playlist;
  int? get currentSongIndex => _currentSongIndex;
  bool get isPlaying => _isPlaying;
  Duration get currentDuration => _currentDuration;
  Duration get totalDuration => _totalDuration;
  set currentSongIndex(int? newIndex) {
    _currentSongIndex = newIndex;
    if (newIndex != null) {
      play();
    }

    notifyListeners();
  }
}
