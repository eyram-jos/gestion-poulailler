import 'package:flutter/material.dart';
import '../repositories/expense_repo.dart';
import '../repositories/sale_repo.dart';
import '../repositories/mortality_repo.dart';
import '../models/expense.dart';
import '../models/sale.dart';
import '../models/mortality.dart';
import '../services/firebase_service.dart';

class DashboardProvider extends ChangeNotifier {
  final expenseRepo = ExpenseRepo();
  final saleRepo = SaleRepo();
  final mortalityRepo = MortalityRepo();

  List<Expense> expenses = [];
  List<Sale> sales = [];
  List<Mortality> mortalities = [];

  void watchAll(String userId) {
    expenseRepo.getExpenses(userId).listen((e) { expenses = e; notifyListeners(); });
    saleRepo.getSales(userId).listen((s) { sales = s; notifyListeners(); });
    // mortalities are per wave; for total mortality you may listen to collection
    FirebaseService.firestore.collection('mortalities').where('userId', isEqualTo: userId).snapshots().listen((snap) {
      mortalities = snap.docs.map((d) => Mortality.fromMap({...d.data(), 'id': d.id})).toList();
      notifyListeners();
    });
  }

  double totalExpenses() => expenses.fold(0.0, (p, e) => p + e.amount);
  double totalRevenue() => sales.fold(0.0, (p, s) => p + s.total);
  int totalMortality() => mortalities.fold(0, (p, m) => p + m.count);

  double profit() => totalRevenue() - totalExpenses();
}
