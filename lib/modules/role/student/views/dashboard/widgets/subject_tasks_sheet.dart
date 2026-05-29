import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../models/app_enums.dart';
import '../../../models/tasks_model.dart';
import 'dart:async';

class SubjectTasksSheet extends StatelessWidget {
  final String enrollmentDocId;
  final String subjectName;

  const SubjectTasksSheet({
    super.key,
    required this.enrollmentDocId,
    required this.subjectName,
  });

  static void show(BuildContext context, {required String enrollmentDocId, required String subjectName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubjectTasksSheet(
        enrollmentDocId: enrollmentDocId,
        subjectName: subjectName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2330),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subjectName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Current Tasks & Assignments',
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('enrollments')
                  .doc(enrollmentDocId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.californiaBlue));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('No subject tracking found.', style: TextStyle(color: Colors.white54)),
                  );
                }

                final dataMap = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final List<dynamic> rawTasks = dataMap['tasksList'] ?? [];

                if (rawTasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks added to this subject yet.', style: TextStyle(color: Colors.white54)),
                  );
                }

                final tasks = rawTasks.map((t) => Task.fromJson(t as Map<String, dynamic>)).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 4),

                                // --- WIRED LIVE COUNTDOWN COMPONENT ---
                                TaskCountdownText(task: task),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.statusLabel,
                              style: TextStyle(color: _getStatusColor(task.status), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed: return AppColors.lime;
      case TaskStatus.inProgress: return AppColors.californiaBlue;
      case TaskStatus.dueSoon: return AppColors.nectarine;
      default: return Colors.white54;
    }
  }
}

class TaskCountdownText extends StatefulWidget {
  final Task task;
  const TaskCountdownText({super.key, required this.task});

  @override
  State<TaskCountdownText> createState() => _TaskCountdownTextState();
}

class _TaskCountdownTextState extends State<TaskCountdownText> {
  Timer? _ticker;
  late String _displayString;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();

    // If the task is in progress and has a valid start point, run a 1-second interval loop
    if (widget.task.status == TaskStatus.inProgress && widget.task.startedAt != null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        _calculateRemainingTime();
      });
    }
  }

  void _calculateRemainingTime() {
    if (widget.task.status != TaskStatus.inProgress || widget.task.startedAt == null) {
      _displayString = widget.task.estimatedTime;
      return;
    }

    final totalAllowedMinutes = (widget.task.estimatedHours * 60).round();
    final minutesPassed = DateTime.now().difference(widget.task.startedAt!).inMinutes;
    final minutesRemaining = totalAllowedMinutes - minutesPassed;

    if (minutesRemaining <= 0) {
      if (mounted) {
        setState(() {
          _displayString = "Time Overdue!";
        });
      }
      return;
    }

    final hours = minutesRemaining ~/ 60;
    final minutes = minutesRemaining % 60;

    if (mounted) {
      setState(() {
        if (hours > 0) {
          _displayString = '$hours hr $minutes min left';
        } else {
          _displayString = '$minutes min left';
        }
      });
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayString,
      style: TextStyle(
        color: widget.task.status == TaskStatus.inProgress ? AppColors.californiaBlue : Colors.white38,
        fontSize: 11,
        fontWeight: widget.task.status == TaskStatus.inProgress ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}