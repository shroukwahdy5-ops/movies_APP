import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final bool outlined;
  final bool loading;

  const AppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = AppColors.yellow,
    this.textColor = Colors.black,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final child = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: outlined ? color : textColor),
          )
        : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                shape: shape,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: textColor,
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}
