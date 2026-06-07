import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../../../shared/styles/app_colors.dart';
import '../../../providers/classes_provider.dart';

class AddStudentBottomSheet extends StatefulWidget {
  final String className;
  final String subjectCode;

  const AddStudentBottomSheet({
    super.key,
    required this.className,
    required this.subjectCode,
  });

  static Future<void> show(
      BuildContext context, {
        required String className,
        required String subjectCode,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddStudentBottomSheet(
        className: className,
        subjectCode: subjectCode,
      ),
    );
  }

  @override
  State<AddStudentBottomSheet> createState() => _AddStudentBottomSheetState();
}

class _AddStudentBottomSheetState extends State<AddStudentBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    // FIXED: Changed LecturerClassesProvider to your authoritative ClassesProvider type
    final classesProvider = context.read<ClassesProvider>();

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottom),
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
          Row(
            // FIXED: Changed MainAxisAlignment.between to spaceBetween
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Student',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Search and select a student to manually enroll them.',
            style: TextStyle(fontSize: 12, color: Colors.white54),
          ),
          const SizedBox(height: 20),

          const Text(
            'Student Search Name',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
          const SizedBox(height: 6),

          TextField(
            controller: _searchController,
            style: const TextStyle(color: AppColors.white, fontSize: 13),
            cursorColor: AppColors.white,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim().toLowerCase();
              });
            },
            decoration: InputDecoration(
              hintText: 'Type standard profile name...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 18),
              filled: true,
              fillColor: AppColors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Available Registered Student Records',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.white),
          ),
          const SizedBox(height: 6),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.35,
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No registered student profiles found.', style: TextStyle(color: Colors.white38, fontSize: 13))),
                  );
                }

                final filteredList = snapshot.data!.docs.where((doc) {
                  final name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No matching students found.', style: TextStyle(color: Colors.white38, fontSize: 13))),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    final studentDoc = filteredList[index];
                    final studentData = studentDoc.data() as Map<String, dynamic>;
                    final studentUid = studentDoc.id;
                    final studentName = studentData['name'] ?? 'Unknown Student';
                    final studentEmail = studentData['email'] ?? '';

                    final initials = studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.black,
                        radius: 18,
                        child: Text(
                          initials,
                          style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        studentName,
                        style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        studentEmail,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      trailing: _saving
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.white))
                          : IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white, size: 20),
                        onPressed: () async {
                          setState(() => _saving = true);

                          final success = await classesProvider.manuallyEnrollStudent(
                            studentUid: studentUid,
                            className: widget.className,
                            subjectCode: widget.subjectCode,
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E2330),
                                content: Text(
                                  success
                                      ? '$studentName has been enrolled successfully!'
                                      : '$studentName is already enrolled inside this class.',
                                  style: const TextStyle(color: AppColors.white, fontSize: 13),
                                ),
                              ),
                            );
                          }
                        },
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
}