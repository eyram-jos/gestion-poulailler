import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';

class SubscriptionRepo {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  Future<void> ensureSubscriptionExists(String userId) async {
    final doc = _fs.collection('subscriptions').doc(userId);
    final snap = await doc.get();

    if (!snap.exists) {
      await doc.set({
        'plan': 'free',
        'status': 'trial',
        'trialEndsAt': DateTime.now().add(const Duration(days: 14)),
        'expireAt': null,
        'createdAt': DateTime.now(),
      });
    }
  }

  Stream<SubscriptionModel> watchSubscription(String userId) {
    return _fs.collection('subscriptions').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) {
        return const SubscriptionModel(plan: 'free', status: 'trial');
      }
      return SubscriptionModel.fromMap(data);
    });
  }

  Future<void> setPlanDemo(String userId, {required bool pro}) async {
    final now = DateTime.now();

    await _fs.collection('subscriptions').doc(userId).set({
      'plan': pro ? 'pro' : 'free',
      'status': pro ? 'active' : 'trial',
      'startDate': pro ? now : null,
      'expireAt': pro ? now.add(const Duration(days: 30)) : null,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }
}