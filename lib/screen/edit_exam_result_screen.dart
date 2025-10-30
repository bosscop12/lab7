// screen/edit_exam_result_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/exam_result.dart';

String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost';
  if (Platform.isAndroid) return 'http://10.0.2.2';
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
  late TextEditingController _pointController;
  late TextEditingController _studentCodeController;
  late TextEditingController _courseCodeController; // ✅ เพิ่ม controller สำหรับรหัสห้อง

  @override
  void initState() {
    super.initState();
    _pointController = TextEditingController(text: widget.examResult.point.toString());
    _studentCodeController = TextEditingController(text: widget.examResult.studentCode);
    _courseCodeController = TextEditingController(text: widget.examResult.courseCode); // ✅ กำหนดค่าเริ่มต้น
  }

  Future<void> _onSave() async {
    if (_pointController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกคะแนน'), backgroundColor: Colors.orange),
      );
      return;
    }

    final updatedResult = ExamResult(
      id: widget.examResult.id,
      studentCode: _studentCodeController.text, // ✅ แก้ไขรหัสนักศึกษาได้
      courseCode: _courseCodeController.text, // ✅ แก้ไขรหัสห้องได้
      point: int.tryParse(_pointController.text) ?? 0,
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
          SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขข้อมูล: Status $statusCode'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'), backgroundColor: Colors.deepOrange),
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
            SnackBar(content: Text('เกิดข้อผิดพลาดในการลบข้อมูล: Status $statusCode'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ: $e'), backgroundColor: Colors.deepOrange),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Edit Student Code
              TextField(
                controller: _studentCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Student Code',
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Edit Course Code
              TextField(
                controller: _courseCodeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Course Code',
                ),
              ),
              const Divider(),
              const SizedBox(height: 24),

              // ✅ Edit Point
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

// ===================== API FUNCTIONS =====================

Future<int> updateExamResult(ExamResult oldResult, ExamResult newResult) async {
  try {
    final url = '${getApiBaseUrl()}$apiBasePath/exam_results.php?id=${oldResult.id}';
    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(newResult.toJson()),
    );
    return response.statusCode;
  } catch (e) {
    throw Exception('Failed to connect to the server: $e');
  }
}

Future<int> deleteExamResult(ExamResult result) async {
  try {
    final url = '${getApiBaseUrl()}$apiBasePath/exam_results.php?id=${result.id}';
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
