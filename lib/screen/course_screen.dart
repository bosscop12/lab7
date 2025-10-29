import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lab7_101/model/course.dart';
import 'package:lab7_101/screen/add_course_screen.dart';
// TODO: 3. เปลี่ยนการ import หน้าจอจาก edit_student_screen.dart เป็น edit_course_screen.dart
import 'edit_course_screen.dart';

// เปลี่ยนชื่อคลาสจาก StudentScreen เป็น CourseScreen
class CourseScreen extends StatefulWidget {
  static const routeName = '/';
  const CourseScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _CourseScreenState();
  }
}

// เปลี่ยนชื่อ State class จาก _StudentScreenState เป็น _CourseScreenState
class _CourseScreenState extends State<CourseScreen> {
  // เปลี่ยนตัวแปรจาก students เป็น courses
  late Future<List<Course>> courses;

  @override
  void initState() {
    print("initState"); // สำหรับทดสอบ
    super.initState();
    // เรียกใช้ฟังก์ชัน fetchCourses()
    courses = fetchCourses();
  }

  void _refreshData() {
    setState(() {
      print("setState"); // สำหรับทดสอบ
      // เรียกใช้ฟังก์ชัน fetchCourses()
      courses = fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build"); // สำหรับทดสอบ
    return Scaffold(
      appBar: AppBar(
        // เปลี่ยน title
        title: Text('Course'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                // ไปยังหน้า AddCourseScreen
                MaterialPageRoute(builder: (context) => AddCourseScreen()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Center(
        // เปลี่ยนชนิดข้อมูลใน FutureBuilder
        child: FutureBuilder<List<Course>>(
          future: courses, // ใช้ตัวแปร courses
          builder: (context, snapshot) {
            print("builder"); // สำหรับทดสอบ
            print(snapshot.connectionState); // สำหรับทดสอบ
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
                        Text(
                          'Total ${snapshot.data!.length} items',
                        ), // แสดงจำนวนรายการ
                      ],
                    ),
                  ),
                  Expanded(
                    child: snapshot.data!.isNotEmpty
                        ? ListView.separated(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                // เปลี่ยนไปใช้ courseName และ courseCode
                                title: Text(snapshot.data![index].courseName),
                                subtitle: Text(
                                  snapshot.data![index].courseCode,
                                ),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                // ไปยังหน้า EditCourseScreen และส่งข้อมูล course ไปด้วย
                                                EditCourseScreen(
                                              course: snapshot.data![index],
                                            ),
                                          ),
                                        );
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
                                            // เปลี่ยนข้อความใน content
                                            content: Text(
                                              "Do you want to delete: ${snapshot
                                                      .data![index].courseName}",
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                                onPressed: () async {
                                                  // เรียกใช้ฟังก์ชัน deleteCourse
                                                  await deleteCourse(
                                                    snapshot.data![index],
                                                  );
                                                  setState(() {
                                                    // เรียกใช้ fetchCourses() เพื่อ refresh ข้อมูล
                                                    courses = fetchCourses();
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: Text('Delete'),
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

// เปลี่ยนชื่อฟังก์ชันและชนิดข้อมูลที่คืนค่า
Future<List<Course>> fetchCourses() async {
  // TODO: 4. เปลี่ยน URL ของ API ไปยัง endpoint ของ course
  final response = await http.get(
    Uri.parse('http://192.168.56.1/pakapol/api/courses.php'),
  );
  if (response.statusCode == 200) {
    // เรียกใช้ฟังก์ชัน parseCourses
    return compute(parseCourses, response.body);
  } else {
    // เปลี่ยนข้อความ error
    throw Exception('Failed to load Course');
  }
}

// เปลี่ยนชื่อฟังก์ชันและชนิดข้อมูล
List<Course> parseCourses(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  // เปลี่ยนไปใช้ Course.fromJson
  return parsed.map<Course>((json) => Course.fromJson(json)).toList();
}

// เปลี่ยนชื่อฟังก์ชันและพารามิเตอร์
Future<int> deleteCourse(Course course) async {
  // TODO: 5. เปลี่ยน URL และ parameter สำหรับการลบข้อมูล
  final response = await http.delete(
    Uri.parse(
      'http://192.168.56.1/pakapol/api/course.php?course_code=${course.courseCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    return response.statusCode;
  } else {
    // เปลี่ยนข้อความ error
    throw Exception('Failed to delete course.');
  }
}