import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';

class MoviesGrid extends StatelessWidget {
  final List<Movie> movies;
  final ScrollController? controller;
  final EdgeInsets padding;

  const MoviesGrid({
    super.key,
    required this.movies,
    this.controller,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 100),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.67,
      ),
      itemBuilder: (_, i) => MovieCard(movie: movies[i]),
    );
  }
}
