import 'package:flutter/material.dart';
import '../models/wave.dart';
import '../repositories/wave_repo.dart';

class WaveProvider extends ChangeNotifier {
  final repo = WaveRepo();
  List<Wave> waves = [];
  void watch(String userId) {
    repo.getWaves(userId).listen((list) {
      waves = list;
      notifyListeners();
    });
  }

  Future<void> createWave(String userId, String name, int number, DateTime start) =>
      repo.createWave(userId, name, number, start);
}
