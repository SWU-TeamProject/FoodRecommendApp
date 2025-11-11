import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _gender = '남'; // 기본값

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // 서버로 전송하거나 다음 단계로 이동
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 완료 (임시 메시지)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // ID 입력칸
                TextFormField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: '아이디',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '아이디를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력칸
                TextFormField(
                  controller: _pwController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 키 입력칸
                TextFormField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ], // ✅ 소수점 허용 (최대 소수 둘째 자리)
                  decoration: const InputDecoration(
                    labelText: '키 (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '키를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 몸무게 입력칸
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ], // ✅ 소수점 허용 (최대 소수 둘째 자리)
                  decoration: const InputDecoration(
                    labelText: '몸무게 (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '몸무게를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 성별 선택칸
                Row(
                  children: [
                    const Text('성별:'),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: '남',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() => _gender = value!);
                            },
                          ),
                          const Text('남'),
                          Radio<String>(
                            value: '여',
                            groupValue: _gender,
                            onChanged: (value) {
                              setState(() => _gender = value!);
                            },
                          ),
                          const Text('여'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 제출 버튼
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('회원가입 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
