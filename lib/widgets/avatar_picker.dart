import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';

class AvatarPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const AvatarPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.avatarsCount,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.yellow : Colors.transparent,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: isSelected ? 38 : 30,
                backgroundColor: AppColors.surface,
                backgroundImage: CachedNetworkImageProvider(AppConstants.avatarUrl(i)),
              ),
            ),
          );
        },
      ),
    );
  }
}
