import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.userImage});
  final File? userImage;

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // 입력 컨트롤러
  final TextEditingController _foodNameCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _carbCtrl = TextEditingController();
  final TextEditingController _proteinCtrl = TextEditingController();
  final TextEditingController _fatCtrl = TextEditingController();

  File? _selectedImage;
  bool _isAnalyzingAI = false;
  bool _isUploading = false;

  // 소수점 이하 2자리까지만 허용
  final List<TextInputFormatter> _numFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
  ];

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.userImage;
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
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 선택 중 오류: $e')),
      );
    }
  }

  Future<void> _analyzeByAI() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 사진을 선택해주세요.')),
      );
      return;
    }
    setState(() => _isAnalyzingAI = true);
    try {
      // TODO: 백엔드로 사진 분석 요청 (Multipart POST)
      await Future.delayed(const Duration(milliseconds: 600)); // 데모 지연
      final fake = {
        'foodName': '불고기덮밥',
        'kcal': '650.5',
        'carb': '85.2',
        'protein': '24.8',
        'fat': '18.0',
      };
      _foodNameCtrl.text = fake['foodName'] ?? '';
      _kcalCtrl.text = fake['kcal'] ?? '';
      _carbCtrl.text = fake['carb'] ?? '';
      _proteinCtrl.text = fake['protein'] ?? '';
      _fatCtrl.text = fake['fat'] ?? '';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('AI 분석 오류: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAnalyzingAI = false);
    }
  }

  Future<void> _uploadToBackend() async {
    setState(() => _isUploading = true);
    try {
      // TODO: 입력값 업로드 API (사진 분석과 별개, 최종 등록)
      await Future.delayed(const Duration(milliseconds: 600)); // 데모 지연
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업로드 완료')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 하단 업로드 버튼은 항상 보이게 두고, 본문은 ListView로 단순 구성
    return Scaffold(
      appBar: AppBar(title: const Text('음식 업로드')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isUploading || _isAnalyzingAI) ? null : _uploadToBackend,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isUploading
                  ? const SizedBox(
                  width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('업로드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            // 1) 상단: 사진 업로드/제거
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isAnalyzingAI ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('사진 업로드'),
                ),
                if (_selectedImage != null)
                  TextButton.icon(
                    onPressed: _isAnalyzingAI ? null : () => setState(() => _selectedImage = null),
                    icon: const Icon(Icons.close),
                    label: const Text('사진 제거'),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 미리보기
            Container(
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: (_selectedImage == null)
                  ? Center(child: Text('선택된 사진이 없습니다', style: TextStyle(color: Colors.grey[600])))
                  : Image.file(_selectedImage!, fit: BoxFit.cover),
            ),

            // 2) AI로 음식&칼로리 알아보기
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _isAnalyzingAI ? null : _analyzeByAI,
                icon: _isAnalyzingAI
                    ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome),
                label: const Text('AI로 음식&칼로리 알아보기'),
              ),
            ),

            const SizedBox(height: 20),

            // 3) 입력칸들
            _LabeledField(
              label: '음식명',
              controller: _foodNameCtrl,
              hintText: '예) 불고기덮밥',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: '칼로리 (kcal)',
              controller: _kcalCtrl,
              hintText: '예) 650.5',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _numFormatters,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: '탄수화물 (g)',
              controller: _carbCtrl,
              hintText: '예) 85.2',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _numFormatters,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: '단백질 (g)',
              controller: _proteinCtrl,
              hintText: '예) 24.8',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _numFormatters,
            ),
            const SizedBox(height: 12),
            _LabeledField(
              label: '지방 (g)',
              controller: _fatCtrl,
              hintText: '예) 18.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _numFormatters,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
