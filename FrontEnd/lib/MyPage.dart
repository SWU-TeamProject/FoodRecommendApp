import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'style.dart'; // 프로젝트 공통 스타일을 쓰면 여기를 활성화하세요.

class MyPage extends StatefulWidget {
  const MyPage({super.key, this.uid});
  final int? uid;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _passwordCtrl = TextEditingController(); // 비번 변경: 항상 빈 칸
  final TextEditingController _heightCtrl   = TextEditingController(); // cm
  final TextEditingController _weightCtrl   = TextEditingController(); // kg

  // 성별: '남' 또는 '여'
  String? _gender; // 프리필 대상

  // 로딩 상태
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 진입 시 백엔드에서 프리필
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  /// TODO: 백엔드 연동 지점
  /// 실제로는 dio/http 등으로 사용자 프로필을 받아와서 아래 필드를 채우세요.
  Future<void> _loadProfile() async {
    try {
      // --- 샘플 더미 데이터 (백엔드 연동 시 제거) ---
      await Future.delayed(const Duration(milliseconds: 300));
      final double fetchedHeight = 176.3; // cm
      final double fetchedWeight = 71.5;  // kg
      final String fetchedGender = '남';   // '남' 또는 '여'
      // ---------------------------------------

      // 비밀번호 칸은 항상 비어있게 유지
      _passwordCtrl.text = '';

      // 프리필 적용
      _heightCtrl.text = fetchedHeight.toString();
      _weightCtrl.text = fetchedWeight.toString();
      _gender = fetchedGender;
    } catch (e) {
      // 에러 처리(스낵바/다이얼로그 등)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 정보를 불러오지 못했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // 숫자 파싱 유틸
  double? _parseDouble(String s) {
    try {
      return double.parse(s);
    } catch (_) {
      return null;
    }
  }

  // 저장 버튼 탭 처리
  Future<void> _onSave() async {
    // 유효성 검사
    if (!_formKey.currentState!.validate()) return;

    final String newPassword = _passwordCtrl.text.trim(); // 빈 문자열이면 미변경
    final double? height = _parseDouble(_heightCtrl.text.trim());
    final double? weight = _parseDouble(_weightCtrl.text.trim());
    final String? gender = _gender;

    // TODO: 백엔드 호출
    // - newPassword가 빈 문자열이면 비번 미변경 분기
    // - height/weight/gender는 항상 프로필 업데이트 대상
    //
    // 예시 (의사코드):
    // final body = {
    //   if (newPassword.isNotEmpty) 'newPassword': newPassword,
    //   'height': height,
    //   'weight': weight,
    //   'gender': gender, // '남' | '여'
    // };
    // final res = await dio.put('/api/user/profile', data: body);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 비밀번호 변경
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호 변경',
                    hintText: '새 비밀번호(미입력 시 변경 없음)',
                    border: OutlineInputBorder(),
                  ),
                  // 비밀번호는 선택 입력: 유효성 검사 (있을 때만)
                  validator: (v) {
                    if (v == null || v.isEmpty) return null; // 미변경
                    if (v.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 키 (cm)
                TextFormField(
                  controller: _heightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: '키 (cm)',
                    hintText: '예: 175.0',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final d = _parseDouble(v?.trim() ?? '');
                    if (d == null) return '숫자를 입력하세요.';
                    if (d < 100 || d > 250) return '키는 100–250cm 범위로 입력하세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 몸무게 (kg)
                TextFormField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: '몸무게 (kg)',
                    hintText: '예: 70.0',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final d = _parseDouble(v?.trim() ?? '');
                    if (d == null) return '숫자를 입력하세요.';
                    if (d < 30 || d > 300) return '몸무게는 30–300kg 범위로 입력하세요.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 성별 선택
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: '성별',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: '남', child: Text('남')),
                    DropdownMenuItem(value: '여', child: Text('여')),
                  ],
                  onChanged: (val) => setState(() => _gender = val),
                  validator: (v) => v == null ? '성별을 선택하세요.' : null,
                ),
                const SizedBox(height: 24),

                // 저장 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSave,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
