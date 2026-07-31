import 'package:flutter/material.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/controllers/student_setup_controller.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_generate_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_profile.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_schedule.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_semester.dart';
import 'package:mae_assignment_frontend/modules/new_user_setup/views/student_setup/steps/student_subjects.dart';
import 'package:mae_assignment_frontend/modules/role/student/views/central_student_navigation.dart';
import 'package:provider/provider.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/styles/app_colors.dart';
import '../../../auth/services/auth_service.dart';
import '../../models/student_model.dart';
import '../../provider/student_provider.dart';

class StudentSetupPage extends StatefulWidget {
  const StudentSetupPage({super.key});

  @override
  State<StudentSetupPage> createState() => StudentSetupPageState();
}

class StudentSetupPageState extends State<StudentSetupPage> {
  int currentStep = 0;
  late final SetupController controller = SetupController();

  void nextStep() => setState(() => currentStep++);
  void prevStep() => setState(() => currentStep--);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onSetupDone(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No authenticated user found.')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.californiaBlue),
      ),
    );

    try {
      final List<Map<String, String>> safeSubjects = controller.subjects
          .whereType<Map>()
          .map(
            (item) => {
              'name': item['name']?.toString() ?? 'Unknown',
              'color': item['color']?.toString() ?? '60A5FA',
            },
          )
          .toList();

      // Global student document (no semester-specific fields)
      final studentModel = StudentModel(
        id: uid,
        name: controller.nameController.text.trim().isNotEmpty
            ? controller.nameController.text.trim()
            : 'Student',
        email: FirebaseAuth.instance.currentUser?.email ?? '',
        programme: controller.programmeController.text.trim(),
        dayStart: controller.dayStart,
        dayEnd: controller.dayEnd,
        blockedSlots: controller.blockedSlots.toList(),
      );

      // Semester document (subjects live here)
      final semesterModel = SemesterModel(
        id: 'sem_${controller.semester}_yr${controller.year}',
        semester: controller.semester,
        year: controller.year,
        semStart: controller.semStart,
        semEnd: controller.semEnd,
        examDates: controller.examDates,
        subjects: safeSubjects,
      );

      await context.read<StudentProvider>().save(studentModel, semesterModel);
      await AuthService.completeSetup();

      // Create class documents for each subject
      final firestore = FirebaseFirestore.instance;
      for (var subject in safeSubjects) {
        final subjectName = subject['name'] ?? 'Unknown';
        final subjectColorStr = subject['color'] ?? '60A5FA';
        final safeClassId = subjectName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
            .replaceAll(RegExp(r'[\s-]'), '_');

        await firestore.collection('classes').doc(safeClassId).set({
          'id': safeClassId,
          'name': subjectName,
          'code': safeClassId.toUpperCase().padRight(6, 'X').substring(0, 6),
          'semester': 'Semester ${semesterModel.semester}',
          'accentColorValue':
              int.tryParse('0xFF$subjectColorStr') ?? 0xFF60A5FA,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await firestore
            .collection('enrollments')
            .doc('${uid}_$safeClassId')
            .set({
              'studentId': uid,
              'classId': safeClassId,
              'semester': semesterModel.id,
              'qstudentName': studentModel.name,
              'joinedAt': FieldValue.serverTimestamp(),
              'weeklyStudyHours': 0.0,
              'completedTasks': 0,
              'pendingTasks': 0,
              'burnoutIndex': 0.0,
            });
      }

      if (!context.mounted) return;
      Navigator.of(context).pop();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const CentralStudentNavigation(),
          transitionsBuilder: (_, animation, _, child) => ScaleTransition(
            scale: Tween<double>(begin: 1.1, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: FadeTransition(opacity: animation, child: child),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Setup Failed',
              style: TextStyle(color: Colors.white),
            ),
            content: SingleChildScrollView(
              child: Text('$e', style: const TextStyle(color: Colors.white70)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(color: AppColors.californiaBlue),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget buildStep(BuildContext context) {
    switch (currentStep) {
      case 0:
        return StudentProfile(controller: controller, onNext: nextStep);
      case 1:
        return StudentSchedule(
          controller: controller,
          onNext: nextStep,
          onBack: prevStep,
        );
      case 2:
        return StudentSemester(
          controller: controller,
          onNext: nextStep,
          onBack: prevStep,
        );
      case 3:
        return StudentSubjects(
          controller: controller,
          onNext: nextStep,
          onBack: prevStep,
        );
      case 4:
        return StudentGenerateProfile(onDone: () => onSetupDone(context));
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.californiaBlue, AppColors.greenSheen],
          ),
        ),
        child: SafeArea(child: Builder(builder: buildStep)),
      ),
    );
  }
}
