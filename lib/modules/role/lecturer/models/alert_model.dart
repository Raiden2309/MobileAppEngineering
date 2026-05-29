class AlertModel {
  final String type;
  final String emoji;
  final String title;
  final String meta;
  final bool read;
  final String studentId;
  final String studentName;

  const AlertModel({
    required this.type,
    required this.emoji,
    required this.title,
    required this.meta,
    required this.studentId,
    required this.studentName,
    this.read = false,
  });

  AlertModel copyWith({
    String? type,
    String? emoji,
    String? title,
    String? meta,
    String? studentId,
    String? studentName,
    bool? read,
  }) =>
      AlertModel(
        type: type ?? this.type,
        emoji: emoji ?? this.emoji,
        title: title ?? this.title,
        meta: meta ?? this.meta,
        studentId: studentId ?? this.studentId,
        studentName: studentName ?? this.studentName,
        read: read ?? this.read,
      );
}