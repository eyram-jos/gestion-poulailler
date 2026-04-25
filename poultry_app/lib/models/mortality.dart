import 'package:cloud_firestore/cloud_firestore.dart';
class Mortality {
  final String id;
  final String userId;
  final String waveId;
  final DateTime date;
  final int count;
  final String notes;
  Mortality({required this.id, required this.userId, required this.waveId, required this.date, required this.count, this.notes = ''});
  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'waveId': waveId,
    'date': Timestamp.fromDate(date),
    'count': count,
    'notes': notes,
  };
  factory Mortality.fromMap(Map<String, dynamic> m) => Mortality(
    id: m['id'],
    userId: m['userId'] ?? '',
    waveId: m['waveId'],
    date: (m['date'] as Timestamp).toDate(),
    count: (m['count'] ?? 0),
    notes: m['notes'] ?? '',
  );
}
