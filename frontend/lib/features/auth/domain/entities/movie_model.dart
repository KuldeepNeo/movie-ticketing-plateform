class MovieModel {
  final int id;
  final String title;
  final String synopsis;
  final int runtimeMinutes;
  final String language;
  final String genre;
  final String ageRating;
  final String posterUrl;
  final String bannerUrl;
  final String status;
  final String? createdAt;

  const MovieModel({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.runtimeMinutes,
    required this.language,
    required this.genre,
    required this.ageRating,
    required this.posterUrl,
    required this.bannerUrl,
    required this.status,
    this.createdAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String? ?? '',
      runtimeMinutes: json['runtime_minutes'] as int,
      language: json['language'] as String,
      genre: json['genre'] as String,
      ageRating: json['age_rating'] as String,
      posterUrl: json['poster_url'] as String,
      bannerUrl: json['banner_url'] as String? ?? '',
      status: json['status'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'runtime_minutes': runtimeMinutes,
      'language': language,
      'genre': genre,
      'age_rating': ageRating,
      'poster_url': posterUrl,
      'banner_url': bannerUrl,
      'status': status,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'MovieModel(id: $id, title: $title, status: $status)';
  }
}
