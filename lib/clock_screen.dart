import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ClockScreen extends StatefulWidget {
  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  List<Map<String, dynamic>> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2/my_php_backend/get_alarms.php'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      if (jsonData is List) {
        setState(() {
          alarms = List<Map<String, dynamic>>.from(jsonData);
        });
      } else if (jsonData is Map) {
        setState(() {
          alarms = [Map<String, dynamic>.from(jsonData)];
        });
      }
    } else {
      print('Failed to load alarms');
    }
  }

  void _addAlarm() {
    setState(() {
      final newAlarm = {
        'name': 'New Alarm',
        'time': 'XX:XX',
        'enabled': true,
        'days': [],
      };
      alarms.add(newAlarm);
      _saveAlarmToDatabase(newAlarm);
    });
  }

  void _deleteAlarm(int index) async {
    final alarmId = alarms[index]['id'];
    await http.post(
      Uri.parse('http://10.0.2.2/my_php_backend/delete_alarm.php'),
      body: {'id': alarmId.toString()},
    );

    setState(() {
      alarms.removeAt(index);
    });
  }

  void _editAlarm(int index, String name, String time, List<String> days) {
    setState(() {
      alarms[index]['name'] = name;
      alarms[index]['time'] = time;
      alarms[index]['days'] = days;
      _saveAlarmToDatabase(alarms[index]);
    });
  }

  void _saveAlarmToDatabase(Map<String, dynamic> alarm) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2/my_php_backend/save_alarm.php'),
      body: {
        'id': alarm['id']?.toString() ?? '',
        'name': alarm['name'],
        'time': alarm['time'],
        'days': jsonEncode(alarm['days']),
        'enabled': alarm['enabled'] ? '1' : '0',
      },
    );

    if (response.statusCode != 200) {
      print('Failed to save alarm');
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
          'Clock',
          style: TextStyle(color: Color(0xFFEFEFEF)), // สีตัวอักษรแถบด้านบน
        ),
      ),
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        alarms[index]['name'] ?? 'No name provided',
                        style: const TextStyle(
                            color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                      subtitle: Text(
                        'Time: ${alarms[index]['time'] ?? 'No time specified'}\nDays: ${_formatDays(alarms[index]['days']) ?? 'No days specified'}',
                        style: const TextStyle(
                            color: Color(0xFF0A1931)), // สีตัวอักษร
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            activeColor: const Color(
                                0xFF185ADB), // สีของ Switch เมื่อเปิด
                            value: alarms[index]['enabled'] == '1' ||
                                alarms[index]['enabled'] == true,
                            onChanged: (value) {
                              setState(() {
                                alarms[index]['enabled'] = value;
                              });
                              _saveAlarmToDatabase(alarms[index]);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color(0xFFFFC947)), // สีไอคอนลบ
                            onPressed: () {
                              _deleteAlarm(index);
                            },
                          ),
                        ],
                      ),
                      onTap: () async {
                        final editedAlarm = await showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController nameController =
                                TextEditingController(
                                    text: alarms[index]['name']);
                            TextEditingController timeController =
                                TextEditingController(
                                    text: alarms[index]['time']);
                            List<String> selectedDays =
                                alarms[index]['days'] != null &&
                                        alarms[index]['days'] is List
                                    ? List<String>.from(alarms[index]['days'])
                                    : [];
                            List<String> daysOfWeek = [
                              'Sunday',
                              'Monday',
                              'Tuesday',
                              'Wednesday',
                              'Thursday',
                              'Friday',
                              'Saturday'
                            ];

                            return AlertDialog(
                              backgroundColor:
                                  const Color(0xFFEFEFEF), // สีพื้นหลังกล่อง
                              title: const Text(
                                'Edit Alarm',
                                style: TextStyle(
                                    color:
                                        Color(0xFF0A1931)), // สีตัวอักษรหัวข้อ
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Alarm Name',
                                      labelStyle: TextStyle(
                                          color: Color(
                                              0xFF0A1931)), // สีตัวอักษร label
                                    ),
                                  ),
                                  TextField(
                                    controller: timeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Time (HH:MM)',
                                      labelStyle: TextStyle(
                                          color: Color(
                                              0xFF0A1931)), // สีตัวอักษร label
                                    ),
                                    onTap: () async {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (pickedTime != null) {
                                        timeController.text =
                                            pickedTime.format(context);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Select Days',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0A1931), // สีตัวอักษร
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8.0,
                                    children: daysOfWeek.map((day) {
                                      return ChoiceChip(
                                        avatar: selectedDays.contains(day)
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.black,
                                              )
                                            : null,
                                        label: Text(day),
                                        selected: selectedDays.contains(day),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedDays.add(day);
                                            } else {
                                              selectedDays.remove(day);
                                            }
                                          });
                                        },
                                        selectedColor: const Color(
                                            0xFF185ADB), // สีพื้นหลังเมื่อถูกเลือก
                                        backgroundColor: Colors.grey[
                                            200], // สีพื้นหลังเมื่อไม่ถูกเลือก
                                        labelStyle: TextStyle(
                                          color: selectedDays.contains(day)
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, null);
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Color(
                                            0xFF0A1931)), // สีตัวอักษรปุ่ม
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                      context,
                                      {
                                        'name': nameController.text,
                                        'time': timeController.text,
                                        'days': selectedDays,
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(
                                        color: Color(
                                            0xFF185ADB)), // สีตัวอักษรปุ่ม
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (editedAlarm != null) {
                          _editAlarm(index, editedAlarm['name'],
                              editedAlarm['time'], editedAlarm['days']);
                        }
                      },
                      onLongPress: () => _deleteAlarm(index),
                    ),
                  );
                },
              ),
            ),
            FloatingActionButton(
              backgroundColor: const Color(0xFF185ADB), // สีปุ่มเพิ่ม
              onPressed: _addAlarm,
              child: const Icon(
                Icons.add,
                color: Color(0xFFFFC947), // สีไอคอนบวก
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDays(dynamic days) {
    if (days == null || days.isEmpty) {
      return 'No days specified';
    }
    return days is List ? days.join(', ') : days.toString();
  }
}
