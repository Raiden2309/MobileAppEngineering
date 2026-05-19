class SemesterModel {
  final String name;
  final String studyHoursStart;
  final String studyHoursEnd;
  final int subjectCount;
  final bool isCurrent;

  const SemesterModel({
    required this.name,
    required this.studyHoursStart,
    required this.studyHoursEnd,
    required this.subjectCount,
    required this.isCurrent,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      name:             json['name'] as String,
      studyHoursStart:  json['study_hours_start'] as String,
      studyHoursEnd:    json['study_hours_end'] as String,
      subjectCount:     json['subject_count'] as int,
      isCurrent:        json['is_current'] as bool,
    );
  }

  SemesterModel copyWith({bool? isCurrent}) {
    return SemesterModel(
      name: name,
      studyHoursStart: studyHoursStart,
      studyHoursEnd: studyHoursEnd,
      subjectCount: subjectCount,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}