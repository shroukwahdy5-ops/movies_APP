import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/local_storage.dart';

class LibraryProvider extends ChangeNotifier {
  String? _email;
  List<Movie> watchlist = [];
  List<Movie> history = [];

  Future<void> load(String email) async {
    _email = email;
    watchlist = LocalStorage.getMovies('watch_$email');
    history = LocalStorage.getMovies('history_$email');
    notifyListeners();
  }

  void clear() {
    _email = null;
    watchlist = [];
    history = [];
    notifyListeners();
  }

  bool isInWatchlist(int id) => watchlist.any((m) => m.id == id);

  Future<void> toggleWatchlist(Movie movie) async {
    if (_email == null) return;
    if (isInWatchlist(movie.id)) {
      watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      watchlist.insert(0, movie);
    }
    notifyListeners();
    await LocalStorage.saveMovies('watch_$_email', watchlist);
  }

  Future<void> addToHistory(Movie movie) async {
    if (_email == null) return;
    history.removeWhere((m) => m.id == movie.id);
    history.insert(0, movie);
    notifyListeners();
    await LocalStorage.saveMovies('history_$_email', history);
  }
}
