// if (enrolledCourses.isEmpty)
// const Center(
// child: Padding(
// padding: EdgeInsets.symmetric(vertical: 40),
// child: Text(
// "You haven't joined any classes yet.\nGo to settings to enroll in courses!",
// textAlign: TextAlign.center,
// style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
// ),
// ),
// )
// else
// ListView.builder(
// shrinkWrap: true,
// physics: const NeverScrollableScrollPhysics(),
// itemCount: enrolledCourses.length,
// itemBuilder: (context, index) {
// final joinedClass = enrolledCourses[index];
// final classNameStr = joinedClass.name;
// final courseCodeStr = joinedClass.code;
// final colorString = joinedClass.colorHex;
//
// final cardAccentColor = Color(int.tryParse(colorString.replaceAll('#', '0xFF')) ?? 0xFF60A5FA);
//
// final docId = '${uid}_${classNameStr.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').replaceAll(RegExp(r'[\s-]'), '_')}';
//
// return Padding(
// padding: const EdgeInsets.only(bottom: 12),
// child: Material(
// color: Colors.transparent,
// child: InkWell(
// onTap: () {
// // Open task popup window cleanly on tap action triggers
// SubjectTasksSheet.show(
// context,
// enrollmentDocId: docId,
// subjectName: classNameStr,
// );
// },
// borderRadius: BorderRadius.circular(16),
// child: Container(
// padding: const EdgeInsets.all(16),
// decoration: BoxDecoration(
// color: Colors.white.withOpacity(0.05),
// borderRadius: BorderRadius.circular(16),
// border: Border.all(color: Colors.white10),
// ),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// classNameStr,
// style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
// ),
// const SizedBox(height: 4),
// Text(
// courseCodeStr,
// style: const TextStyle(color: Colors.white54, fontSize: 12),
// ),
// ],
// ),
// Container(
// padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// decoration: BoxDecoration(
// color: cardAccentColor.withOpacity(0.15),
// borderRadius: BorderRadius.circular(12),
// border: Border.all(color: cardAccentColor.withOpacity(0.3)),
// ),
// child: Text(
// 'Sem ${joinedClass.semesterId}',
// style: TextStyle(color: cardAccentColor, fontWeight: FontWeight.bold, fontSize: 12),
// ),
// ),
// ],
// ),
// ),
// ),
// ),
// );
// },
// ),