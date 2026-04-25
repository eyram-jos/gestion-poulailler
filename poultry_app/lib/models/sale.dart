import 'package:cloud_firestore/cloud_firestore.dart';
class Sale {
  final String id;
  final String userId;
  final String waveId;
  final int quantity;
  final double priceUnit;
  final double total;
  final DateTime date;
  Sale({required this.id, required this.userId, required this.waveId, required this.quantity, required this.priceUnit, required this.total, required this.date});
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'waveId': waveId,
    'quantity': quantity,
    'priceUnit': priceUnit,
    'total': total,
    'date': Timestamp.fromDate(date),
  };
  factory Sale.fromMap(Map<String, dynamic> m) => Sale(
    id: m['id'],
    userId: m['userId'],
    waveId: m['waveId'],
    quantity: (m['quantity'] ?? 0),
    priceUnit: ((m['priceUnit'] ?? m['pricePer']) as num).toDouble(),
    total: (m['total'] as num).toDouble(),
    date: (m['date'] as Timestamp).toDate(),
  );
}
