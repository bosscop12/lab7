import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/exam.dart';
import 'edit_exam_screen.dart';

class ExamScreen extends StatefulWidget {
  static const routeName = '/exam';
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  late Future<List<ExamResults>> exams;
  String? selectedCourse; // เก็บค่าที่เลือกจาก dropdown

  @override
  void initState() {
    super.initState();
    exams = fetchExams();
  }

  void _refreshData() {
    setState(() {
      exams = fetchExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: Center(
        child: FutureBuilder<List<ExamResults>>(
          future: exams,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              // --- ดึงรายชื่อวิชาที่ไม่ซ้ำ, trim ช่องว่าง และเรียงตัวอักษร
              final courses = snapshot.data!
                  .map((e) => e.courseCode.trim())
                  .toSet()
                  .toList()
                ..sort();

              // --- กรองข้อมูลตามวิชาที่เลือก
              final filteredExams = selectedCourse == null
                  ? snapshot.data!
                  : snapshot.data!
                      .where((e) => e.courseCode.trim() == selectedCourse)
                      .toList();

              return Column(
                children: [
                  // Dropdown + สรุปจำนวน
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    color: Colors.teal.withAlpha(100),
                    child: Row(
                      children: [
                        const Text("เลือกวิชา: "),
                        DropdownButton<String>(
                          value: selectedCourse,
                          hint: const Text("ทั้งหมด"),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("ทั้งหมด"),
                            ),
                            ...courses.map((course) {
                              return DropdownMenuItem(
                                value: course,
                                child: Text(course),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCourse = value;
                            });
                          },
                        ),
                        const Spacer(),
                        Text("Total ${filteredExams.length} items"),
                      ],
                    ),
                  ),

                  // List ของผลสอบ
                  Expanded(
                    child: filteredExams.isNotEmpty
                        ? ListView.separated(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: filteredExams.length,
                            itemBuilder: (context, index) {
                              final exam = filteredExams[index];
                              return ListTile(
                                title: Text("Student: ${exam.studentCode}"),
                                subtitle: Text(
                                  "Course: ${exam.courseCode} | Point: ${exam.point}",
                                ),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditExamScreen(exam: exam),
                                          ),
                                        );
                                        if (result == true) _refreshData();
                                      },
                                      icon: const Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title:
                                                const Text('Confirm Delete'),
                                            content: Text(
                                              "Do you want to delete exam id: ${exam.id}?",
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  await deleteExam(exam);
                                                  _refreshData();
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete'),
                                              ),
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.blueGrey,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) =>
                                const Divider(),
                          )
                        : const Center(child: Text('No items')),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btnAdd",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditExamScreen(
                    courseCode: selectedCourse, // prefill courseCode
                  ),
                ),
              );
              if (result == true) _refreshData();
            },
            tooltip: "Add",
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            heroTag: "btnRefresh",
            onPressed: _refreshData,
            tooltip: "Refresh",
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

// ================= API =================
Future<List<ExamResults>> fetchExams() async {
  final response = await http.get(
    Uri.parse('http://192.168.56.1/pakapol/api/exam_results.php'),
  );
  if (response.statusCode == 200) {
    return compute(parseExams, response.body);
  } else {
    throw Exception('Failed to load Exam Results');
  }
}

List<ExamResults> parseExams(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<ExamResults>((json) => ExamResults.fromJson(json))
      .toList();
}

Future<int> deleteExam(ExamResults exam) async {
  final response = await http.delete(
    Uri.parse(
      'http://192.168.56.1/pakapol/api/exam_results.php?id=${exam.id}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) return response.statusCode;
  throw Exception('Failed to delete exam.');
}