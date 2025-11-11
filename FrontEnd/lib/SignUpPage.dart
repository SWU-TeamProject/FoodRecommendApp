import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 기존 컨트롤러/상태를 그대로 둔다는 가정
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController(); // cm
  final TextEditingController _weightCtrl = TextEditingController(); // kg

  String? _gender; // 'M' or 'F'
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8080', // 예: http://192.168.0.10:8080
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'Content-Type': 'application/json'},
  ));

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _toast('성별을 선택해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final body = {
        'name': _idCtrl.text.trim(),
        'password': _pwCtrl.text, // 최소길이 요구 없음
        'height': double.parse(_heightCtrl.text.trim()),
        'weight': double.parse(_weightCtrl.text.trim()),
        'gender': _gender, // 'male' or 'female'
      };

      final res = await _dio.post('/api/user/register', data: body);

      // 성공 (200 OK 또는 201 Created)
      if (res.statusCode == 200 || res.statusCode == 201) {
        _toast('회원가입이 완료되었습니다.');
        if (mounted) Navigator.pop(context, true); // 이전 화면(로그인 등)으로 성공값 전달
        return;
      }

      // 예상치 못한 코드
      _toast('알 수 없는 응답: ${res.statusCode}');
    } on DioException catch (e) {
      final code = e.response?.statusCode;

      // 서버에서 상태코드 운영 권장안:
      // 201 Created: 가입 성공
      // 400 Bad Request: 폼 검증 실패(숫자/필수값 등)
      // 409 Conflict: 중복 ID
      // 422 Unprocessable Entity: 비즈니스 규칙 위반(형식은 맞는데 정책 위배)
      // 500 Internal Server Error: 서버 에러
      switch (code) {
        case 400:
          _toast('입력값을 확인해주세요. (400)');
          break;
        case 409:
          _toast('이미 존재하는 ID입니다. (409)');
          break;
        case 422:
          _toast('요청 형식은 맞지만 처리할 수 없습니다. (422)');
          break;
        case 500:
          _toast('서버 오류가 발생했습니다. (500)');
          break;
        default:
          _toast('네트워크/요청 오류가 발생했습니다. (${code ?? e.type})');
      }
    } catch (e) {
      _toast('예상치 못한 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? '필수 입력입니다.' : null;

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '필수 입력입니다.';
    final t = v.trim();
    // 소수 허용(앞/뒤 0 허용)
    final ok = RegExp(r'^\d+(\.\d+)?$').hasMatch(t);
    if (!ok) return '숫자만 입력(소수점 허용)';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID',
                  hintText: '원하는 아이디를 입력',
                ),
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pwCtrl,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightCtrl,
                decoration: const InputDecoration(
                  labelText: '키 (cm)',
                  hintText: '예: 175.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                validator: _numberValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightCtrl,
                decoration: const InputDecoration(
                  labelText: '몸무게 (kg)',
                  hintText: '예: 65.2',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                validator: _numberValidator,
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: '성별',
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _gender,
                    hint: const Text('선택'),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('남')),
                      DropdownMenuItem(value: 'F', child: Text('여')),
                    ],
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _isLoading ? null : _signup,
                  child: _isLoading
                      ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}