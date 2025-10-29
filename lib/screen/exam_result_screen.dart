import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab7_101/screen/add_exam_result_screen.dart';
import 'package:lab7_101/screen/edit_exam_result_screen.dart';

// Model
import '../model/exam_result.dart';
// Screens
class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key});
  static const routeName = '/';

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  late Future<List<ExamResult>> examResults;

  @override
  void initState() {
    super.initState();
    examResults = fetchExamResults();
  }

  void _refreshData() {
    setState(() {
      examResults = fetchExamResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddExamResultScreen(),
                ),
              );
              if (added == true) _refreshData();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ExamResult>>(
        future: examResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No exam results found.'));
          }

          final results = snapshot.data!;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal.withOpacity(0.1),
                child: Center(
                  child: Text(
                    'Total ${results.length} items',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return ListTile(
                      title: Text(result.studentName),
                      subtitle: Text(
                          'Code: ${result.studentCode} - Points: ${result.point.toStringAsFixed(1)}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditExamResultScreen(
                                    examResult: result,
                                  ),
                                ),
                              );
                              if (updated == true) _refreshData();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: Text(
                                      'Do you want to delete result for ${result.studentName}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        try {
                                          int statusCode =
                                              await deleteExamResult(result);
                                          Navigator.pop(context);
                                          if (statusCode == 200) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Delete successful!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            _refreshData();
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Delete failed. Status Code: $statusCode'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          debugPrint('Error during delete: $e');
                                          Navigator.pop(context);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// ---------------- API Functions ----------------
Future<List<ExamResult>> fetchExamResults() async {
  final response = await http.get(
    Uri.parse('http://192.168.56.1/pakapol/api/exam_result.php'),
  );

  if (response.statusCode == 200) {
    return compute(parseExamResults, response.body);
  } else {
    throw Exception(
        'Failed to load exam results (status ${response.statusCode})');
  }
}

List<ExamResult> parseExamResults(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ExamResult>((json) => ExamResult.fromJson(json)).toList();
}

Future<int> deleteExamResult(ExamResult result) async {
  try {
    final response = await http.delete(
      Uri.parse(
          'http://192.168.56.1/pakapol/api/exam_result.php?student_code=${result.studentCode}'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    return response.statusCode;
  } catch (e) {
    debugPrint('Error during http.delete: $e');
    return 0;
  }
} 