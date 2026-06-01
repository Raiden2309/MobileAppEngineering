class SemesterModel {
  final String name;
  final String start;
  final String end;
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
    required this.start,
    required this.end,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    return SemesterModel(
      name: json['name'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      studyHoursStart: json['study_hours_start'] as String? ?? '',
      studyHoursEnd: json['study_hours_end'] as String? ?? '',
      subjectCount: json['subject_count'] as int? ?? 0,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  SemesterModel copyWith({
    String? name,
    String? studyHoursStart,
    String? studyHoursEnd,
    int? subjectCount,
    bool? isCurrent,
  }) {
    return SemesterModel(
      name: name ?? this.name,
      start: start,
      end: end,
      studyHoursStart: studyHoursStart ?? this.studyHoursStart,
      studyHoursEnd: studyHoursEnd ?? this.studyHoursEnd,
      subjectCount: subjectCount ?? this.subjectCount,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }
}