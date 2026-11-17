import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../models/user_model.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static List<UserModel> getUsers() {
    final raw = _prefs.getString('users');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => UserModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveUsers(List<UserModel> users) async {
    await _prefs.setString('users', jsonEncode(users.map((e) => e.toJson()).toList()));
  }

  static String? get currentEmail => _prefs.getString('current_email');

  static Future<void> setCurrentEmail(String? email) async {
    if (email == null) {
      await _prefs.remove('current_email');
    } else {
      await _prefs.setString('current_email', email);
    }
  }

  static bool get onboardingSeen => _prefs.getBool('onboarding_seen') ?? false;

  static Future<void> setOnboardingSeen() async {
    await _prefs.setBool('onboarding_seen', true);
  }

  static List<Movie> getMovies(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Movie.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveMovies(String key, List<Movie> movies) async {
    await _prefs.setString(key, jsonEncode(movies.map((e) => e.toJson()).toList()));
  }

  static Future<void> removeKey(String key) async {
    await _prefs.remove(key);
  }
}
