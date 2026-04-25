import 'package:cloud_firestore/cloud_firestore.dart';
class Expense {
  final String id;
  final String userId;
  final String waveId;
  final String type;
  final String label;
  final double amount;
  final DateTime date;
  Expense({required this.id, required this.userId, required this.waveId, required this.type, required this.label, required this.amount, required this.date});
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'waveId': waveId,
    'type': type,
    'label': label,
    'amount': amount,
    'date': Timestamp.fromDate(date),
  };
  factory Expense.fromMap(Map<String, dynamic> m) => Expense(
    id: m['id'],
    userId: m['userId'],
    waveId: m['waveId'],
    type: m['type'],
    label: m['label'],
    amount: (m['amount'] as num).toDouble(),
    date: (m['date'] as Timestamp).toDate(),
  );
}
