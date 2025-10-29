import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/exam.dart';
import 'package:http/http.dart' as http;

class EditExamScreen extends StatefulWidget {
  final ExamResults? exam;
  final String? courseCode; // เพิ่มตรงนี้

  const EditExamScreen({super.key, this.exam, this.courseCode});

  @override
  State<EditExamScreen> createState() => _EditExamScreenState();
}

class _EditExamScreenState extends State<EditExamScreen> {
  TextEditingController studentCodeController = TextEditingController();
  TextEditingController courseCodeController = TextEditingController();
  TextEditingController pointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill สำหรับ Add หรือ Edit
    studentCodeController.text = widget.exam?.studentCode ?? '';
    courseCodeController.text =
        widget.courseCode ?? widget.exam?.courseCode ?? '';
    pointController.text = widget.exam?.point ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.exam != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Exam Result" : "Add Exam Result"),
        actions: [
          IconButton(
            onPressed: () async {
              if (isEdit) {
                int rt = await updateExam(
                  ExamResults(
                    id: widget.exam!.id,
                    studentCode: studentCodeController.text,
                    courseCode: courseCodeController.text,
                    point: pointController.text,
                  ),
                );
                if (rt != 0) Navigator.pop(context, true);
              } else {
                int rt = await addExam(
                  ExamResults(
                    id: "0",
                    studentCode: studentCodeController.text,
                    courseCode: courseCodeController.text,
                    point: pointController.text,
                  ),
                );
                if (rt != 0) Navigator.pop(context, true);
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Student Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: courseCodeController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pointController,
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

/// Update Exam
Future<int> updateExam(ExamResults exam) async {
  final response = await http.put(
    Uri.parse(
      'http://158.108.112.140/wachira/api/exam_results.php?id=${exam.id}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': exam.studentCode,
      'course_code': exam.courseCode,
      'point': exam.point,
    }),
  );
  if (response.statusCode == 200) return response.statusCode;
  throw Exception('Failed to update exam.');
}

/// Add Exam
Future<int> addExam(ExamResults exam) async {
  final response = await http.post(
    Uri.parse('http://158.108.112.140/wachira/api/exam_results.php'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': exam.studentCode,
      'course_code': exam.courseCode,
      'point': exam.point,
    }),
  );
  if (response.statusCode == 200) return response.statusCode;
  throw Exception('Failed to add exam.');
}
