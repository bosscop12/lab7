// screen/add_exam_result_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/exam_result.dart';
// import '../model/student.dart'; // No longer needed
// import '../model/course.dart'; // No longer needed

// (ฟังก์ชันนี้ควรจะเหมือนกับในไฟล์ ExamResultScreen.dart)
String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost';
  if (Platform.isAndroid) return 'http://10.0.2.2';
  return 'http://localhost';
}

const String apiBasePath = '/pakapol/api';

class AddExamResultScreen extends StatefulWidget {
  const AddExamResultScreen({super.key});

  @override
  State<AddExamResultScreen> createState() => _AddExamResultScreenState();
}

class _AddExamResultScreenState extends State<AddExamResultScreen> {
  final TextEditingController _studentCodeController = TextEditingController();
  final TextEditingController _courseCodeController = TextEditingController();
  final TextEditingController _pointController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _onSave() async {
    // ⭐️ 1. ตรวจสอบข้อมูลว่าง
    if (_studentCodeController.text.isEmpty ||
        _courseCodeController.text.isEmpty ||
        _pointController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('กรุณากรอกข้อมูลให้ครบถ้วน'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    final newResult = ExamResult(
      id: 0, // Placeholder
      studentCode: _studentCodeController.text,
      courseCode: _courseCodeController.text,
      point: int.tryParse(_pointController.text) ?? 0,
      studentName: _studentCodeController.text, // Placeholder Name
      courseName: _courseCodeController.text, // Placeholder Name
    );

    try {
      // ⭐️ 2. เรียกใช้ฟังก์ชัน API และรับค่า Status Code
      int statusCode = await addExamResult(newResult);
      if (!mounted) return; // เช็ค mounted ก่อนเข้าถึง context

      if (statusCode == 201 || statusCode == 200) {
        // ⭐️ 3. สำเร็จ
        Navigator.pop(context, true);
      } else if (statusCode == 0) {
        // ⭐️ 4. ดักจับ Network Error (ตามรูปแบบ 0 ที่กำหนดใน addExamResult)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network Error: Could not connect to the server.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // ⭐️ 5. ดักจับ Status Code อื่นๆ (เช่น 400, 500)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add result. Status Code: $statusCode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ⭐️ 6. ดักจับ Error อื่นๆ (เช่น การแปลงข้อมูลผิดพลาด)
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

  @override
  Widget build(BuildContext context) {
    // ⭐️ โครงสร้าง UI ถูกปรับให้เหลือแค่ TextField 3 ตัวแล้ว (ตามที่คุณได้แก้ไขก่อนหน้า)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam Result'),
        actions: [
          IconButton(
            onPressed: _onSave, 
            icon: const Icon(Icons.save)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _studentCodeController,
                decoration: const InputDecoration(
                  labelText: 'Student Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pointController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Point',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================== API FUNCTIONS (Add Screen) ==================

// ฟังก์ชันสำหรับ "เพิ่ม" ข้อมูล (POST)
Future<int> addExamResult(ExamResult newResult) async {
  try {
    final url = '${getApiBaseUrl()}$apiBasePath/exam_results.php';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(newResult.toJson()),
    );
    return response.statusCode;
  } catch (e) {
    // ⭐️ 7. คืนค่า 0 หากเกิด Network/Connection Error
    print('Error during http.post: $e');
    return 0; // คืนค่า 0 เพื่อบอกให้ UI จัดการ Network Error
  }
}