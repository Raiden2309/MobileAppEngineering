import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/classes_provider.dart';
import 'widgets/class_card.dart';
import 'widgets/create_class_sheet.dart';
import 'class_detail_page.dart';

class LecturerClassesSection extends StatelessWidget {
  const LecturerClassesSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the real-time classes list from the provider stream
    final classesProvider = context.watch<ClassesProvider>();
    final classList = classesProvider.classes;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Classes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => CreateClassSheet.show(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Handle loading state
            if (classesProvider.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            // Handle empty state gracefully
            else if (classList.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'No active classes found.\nTap the + icon to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              )
            // Render the live synchronized class cards
            else
              Expanded(
                child: ListView.builder(
                  itemCount: classList.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final currentClass = classList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: ClassCard(
                        classModel: currentClass,
                        onTap: () {
                          // FIXED: Swapped out the raw string path argument crash for a direct MaterialPageRoute
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClassDetailPage(classModel: currentClass),
                            ),
                          );
                        },
                        onDelete: () =>
                            classesProvider.deleteClass(currentClass.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
