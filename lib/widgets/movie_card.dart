import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/movie.dart';
import '../screens/movie_details_screen.dart';
import 'rating_badge.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.mediumCover,
              fit: BoxFit.cover,
              placeholder: (context, error) => Container(color: AppColors.surface),
              errorWidget: (context, error, stackTrace) => Container(
                color: AppColors.surface,
                child: const Icon(Icons.broken_image, color: AppColors.grey),
              ),
            ),
            Positioned(top: 8, left: 8, child: RatingBadge(rating: movie.rating)),
          ],
        ),
      ),
    );
  }
}
