import 'package:mae_assignment_frontend/modules/role/student/models/semester_details_model.dart';

class StudentSettingsModel {
  final int userId;
  final String userName;
  final String semester;
  final int year;
  final int subjectCount;
  final String studyHoursStart;
  final String studyHoursEnd;
  final int blockedSlotsCount;
  final bool taskReminders;
  final bool slotEndPrompts;
  final bool burnoutWarnings;
  final bool weeklyResetSummary;
  final String appVersion;
  final List<SemesterModel> semesters;

  const StudentSettingsModel({
    required this.userId,
    required this.userName,
    required this.semester,
    required this.year,
    required this.subjectCount,
    required this.studyHoursStart,
    required this.studyHoursEnd,
    required this.blockedSlotsCount,
    required this.taskReminders,
    required this.slotEndPrompts,
    required this.burnoutWarnings,
    required this.weeklyResetSummary,
    this.appVersion = 'v1.0',
    this.semesters = const [],
  });

  factory StudentSettingsModel.fromJson(Map<String, dynamic> json) {
    return StudentSettingsModel(
      userId:             json['user_id'] as int,
      userName:           json['user_name'] as String,
      semester:           json['semester'] as String,
      year:               json['year'] as int,
      subjectCount:       json['subject_count'] as int,
      studyHoursStart:    json['study_hours_start'] as String,
      studyHoursEnd:      json['study_hours_end'] as String,
      blockedSlotsCount:  json['blocked_slots_count'] as int,
      taskReminders:      json['task_reminders'] as bool,
      slotEndPrompts:     json['slot_end_prompts'] as bool,
      burnoutWarnings:    json['burnout_warnings'] as bool,
      weeklyResetSummary: json['weekly_reset_summary'] as bool,
      appVersion:         json['app_version'] as String? ?? 'v1.0',
      semesters: (json['semesters'] as List<dynamic>? ?? [])
          .map((e) => SemesterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  StudentSettingsModel copyWith({
    bool? taskReminders,
    bool? slotEndPrompts,
    bool? burnoutWarnings,
    bool? weeklyResetSummary,
    List<SemesterModel>? semesters,
  }) {
    return StudentSettingsModel(
      userId:             userId,
      userName:           userName,
      semester:           semester,
      year:               year,
      subjectCount:       subjectCount,
      studyHoursStart:    studyHoursStart,
      studyHoursEnd:      studyHoursEnd,
      blockedSlotsCount:  blockedSlotsCount,
      taskReminders:      taskReminders      ?? this.taskReminders,
      slotEndPrompts:     slotEndPrompts     ?? this.slotEndPrompts,
      burnoutWarnings:    burnoutWarnings    ?? this.burnoutWarnings,
      weeklyResetSummary: weeklyResetSummary ?? this.weeklyResetSummary,
      appVersion:         appVersion,
      semesters:          semesters          ?? this.semesters,
    );
  }

  factory StudentSettingsModel.mockData() {
    return StudentSettingsModel(
      userId:             1,
      userName:           'Alex',
      semester:           '4',
      year:               2,
      subjectCount:       4,
      studyHoursStart:    '8 AM',
      studyHoursEnd:      '10 PM',
      blockedSlotsCount:  6,
      taskReminders:      true,
      slotEndPrompts:     true,
      burnoutWarnings:    true,
      weeklyResetSummary: false,
      appVersion:         'v1.0',
      semesters: const [
        SemesterModel(
          name: 'Semester 4 · Year 2',
          studyHoursStart: '8 AM',
          studyHoursEnd: '10 PM',
          subjectCount: 4,
          isCurrent: true,
        ),
        SemesterModel(
          name: 'Semester 3 · Year 2',
          studyHoursStart: '9 AM',
          studyHoursEnd: '9 PM',
          subjectCount: 5,
          isCurrent: false,
        ),
      ],
    );
  }
}