class ClassEnrollmentModel {
  final int classId;
  final int studentId;
  final String studentName;
  final String studentInitials;
  final DateTime joinedAt;

  const ClassEnrollmentModel({
    required this.classId,
    required this.studentId,
    required this.studentName,
    required this.studentInitials,
    required this.joinedAt,
  });

  factory ClassEnrollmentModel.fromJson(Map<String, dynamic> json) {
    return ClassEnrollmentModel(
      classId:          json['class_id'] as int,
      studentId:        json['student_id'] as int,
      studentName:      json['student_name'] as String,
      studentInitials:  json['student_initials'] as String,
      joinedAt:         DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'class_id':         classId,
    'student_id':       studentId,
    'student_name':     studentName,
    'student_initials': studentInitials,
    'joined_at':        joinedAt.toIso8601String(),
  };

  ClassEnrollmentModel copyWith({
    int? classId,
    int? studentId,
    String? studentName,
    String? studentInitials,
    DateTime? joinedAt,
  }) {
    return ClassEnrollmentModel(
      classId:         classId         ?? this.classId,
      studentId:       studentId       ?? this.studentId,
      studentName:     studentName     ?? this.studentName,
      studentInitials: studentInitials ?? this.studentInitials,
      joinedAt:        joinedAt        ?? this.joinedAt,
    );
  }
}