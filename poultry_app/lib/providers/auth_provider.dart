import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repo.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final repo = AuthRepo();

  UserModel? user;

  bool get isAuthenticated => user != null;

  Future<void> signup(
    String email,
    String password,
    String name,
  ) async {
    user = await repo.signup(email, password, name);
    notifyListeners();
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    user = await repo.login(email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await repo.signout();
    user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final u = repo.currentUser;

    if (u == null) return;

    user = UserModel(
      id: u.uid,
      email: u.email ?? '',
      name: '',
    );

    notifyListeners();
  }

  // -------- AJOUT MOT DE PASSE OUBLIE --------
  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email.trim(),
    );
  }
}