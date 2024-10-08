import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // นำเข้า fl_chart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class GraphScreen extends StatefulWidget {
  final String projectName;

  GraphScreen({required this.projectName});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<FlSpot> graphData = [];
  List<Map<String, dynamic>> summaryData = [];
  List<DateTime> dateLabels = []; // สร้าง list สำหรับเก็บวันที่ทั้งหมด

  @override
  void initState() {
    super.initState();
    _fetchGraphData(); // ดึงข้อมูลเมื่อเปิดหน้า
  }

  Future<void> _fetchGraphData() async {
    var url = Uri.parse('http://10.0.2.2/my_php_backend/fetch_graph_data.php');
    var response = await http.post(url, body: {
      'project_name': widget.projectName,
    });

    print(response.body); // พิมพ์เนื้อหาการตอบกลับจากเซิร์ฟเวอร์

    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body); // พยายามแปลง JSON

        if (data is Map<String, dynamic> && data['success'] == true) {
          setState(() {
            // แสดงข้อมูล graph
            graphData = (data['summary'] as List)
                .map((item) => FlSpot(
                      DateTime.parse(item['date'])
                          .millisecondsSinceEpoch
                          .toDouble(),
                      double.parse(item['value']),
                    ))
                .toList();

            // สร้างวันที่ทั้งหมดที่อยู่ในช่วงข้อมูล graphData
            DateTime startDate =
                DateTime.fromMillisecondsSinceEpoch(graphData.first.x.toInt());
            DateTime endDate =
                DateTime.fromMillisecondsSinceEpoch(graphData.last.x.toInt());

            dateLabels = [];
            for (DateTime date = startDate;
                date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
                date = date.add(Duration(days: 1))) {
              dateLabels.add(date);
            }

            // แสดงข้อมูลสรุป
            summaryData = List<Map<String, dynamic>>.from(data['summary']);
          });
        } else {
          print('Error: No graph data available');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: No graph data available')),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response data: $e')),
        );
      }
    } else {
      print('Server error: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  Future<void> _deleteData(int id) async {
    var url = Uri.parse('http://10.0.2.2/my_php_backend/delete_data.php');
    var response = await http.post(url, body: {
      'id': id.toString(),
      'project_name': widget.projectName, // ต้องส่งค่า project_name ด้วย
    });

    if (response.statusCode == 200) {
      try {
        var data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            // ลบข้อมูลออกจาก summaryData และ graphData เพื่ออัปเดต UI
            summaryData.removeWhere((item) => int.parse(item['id']) == id);
            graphData.removeWhere((spot) => spot.x == id.toDouble());
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } catch (e) {
        print('Error parsing JSON: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response data: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1931), // สีแถบด้านบน
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFFFFC947)), // สีไอคอนย้อนกลับ
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Graph',
          style: TextStyle(color: Color(0xFFEFEFEF)), // สีตัวอักษรแถบด้านบน
        ),
      ),
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Project: ${widget.projectName}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1931), // สีตัวอักษร
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Value',
                style: TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
              ),
              SizedBox(
                height: 300,
                child: graphData.isEmpty
                    ? const Center(
                        child: Text(
                          'No data available',
                          style:
                              TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
                        ),
                      )
                    : LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: graphData,
                              isCurved: true,
                              color: const Color(0xFF185ADB), // สีเส้นกราฟ
                              barWidth: 4,
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  DateTime date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          value.toInt());
                                  if (dateLabels
                                      .any((d) => d.isAtSameMomentAs(date))) {
                                    return Text(
                                      DateFormat('dd/MM').format(date),
                                      style: const TextStyle(
                                          color:
                                              Color(0xFF0A1931)), // สีตัวอักษร
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toString(),
                                  style: const TextStyle(
                                      color: Color(0xFF0A1931)), // สีตัวอักษร
                                ),
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                          ),
                          minX: graphData.isNotEmpty ? graphData.first.x : 0,
                          maxX: graphData.isNotEmpty ? graphData.last.x : 1,
                          minY: 0,
                          maxY: graphData.isNotEmpty
                              ? graphData
                                      .map((e) => e.y)
                                      .reduce((a, b) => a > b ? a : b) +
                                  1
                              : 1,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Text(
                'Summary',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1931), // สีตัวอักษร
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Date',
                        style:
                            TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Value',
                        style:
                            TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Description',
                        style:
                            TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delete',
                        style:
                            TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                    ),
                  ],
                  rows: summaryData
                      .map(
                        (item) => DataRow(cells: [
                          DataCell(Text(
                            item['date'],
                            style: const TextStyle(
                                color: Color(0xFF0A1931)), // สีตัวอักษร
                          )),
                          DataCell(Text(
                            item['value'].toString(),
                            style: const TextStyle(
                                color: Color(0xFF0A1931)), // สีตัวอักษร
                          )),
                          DataCell(Text(
                            item['description'],
                            style: const TextStyle(
                                color: Color(0xFF0A1931)), // สีตัวอักษร
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFFFFC947)), // สีไอคอนลบ
                            onPressed: () {
                              _deleteData(int.parse(item['id']));
                            },
                          )),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
