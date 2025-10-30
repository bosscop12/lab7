import 'dart:convert';
import 'package:flutter/material.dart';
// TODO: 1. เปลี่ยนการ import model จาก student.dart เป็น course.dart
import '../model/course.dart';
import 'package:http/http.dart' as http;

// เปลี่ยนชื่อคลาสจาก EditStudentScreen เป็น EditCourseScreen
class EditCourseScreen extends StatefulWidget {
  // เปลี่ยนชนิดของตัวแปรจาก Student เป็น Course
  final Course? course;
  const EditCourseScreen({super.key, this.course});
  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

// เปลี่ยนชื่อ State class
class _EditCourseScreenState extends State<EditCourseScreen> {
  // เปลี่ยนชนิดของตัวแปรจาก Student เป็น Course
  Course? course;
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  // สร้าง Controller สำหรับ Credits
  TextEditingController creditController = TextEditingController();
  
  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    // รับค่า course จาก widget
    course = widget.course!;
    codeController.text = course!.courseCode;
    nameController.text = course!.courseName;
    // กำหนดค่าเริ่มต้นให้ creditsController (แปลง int เป็น String)
    creditController.text = course!.credit.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // เปลี่ยน title
        title: const Text("Edit Course"),
        actions: [
          IconButton(
            onPressed: () async {
              // เรียกใช้ฟังก์ชัน updateCourse
              int rt = await updateCourse(
                Course(
                  courseCode: course!.courseCode,
                  courseName: nameController.text,
                  // แปลงค่าจาก creditsController (String) กลับเป็น int
                  credit: int.parse(creditController.text),
                ),
              );
              if (rt != 0) {
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: codeController,
              enabled: true, // รหัสวิชาไม่ควรแก้ไขได้
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // เปลี่ยน label
                labelText: 'Course Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                // เปลี่ยน label
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 10),
            // TODO: 2. เปลี่ยน Dropdown ของ Gender เป็น TextField ของ Credits
            TextField(
              controller: creditController,
              keyboardType: TextInputType.number, // กำหนด keyboard เป็นตัวเลข
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Credit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// เปลี่ยนชื่อฟังก์ชันและพารามิเตอร์
Future<int> updateCourse(Course course) async {
  // TODO: 3. เปลี่ยน URL และ parameter สำหรับการอัปเดตข้อมูล
  final response = await http.put(
    Uri.parse(
      'http://192.168.56.1/pakapol/api/course.php?course_code='+
          course.courseCode,
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    // TODO: 4. เปลี่ยน body ของ request ให้ตรงกับข้อมูล Course
    body: jsonEncode(<String, String>{
      'course_code': course.courseCode,
      'course_name': course.courseName,
      'credit': course.credit.toString(), // แปลง int เป็น String ก่อนส่ง
    }),
  );
  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    // เปลี่ยนข้อความ error
    throw Exception('Failed to update course.');
  }
}