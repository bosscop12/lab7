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

class AddExamResultScreen extends StatefulWidget {
  const AddExamResultScreen({super.key});

  @override
  State<AddExamResultScreen> createState() => _AddExamResultScreenState();
}

class _AddExamResultScreenState extends State<AddExamResultScreen> {
  String? _selectedStudentCode;
  String? _selectedCourseCode;
  final TextEditingController _pointController = TextEditingController();

  late Future<List<ExamResult>> _examResultsFuture;

  @override
  void initState() {
    super.initState();
    _examResultsFuture = fetchExamResults();
  }

  Future<List<ExamResult>> fetchExamResults() async {
    final url = '${getApiBaseUrl()}$apiBasePath/exam_results.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      final decoded = jsonDecode(body) as List;
      return decoded.map((e) => ExamResult.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<int> addExamResult(ExamResult newResult) async {
    try {
      final url = '${getApiBaseUrl()}$apiBasePath/exam_results.php';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(newResult.toJson()),
      );
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 0;
    }
  }

  Future<void> _onSave(List<ExamResult> allResults) async {
    if (_selectedStudentCode == null ||
        _selectedCourseCode == null ||
        _pointController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกนักเรียน วิชา และกรอกคะแนน'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 🔍 ดึงชื่อจากข้อมูลเดิม
    final studentName = allResults
            .firstWhere((r) => r.studentCode == _selectedStudentCode,
                orElse: () => ExamResult(
                    id: 0,
                    studentCode: '',
                    courseCode: '',
                    studentName: '',
                    courseName: '',
                    point: 0))
            .studentName ??
        '';

    final courseName = allResults
            .firstWhere((r) => r.courseCode == _selectedCourseCode,
                orElse: () => ExamResult(
                    id: 0,
                    studentCode: '',
                    courseCode: '',
                    studentName: '',
                    courseName: '',
                    point: 0))
            .courseName ??
        '';

    final newResult = ExamResult(
      id: 0,
      studentCode: _selectedStudentCode!,
      studentName: studentName,
      courseCode: _selectedCourseCode!,
      courseName: courseName,
      point: int.tryParse(_pointController.text) ?? 0,
    );

    int status = await addExamResult(newResult);
    if (!mounted) return;

    if (status == 200 || status == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกล้มเหลว (Status: $status)'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exam Result'),
      ),
      body: FutureBuilder<List<ExamResult>>(
        future: _examResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          final results = snapshot.data ?? [];

          // ✅ สร้าง list เฉพาะที่ไม่ซ้ำ
          final studentList = {
            for (var r in results) r.studentCode: r.studentName
          };
          final courseList = {
            for (var r in results) r.courseCode: r.courseName
          };

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Dropdown นักเรียน
                DropdownButtonFormField<String>(
                  value: _selectedStudentCode,
                  items: studentList.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text('${e.value} ${e.key}'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedStudentCode = val;
                  }),
                  decoration: const InputDecoration(
                    labelText: 'เลือกนักเรียน',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Dropdown วิชา
                DropdownButtonFormField<String>(
                  value: _selectedCourseCode,
                  items: courseList.entries
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text('${e.value} ${e.key}'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedCourseCode = val;
                  }),
                  decoration: const InputDecoration(
                    labelText: 'เลือกรายวิชา',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // ช่องคะแนน (พิมพ์ได้)
                TextField(
                  controller: _pointController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'คะแนน (Point)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton.icon(
                  onPressed: () => _onSave(results),
                  icon: const Icon(Icons.save),
                  label: const Text('บันทึกผลสอบ'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
