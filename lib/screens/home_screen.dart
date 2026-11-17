import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/rating_badge.dart';
import 'browse_screen.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _featured =
      ApiService.getMovies(sortBy: 'like_count', limit: 10);
  final _pageController = PageController(viewportFraction: 0.58);
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        FutureBuilder<List<Movie>>(
          future: _featured,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 520,
                child: Center(child: CircularProgressIndicator(color: AppColors.yellow)),
              );
            }
            if (snapshot.hasError || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 300,
                child: Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _featured = ApiService.getMovies(sortBy: 'like_count', limit: 10);
                    }),
                    child: const Text('Retry', style: TextStyle(color: AppColors.yellow)),
                  ),
                ),
              );
            }
            final movies = snapshot.data!;
            return SizedBox(
              height: 560,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movies[_current].largeCover,
                    fit: BoxFit.cover,
                    color: Colors.black.withAlpha(150),
                    colorBlendMode: BlendMode.darken,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withAlpha(80), AppColors.background],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        const Text(
                          'Available Now',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 330,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: movies.length,
                            onPageChanged: (i) => setState(() => _current = i),
                            itemBuilder: (_, i) {
                              final movie = movies[i];
                              final selected = i == _current;
                              return AnimatedPadding(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: selected ? 0 : 24),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailsScreen(movieId: movie.id),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: movie.mediumCover,
                                          fit: BoxFit.cover,
                                        ),
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: RatingBadge(rating: movie.rating),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Watch Now',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        for (final genre in AppConstants.homeGenres) _GenreRow(genre: genre),
      ],
    );
  }
}

class _GenreRow extends StatefulWidget {
  final String genre;

  const _GenreRow({required this.genre});

  @override
  State<_GenreRow> createState() => _GenreRowState();
}

class _GenreRowState extends State<_GenreRow> {
  late final Future<List<Movie>> _movies =
      ApiService.getMovies(genre: widget.genre, sortBy: 'rating', limit: 10);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.genre,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BrowseScreen(initialGenre: widget.genre, showBack: true),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('See More', style: TextStyle(color: AppColors.yellow)),
                      Icon(Icons.arrow_forward, size: 16, color: AppColors.yellow),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: FutureBuilder<List<Movie>>(
              future: _movies,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Failed to load', style: TextStyle(color: AppColors.grey)));
                }
                final movies = snapshot.data!;
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: movies.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => AspectRatio(
                    aspectRatio: 0.67,
                    child: MovieCard(movie: movies[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
