class MovieModel {
  final String id;
  final String title;
  final String posterUrl;
  final String genre;
  final String actor;

  final String plot;

  final List<String> keywords;

  final String addedBy;
  final String status;
  final String imdbRating;

  MovieModel({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.genre,
    required this.actor,
    required this.plot,
    required this.keywords,
    required this.addedBy,
    required this.status,
    this.imdbRating = "N/A",
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'posterUrl': posterUrl,
      'genre': genre,
      'actor': actor,
      'plot': plot,
      'keywords': keywords,
      'addedBy': addedBy,
      'status': status,
      'imdbRating': imdbRating,
    };
  }

  factory MovieModel.fromMap(Map<String, dynamic> map) {
    return MovieModel(
      id: '',
      title: map['title'] ?? '',
      posterUrl: map['posterUrl'] ?? '',
      genre: map['genre'] ?? '',
      actor: map['actor'] ?? '',
      plot: map['plot'] ?? '',
      keywords: List<String>.from(map['keywords'] ?? []),
      addedBy: map['addedBy'] ?? '',
      status: map['status'] ?? 'pending',
      imdbRating: map['imdbRating'] ?? 'N/A',
    );
  }

  MovieModel copyWith({
    String? id,
    String? title,
    String? posterUrl,
    String? genre,
    String? actor,
    String? plot,
    List<String>? keywords,
    String? addedBy,
    String? status,
    String? imdbRating,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      genre: genre ?? this.genre,
      actor: actor ?? this.actor,
      plot: plot ?? this.plot,
      keywords: keywords ?? this.keywords,
      addedBy: addedBy ?? this.addedBy,
      status: status ?? this.status,
      imdbRating: imdbRating ?? this.imdbRating,
    );
  }
}
