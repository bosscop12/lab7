import 'dart:convert';
import 'package:flutter/material.dart';
import '../model/student.dart';
import 'package:http/http.dart' as http;

class EditStudentScreen extends StatefulWidget {
  final Student? student;
  const EditStudentScreen({super.key, this.student});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late Student student; // ใช้ late เพราะเราจะกำหนดค่าใน initState
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  String dropdownValue = "F";

  final _formKey = GlobalKey<FormState>(); // สำหรับ validate form

  @override
  void initState() {
    super.initState();

    // ถ้า widget.student เป็น null ให้สร้าง default student
    student =
        widget.student ??
        Student(studentCode: '', studentName: '', gender: 'F');

    codeController.text = student.studentCode;
    nameController.text = student.studentName;

    // ตรวจสอบ gender ว่าอยู่ใน ['F', 'M'] หรือไม่
    dropdownValue = (student.gender == 'F' || student.gender == 'M')
        ? student.gender
        : 'F';
  }

  @override
  void dispose() {
    nameController.dispose();
    codeController.dispose();
    super.dispose();
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    Student updatedStudent = Student(
      studentCode: student.studentCode,
      studentName: nameController.text.trim(),
      gender: dropdownValue,
    );

    try {
      int status = await updateStudent(updatedStudent);
      if (status == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update success!')));
        Navigator.pop(context, updatedStudent);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Update failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Student"),
        actions: [
          IconButton(onPressed: _saveStudent, icon: const Icon(Icons.save)),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Student Code (disabled)
              TextFormField(
                controller: codeController,
                enabled: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Student Code',
                ),
              ),
              const SizedBox(height: 16),

              // Student Name
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Student Name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                initialValue: dropdownValue,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      dropdownValue = value;
                    });
                  }
                },
                items: ['F', 'M'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Update student via HTTP PUT
Future<int> updateStudent(Student student) async {
  final response = await http.put(
    Uri.parse(
      'http://192.168.56.1/pakapol/api/student.php?student_code=${student.studentCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'student_code': student.studentCode,
      'student_name': student.studentName,
      'gender': student.gender,
    }),
  );

  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to update student: ${response.body}');
  }
}