import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({
    super.key,
    required this.uid,
    this.userImage,
  });

  final int? uid;
  final File? userImage;

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
    try {
      final formData = FormData.fromMap({
        'uid': widget.uid,
        'image': await MultipartFile.fromFile(_previewImage!.path),
      });

      final response = await dio.post(
        'http://<서버주소>/api/food/analyze', // TODO: 실제 서버 주소로 교체
        data: formData,
      );

      if (response.statusCode == 200 && response.data is Map && response.data['foodName'] != null) {
        setState(() {
          _foodNameCtrl.text = response.data['foodName'] as String? ?? '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음식명이 자동 입력되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('분석 결과를 불러오지 못했습니다.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석 중 오류가 발생했습니다.')),
      );
    }
  }

  // ✅ 3) 음식명으로 성분분석 → 칼/탄/단/지 자동입력 (Dio 뼈대)
  Future<void> _analyzeByNameAndFillMacros() async {
    final name = _foodNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('음식명을 먼저 입력하세요.')),
      );
      return;
    }

    final dio = Dio();
    try {
      final response = await dio.post(
        'http://<서버주소>/api/food/ingredients', // TODO: 실제 서버 주소로 교체
        data: {
          'uid': widget.uid,
          'foodName': name,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        setState(() {
          // 서버 응답 키는 추후 실제 포맷에 맞춰 교체
          _kcalCtrl.text    = '${data['calories'] ?? ''}';
          _carbCtrl.text    = '${data['carbohydrates'] ?? ''}';
          _proteinCtrl.text = '${data['protein'] ?? ''}';
          _fatCtrl.text     = '${data['fat'] ?? ''}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성분이 자동 입력되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('성분 분석 결과를 불러오지 못했습니다.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성분 분석 중 오류가 발생했습니다.')),
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
                onPressed: () {
                  // 기존 업로드 로직 그대로 유지
                },
                child: const Text('업로드'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
