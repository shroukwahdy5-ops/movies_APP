import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(160),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 3),
          const Icon(Icons.star, size: 12, color: AppColors.yellow),
        ],
      ),
    );
  }
}
