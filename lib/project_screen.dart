import 'package:flutter/material.dart';
import 'save_data_screen.dart'; // เพิ่ม import สำหรับ SaveDataScreen
import 'graph_screen.dart'; // เพิ่ม import สำหรับ GraphScreen
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'clock_screen.dart'; // เพิ่ม import สำหรับ ClockScreen
import 'package:url_launcher/url_launcher.dart'; // เพิ่ม import สำหรับ url_launcher

class ProjectScreen extends StatelessWidget {
  final String username;
  final String projectName;

  const ProjectScreen(
      {super.key, required this.username, required this.projectName});

  Future<void> _downloadFile(BuildContext context) async {
    var url = Uri.parse('http://10.0.2.2/my_php_backend/export_to_excel.php');
    var response = await http.post(
      url,
      body: {'project_name': projectName},
    );

    if (response.statusCode == 200) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final filePath = '${directory.path}/data_export_$projectName.xls';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get storage directory')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to download file: ${response.statusCode}')),
      );
    }
  }

  Future<void> _openChatGpt(BuildContext context) async {
    final url = Uri.parse('https://chatgpt.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1931),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFC947)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Project',
          style: TextStyle(color: Color(0xFFEFEFEF)),
        ),
      ),
      backgroundColor: Color(0xFFEFEFEF),
      body: Column(
        children: [
          // ส่วนแสดงโปรไฟล์และโปรเจค
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF185ADB),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Color(0xFFEFEFEF),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $username',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1931),
                      ),
                    ),
                    Text(
                      'Project: $projectName',
                      style: TextStyle(color: Color(0xFF0A1931)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ปุ่มต่างๆ ของโปรเจค
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: [
                _buildProjectButton(
                  context,
                  'Save data',
                  Icons.save,
                  Color(0xFF185ADB),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaveDataScreen(
                          username: username,
                          projectName: projectName,
                        ),
                      ),
                    );
                  },
                ),
                _buildProjectButton(
                  context,
                  'Graph',
                  Icons.show_chart,
                  Color(0xFF185ADB),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GraphScreen(
                          projectName: projectName,
                        ),
                      ),
                    );
                  },
                ),
                _buildProjectButton(
                  context,
                  'Download',
                  Icons.download,
                  Color(0xFF185ADB),
                  () {
                    _downloadFile(context);
                  },
                ),
                _buildProjectButton(
                  context,
                  'Clock',
                  Icons.timer,
                  Color(0xFF185ADB),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClockScreen(),
                      ),
                    );
                  },
                ),
                _buildProjectButton(
                  context,
                  'Chat GPT',
                  Icons.chat,
                  Color(0xFF185ADB),
                  () {
                    _openChatGpt(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectButton(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Color(0xFFEFEFEF),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(color: Color(0xFF0A1931)),
            ),
          ],
        ),
      ),
    );
  }
}
