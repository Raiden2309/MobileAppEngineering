class LecturerSettingsModel {
  final int    userId;
  final String userName;
  final String department;
  final int    activeClassesCount;
  final bool   burnoutAlerts;
  final bool   fallingBehindAlerts;
  final bool   weeklyEngagementReport;
  final String appVersion;
  final String? avatarUrl;

  const LecturerSettingsModel({
    required this.userId,
    required this.userName,
    required this.department,
    required this.activeClassesCount,
    required this.burnoutAlerts,
    required this.fallingBehindAlerts,
    required this.weeklyEngagementReport,
    required this.appVersion,
    this.avatarUrl,
  });

  factory LecturerSettingsModel.fromJson(Map<String, dynamic> json) {
    return LecturerSettingsModel(
      userId:                 (json['user_id']                as num).toInt(),
      userName:               json['name']                   as String,
      department:             json['department']             as String,
      activeClassesCount:     (json['active_classes_count']  as num).toInt(),
      burnoutAlerts:          json['burnout_alerts']         as bool,
      fallingBehindAlerts:    json['falling_behind_alerts']  as bool,
      weeklyEngagementReport: json['weekly_engagement_report'] as bool,
      appVersion:             json['app_version']            as String,
      avatarUrl:              json['avatar_url']             as String?,
    );
  }

  factory LecturerSettingsModel.mockData() {
    return const LecturerSettingsModel(
      userId:                 1,
      userName:               'Dr. Sarah Lim',
      department:             'Diploma in Computer Science',
      activeClassesCount:     3,
      burnoutAlerts:          true,
      fallingBehindAlerts:    true,
      weeklyEngagementReport: false,
      appVersion:             'v1.0',
      avatarUrl:              null,
    );
  }

  LecturerSettingsModel copyWith({
    int?    userId,
    String? userName,
    String? department,
    int?    activeClassesCount,
    bool?   burnoutAlerts,
    bool?   fallingBehindAlerts,
    bool?   weeklyEngagementReport,
    String? appVersion,
    String? avatarUrl,
  }) {
    return LecturerSettingsModel(
      userId:                 userId                 ?? this.userId,
      userName:               userName               ?? this.userName,
      department:             department             ?? this.department,
      activeClassesCount:     activeClassesCount     ?? this.activeClassesCount,
      burnoutAlerts:          burnoutAlerts          ?? this.burnoutAlerts,
      fallingBehindAlerts:    fallingBehindAlerts    ?? this.fallingBehindAlerts,
      weeklyEngagementReport: weeklyEngagementReport ?? this.weeklyEngagementReport,
      appVersion:             appVersion             ?? this.appVersion,
      avatarUrl:              avatarUrl              ?? this.avatarUrl,
    );
  }
}