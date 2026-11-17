import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../core/app_colors.dart';
import '../models/movie.dart';
import '../widgets/empty_state.dart';
import '../widgets/movies_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Movie> _movies = [];
  bool _loading = false;
  String _lastQuery = '';

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    _lastQuery = q;
    if (q.isEmpty) {
      setState(() {
        _movies = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ApiService.getMovies(query: q, limit: 30);
      if (!mounted || q != _lastQuery) return;
      setState(() {
        _movies = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || q != _lastQuery) return;
      setState(() {
        _movies = [];
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(color: AppColors.grey),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
                : _movies.isEmpty
                    ? const EmptyState()
                    : MoviesGrid(movies: _movies),
          ),
        ],
      ),
    );
  }
}
