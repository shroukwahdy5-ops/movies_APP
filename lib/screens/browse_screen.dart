import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../core/app_colors.dart';
import '../core/app_constants.dart';
import '../core/utils.dart';
import '../models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movies_grid.dart';

class BrowseScreen extends StatefulWidget {
  final String initialGenre;
  final bool showBack;

  const BrowseScreen({super.key, this.initialGenre = 'Action', this.showBack = false});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _scroll = ScrollController();
  late String _genre = widget.initialGenre;
  final List<Movie> _movies = [];
  int _page = 1;
  int _request = 0;
  bool _loading = false;
  bool _hasMore = true;

  static const _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) _load();
    });
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (!reset && (_loading || !_hasMore)) return;
    if (reset) {
      _request++;
      _page = 1;
      _hasMore = true;
      _movies.clear();
    }
    final request = _request;
    setState(() => _loading = true);
    try {
      final result = await ApiService.getMovies(genre: _genre, page: _page, limit: _pageSize);
      if (!mounted || request != _request) return;
      setState(() {
        _movies.addAll(result);
        _hasMore = result.length == _pageSize;
        _page++;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() => _loading = false);
      showSnack(context, 'Something went wrong');
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showBack
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.yellow),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final g = AppConstants.genres[i];
                  final selected = g == _genre;
                  return GestureDetector(
                    onTap: () {
                      if (selected) return;
                      setState(() => _genre = g);
                      _load(reset: true);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.yellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.yellow, width: 2),
                      ),
                      child: Text(
                        g,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.black : AppColors.yellow,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _movies.isEmpty && !_loading
                  ? const EmptyState()
                  : Stack(
                      children: [
                        MoviesGrid(movies: _movies, controller: _scroll),
                        if (_loading)
                          const Align(
                            alignment: Alignment.topCenter,
                            child: LinearProgressIndicator(color: AppColors.yellow),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
