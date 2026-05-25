import 'package:flutter/material.dart';
import '../../../../shared/styles/app_colors.dart';

const List<Color> subjectPalette = [
  AppColors.greenSheen,
  AppColors.mikadoYellow,
  AppColors.softPurple,
  AppColors.californiaBlue,
  AppColors.nectarine,
  AppColors.skyCyan,
  AppColors.pink,
  AppColors.lime,
];

class SubjectProgress {
  final String name;
  final String code;
  final double progress;
  final int completed;
  final int remaining;
  final int dueSoon;

  const SubjectProgress({
    required this.name,
    required this.code,
    required this.progress,
    required this.completed,
    required this.remaining,
    required this.dueSoon,
  });

  Color get color {
    final hash = code.codeUnits.fold(0, (acc, c) => acc * 31 + c);
    return subjectPalette[hash.abs() % subjectPalette.length];
  }

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      name:      json['name'] as String,
      code:      json['code'] as String,
      progress:  (json['progress'] as num).toDouble(),
      completed: json['completed'] as int,
      remaining: json['remaining'] as int,
      dueSoon:   json['due_soon'] as int,
    );
  }
}

class SemesterProgressModel {
  final String semesterName;
  final String dateRange;
  final double overallProgress;
  final int completedTasks;
  final int totalTasks;
  final int currentWeek;
  final int totalWeeks;
  final double timelineProgress;
  final int weeksRemaining;
  final String finalExamDate;
  final List<SubjectProgress> subjects;

  const SemesterProgressModel({
    required this.semesterName,
    required this.dateRange,
    required this.overallProgress,
    required this.completedTasks,
    required this.totalTasks,
    required this.currentWeek,
    required this.totalWeeks,
    required this.timelineProgress,
    required this.weeksRemaining,
    required this.finalExamDate,
    required this.subjects,
  });

  factory SemesterProgressModel.fromJson(Map<String, dynamic> json) {
    return SemesterProgressModel(
      semesterName:     json['semester_name'] as String,
      dateRange:        json['date_range'] as String,
      overallProgress:  (json['overall_progress'] as num).toDouble(),
      completedTasks:   json['completed_tasks'] as int,
      totalTasks:       json['total_tasks'] as int,
      currentWeek:      json['current_week'] as int,
      totalWeeks:       json['total_weeks'] as int,
      timelineProgress: (json['timeline_progress'] as num).toDouble(),
      weeksRemaining:   json['weeks_remaining'] as int,
      finalExamDate:    json['final_exam_date'] as String,
      subjects: (json['subjects'] as List<dynamic>)
          .map((s) => SubjectProgress.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  factory SemesterProgressModel.mockData() {
    return const SemesterProgressModel(
      semesterName:     'Sem 4',
      dateRange:        'March – July 2026',
      overallProgress:  0.65,
      completedTasks:   10,
      totalTasks:       20,
      currentWeek:      8,
      totalWeeks:       14,
      timelineProgress: 0.57,
      weeksRemaining:   6,
      finalExamDate:    '14 July',
      subjects: [
        SubjectProgress(name: 'CT124 System Proposal', code: 'CT124',  progress: 0.65, completed: 7, remaining: 4, dueSoon: 1),
        SubjectProgress(name: 'Research Methods',      code: 'RM302',  progress: 0.40, completed: 2, remaining: 3, dueSoon: 1),
        SubjectProgress(name: 'Mobile Development',    code: 'MOB401', progress: 0.25, completed: 1, remaining: 3, dueSoon: 0),
        SubjectProgress(name: 'Software Engineering',  code: 'SE305',  progress: 0.10, completed: 0, remaining: 4, dueSoon: 1),
      ],
    );
  }
}