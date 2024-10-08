import 'package:flutter/material.dart';
import 'login_screen.dart'; // นำเข้าไฟล์ LoginScreen

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LoginScreen(), // ตั้งค่าเริ่มต้นให้เป็นหน้า LoginScreen
    );
  }
}
