class LecturerModel {
  final String id;
  final String name;
  final String email;
  final String programme;
  final List<LecturerClass> classes;

  const LecturerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.programme,
    required this.classes,
  });

  factory LecturerModel.fromJson(Map<String, dynamic> json) => LecturerModel(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    programme: json['programme'],
    classes: (json['classes'] as List)
        .map((c) => LecturerClass.fromJson(c))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'programme': programme,
    'classes': classes.map((c) => c.toJson()).toList(),
  };
}

class LecturerClass {
  final String name;
  final String code;
  final String joinCode;

  const LecturerClass({
    required this.name,
    required this.code,
    required this.joinCode,
  });

  factory LecturerClass.fromJson(Map<String, dynamic> json) => LecturerClass(
    name: json['name'],
    code: json['code'],
    joinCode: json['joinCode'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'joinCode': joinCode,
  };
}