import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // ฟังก์ชันสำหรับการลงทะเบียน
  Future<void> _register() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      var url = Uri.parse(
          'http://10.0.2.2/my_php_backend/register.php'); // URL ของไฟล์ PHP
      var response = await http.post(url, body: {
        'username': username,
        'password': password,
      });

      var data = json.decode(response.body);
      if (data['success']) {
        // การลงทะเบียนสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Successful!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${data['message']}')),
        );
      }
    } else {
      // รหัสผ่านไม่ตรงกัน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
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
          'Sign in',
          style: TextStyle(color: Color(0xFFEFEFEF)), // สีตัวอักษรแถบด้านบน
        ),
      ),
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    labelStyle:
                        TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร label
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle:
                        TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร label
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle:
                        TextStyle(color: Color(0xFF0A1931)), // สีตัวอักษร label
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185ADB), // สีปุ่ม
                    foregroundColor: const Color(0xFFFFC947), // สีตัวอักษรปุ่ม
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
