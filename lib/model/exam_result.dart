class ExamResult {
  final String studentCode;
  final String studentName;
  // 1. เปลี่ยนชนิดข้อมูลจาก int เป็น double เพื่อรองรับทศนิยม
  final double point;

  ExamResult({
    required this.studentCode,
    required this.studentName,
    required this.point,
  });

  // ส่วนของ name constructor ที่จะแปลง json string มาเป็น ExamResult object
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      // ใช้ '??' เพื่อกำหนดค่าเริ่มต้นเป็นข้อความว่าง ('') หากข้อมูลที่ได้รับมาเป็น null
      studentCode: json['student_code'] ?? '',
      studentName: json['student_name'] ?? '',

      // 2. เปลี่ยนจาก int.parse เป็น double.parse เพื่อแปลงเลขทศนิยม
      // โดยกำหนดค่าเริ่มต้นเป็น '0.0' หากเป็น null
      point: double.parse((json['point'] ?? '0.0').toString()),
    );
  }
}