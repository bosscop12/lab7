import 'package:flutter/material.dart';
import 'student_screen.dart';
import 'course_screen.dart';
import 'exam_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main Menu")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const StudentScreen()),
                );
              },
              child: const Text("ไปที่ Student"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const CourseScreen()),
                );
              },
              child: const Text("ไปที่ Course"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ExamScreen()),
                );
              },
              child: const Text("ไปที่ Exam"),
            ),
          ],
        ),
      ),
    );
  }
}
