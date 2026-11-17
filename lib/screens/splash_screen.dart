import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/local_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _next);
  }

  void _next() {
    if (!mounted) return;
    final loggedIn = context.read<AuthProvider>().user != null;
    final route = loggedIn
        ? '/home'
        : LocalStorage.onboardingSeen
            ? '/login'
            : '/onboarding';
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, size: 110, color: AppColors.yellow),
            SizedBox(height: 8),
            Text(
              'Route',
              style: TextStyle(color: AppColors.yellow, fontSize: 32, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }
}
