import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/course.dart';
import 'package:http/http.dart' as http;

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});
  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  String dropdownValue = "3";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Course"),
        actions: [
          IconButton(
            onPressed: () async {
              if (codeController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                try {
                  int rt = await insertCourse(
                    Course(
                      courseCode: codeController.text,
                      courseName: nameController.text,
                      credit: int.parse(dropdownValue),
                    ),
                  );

                  print('API Response Status Code: $rt');

                  if (rt == 201 || rt == 200) {
                    if (mounted) Navigator.pop(context);
                  } else if (rt == 0) {
                    // ดักจับ Error ที่เรากำหนดเองสำหรับปัญหา Network
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Network Error: Could not connect to the server.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    // สำหรับ Status Code อื่นๆ ที่ไม่ใช่ความสำเร็จ
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add course. Status Code: $rt',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  // ดักจับ Error อื่นๆ ที่อาจเกิดขึ้น เช่น การแปลงข้อมูลผิดพลาด
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
            TextField(
              controller: codeController,
              enabled: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Code',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course Name',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: dropdownValue,
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Credit',
                border: OutlineInputBorder(),
              ),
              items: ['1', '2', '3'].map<DropdownMenuItem<String>>((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [const SizedBox(width: 10), Text(value)],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<int> insertCourse(Course course) async {
  final requestBody = jsonEncode(<String, dynamic>{
    'course_code': course.courseCode,
    'course_name': course.courseName,
    'credit': course.credit.toString(),
  });

  print('Sending data to API: $requestBody');

  try {
    final response = await http.post(
      Uri.parse('http://192.168.56.1/pakapol/api/course.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBody,
    );

    print('API Response Body: ${response.body}');
    return response.statusCode;
  } catch (e) {
    // --- START: นี่คือส่วนสำคัญที่เพิ่มเข้ามา ---
    // หากเกิด Error ระหว่างการเชื่อมต่อ (เช่น Network, Timeout)
    print('Error during http.post: $e');
    return 0; // คืนค่า 0 เพื่อบอกให้ UI รู้ว่าเกิด Network Error
    // --- END: นี่คือส่วนสำคัญที่เพิ่มเข้ามา ---
  }
}
