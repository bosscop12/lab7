// screen/edit_exam_result_screen.dart

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
  // ⭐️ ใช้ 10.0.2.2 สำหรับ Android Emulator
  if (Platform.isAndroid) return 'http://10.0.2.2';
  // ⭐️ (ถ้าใช้มือถือจริง หรือ API อยู่อีกเครื่อง ให้ใส่ IP นั้นแทน)
  // if (Platform.isAndroid) return 'http://10.96.33.115';
  return 'http://localhost';
}

const String apiBasePath = '/pakapol/api';

class EditExamResultScreen extends StatefulWidget {
  final ExamResult examResult;
  const EditExamResultScreen({super.key, required this.examResult});

  @override
  State<EditExamResultScreen> createState() => _EditExamResultScreenState();
}

class _EditExamResultScreenState extends State<EditExamResultScreen> {
  // ⭐️ 1. เหลือแค่ TextEditingController สำหรับ point
  late TextEditingController _pointController;

  // ⭐️ 2. ลบ _dataFuture, _selectedStudentCode, _selectedCourseCode ทิ้ง

  @override
  void initState() {
    super.initState();
    // ⭐️ 3. เหลือแค่ _pointController ที่ผูกกับค่าเดิม
    _pointController =
        TextEditingController(text: widget.examResult.point.toString());

    // ⭐️ 4. ลบการเรียก Future.wait ออก
  }

  Future<void> _onSave() async {
    // ⭐️ 5. ตรวจสอบแค่ point เท่านั้น
    if (_pointController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('กรุณากรอกคะแนน'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    // ใช้ studentCode และ courseCode เดิม แต่สร้าง newResult เพื่อส่งไป API
    final updatedResult = ExamResult(
      id: widget.examResult.id,
      // ⭐️ 6. ใช้ค่าเดิม (readonly)
      studentCode: widget.examResult.studentCode,
      courseCode: widget.examResult.courseCode,
      // ⭐️ 7. ใช้ค่า point ที่แก้ไข
      point: int.tryParse(_pointController.text) ?? 0,
      // (Name จะถูกดึงมาใหม่ในหน้า List อยู่แล้ว)
      studentName: widget.examResult.studentName,
      courseName: widget.examResult.courseName,
    );

    try {
      int statusCode = await updateExamResult(widget.examResult, updatedResult);
      if (!mounted) return;

      if (statusCode == 200) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: Status $statusCode'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'),
            backgroundColor: Colors.deepOrange),
      );
    }
  }

  Future<void> _onDelete() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณต้องการลบผลสอบนี้ใช่หรือไม่?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        int statusCode = await deleteExamResult(widget.examResult);
        if (!mounted) return;

        if (statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('เกิดข้อผิดพลาดในการลบข้อมูล: Status $statusCode'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'),
              backgroundColor: Colors.deepOrange),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Exam Result'),
        actions: [
          IconButton(onPressed: _onSave, icon: const Icon(Icons.save)),
          IconButton(onPressed: _onDelete, icon: const Icon(Icons.delete)),
        ],
      ),
      // ⭐️ 8. ลบ FutureBuilder ออก
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐️ 9. แสดง Student Code เป็น Text/Read-only
              ListTile(
                title: Text(widget.examResult.studentCode),
                subtitle: const Text('Student Code (Not Editable)'),
                leading: const Icon(Icons.person),
              ),
              const Divider(),
              // ⭐️ 10. แสดง Course Code เป็น Text/Read-only
              ListTile(
                title: Text(widget.examResult.courseCode),
                subtitle: const Text('Course Code (Not Editable)'),
                leading: const Icon(Icons.class_),
              ),
              const Divider(),
              const SizedBox(height: 24),
              // ⭐️ 11. เหลือแค่ TextField สำหรับ Point ที่แก้ไขได้
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

// ================== API FUNCTIONS (Edit Screen) ==================
// ⭐️ 12. ลบ fetchStudents() และ fetchCourses() ออกไป
/*
Future<List<Student>> fetchStudents() async { ... }
Future<List<Course>> fetchCourses() async { ... }
*/

Future<int> updateExamResult(
    ExamResult oldResult, ExamResult newResult) async {
  try {
    // ⭐️ 2. เปลี่ยน URL ให้ใช้ id
    final url =
        '${getApiBaseUrl()}$apiBasePath/exam_results.php?id=${oldResult.id}';

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // ⭐️ 3. ใช้ toJson() จากโมเดลที่แก้ไขแล้ว
      body: jsonEncode(newResult.toJson()),
    );
    return response.statusCode;
  } catch (e) {
    throw Exception('Failed to connect to the server: $e');
  }
}

Future<int> deleteExamResult(ExamResult result) async {
  try {
    // ⭐️ 4. เปลี่ยน URL ให้ใช้ id
    final url =
        '${getApiBaseUrl()}$apiBasePath/exam_results.php?id=${result.id}';

    final response = await http.delete(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    return response.statusCode;
  } catch (e) {
    throw Exception('Failed to connect to the server: $e');
  }
}