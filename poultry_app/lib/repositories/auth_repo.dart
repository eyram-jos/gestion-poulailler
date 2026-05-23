import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class AuthRepo {
  final auth = FirebaseService.auth;
  final fs = FirebaseService.firestore;

  Future<UserModel> signup(String email, String password, String name) async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;

    final um = UserModel(
      id: user.uid,
      email: user.email ?? email,
      name: name,
    );

    await fs.collection('users').doc(user.uid).set(um.toMap());

    await fs.collection('subscriptions').doc(user.uid).set({
      'plan': 'free',
      'status': 'trial',
      'trialEndsAt': DateTime.now().add(const Duration(days: 14)),
      'renewAt': null,
      'expireAt': null,
      'createdAt': DateTime.now(),
    });

    return um;
  }

  Future<UserModel> login(String email, String password) async {
    final cred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user!;
    return getUserProfile(user.uid, fallbackEmail: user.email ?? email);
  }

  Future<UserModel> getUserProfile(
    String uid, {
    String fallbackEmail = '',
  }) async {
    final snap = await fs.collection('users').doc(uid).get();
    final data = snap.data();

    if (data == null) {
      final fallback = UserModel(
        id: uid,
        email: fallbackEmail,
        name: '',
      );

      await fs.collection('users').doc(uid).set(fallback.toMap());
      return fallback;
    }

    return UserModel.fromMap(data);
  }

  Future<void> signout() => auth.signOut();

  User? get currentUser => auth.currentUser;
}