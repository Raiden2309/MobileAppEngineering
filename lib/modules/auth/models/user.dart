class User {
  final int    id;
  final String name;
  final String email;
  final int    role; // 0 = student, 1 = lecturer

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStudent  => role == 0;
  bool get isLecturer => role == 1;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:    json['id']    as int,
    name:  json['name']  as String,
    email: json['email'] as String,
    role:  json['role']  as int,
  );

  Map<String, dynamic> toJson() => {
    'id':    id,
    'name':  name,
    'email': email,
    'role':  role,
  };
}