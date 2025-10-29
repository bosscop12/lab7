import 'package:flutter/material.dart';

// 1. import หน้าจอทั้งสามเข้ามาอย่างถูกต้อง
import 'screen/student_screen.dart';
import 'screen/course_screen.dart';
import 'screen/exam_result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student & Course Management',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // State สำหรับเก็บ index ของหน้าที่ถูกเลือกปัจจุบัน
  int _selectedIndex = 0;

  // 2. List ของ Widget ที่จะแสดงในแต่ละหน้า
  //    - เพิ่ม ExamResultScreen() เป็นลำดับที่ 3 (index 2)
  static const List<Widget> _widgetOptions = <Widget>[
    StudentScreen(),      // index 0
    CourseScreen(),       // index 1
    ExamResultScreen(),   // index 2
  ];

  // ฟังก์ชันสำหรับเปลี่ยนหน้าเมื่อผู้ใช้กดที่เมนู
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body จะแสดง Widget จาก List ตาม _selectedIndex ที่ถูกเลือก
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // เมนูสำหรับหน้า Students (index 0)
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Students',
          ),
          // เมนูสำหรับหน้า Courses (index 1)
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Courses',
          ),
          // 3. เพิ่มปุ่มเมนูสำหรับ "ผลสอบ" (index 2)
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Exam Results',
          ),
        ],
        currentIndex: _selectedIndex, // ทำให้ไอคอนของหน้าที่เลือกอยู่ Active
        selectedItemColor: Colors.indigo[800],
        onTap: _onItemTapped, // กำหนดฟังก์ชันที่จะทำงานเมื่อกด
      ),
    );
  }
}