class Cast {
  final String name;
  final String character;
  final String? image;

  Cast({required this.name, required this.character, this.image});

  factory Cast.fromJson(Map<String, dynamic> j) => Cast(
        name: j['name'] ?? '',
        character: j['character_name'] ?? '',
        image: j['url_small_image'],
      );
}

class Movie {
  final int id;
  final String title;
  final int year;
  final double rating;
  final int runtime;
  final int likeCount;
  final String mediumCover;
  final String largeCover;
  final String background;
  final List<String> genres;
  final String summary;
  final String trailerCode;
  final List<Cast> cast;
  final List<String> screenshots;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.rating,
    required this.runtime,
    required this.likeCount,
    required this.mediumCover,
    required this.largeCover,
    required this.background,
    required this.genres,
    required this.summary,
    required this.trailerCode,
    required this.cast,
    required this.screenshots,
  });

  factory Movie.fromJson(Map<String, dynamic> j) {
    final shots = <String>[];
    for (var i = 1; i <= 3; i++) {
      final s = j['large_screenshot_image$i'];
      if (s is String && s.isNotEmpty) shots.add(s);
    }
    return Movie(
      id: j['id'] ?? 0,
      title: j['title'] ?? '',
      year: j['year'] ?? 0,
      rating: (j['rating'] as num?)?.toDouble() ?? 0,
      runtime: j['runtime'] ?? 0,
      likeCount: j['like_count'] ?? 0,
      mediumCover: j['medium_cover_image'] ?? '',
      largeCover: j['large_cover_image'] ?? '',
      background: j['background_image_original'] ?? '',
      genres: List<String>.from(j['genres'] ?? const []),
      summary: j['description_full'] ?? j['summary'] ?? '',
      trailerCode: j['yt_trailer_code'] ?? '',
      cast: ((j['cast'] as List?) ?? const [])
          .map((e) => Cast.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      screenshots: shots,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'year': year,
        'rating': rating,
        'runtime': runtime,
        'like_count': likeCount,
        'medium_cover_image': mediumCover,
        'large_cover_image': largeCover,
        'background_image_original': background,
        'genres': genres,
        'summary': summary,
        'yt_trailer_code': trailerCode,
      };
}
