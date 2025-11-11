import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:food_recomm/SignUpPage.dart';
import 'package:food_recomm/MainPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  static const String _loginEndpoint = 'http://localhost:8080/api/user/login';

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final id = _idController.text.trim();
    final pw = _pwController.text.trim();

    if (id.isEmpty || pw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID와 비밀번호를 모두 입력하세요.')),
      );
      return;
    }

    final dio = Dio(
      BaseOptions(
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    try {
      final response = await dio.post(
        _loginEndpoint,
        data: {'name': id, 'password': pw},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
        final uid = response.data['id'];
         Navigator.pushReplacement(
             context,
             MaterialPageRoute(builder: (_) => MyApp(uid: uid)));
      } else {
        String msg = '로그인 실패: 알 수 없는 오류';
        final data = response.data;
        if (data is Map && data['message'] is String) {
          msg = '로그인 실패: ${data['message']}';
        } else if (response.statusCode != null) {
          msg = '아이디 혹은 비밀번호 오류';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on DioException catch (e) {
      String msg = '네트워크 오류';
      if (e.response != null) {
        msg = '서버 응답 오류: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        msg = '연결 시간 초과';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        msg = '서버 응답 지연';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예상치 못한 오류: $e')));
    }
  } // ← _login() 여기서 끝!

  void _signup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ID 입력
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // 비밀번호 입력
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),

            // 로그인 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('로그인'),
              ),
            ),
            const SizedBox(height: 12),

            // 회원가입 버튼
            TextButton(
              onPressed: _signup,
              child: const Text(
                '회원가입',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
