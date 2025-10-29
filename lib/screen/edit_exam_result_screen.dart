import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/exam_result.dart';
import 'package:http/http.dart' as http;

class EditExamResultScreen extends StatefulWidget {
  final ExamResult? examResult;
  const EditExamResultScreen({super.key, this.examResult});
  @override
  State<EditExamResultScreen> createState() => _EditExamResultScreenState();
}

class _EditExamResultScreenState extends State<EditExamResultScreen> {
  ExamResult? examResult;
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentCodeController = TextEditingController();
  TextEditingController pointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    examResult = widget.examResult!;
    studentCodeController.text = examResult!.studentCode;
    studentNameController.text = examResult!.studentName;
    pointController.text = examResult!.point.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Exam Result"),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                int rt = await updateExamResult(
                  ExamResult(
                    studentCode: studentCodeController.text,
                    studentName: studentNameController.text,
                    point: double.parse(pointController.text),
                  ),
                );

                if (rt == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Update successful!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  if (mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Update failed. Status Code: $rt'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                print('Error during update: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An error occurred: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
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
              controller: studentCodeController,
              enabled: true,
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
            TextField(
              controller: pointController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: true,
              ), // Keyboard สำหรับทศนิยม
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

Future<int> updateExamResult(ExamResult result) async {
  final requestBody = jsonEncode(<String, dynamic>{
    'student_code': result.studentCode,
    'student_name': result.studentName,
    'point': result.point.toString(),
  });

  print('Sending update data to API: $requestBody');

  try {
    // *** FIX: แก้ไข parameter ใน URL ให้ถูกต้อง ***
    final response = await http.put(
      Uri.parse(
        'http://192.168.56.1/pakapol/api/exam_result.php?student_code=${result.studentCode}',
      ),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    print('Update Response Status: ${response.statusCode}');
    print('Update Response Body: ${response.body}');
    return response.statusCode;
  } catch (e) {
    print('Error during http.put: $e');
    return 0; // คืนค่า 0 เพื่อบอกว่าเกิด Network Error
  }
}
