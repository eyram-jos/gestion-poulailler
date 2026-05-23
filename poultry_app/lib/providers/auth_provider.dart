import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repo.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final repo = AuthRepo();

  UserModel? user;

  bool get isAuthenticated => user != null;

  String get displayName {
    final name = user?.name.trim() ?? '';
    if (name.isNotEmpty) return name;

    final email = user?.email ?? '';
    if (email.contains('@')) return email.split('@').first;

    return 'Utilisateur';
  }

  Future<void> signup(
  String email,
  String password,
  String name,
) async {
  try {
    user = await repo.signup(email, password, name);
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    String message = 'Une erreur est survenue.';

    switch (e.code) {
      case 'email-already-in-use':
        message =
            'Cet email est déjà utilisé.';
        break;

      case 'weak-password':
        message =
            'Mot de passe trop faible.';
        break;

      case 'invalid-email':
        message =
            'Adresse email invalide.';
        break;

      default:
        message =
            'Impossible de créer le compte.';
    }

    throw Exception(message);
  }
}

  Future<void> login(
  String email,
  String password,
) async {
  try {
    user = await repo.login(email, password);
    notifyListeners();
  } on FirebaseAuthException catch (e) {
    String message = 'Une erreur est survenue.';

    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
        message = 'Email ou mot de passe incorrect.';
        break;

      case 'user-not-found':
        message = 'Aucun compte trouvé avec cet email.';
        break;

      case 'invalid-email':
        message = 'Adresse email invalide.';
        break;

      case 'too-many-requests':
        message =
            'Trop de tentatives. Réessayez plus tard.';
        break;

      default:
        message = 'Connexion impossible.';
    }

    throw Exception(message);
  }
}

  Future<void> logout() async {
    await repo.signout();
    user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final u = repo.currentUser;

    if (u == null) return;

    user = await repo.getUserProfile(
      u.uid,
      fallbackEmail: u.email ?? '',
    );

    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: email.trim(),
    );
  }
}