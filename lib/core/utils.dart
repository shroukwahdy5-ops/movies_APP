import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    final ok = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(v.trim());
    return ok ? null : 'Invalid email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'This field is required';
    return v.length < 6 ? 'Minimum 6 characters' : null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return RegExp(r'^\d{10,15}$').hasMatch(v.trim()) ? null : 'Invalid phone number';
  }
}

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<bool> openTrailer(String code) async {
  if (code.isEmpty) return false;
  return launchUrl(
    Uri.parse('https://www.youtube.com/watch?v=$code'),
    mode: LaunchMode.externalApplication,
  );
}
