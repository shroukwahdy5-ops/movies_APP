import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../core/app_colors.dart';
import '../services/local_storage.dart';
import '../widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  late final Future<List<String>> _images = _loadImages();
  int _index = 0;

  static const _pages = [
    ('Find Your Next\nFavorite Movie Here',
        'Get access to a huge library of movies to suit all tastes. You will surely like it.'),
    ('Discover Movies',
        'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.'),
    ('Explore All Genres',
        'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.'),
    ('Create Watchlists',
        'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.'),
    ('Rate, Review, and Learn',
        'Share your thoughts on the movies you have watched. Dive deep into film details and help others discover great movies with your reviews.'),
    ('Start Watching Now', ''),
  ];

  Future<List<String>> _loadImages() async {
    try {
      final movies = await ApiService.getMovies(sortBy: 'like_count', limit: 12);
      return movies.map((m) => m.largeCover).where((e) => e.isNotEmpty).take(6).toList();
    } catch (_) {
      return [];
    }
  }

  void _go(int page) => _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

  Future<void> _finish() async {
    await LocalStorage.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: _images,
        builder: (context, snapshot) {
          final images = snapshot.data ?? const [];
          return PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final page = _pages[i];
              final isFirst = i == 0;
              final isLast = i == _pages.length - 1;
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (i < images.length)
                    CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover)
                  else
                    Container(color: AppColors.surface),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withAlpha(120), Colors.black],
                        stops: const [0.3, 0.6, 1],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(
                          12, 0, 12, MediaQuery.of(context).padding.bottom + 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            page.$1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          if (page.$2.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              page.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.grey, fontSize: 14),
                            ),
                          ],
                          const SizedBox(height: 20),
                          AppButton(
                            text: isFirst ? 'Explore Now' : (isLast ? 'Finish' : 'Next'),
                            onTap: isLast ? _finish : () => _go(_index + 1),
                          ),
                          if (!isFirst) ...[
                            const SizedBox(height: 12),
                            AppButton(text: 'Back', outlined: true, onTap: () => _go(_index - 1)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
