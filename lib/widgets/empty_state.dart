import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, this.message = 'No movies found'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_movies_outlined, size: 90, color: AppColors.yellow),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
