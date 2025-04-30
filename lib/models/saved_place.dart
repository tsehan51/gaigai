class SavedPlace {
  final String imagePath;
  final String title;
  final String lastUpdated;

  SavedPlace({
    required this.imagePath,
    required this.title,
    required this.lastUpdated,
  });

  factory SavedPlace.fromJson(Map<String, dynamic> json) {
    return SavedPlace(
      imagePath: json['imagePath'],
      title: json['title'],
      lastUpdated: json['lastUpdated'],
    );
  }
}