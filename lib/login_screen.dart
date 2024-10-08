import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_screen.dart'; // นำเข้าไฟล์ DashboardScreen
import 'register_screen.dart'; // นำเข้าไฟล์ RegisterScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // สถานะสำหรับการโหลดข้อมูล

  // ฟังก์ชันสำหรับการล็อกอิน
  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both username and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // เริ่มโหลด
    });

    var url = Uri.parse(
        'http://10.0.2.2/my_php_backend/login.php'); // URL ของไฟล์ PHP
    var response = await http.post(url, body: {
      'username': username,
      'password': password,
    });

    setState(() {
      _isLoading = false; // หยุดโหลด
    });

    if (response.body.isNotEmpty) {
      try {
        var data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Successful!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(username: username),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Failed: ${data['message']}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No response from the server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF), // สีพื้นหลัง
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF185ADB),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Color(0xFFEFEFEF), // สีไอคอน
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1931), // สีตัวอักษร
              ),
            ),
            const SizedBox(height: 20),
            // Username Input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Color(0xFF0A1931)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),
            // Password Input
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF0A1931)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // Log in Button
            _isLoading
                ? const CircularProgressIndicator() // แสดง Loading Indicator ขณะกำลังโหลด
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185ADB),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(
                        color: Color(0xFFEFEFEF), // สีตัวอักษรปุ่ม
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            const SizedBox(height: 10),
            // Sign in Button -> ไปที่หน้า RegisterScreen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC947), // สีของปุ่ม Sign in
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
              ),
              child: const Text(
                'Sign in',
                style: TextStyle(
                  color: Color(0xFF0A1931), // สีตัวอักษรปุ่ม
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
