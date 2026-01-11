import 'package:firebase_database/firebase_database.dart';
import '../models/movie_model.dart';

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<void> addMovie(MovieModel movie) async {
    final newRef = _dbRef.child('movies').push();
    final movieWithId = movie.copyWith(id: newRef.key!);
    await newRef.set(movieWithId.toMap());
  }

  Stream<List<MovieModel>> getApprovedMovies() {
    return _dbRef
        .child('movies')
        .orderByChild('status')
        .equalTo('approved')
        .onValue
        .map((event) {
          final List<MovieModel> movies = [];
          if (event.snapshot.exists) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            data.forEach((key, value) {
              final movieMap = Map<String, dynamic>.from(value);
              final movie = MovieModel.fromMap(movieMap).copyWith(id: key);
              movies.add(movie);
            });
          }
          return movies;
        });
  }

  Future<void> toggleFavorite(String uid, String movieId) async {
    final ref = _dbRef
        .child('users')
        .child(uid)
        .child('favorites')
        .child(movieId);
    final snapshot = await ref.get();

    if (snapshot.exists) {
      await ref.remove();
    } else {
      await ref.set(true);
    }
  }

  Stream<bool> isFavoriteStream(String uid, String movieId) {
    return _dbRef
        .child('users')
        .child(uid)
        .child('favorites')
        .child(movieId)
        .onValue
        .map((event) => event.snapshot.exists);
  }
}
