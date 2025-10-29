class ExamResults {
  final String id;
  final String studentCode;
  final String courseCode;
  final String point;
  ExamResults({
    required this.id,
    required this.studentCode,
    required this.courseCode,
    required this.point,
  });

  factory ExamResults.fromJson(Map<String, dynamic> json){
    return ExamResults(
      id: json['id'],
      studentCode: json['student_code'], 
      courseCode: json['course_code'], 
      point: json['point']
      );
  }
}