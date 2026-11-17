import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? user;

  Future<void> init() async {
    await LocalStorage.init();
    final email = LocalStorage.currentEmail;
    if (email != null) {
      user = LocalStorage.getUsers().where((u) => u.email == email).firstOrNull;
    }
  }

  String _clean(String email) => email.trim().toLowerCase();

  bool emailExists(String email) =>
      LocalStorage.getUsers().any((u) => u.email == _clean(email));

  Future<String?> register(UserModel newUser) async {
    final users = LocalStorage.getUsers();
    final email = _clean(newUser.email);
    if (users.any((u) => u.email == email)) return 'Email already registered';
    final created = UserModel(
      name: newUser.name.trim(),
      email: email,
      password: newUser.password,
      phone: newUser.phone.trim(),
      avatar: newUser.avatar,
    );
    users.add(created);
    await LocalStorage.saveUsers(users);
    await LocalStorage.setCurrentEmail(email);
    user = created;
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final found = LocalStorage.getUsers().where((u) => u.email == _clean(email)).firstOrNull;
    if (found == null) return 'No account with this email';
    if (found.password != password) return 'Wrong password';
    await LocalStorage.setCurrentEmail(found.email);
    user = found;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await LocalStorage.setCurrentEmail(null);
    user = null;
    notifyListeners();
  }

  Future<void> updateUser(UserModel updated) async {
    final users = LocalStorage.getUsers();
    final index = users.indexWhere((u) => u.email == updated.email);
    if (index == -1) return;
    users[index] = updated;
    await LocalStorage.saveUsers(users);
    user = updated;
    notifyListeners();
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final users = LocalStorage.getUsers();
    final index = users.indexWhere((u) => u.email == _clean(email));
    if (index == -1) return;
    users[index] = users[index].copyWith(password: newPassword);
    await LocalStorage.saveUsers(users);
    if (user?.email == users[index].email) user = users[index];
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    final current = user;
    if (current == null) return;
    final users = LocalStorage.getUsers()..removeWhere((u) => u.email == current.email);
    await LocalStorage.saveUsers(users);
    await LocalStorage.removeKey('watch_${current.email}');
    await LocalStorage.removeKey('history_${current.email}');
    await LocalStorage.setCurrentEmail(null);
    user = null;
    notifyListeners();
  }
}
