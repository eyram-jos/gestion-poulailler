import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/firebase_service.dart';

class ExpenseRepo {
  final fs = FirebaseService.firestore;
  final _u = Uuid();
  Future<void> addExpense(Expense e) async {
    final id = _u.v4();
    await fs.collection('expenses').doc(id).set({...e.toMap(), 'id': id});
  }

  Stream<List<Expense>> getExpenses(String userId) {
    return fs.collection('expenses').where('userId', isEqualTo: userId).snapshots().map((s) =>
      s.docs.map((d) => Expense.fromMap({...d.data(), 'id': d.id})).toList());
  }
}
