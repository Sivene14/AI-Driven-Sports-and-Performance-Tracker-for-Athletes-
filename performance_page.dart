import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController jumpController = TextEditingController();
  final TextEditingController sprintController = TextEditingController();
  final TextEditingController trainingController = TextEditingController();

  Map<String, dynamic>? feedback;
  Uint8List? chartBytes;

  double _minY(List<FlSpot> spots, double padding) {
    final min = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    return (min - padding).clamp(0, double.infinity);
  }

  double _maxY(List<FlSpot> spots, double padding) {
    final max = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return max + padding;
  }

  Future<Map<String, dynamic>?> _callApi(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("https://intervalic-trey-photometrically.ngrok-free.dev/compare"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "height": data["height"],
          "weight": data["weight"],
          "sprint": data["sprint_speed"],
          "jump": data["vertical_jump_height"],
          "hours": data["training_hours_per_week"],
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          feedback = result["feedback"];
          chartBytes = base64Decode(result["chart"]);
        });
        return result;
      } else {
        throw Exception("API error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("API call failed: $e")),
      );
      return null;
    }
  }

  Future<void> _savePerformance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final data = {
      "height": double.tryParse(heightController.text) ?? 0,
      "weight": double.tryParse(weightController.text) ?? 0,
      "vertical_jump_height": double.tryParse(jumpController.text) ?? 0,
      "sprint_speed": double.tryParse(sprintController.text) ?? 0,
      "training_hours_per_week": double.tryParse(trainingController.text) ?? 0,
      "timestamp": DateTime.now(),
    };

    final apiResult = await _callApi(data);

    await FirebaseFirestore.instance
        .collection("performance")
        .doc(uid)
        .collection("entries")
        .add({...data, "feedback": apiResult?["feedback"]});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Performance data saved & analyzed")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Performance Tracker",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildField(heightController, "Height (cm)", Icons.height),
            _buildField(weightController, "Weight (kg)", Icons.monitor_weight),
            _buildField(jumpController, "Vertical Jump (cm)", Icons.sports_kabaddi),
            _buildField(sprintController, "Sprint Speed (m/s)", Icons.speed),
            _buildField(trainingController, "Training Hours / Week", Icons.timer),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _savePerformance,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Save & Compare",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Performance Trends",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            if (uid != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("performance")
                    .doc(uid)
                    .collection("entries")
                    .orderBy("timestamp")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Text("No data yet.");

                  List<DateTime> timestamps = docs
                      .map((d) => (d["timestamp"] as Timestamp).toDate())
                      .toList();

                  List<FlSpot> spots(String key) => List.generate(
                        docs.length,
                        (i) => FlSpot(i.toDouble(), (docs[i][key] ?? 0).toDouble()),
                      );

                  Widget chart(String title, List<FlSpot> s, Color color, String yLabel,
                      double maxY, List<DateTime> dates,
                      {double minY = 0}) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),
                        Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        SizedBox(
                          height: 250,
                          child: LineChart(
                            LineChartData(
                              minY: minY,
                              maxY: maxY,
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  axisNameWidget: Text(
                                    yLabel,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: (maxY - minY) / 5,
                                    getTitlesWidget: (value, _) => Text(
                                      value.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  axisNameWidget: const Text(
                                    "Date",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, _) {
                                      int i = value.toInt();
                                      if (i >= 0 && i < dates.length) {
                                        final d = dates[i];
                                        return RotatedBox(
                                          quarterTurns: 1,
                                          child: Text("${d.month}/${d.day}",
                                              style: const TextStyle(fontSize: 10)),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: s,
                                  isCurved: true,
                                  color: color,
                                  barWidth: 4,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: color.withOpacity(0.25),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final heightSpots = spots("height");
                  final weightSpots = spots("weight");

                  return Column(
                    children: [
                      chart("Sprint Speed", spots("sprint_speed"), Colors.blueAccent, "m/s", 15, timestamps),
                      chart("Vertical Jump", spots("vertical_jump_height"), Colors.green, "cm", 100, timestamps),
                      chart("Height", heightSpots, Colors.orange, "cm", _maxY(heightSpots, 5), timestamps, minY: _minY(heightSpots, 5)),
                      chart("Weight", weightSpots, Colors.red, "kg", _maxY(weightSpots, 3), timestamps, minY: _minY(weightSpots, 3)),
                      chart("Training Hours", spots("training_hours_per_week"), Colors.purple, "hrs", 100, timestamps),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.blueAccent),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
