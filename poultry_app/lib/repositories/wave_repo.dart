import 'package:uuid/uuid.dart';
import '../models/wave.dart';
import '../services/firebase_service.dart';
import '../services/reminders_service.dart';

class WaveRepo {
  final fs = FirebaseService.firestore;
  final _u = Uuid();

  Stream<List<Wave>> getWaves(String userId) {
    return fs.collection('waves').where('userId', isEqualTo: userId).snapshots().map((s) =>
      s.docs.map((d) => Wave.fromMap({...d.data(), 'id': d.id})).toList());
  }

  Future<void> createWave(String userId, String name, int numberOfChicks, DateTime startDate) async {
    final id = _u.v4();
    final wave = Wave(
      id: id,
      userId: userId,
      name: name,
      chicks: numberOfChicks,
      startDate: startDate,
      isActive: true,
    );
    await fs.collection('waves').doc(id).set(wave.toMap());
    await RemindersService.scheduleVaccineReminders(id, startDate);
  }

  Future<void> updateWaveActive(String id, bool isActive) => fs.collection('waves').doc(id).update({'isActive': isActive});
}
