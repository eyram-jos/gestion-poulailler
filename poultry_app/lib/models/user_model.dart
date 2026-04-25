class UserModel {
  final String id;
  final String email;
  final String name;
  UserModel({required this.id, required this.email, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'email': email, 'name': name};
  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'], email: m['email'], name: m['name'] ?? '');
}
