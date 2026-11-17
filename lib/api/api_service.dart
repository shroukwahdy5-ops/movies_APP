import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const List<String> _mirrors = [
    'https://yts.gg/api/v2/',
    'https://yts.bz/api/v2/',
    'https://yts.lt/api/v2/',
    'https://movies-api.accel.li/api/v2/',
  ];

  static String? _workingBaseUrl;

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36',
  };

  static Future<Map<String, dynamic>> _get(
    String endpoint,
    Map<String, String> params,
  ) async {
    final urlsToTry = <String>[
      if (_workingBaseUrl != null) _workingBaseUrl!,
      ..._mirrors.where((url) => url != _workingBaseUrl),
    ];

    Object? lastError;

    for (final baseUrl in urlsToTry) {
      try {
        final uri =
            Uri.parse('$baseUrl$endpoint').replace(queryParameters: params);
        final response = await http
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 12));

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode} from $baseUrl');
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid JSON format from $baseUrl');
        }

        if (decoded['status'] != 'ok') {
          throw Exception(decoded['status_message'] ?? 'API status not ok');
        }

        final responseData = decoded['data'];
        if (responseData is! Map) {
          throw Exception('Invalid data payload from $baseUrl');
        }

        _workingBaseUrl = baseUrl;
        return Map<String, dynamic>.from(responseData);
      } catch (e) {
        lastError = e;
        debugPrint('ApiService error on $baseUrl$endpoint -> $e');
      }
    }

    throw Exception('All movie API mirrors failed. Last error: $lastError');
  }

  static Future<List<Movie>> getMovies({
    String? genre,
    String? query,
    String sortBy = 'date_added',
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'page': '$page',
      'sort_by': sortBy,
    };
    if (genre != null && genre != 'All') params['genre'] = genre;
    if (query != null && query.trim().isNotEmpty) {
      params['query_term'] = query.trim();
    }

    final data = await _get('list_movies.json', params);
    final list = (data['movies'] as List?) ?? const [];
    return list
        .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<Movie> getMovieDetails(int id) async {
    final data = await _get('movie_details.json', {
      'movie_id': '$id',
      'with_images': 'true',
      'with_cast': 'true',
    });
    return Movie.fromJson(Map<String, dynamic>.from(data['movie']));
  }

  static Future<List<Movie>> getSuggestions(int id) async {
    final data = await _get('movie_suggestions.json', {'movie_id': '$id'});
    final list = (data['movies'] as List?) ?? const [];
    return list
        .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
