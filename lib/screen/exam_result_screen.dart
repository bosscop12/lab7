// import 'dart:async'; // Removed
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/exam_result.dart';
import 'add_exam_result_screen.dart';
import 'edit_exam_result_screen.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({Key? key}) : super(key: key);

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  late Future<List<ExamResult>> _examResultsFuture;

  @override
  void initState() {
    super.initState();
    _examResultsFuture = fetchExamResults();
  }

  void _refreshData() {
    setState(() {
      _examResultsFuture = fetchExamResults();
    });
  }

  Future<void> _handleNavigate({ExamResult? examResult}) async {
    final route = MaterialPageRoute(
      builder: (context) => examResult == null
          ? const AddExamResultScreen()
          : EditExamResultScreen(examResult: examResult),
    );

    final result = await Navigator.push(context, route);
    if (result == true) {
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        actions: [
          IconButton(
            onPressed: () => _handleNavigate(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<ExamResult>>(
        future: _examResultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // (การกรองและเรียงลำดับถูกย้ายไปที่ parseExamResults แล้ว)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam results found.'));
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final e = data[index];
                // ================== MODIFICATION START ==================
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    
                    // ⭐️ 1. นำ leading (id) กลับมาแสดง
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        e.id.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    
                    // Use a Column in the title to stack text vertically
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Code: ${e.studentCode}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(e.courseName),
                        Text(
                          'Course: ${e.courseCode}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Points: ${e.point}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    // The onTap is now on the ListTile
                    onTap: () => _handleNavigate(examResult: e),
                    // We no longer need subtitle or trailing
                  ),
                );
                // =================== MODIFICATION END ===================
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ================== API FUNCTIONS (Modified) ==================

/// ฟังก์ชันสำหรับแปลง JSON string ให้เป็น List<ExamResult>
List<ExamResult> parseExamResults(String responseBody) {
  final decoded = jsonDecode(responseBody) as List;
  final list = decoded.map<ExamResult>((json) => ExamResult.fromJson(json)).toList();

  // ⭐️ 2. กรองข้อมูลที่ id ไม่ใช่ 0
  final filteredList = list.where((result) => result.id != 0).toList();

  // ⭐️ 3. จัดเรียงข้อมูลตาม id (น้อยไปมาก)
  filteredList.sort((a, b) => a.id.compareTo(b.id));

  return filteredList;
}

/// ฟังก์ชันสำหรับดึง Base URL ของ API ตาม Platform
String getApiBaseUrl() {
  if (kIsWeb) return 'http://localhost';
  if (Platform.isAndroid) return 'http://10.0.2.2';
  return 'http://localhost'; // Default for others (iOS, etc.)
}

/// ฟังก์ชันสำหรับดึงข้อมูลผลสอบทั้งหมดจาก API
Future<List<ExamResult>> fetchExamResults() async {
  final url = '${getApiBaseUrl()}/pakapol/api/exam_results.php';
  try {
    final response = await http.get(Uri.parse(url));
    // .timeout(const Duration(seconds: 10)); // Removed

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      // compute จะรัน parseExamResults ใน isolate แยก
      return compute(parseExamResults, body);
    } else {
      throw Exception(
        'Failed to load Exam Results (status ${response.statusCode})',
      );
    }
  } catch (e) {
    throw Exception('Error fetching exam results: $e');
  }
}