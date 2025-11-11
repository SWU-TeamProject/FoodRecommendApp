import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

class UploadPage extends StatefulWidget {
  const UploadPage({
    super.key,
    required this.uid,
    this.userImage,
    this.time,
    this.date,
  });

  final int? uid;
  final File? userImage;
  final String? time;
  final DateTime? date;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TextEditingController _foodNameCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _carbCtrl = TextEditingController();
  final TextEditingController _proteinCtrl = TextEditingController();
  final TextEditingController _fatCtrl = TextEditingController();

  File? _previewImage;

  @override
  void initState() {
    super.initState();
    _previewImage = widget.userImage;
  }

  @override
  void dispose() {
    _foodNameCtrl.dispose();
    _kcalCtrl.dispose();
    _carbCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _previewImage = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다.')),
      );
    }
  }

  // ✅ 2) 사진으로 음식분석 → 음식명만 자동입력 (Dio 뼈대)
  Future<void> _analyzeImageAndFillName() async {
    if (_previewImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 먼저 선택해주세요.')),
      );
      return;
    }

    final dio = Dio();

    dio.interceptors.add(LogInterceptor(
      request: true, requestBody: true, requestHeader: true,
      responseHeader: true, responseBody: true,
    ));

    try {
      // form-data: file 파트만 전송
      final path = _previewImage!.path;
      final filename = p.basename(path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _previewImage!.path,
          filename: _previewImage!.path.split('/').last,
        ),
      });

      // 주소: /api/{uid}/  (예: http://localhost:8080/api/123/)
      final response = await dio.post(
        'http://localhost:8080/api/diet/${widget.uid}/analyze-image',
        data: formData,
        options: Options(validateStatus: (s)=> true),
      );

      // 성공 시: 서버 응답에서 음식명 추출 → 입력칸에 채움
      if (response.statusCode == 200) {
        final body = response.data?.toString() ?? '';
        // "예측 음식: " 접두사 제거
        final parsed = body.replaceFirst(RegExp(r'^예측 음식:\s*'), '').trim();

        if (parsed.isNotEmpty && parsed != '음식을 추정할 수 없습니다.') {
          setState(() => _foodNameCtrl.text = parsed);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('음식명이 자동 입력되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석은 성공했지만 음식명을 찾지 못했습니다.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('분석 실패: ${response.statusCode} / ${response.data}')),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크/요청 오류: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예상치 못한 오류: $e')),
      );
    }
  }

  // ✅ 3) 음식명으로 성분분석 → 칼/탄/단/지 자동입력 (Dio 뼈대)
  Future<void> _analyzeByNameAndFillMacros() async {
    final foodName = _foodNameCtrl.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음식명을 입력하세요.')),
      );
      return;
    }

    try {
      final dio = Dio();
      final res = await dio.post(
        'http://localhost:8080/api/diet/${widget.uid}/analyze',
        data: {'food': foodName},
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      print(res.data);
      if (res.statusCode == 200) {
        Map<String, dynamic>? data;
        final body = res.data;

        if (body is Map) {
          data = body.cast<String, dynamic>();
        } else if (body is String && body.trim().isNotEmpty) {
          data = jsonDecode(body) as Map<String, dynamic>;
        } else if (body is List<int>) {
          data = jsonDecode(utf8.decode(body)) as Map<String, dynamic>;
        }

        if (data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('분석 실패: 응답 파싱 오류')),
          );
          return;
        }

        final map = data!;

        double _numVal(dynamic v) {
          if (v == null) return double.nan;
          if (v is num) return v.toDouble();
          final s = v.toString();
          final m = RegExp(r'[-+]?\d*\.?\d+').firstMatch(s); // "300 kcal" → 300
          return (m == null) ? double.nan : double.parse(m.group(0)!);
        }
        String _fmt2(double x) => x.isNaN ? '' : x.toStringAsFixed(2);

        setState(() {
          _kcalCtrl.text    = _fmt2(_numVal(map['calories']));
          _carbCtrl.text    = _fmt2(_numVal(map['carbohydrates']));
          _proteinCtrl.text = _fmt2(_numVal(map['protein']));
          _fatCtrl.text     = _fmt2(_numVal(map['fat']));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석 결과를 채웠습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('분석 실패: ${res.statusCode}')),
        );
      }
    } catch (e) { // ✅ 누락됐던 catch 추가
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 중 오류가 발생했습니다: $e')),
      );
    } // ✅ try-catch 닫기
  } // ✅ 함수 닫기

 // 업로드 함수
  Future<void> _uploadFood() async {
    final uid  = widget.uid;
    final time = widget.time;
    final date = widget.date ?? DateTime.now();

    if (uid == null || time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('uid 또는 time 값이 없습니다.')),
      );
      return;
    }

    final foodName = _foodNameCtrl.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식품명을 입력하세요.')),
      );
      return;
    }

    // yyyy-MM-dd 형식으로 간단 포맷
    String two(int n) => n.toString().padLeft(2, '0');
    final dateStr = '${date.year}-${two(date.month)}-${two(date.day)}';

    // 숫자 파싱 (비어있으면 0으로)
    double _p(String s) => double.tryParse(s.trim()) ?? 0.0;

    try {
      final dio = Dio(BaseOptions(
        // ✅ 서버가 텍스트/빈 응답을 줘도 파싱 에러 나지 않게
        responseType: ResponseType.plain,
        // 4xx/5xx도 예외 던지지 않게 (우리가 상태코드로 판단)
        validateStatus: (_) => true,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': '*/*', // JSON 강제 안 함
        },
      ));

      final res = await dio.post(
        'http://localhost:8080/api/diet/$uid/eatfood',
        queryParameters: {'date': dateStr, 'time': time},
        data: {
          'food_name': foodName,
          'kcal': _p(_kcalCtrl.text),
          'protein': _p(_proteinCtrl.text),
          'fat': _p(_fatCtrl.text),
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      print(res.data);
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('업로드가 완료되었습니다.')),
        );
        // 메인페이지로 복귀(이 화면을 푸시한 곳으로 돌아감). 결과 true 전달
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(true);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final decimalInputFormatter = FilteringTextInputFormatter.allow(
      RegExp(r'^\d*\.?\d{0,2}$'),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1) 사진입력 버튼 + (선택 시) 임시 미리보기
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('사진 선택'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _previewImage == null ? '선택된 이미지 없음' : '이미지가 선택되었습니다.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_previewImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_previewImage!, height: 200, fit: BoxFit.cover),
                ),

              const SizedBox(height: 16),

              // 2) 사진으로 음식분석 버튼 (음식명만 자동입력)
              ElevatedButton(
                onPressed: _analyzeImageAndFillName,
                child: const Text('사진으로 음식분석'),
              ),

              const SizedBox(height: 16),

              // 3) 음식명 입력칸 + 옆에 성분분석 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _foodNameCtrl,
                      decoration: const InputDecoration(
                        labelText: '음식명',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _analyzeByNameAndFillMacros,
                    child: const Text('성분분석'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4~7) 칼/탄/단/지 입력칸 (그대로 유지)
              TextField(
                controller: _kcalCtrl,
                decoration: const InputDecoration(
                  labelText: '칼로리 (kcal)',
                  border: OutlineInputBorder(),
                ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [decimalInputFormatter],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _carbCtrl,
                decoration: const InputDecoration(
                  labelText: '탄수화물 (g)',
                  border: OutlineInputBorder(),
                ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [decimalInputFormatter],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _proteinCtrl,
                decoration: const InputDecoration(
                  labelText: '단백질 (g)',
                  border: OutlineInputBorder(),
                ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [decimalInputFormatter],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fatCtrl,
                decoration: const InputDecoration(
                  labelText: '지방 (g)',
                  border: OutlineInputBorder(),
                ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [decimalInputFormatter],
              ),

              const SizedBox(height: 16),

              // 8) 업로드 버튼 (기존 로직 유지)
              ElevatedButton(
                onPressed: _uploadFood,
                child: const Text('업로드'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
