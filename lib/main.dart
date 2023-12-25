import 'package:PresensiPro/login-page.dart';
import 'package:flutter/material.dart';
import 'package:change_app_package_name/change_app_package_name.dart';
// import 'package:PresensiPro/home-page.dart';
// import 'package:PresensiPro/login-page.dart';
// import 'package:PresensiPro/simpan-page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}