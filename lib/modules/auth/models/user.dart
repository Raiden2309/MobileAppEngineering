class User {
  final int    id;
  final String name;
  final String email;
  final int    role; // 1 = student, 2 = lecturer

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStudent  => role == 1;
  bool get isLecturer => role == 2;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:    json['id']    is int ? json['id']   as int : int.tryParse(json['id'].toString())   ?? 0,
    name:  json['name']  as String,
    email: json['email'] as String,
    role:  json['role']  is int ? json['role'] as int : int.tryParse(json['role'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id':    id,
    'name':  name,
    'email': email,
    'role':  role,
  };
}