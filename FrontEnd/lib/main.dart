import 'package:flutter/material.dart';
import 'package:food_recomm/UploadPage.dart';
import 'package:food_recomm/LoginPage.dart';
import 'package:food_recomm/RecommendDialog.dart';
import 'package:food_recomm/MyPage.dart';
import 'package:food_recomm/MainPage.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:food_recomm/style.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: MyTheme,
    home: const StartGate(),
    locale: const Locale('ko','KR'),
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('ko', 'KR'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  ));
}

class StartGate extends StatefulWidget {
  const StartGate({super.key});

  @override
  State<StartGate> createState() => _StartGateState();
}

class _StartGateState extends State<StartGate> {
  final storage = const FlutterSecureStorage();
  //final test_id = "aaa";
  //final test_pw = "1234";
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final id = await storage.read(key: 'id');
    final pw = await storage.read(key: 'pw');
    //final id = test_id;
    //final pw = test_pw;

    if (id == null || pw == null) {
      _moveToLogin();
      return;
    }
    try {
      final dio = Dio();
      final response = await dio.post(
        'http://localhost:8080/api/user/login',
        data: {'name': id, 'password': pw},
      );
      print('[AUTH] call /api/user/login');
      if (response.statusCode == 200) {
        print(200);
        final int uid = response.data['id'];
        _moveToMain(uid);
      } else {
        print("err");
        _moveToLogin();
      }
    } catch (e) {
      print("catchE");
      _moveToLogin();
    }
  }

  void _moveToMain(uid) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyApp(uid: uid)),
    );
  }
  void _moveToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
