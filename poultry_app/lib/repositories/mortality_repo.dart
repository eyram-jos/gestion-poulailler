import 'package:uuid/uuid.dart';
import '../models/mortality.dart';
import '../services/firebase_service.dart';

class MortalityRepo {
  final fs = FirebaseService.firestore;
  final _u = Uuid();

  Future<void> addMortality(Mortality m) async {
    final id = _u.v4();
    await fs.collection('mortalities').doc(id).set({...m.toMap(), 'id': id});
  }

  Stream<List<Mortality>> getMortalityForWave(String userId, String waveId) {
    return fs.collection('mortalities').where('userId', isEqualTo: userId).where('waveId', isEqualTo: waveId).snapshots().map((s) =>
      s.docs.map((d) => Mortality.fromMap({...d.data(), 'id': d.id})).toList());
  }
}
