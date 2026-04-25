import 'package:cloud_firestore/cloud_firestore.dart';
class Wave {
  final String id;
  final String userId;
  final String name;
  final int chicks;
  final DateTime startDate;
  final bool isActive;
  Wave({
    required this.id,
    required this.userId,
    required this.name,
    required this.chicks,
    required this.startDate,
    required this.isActive,
  });
  Map<String, dynamic> toMap() => {
    'userId': userId,
    'name': name,
    'chicks': chicks,
    'startDate': Timestamp.fromDate(startDate),
    'isActive': isActive,
  };
  factory Wave.fromMap(Map<String, dynamic> m) => Wave(
    id: m['id'],
    userId: m['userId'] ?? '',
    name: m['name'],
    chicks: (m['chicks'] ?? m['numberOfChicks'] ?? 0),
    startDate: (m['startDate'] as Timestamp).toDate(),
    isActive: m['isActive'] ?? true,
  );
}
