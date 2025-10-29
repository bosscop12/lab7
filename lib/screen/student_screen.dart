import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/student.dart';
import 'add_student_screen.dart';
import 'edit_student_screen.dart';

class StudentScreen extends StatefulWidget {
  static const routeName = '/';
  const StudentScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StudentScreenState();
  }
}

class _StudentScreenState extends State<StudentScreen> {
  late Future<List<Student>> students;

  @override
  void initState() {
    super.initState();
    students = fetchStudents();
  }

  void _refreshData() {
    setState(() {
      students = fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddStudentScreen(),
                ),
              );
              if (result == true) {
                _refreshData(); // refresh list หลังจากเพิ่มเสร็จ
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<List<Student>>(
          future: students,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text('Total ${snapshot.data!.length} items'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: snapshot.data!.isNotEmpty
                        ? ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].studentName),
                                subtitle: Text(
                                  snapshot.data![index].studentCode,
                                ),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditStudentScreen(
                                              student: snapshot.data![index],
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          _refreshData(); // refresh หลังจากแก้ไขเสร็จ
                                        }
                                      },
                                      icon: Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Text(
                                                  "Do you want to delete: ${snapshot.data![index].studentCode}",
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                    ),
                                                    onPressed: () async {
                                                      await deleteStudent(
                                                        snapshot.data![index],
                                                      );
                                                      _refreshData();
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Delete'),
                                                  ),
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.blueGrey,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Close'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(
                            child: Text('No items'),
                          ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ================== Functions ==================

// ดึงข้อมูล Student ทั้งหมด
Future<List<Student>> fetchStudents() async {
  final response = await http.get(
    Uri.parse('http://192.168.56.1/pakapol/api/student.php'),
  );
  if (response.statusCode == 200) {
    return compute(parsestudents, response.body);
  } else {
    throw Exception('Failed to load Student');
  }
}

// แปลง JSON เป็น List<Student>
List<Student> parsestudents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

// ลบ Student
Future<int> deleteStudent(Student student) async {
  final response = await http.delete(
    Uri.parse(
      'http://192.168.56.1/pakapol/api/student.php?student_code=${student.studentCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    throw Exception('Failed to delete student.');
  }
}
