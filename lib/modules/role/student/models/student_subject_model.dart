class StudentSubjectModel {
  final int id;
  final int studentId;
  final int semesterId;
  final int subjectId;
  final String name;
  final String code;
  final String colorHex;

  const StudentSubjectModel({
    required this.id,
    required this.studentId,
    required this.semesterId,
    required this.subjectId,
    required this.name,
    required this.code,
    required this.colorHex,
  });

  factory StudentSubjectModel.fromJson(Map<String, dynamic> json) {
    return StudentSubjectModel(
      id:         json['id'] as int,
      studentId:  json['student_id'] as int,
      semesterId: json['semester_id'] as int,
      subjectId:  json['subject_id'] as int,
      name:       json['name'] as String,
      code:       json['code'] as String,
      colorHex:   json['color_hex'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':          id,
    'student_id':  studentId,
    'semester_id': semesterId,
    'subject_id':  subjectId,
    'name':        name,
    'code':        code,
    'color_hex':   colorHex,
  };

  StudentSubjectModel copyWith({
    int? id,
    int? studentId,
    int? semesterId,
    int? subjectId,
    String? name,
    String? code,
    String? colorHex,
  }) {
    return StudentSubjectModel(
      id:         id         ?? this.id,
      studentId:  studentId  ?? this.studentId,
      semesterId: semesterId ?? this.semesterId,
      subjectId:  subjectId  ?? this.subjectId,
      name:       name       ?? this.name,
      code:       code       ?? this.code,
      colorHex:   colorHex   ?? this.colorHex,
    );
  }
}