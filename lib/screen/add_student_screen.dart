import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _addStudent() async {
    final response = await http.post(
      Uri.parse('http://192.168.56.1/pakapol/api/student.php'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "student_code": _codeController.text,
        "student_name": _nameController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add student")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Student")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Student Code"),
                validator: (value) =>
                    value!.isEmpty ? "Enter student code" : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Student Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter student name" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addStudent();
                  }
                },
                child: Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
