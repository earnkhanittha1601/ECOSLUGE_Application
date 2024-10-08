import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SaveDataScreen extends StatefulWidget {
  final String username;
  final String projectName;

  const SaveDataScreen(
      {super.key, required this.username, required this.projectName});

  @override
  _SaveDataScreenState createState() => _SaveDataScreenState();
}

class _SaveDataScreenState extends State<SaveDataScreen> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  // ฟังก์ชันสำหรับยืนยันและบันทึกข้อมูล
  Future<void> _confirmAndSaveData() async {
    // ข้อมูลที่ต้องการแสดงใน Dialog
    String value = _valueController.text;
    String description = _descriptionController.text;
    String date =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    // แสดง Dialog เพื่อยืนยันข้อมูลก่อนบันทึก
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Date: $date"),
              SizedBox(height: 10),
              Text("Project: ${widget.projectName}"),
              SizedBox(height: 10),
              Text("Value: $value"),
              SizedBox(height: 10),
              Text("Description: $description"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // ไม่ยืนยันการบันทึก
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // ยืนยันการบันทึก
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );

    // ถ้ายืนยันการบันทึก ให้ทำการบันทึกข้อมูล
    if (confirm == true) {
      _saveData();
    }
  }

  Future<void> _saveData() async {
    String value = _valueController.text;
    String description = _descriptionController.text;
    String date =
        "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";

    var url = Uri.parse('http://10.0.2.2/my_php_backend/save_data.php');
    var response = await http.post(url, body: {
      'username': widget.username,
      'project_name': widget.projectName,
      'value': value,
      'description': description,
      'date': date,
    });

    if (response.statusCode == 200) {
      print(response.body); // ตรวจสอบเนื้อหา response

      try {
        var data = json.decode(response.body);

        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save data: ${data['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing JSON: $e')),
        );
        print('Error decoding JSON: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  // ฟังก์ชันสำหรับเลือกวันที่
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
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
          'Save data',
          style: TextStyle(color: Color(0xFFEFEFEF)), // สีตัวอักษรแถบด้านบน
        ),
      ),
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(
                    color: Color(0xFF0A1931), // สีตัวอักษร
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF185ADB), // สีปุ่มเลือกวันที่
                    foregroundColor:
                        const Color(0xFFEFEFEF), // สีตัวอักษรปุ่มเลือกวันที่
                  ),
                  child: const Text('Select date'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Project: ${widget.projectName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1931), // สีตัวอักษร
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Name',
              style: TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
            ),
            TextField(
              enabled: false,
              controller: TextEditingController(text: widget.username),
              decoration: InputDecoration(
                fillColor: Colors.grey[300],
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF185ADB)), // สีขอบ
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Value',
              style: TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
            ),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Value',
                labelStyle:
                    TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร label
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
                labelStyle:
                    TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร label
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _confirmAndSaveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185ADB), // สีปุ่มบันทึก
                  foregroundColor:
                      const Color(0xFFEFEFEF), // สีตัวอักษรปุ่มบันทึก
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
