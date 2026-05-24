class AlertModel {
  final String type;
  final String emoji;
  final String title;
  final String meta;
  final bool read;

  const AlertModel({
    required this.type,
    required this.emoji,
    required this.title,
    required this.meta,
    this.read = false,
  });

  AlertModel copyWith({
    String? type,
    String? emoji,
    String? title,
    String? meta,
    bool? read,
  }) =>
      AlertModel(
        type: type ?? this.type,
        emoji: emoji ?? this.emoji,
        title: title ?? this.title,
        meta: meta ?? this.meta,
        read: read ?? this.read,
      );
}