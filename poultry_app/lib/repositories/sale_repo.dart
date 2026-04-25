import 'package:uuid/uuid.dart';
import '../models/sale.dart';
import '../services/firebase_service.dart';

class SaleRepo {
  final fs = FirebaseService.firestore;
  final _u = Uuid();
  Future<void> addSale(Sale s) async {
    final id = _u.v4();
    await fs.collection('sales').doc(id).set({...s.toMap(), 'id': id});
  }

  Stream<List<Sale>> getSales(String userId) {
    return fs.collection('sales').where('userId', isEqualTo: userId).snapshots().map((s) =>
      s.docs.map((d) => Sale.fromMap({...d.data(), 'id': d.id})).toList());
  }
}
