import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class GradeBarChart extends StatefulWidget {
  final bool isTeacher;
  final String teacherId;

  const GradeBarChart({
    super.key,
    required this.isTeacher,
    required this.teacherId,
  });

  @override
  State<GradeBarChart> createState() => _GradeBarChartState();
}

class _GradeBarChartState extends State<GradeBarChart> {
  int g5PreInd = 0, g5PreInst = 0, g5PreFrus = 0;
  int g5PostInd = 0, g5PostInst = 0, g5PostFrus = 0;
  int g6PreInd = 0, g6PreInst = 0, g6PreFrus = 0;
  int g6PostInd = 0, g6PostInst = 0, g6PostFrus = 0;

  final GlobalKey _chartKey5 = GlobalKey();
  final GlobalKey _chartKey6 = GlobalKey();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final students = await FirebaseFirestore.instance
          .collection('Students')
          .where('teacherId', isEqualTo: widget.teacherId)
          .get();

      if (students.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      List<Future<void>> fetches = [];

      for (var student in students.docs) {
        final grade = student.data()['gradeLevel']?.toString().trim();
        final studentId = student.id;

        if (grade == "5" || grade == "6") {
          final fetchPerformance = FirebaseFirestore.instance
              .collection('StudentPerformance')
              .where('studentId', isEqualTo: studentId)
              .get()
              .then((performances) {
            for (var doc in performances.docs) {
              final typeRaw = doc.data()['type'];
              final profileRaw = doc.data()['oralReadingProfile'];
              if (typeRaw == null || profileRaw == null) continue;
              final type = typeRaw.toString().toLowerCase().trim();
              final profile = profileRaw.toString().trim();

              if (grade == "5") {
                if (type == "pretest") _inc(profile, true, true);
                if (type == "post test" || type == "posttest") _inc(profile, true, false);
              } else if (grade == "6") {
                if (type == "pretest") _inc(profile, false, true);
                if (type == "post test" || type == "posttest") _inc(profile, false, false);
              }
            }
          });

          fetches.add(fetchPerformance);
        }
      }

      if (fetches.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      await Future.wait(fetches);
    } catch (e) {
      print("Error while fetching data: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _inc(String profile, bool g5, bool pre) {
    final profileLower = profile.toLowerCase();
    if (profileLower == "independent") {
      g5 ? (pre ? g5PreInd++ : g5PostInd++) : (pre ? g6PreInd++ : g6PostInd++);
    } else if (profileLower == "instructional") {
      g5 ? (pre ? g5PreInst++ : g5PostInst++) : (pre ? g6PreInst++ : g6PostInst++);
    } else if (profileLower == "frustration") {
      g5 ? (pre ? g5PreFrus++ : g5PostFrus++) : (pre ? g6PreFrus++ : g6PostFrus++);
    }
  }

  double _percentage(int value, int total) {
    if (total == 0) return 0;
    return (value / total * 100);
  }

  List<BarChartGroupData> _buildGroupedData(List<double> pre, List<double> post) {
    return List.generate(3, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: pre[i],
            color: Colors.amber,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: post[i],
            color: Colors.deepOrangeAccent,
            width: 10,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        barsSpace: 6,
      );
    });
  }

  Widget _buildChart(String grade, List<int> pre, List<int> post, GlobalKey chartKey) {
    final totalPre = pre.isEmpty ? 0 : pre.fold(0, (a, b) => a + b);
    final totalPost = post.isEmpty ? 0 : post.fold(0, (a, b) => a + b);

    final prePercent = pre.map((e) => _percentage(e, totalPre)).toList();
    final postPercent = post.map((e) => _percentage(e, totalPost)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          key: chartKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "Grade $grade Oral Reading Profiles",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 280,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: _buildGroupedData(prePercent, postPercent),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Independent', style: TextStyle(color: Colors.white, fontSize: 10));
                              case 1:
                                return const Text('Instructional', style: TextStyle(color: Colors.white, fontSize: 10));
                              case 2:
                                return const Text('Frustration', style: TextStyle(color: Colors.white, fontSize: 10));
                              default:
                                return const Text('');
                            }
                          },
                          reservedSize: 42,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, _) => Text('${value.toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem('${rod.toY.toStringAsFixed(1)}%', const TextStyle(color: Colors.white));
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Legend inside RepaintBoundary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendItem(Colors.amber, "Pretest"),
                    const SizedBox(width: 24),
                    _legendItem(Colors.deepOrangeAccent, "Posttest"),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (widget.isTeacher)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text("Save as PDF", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _exportChartToPDF(chartKey, "Grade $grade Chart"),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _exportChartToPDF(GlobalKey chartKey, String title) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await WidgetsBinding.instance.endOfFrame;

      final context = chartKey.currentContext;
      if (context == null) {
        print("Chart context is null.");
        return;
      }
      final boundary = context.findRenderObject();
      if (boundary == null || boundary is! RenderRepaintBoundary) {
        print("RenderRepaintBoundary not found.");
        return;
      }

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print("Failed to get byte data from image.");
        return;
      }
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Image(pw.MemoryImage(pngBytes)),
            ],
          ),
        ),
      );

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e) {
      print("Error exporting chart to PDF: $e");
    }
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildChart("5", [g5PreInd, g5PreInst, g5PreFrus], [g5PostInd, g5PostInst, g5PostFrus], _chartKey5),
                _buildChart("6", [g6PreInd, g6PreInst, g6PreFrus], [g6PostInd, g6PostInst, g6PostFrus], _chartKey6),
              ],
            ),
          );
  }
}
