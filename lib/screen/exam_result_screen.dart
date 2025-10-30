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
    String? _selectedCourse; // ✅ เก็บชื่อหรือรหัสวิชาที่เลือก

    @override
    void initState() {
      super.initState();
      _examResultsFuture = fetchExamResults();
    }

    void _refreshData() {
      setState(() {
        _examResultsFuture = fetchExamResults();
        _selectedCourse = null;
      });
    }

    Future<void> _handleNavigate({ExamResult? examResult}) async {
      final route = MaterialPageRoute(
        builder: (context) => examResult == null
            ? const AddExamResultScreen()
            : EditExamResultScreen(examResult: examResult),
      );
      final result = await Navigator.push(context, route);
      if (result == true) _refreshData();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exam Results'),
          actions: [
            IconButton(onPressed: () => _handleNavigate(), icon: const Icon(Icons.add)),
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
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No exam results found.'));
            }

            final data = snapshot.data!;
            final groupedData = groupByCourse(data);
            final courseList = groupedData.entries
                .map((e) => '${e.value.first.courseName} ${e.key}')
                .toList();

            // ✅ ฟิลเตอร์ข้อมูลตามวิชาที่เลือก
            final filteredData = _selectedCourse == null
                ? groupedData
                : groupedData
                    .map((code, list) {
                      final displayName = '${list.first.courseName} $code';
                      if (displayName == _selectedCourse) {
                        return MapEntry(code, list);
                      } else {
                        return MapEntry(code, []);
                      }
                    })
                    ..removeWhere((k, v) => v.isEmpty);

            return Column(
              children: [
                // ✅ Dropdown เลือกวิชา
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'เลือกวิชา',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    items: courseList.map((courseName) {
                      return DropdownMenuItem(
                        value: courseName,
                        child: Text(courseName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value;
                      });
                    },
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _refreshData(),
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final courseCode = filteredData.keys.elementAt(index);
                        final resultsForCourse = filteredData[courseCode]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '${resultsForCourse.first.courseName} ($courseCode)',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: resultsForCourse.length,
                              itemBuilder: (context, idx) {
                                final e = resultsForCourse[idx];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(e.id.toString()),
                                    ),
                                    title: Text(e.studentName),
                                    subtitle: Text('Code: ${e.studentCode}\nPoints: ${e.point}'),
                                    onTap: () => _handleNavigate(examResult: e),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
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

    // ✅ จัดกลุ่มตามรหัสวิชา
    Map<String, List<ExamResult>> groupByCourse(List<ExamResult> examResults) {
      final Map<String, List<ExamResult>> groupedResults = {};
      for (var result in examResults) {
        groupedResults.putIfAbsent(result.courseCode, () => []);
        groupedResults[result.courseCode]!.add(result);
      }
      return groupedResults;
    }
  }

  // ================== API ==================

  List<ExamResult> parseExamResults(String responseBody) {
    final decoded = jsonDecode(responseBody) as List;
    final list = decoded.map<ExamResult>((json) => ExamResult.fromJson(json)).toList();
    final filteredList = list.where((result) => result.id != 0).toList();
    filteredList.sort((a, b) => a.id.compareTo(b.id));
    return filteredList;
  }

  String getApiBaseUrl() {
    if (kIsWeb) return 'http://localhost';
    if (Platform.isAndroid) return 'http://10.0.2.2';
    return 'http://localhost';
  }

  Future<List<ExamResult>> fetchExamResults() async {
    final url = '${getApiBaseUrl()}/pakapol/api/exam_results.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes);
      return compute(parseExamResults, body);
    } else {
      throw Exception('Failed to load Exam Results (${response.statusCode})');
    }
  }
