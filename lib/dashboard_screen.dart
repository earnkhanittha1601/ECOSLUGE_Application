import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart'; // นำเข้าหน้า LoginScreen
import 'project_screen.dart'; // นำเข้าหน้า ProjectScreen
import 'package:intl/intl.dart'; // ใช้สำหรับจัดรูปแบบวันที่

class DashboardScreen extends StatefulWidget {
  final String username;

  const DashboardScreen({super.key, required this.username});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<String> projects = [];
  String currentDate =
      DateFormat('dd/MM/yyyy').format(DateTime.now()); // วันที่ปัจจุบัน

  @override
  void initState() {
    super.initState();
    _fetchProjects(); // ดึงรายการโปรเจคเมื่อเริ่มต้นหน้าจอ
  }

  Future<void> _fetchProjects() async {
    var url = Uri.parse('http://10.0.2.2/my_php_backend/fetch_projects.php');
    var response = await http.post(url, body: {
      'username': widget.username,
    });

    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          projects =
              List<String>.from(data['projects']); // ดึงรายการโปรเจคมาแสดง
        });
      }
    }
  }

  Future<void> _createProject() async {
    TextEditingController projectNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Project Name"),
          content: TextField(
            controller: projectNameController,
            decoration: InputDecoration(hintText: "Project Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String projectName = projectNameController.text;
                if (projectName.isNotEmpty) {
                  var url = Uri.parse(
                      'http://10.0.2.2/my_php_backend/create_project.php');
                  var response = await http.post(url, body: {
                    'username': widget.username,
                    'project_name': projectName,
                  });

                  var data = json.decode(response.body);
                  if (data['success']) {
                    setState(() {
                      projects.add(projectName); // เพิ่มโปรเจคในรายการ
                    });
                  }
                }
                Navigator.of(context).pop(); // ปิด Dialog หลังจากสร้างโปรเจค
              },
              child: Text("Create"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProject(String oldProjectName) async {
    TextEditingController projectNameController =
        TextEditingController(text: oldProjectName);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Project Name"),
          content: TextField(
            controller: projectNameController,
            decoration: InputDecoration(hintText: "New Project Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String newProjectName = projectNameController.text;
                if (newProjectName.isNotEmpty &&
                    newProjectName != oldProjectName) {
                  var url = Uri.parse(
                      'http://10.0.2.2/my_php_backend/edit_project.php');
                  var response = await http.post(url, body: {
                    'username': widget.username,
                    'old_project_name': oldProjectName,
                    'new_project_name': newProjectName,
                  });

                  var data = json.decode(response.body);
                  if (data['success']) {
                    setState(() {
                      int index = projects.indexOf(oldProjectName);
                      projects[index] =
                          newProjectName; // แก้ไขชื่อโปรเจคในรายการ
                    });
                  }
                }
                Navigator.of(context).pop(); // ปิด Dialog หลังจากแก้ไขโปรเจค
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProject(String projectName) async {
    var url = Uri.parse('http://10.0.2.2/my_php_backend/delete_project.php');
    var response = await http.post(url, body: {
      'username': widget.username,
      'project_name': projectName,
    });

    var data = json.decode(response.body);
    if (data['success']) {
      setState(() {
        projects.remove(projectName); // ลบโปรเจคออกจากรายการในแอป
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project and table deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete project: ${data['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.only(top: 60.0), // ขยับด้านบนลงมา
        child: Column(
          children: [
            // ส่วนโปรไฟล์ผู้ใช้
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0, vertical: 20.0), // ลด Padding ด้านบน
              decoration: BoxDecoration(
                color: const Color(0xFF0A1931), // เพิ่มแถบด้านบน
                borderRadius: BorderRadius.circular(0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF185ADB),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFFEFEFEF), // สีไอคอนโปรไฟล์
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, ${widget.username}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEFEFEF), // สีตัวอักษร
                        ),
                      ),
                      Text(
                        currentDate, // แสดงวันที่ปัจจุบัน
                        style: const TextStyle(color: Color(0xFFEFEFEF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // เพิ่มช่องว่างระหว่างแถบและเนื้อหา
            // แสดงรายการโปรเจคที่ดึงมาจากฐานข้อมูล
            Expanded(
              child: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  String projectName = projects[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        projectName,
                        style: const TextStyle(
                          color: Color(0xFF0A1931), // สีตัวอักษรชื่อโปรเจค
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF185ADB)),
                            onPressed: () {
                              _editProject(
                                  projectName); // เรียกฟังก์ชันแก้ไขโปรเจค
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFFFFC947)),
                            onPressed: () {
                              _deleteProject(
                                  projectName); // เรียกฟังก์ชันลบโปรเจค
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // การนำทางไปยัง ProjectScreen พร้อมส่งชื่อโปรเจคและ username
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProjectScreen(
                              username: widget.username,
                              projectName: projectName, // ชื่อโปรเจคที่ถูกเลือก
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // ปุ่มสร้างโปรเจคใหม่
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: GestureDetector(
                  onTap: _createProject,
                  child: Container(
                    width: 80, // ลดขนาดปุ่ม
                    height: 80, // ลดขนาดปุ่ม
                    decoration: BoxDecoration(
                      color: const Color(0xFF185ADB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        size: 30, // ลดขนาดไอคอนบวก
                        color: Color(0xFFFFC947), // สีไอคอนปุ่มเพิ่มโปรเจค
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ปุ่มออกจากระบบ
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF0A1931)),
                  onPressed: () {
                    // ฟังก์ชันออกจากระบบ
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
