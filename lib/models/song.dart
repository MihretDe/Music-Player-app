class Song {
  final String songName;
  final String artistName;
  bool isFavorite;
  final String audioPath;

  Song({
    required this.songName,
    required this.artistName,
    required this.audioPath,
    this.isFavorite = false,
  });
}
