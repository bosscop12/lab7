// model/exam_result.dart

class ExamResult {
  // ⭐️ 1. นำ id กลับมา
  final int id;
  final String studentCode;
  final String studentName;
  final String courseCode;
  final String courseName;
  final int point;

  ExamResult({
    // ⭐️ 1. นำ id กลับมา
    required this.id,
    required this.studentCode,
    required this.studentName,
    required this.courseCode,
    required this.courseName,
    required this.point,
  });

  // Factory constructor สำหรับแปลง JSON ที่ได้รับจาก API
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      // ⭐️ 1. นำ id กลับมา
      id: int.tryParse(json['id'].toString()) ?? 0,
      studentCode: json['student_code'] ?? '',
      studentName: json['student_name'] ?? '',
      courseCode: json['course_code'] ?? '',
      courseName: json['course_name'] ?? '',
      // ⭐️ (แก้ไข) แก้ point ที่เคยให้ค่า default 10 เป็น 0
      point: int.tryParse(json['point'].toString()) ?? 0,
    );
  }

  // ฟังก์ชันสำหรับแปลง Object เป็น JSON เพื่อส่งไปให้ API (สำหรับ Add/Update)
  Map<String, dynamic> toJson() {
    return {
      // 'id' ไม่ต้องส่งไปใน body เพราะ API (PHP) ไม่ได้ใช้
      'student_code': studentCode,
      'course_code': courseCode,
      // ⭐️ 2. (สำคัญ) ส่ง point เป็น int (number) ไม่ใช่ String
      'point': point,
    };
  }
}