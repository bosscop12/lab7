class Course {
  final String courseCode;
  final String courseName;
  // 1. แก้ไขชื่อ property เป็น credit (ไม่มี s)
  final int credit;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.credit, // 2. แก้ไข parameter ใน constructor
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseCode: json['course_code'],
      courseName: json['course_name'],
      // 3. แก้ไข key ที่อ่านจาก JSON เป็น 'credit'
      credit: int.parse(json['credit'].toString()),
    );
  }
}