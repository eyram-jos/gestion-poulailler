import 'dart:async';
import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../repositories/subscription_repo.dart';

class SubscriptionProvider extends ChangeNotifier {
  final _repo = SubscriptionRepo();
  StreamSubscription<SubscriptionModel>? _sub;

  SubscriptionModel _current =
      const SubscriptionModel(plan: 'free', status: 'trial');

  SubscriptionModel get current => _current;

  bool get isPro => _current.isPro;

  bool get isFree => !isPro;

  bool get isExpired => _current.isExpired;

DateTime? get expireAt => _current.expireAt;

int get daysRemaining {
  if (_current.expireAt == null) return 999;
  return _current.expireAt!
      .difference(DateTime.now())
      .inDays;
}

bool get shouldRenewWarn {
  return isPro &&
      expireAt != null &&
      daysRemaining <= 5 &&
      daysRemaining >= 0;
}



int get trialDaysRemaining {
 if (_current.trialEndsAt == null) return 0;

 final d = _current.trialEndsAt!
     .difference(DateTime.now())
     .inDays;

 return d < 0 ? 0 : d;
}

bool get trialExpired {
 if (_current.trialEndsAt == null) return false;

 return DateTime.now().isAfter(
   _current.trialEndsAt!,
 );
}




  Future<void> watch(String userId) async {
    await _repo.ensureSubscriptionExists(userId);
    await _sub?.cancel();

    _sub = _repo.watchSubscription(userId).listen((value) {
      _current = value;
      notifyListeners();
    });
  }

  // 🔒 LIMITES FREE
  bool canCreateWave(int wavesCount) {
    if (isPro) return true;
    return wavesCount < 1;
  }

  bool canAccessAdvancedReports() {
    return isPro;
  }

  bool canExportData() {
    return isPro;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}