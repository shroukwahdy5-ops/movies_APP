import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../core/app_colors.dart';
import '../core/utils.dart';
import '../models/movie.dart';
import '../providers/library_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/movie_card.dart';

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Movie> _movie = ApiService.getMovieDetails(widget.movieId);
  late final Future<List<Movie>> _similar = _loadSimilar();

  Future<List<Movie>> _loadSimilar() async {
    try {
      return await ApiService.getSuggestions(widget.movieId);
    } catch (_) {
      return [];
    }
  }

  Future<void> _watch(Movie movie) async {
    final library = context.read<LibraryProvider>();
    final opened = await openTrailer(movie.trailerCode);
    if (!mounted) return;
    if (!opened) {
      showSnack(context, 'Trailer not available');
      return;
    }
    await library.addToHistory(movie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: _movie,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load movie'),
                  TextButton(
                    onPressed: () => setState(() {
                      _movie = ApiService.getMovieDetails(widget.movieId);
                    }),
                    child: const Text('Retry', style: TextStyle(color: AppColors.yellow)),
                  ),
                ],
              ),
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(Movie movie) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 460,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: movie.largeCover,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.background],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  left: 8,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 4,
                  right: 8,
                  child: Consumer<LibraryProvider>(
                    builder: (_, library, child) => IconButton(
                      icon: Icon(
                        library.isInWatchlist(movie.id) ? Icons.bookmark : Icons.bookmark_border,
                        color: library.isInWatchlist(movie.id) ? AppColors.yellow : Colors.white,
                      ),
                      onPressed: () => library.toggleWatchlist(movie),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () => _watch(movie),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.yellow),
                      child: const Icon(Icons.play_arrow, size: 50, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '${movie.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Watch',
                  color: AppColors.red,
                  textColor: Colors.white,
                  onTap: () => _watch(movie),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _StatChip(icon: Icons.favorite, text: '${movie.likeCount}')),
                    const SizedBox(width: 10),
                    Expanded(child: _StatChip(icon: Icons.access_time_filled, text: '${movie.runtime}')),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _StatChip(icon: Icons.star, text: movie.rating.toStringAsFixed(1))),
                  ],
                ),
                if (movie.screenshots.isNotEmpty) ...[
                  const _SectionTitle('Screen Shots'),
                  for (final shot in movie.screenshots)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: shot,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(height: 180, color: AppColors.surface),
                        ),
                      ),
                    ),
                ],
                FutureBuilder<List<Movie>>(
                  future: _similar,
                  builder: (context, snapshot) {
                    final list = snapshot.data ?? const [];
                    if (list.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionTitle('Similar'),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.67,
                          ),
                          itemBuilder: (_, i) => MovieCard(movie: list[i]),
                        ),
                      ],
                    );
                  },
                ),
                if (movie.summary.isNotEmpty) ...[
                  const _SectionTitle('Summary'),
                  Text(movie.summary, style: const TextStyle(fontSize: 14, height: 1.5)),
                ],
                if (movie.cast.isNotEmpty) ...[
                  const _SectionTitle('Cast'),
                  for (final c in movie.cast) _CastTile(cast: c),
                ],
                if (movie.genres.isNotEmpty) ...[
                  const _SectionTitle('Genres'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in movie.genres)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(g),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.yellow, size: 22),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  final Cast cast;

  const _CastTile({required this.cast});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: cast.image == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.grey)
                  : CachedNetworkImage(
                      imageUrl: cast.image!,
                      fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                          const Icon(Icons.person, size: 40, color: AppColors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name : ${cast.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Character : ${cast.character}',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
