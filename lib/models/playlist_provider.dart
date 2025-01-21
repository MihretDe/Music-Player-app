import 'package:flutter/material.dart';
import 'package:music/models/song.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PlaylistProvider extends ChangeNotifier {
  final List<Song> _playlist = [];
  int? _currentSongIndex;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Constructor
  PlaylistProvider() {
    listenToDuration();
    requestStoragePermission();
  }

  // Initially not playing
  bool _isPlaying = false;

  Future<void> requestStoragePermission() async {
    final storagePermission = await Permission.manageExternalStorage.request();
    if (storagePermission.isGranted) {
      print('MANAGE_EXTERNAL_STORAGE permission granted');
      await loadAllFiles(); 
    } else {
      print('MANAGE_EXTERNAL_STORAGE permission denied');
    }
  }

  // Load music files from local storage
  Future<void> loadAllFiles() async {
    try {
      final Directory rootDir =
          Directory('/storage/emulated/0/Music'); 
      final List<FileSystemEntity> files =
          rootDir.listSync(recursive: true, followLinks: false);
      // print(files);
      for (var file in files) {
        if (file is File && _isAudioFile(file.path)) {
          // print('Audio file found: ${file.path}');
          String fileName = p.basenameWithoutExtension(
              file.path); 

          List<String> parts = fileName.split(' - ');

          String artistName = 'Unknown';
          String songName = fileName;

          if (parts.length == 2) {
            artistName = parts[0];
            songName = parts[1];
          }

          
          _playlist.add(Song(
            audioPath: file.path,
            artistName: artistName,
            songName: songName,
          ));
        }
      }
      notifyListeners();
      // print("playlist: $_playlist");
    } catch (e) {
      print("Error accessing files: $e");
    }
  }

  // Check if the file is an audio file
  bool _isAudioFile(String path) {
    const List<String> audioExtensions = ['.mp3', '.m4a', '.wav', '.ogg'];
    return audioExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  // Play the selected song
  void play() async {
    if (_currentSongIndex == null) return;
    final String path = _playlist[_currentSongIndex!].audioPath;
    print('$path path');
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(path));
    _isPlaying = true;
    notifyListeners();
  }

  // Pause the current song
  void pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  // Resume playing
  void resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  // Pause or resume
  void playOrPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  // Seek to a specific position
  void seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Play previous song
  void playPrevious() {
    if (_currentSongIndex == 0) {
      _currentSongIndex = _playlist.length - 1;
    } else {
      _currentSongIndex = _currentSongIndex! - 1;
    }
    play();
  }

  // Play next song
  void playNext() {
    if (_currentSongIndex == _playlist.length - 1) {
      _currentSongIndex = 0;
    } else {
      _currentSongIndex = _currentSongIndex! + 1;
    }
    play();
  }

  // Listen to duration changes
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

  // Dispose of the audio player
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  void stopCurrentSong() {
  _audioPlayer.stop(); 
}

  // Getters and Setters
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
