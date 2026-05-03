import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wave.dart';

class WaveProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  List<Wave> _waves = [];
  List<Wave> get waves => _waves;

  void watch(String userId) {
    _db
        .collection('waves')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      _waves = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Wave.fromMap(data);
      }).toList();

      notifyListeners();
    });
  }

  Future<void> createWave(
    String userId,
    String name,
    int chicks,
    DateTime startDate,
  ) async {
    await _db.collection('waves').add({
      'userId': userId,
      'name': name,
      'chicks': chicks,
      'startDate': Timestamp.fromDate(startDate),
      'isActive': true,
    });
  }

  // 🔥 NOUVELLE FONCTION
  Future<void> endWave(String waveId) async {
    await _db.collection('waves').doc(waveId).update({
      'isActive': false,
    });
  }
}