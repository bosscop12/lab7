import 'dart:convert';
import 'package:flutter/material.dart';
// 1. เปลี่ยนการ import model เป็น exam_result.dart
import '../model/exam_result.dart';
import 'package:http/http.dart' as http;

// 2. เปลี่ยนชื่อคลาสเป็น AddExamResultScreen
class AddExamResultScreen extends StatefulWidget {
  const AddExamResultScreen({super.key});
  @override
  State<AddExamResultScreen> createState() => _AddExamResultScreenState();
}

class _AddExamResultScreenState extends State<AddExamResultScreen> {
  // 3. เปลี่ยนชื่อ Controller ให้สื่อความหมายมากขึ้น
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentCodeController = TextEditingController();
  TextEditingController pointController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 4. เปลี่ยน Title ของหน้าจอ
        title: const Text("Add Exam Result"),
        actions: [
          IconButton(
            onPressed: () async {
              if (studentCodeController.text.isNotEmpty &&
                  studentNameController.text.isNotEmpty &&
                  pointController.text.isNotEmpty) {
                try {
                  // 5. เรียกใช้ฟังก์ชัน insertExamResult
                  int rt = await insertExamResult(
                    ExamResult(
                      studentCode: studentCodeController.text,
                      studentName: studentNameController.text,
                      point: double.parse(pointController.text),
                    ),
                  );

                  print('API Response Status Code: $rt');

                  if (rt == 201 || rt == 200) {
                    if (mounted) Navigator.pop(context);
                  } else if (rt == 0) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Network Error: Could not connect to the server.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to add result. Status Code: $rt'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  print('Error in onPressed: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('An unexpected error occurred: $e'),
                        backgroundColor: Colors.deepOrange,
                      ),
                    );
                  }
                }
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
            // 6. เปลี่ยน UI Fields ให้สอดคล้องกับข้อมูลผลสอบ
            TextField(
              controller: studentCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: studentNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Name',
              ),
            ),
            const SizedBox(height: 10),
            // เปลี่ยนจาก Dropdown เป็น TextField สำหรับ Point
            TextField(
              controller: pointController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Point',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 7. เปลี่ยนฟังก์ชันสำหรับส่งข้อมูลไปยัง API ของ exam_result
Future<int> insertExamResult(ExamResult result) async {
  final requestBody = jsonEncode(<String, dynamic>{
    'student_code': result.studentCode,
    'student_name': result.studentName,
    'point': result.point.toString(),
  });

  print('Sending data to API: $requestBody');

  try {
    // *** สำคัญ: คุณต้องเปลี่ยน URL นี้ให้เป็น API สำหรับบันทึกผลสอบของคุณ ***
    final response = await http.post(
      Uri.parse('http://192.168.56.1/pakapol/api/exam_result.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    print('API Response Body: ${response.body}');
    return response.statusCode;
  } catch (e) {
    print('Error during http.post: $e');
    return 0; // คืนค่า 0 เพื่อบอกให้ UI รู้ว่าเกิด Network Error
  }
}