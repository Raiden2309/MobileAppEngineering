import 'package:mae_assignment_frontend/modules/role/student/models/semester_details_model.dart';

import '../controllers/student_settings_controller.dart';

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
  final List<Map<String, String>> subjects;
  final Set<String> blockedSlots;
  final String? avatarUrl;
  final int joinedClassCount;           // NEW
  final List<JoinedClassModel> joinedClasses; // NEW

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
    this.appVersion    = 'v1.0',
    this.semesters     = const [],
    this.subjects      = const [],
    this.blockedSlots  = const {},
    this.avatarUrl,
    this.joinedClassCount  = 0,         // NEW
    this.joinedClasses     = const [],  // NEW
  });

  factory StudentSettingsModel.fromJson(Map<String, dynamic> json) {
    final classes = (json['joined_classes'] as List<dynamic>? ?? [])
        .map((e) => JoinedClassModel.fromJson(e as Map<String, dynamic>))
        .toList();

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
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
      blockedSlots:      Set<String>.from(json['blocked_slots'] as List? ?? []),
      avatarUrl:         json['avatar_url'] as String?,
      joinedClasses:     classes,                // NEW
      joinedClassCount:  classes.length,         // NEW
    );
  }

  StudentSettingsModel copyWith({
    String? userName,
    bool? taskReminders,
    bool? slotEndPrompts,
    bool? burnoutWarnings,
    bool? weeklyResetSummary,
    List<SemesterModel>? semesters,
    List<Map<String, String>>? subjects,
    Set<String>? blockedSlots,
    String? avatarUrl,
    int? joinedClassCount,                       // NEW
    List<JoinedClassModel>? joinedClasses,       // NEW
  }) {
    return StudentSettingsModel(
      userId:             userId,
      userName:           userName            ?? this.userName,
      semester:           semester,
      year:               year,
      subjectCount:       subjectCount,
      studyHoursStart:    studyHoursStart,
      studyHoursEnd:      studyHoursEnd,
      blockedSlotsCount:  blockedSlotsCount,
      taskReminders:      taskReminders       ?? this.taskReminders,
      slotEndPrompts:     slotEndPrompts      ?? this.slotEndPrompts,
      burnoutWarnings:    burnoutWarnings     ?? this.burnoutWarnings,
      weeklyResetSummary: weeklyResetSummary  ?? this.weeklyResetSummary,
      appVersion:         appVersion,
      semesters:          semesters           ?? this.semesters,
      subjects:           subjects            ?? this.subjects,
      blockedSlots:       blockedSlots        ?? this.blockedSlots,
      avatarUrl:          avatarUrl           ?? this.avatarUrl,
      joinedClassCount:   joinedClassCount    ?? this.joinedClassCount,   // NEW
      joinedClasses:      joinedClasses       ?? this.joinedClasses,      // NEW
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
          name:            'Semester 4 · Year 2',
          studyHoursStart: '8 AM',
          studyHoursEnd:   '10 PM',
          subjectCount:    4,
          isCurrent:       true,
        ),
        SemesterModel(
          name:            'Semester 3 · Year 2',
          studyHoursStart: '9 AM',
          studyHoursEnd:   '9 PM',
          subjectCount:    5,
          isCurrent:       false,
        ),
      ],
      subjects: [
        {'name': 'Mathematics',         'color': '4F86C6'},
        {'name': 'Data Structures',     'color': 'F87171'},
        {'name': 'Operating Systems',   'color': '34D399'},
        {'name': 'Software Engineering','color': 'FBBF24'},
      ],
      blockedSlots: {
        '0_0', '0_1',
        '2_2', '2_3',
        '4_5', '4_6',
      },
      avatarUrl: null,
      // NEW — mock joined classes
      joinedClasses: const [
        JoinedClassModel(id: '1', name: 'CS301 — Algorithm Design'),
        JoinedClassModel(id: '2', name: 'CS410 — Machine Learning'),
      ],
      joinedClassCount: 2,
    );
  }
}