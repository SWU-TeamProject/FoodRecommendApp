import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key, this.userImage});
  final File? userImage; // 타입 명시 및 null 허용

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  // 입력값 상태 (기존 content -> 음식명으로 매핑)
  final TextEditingController _foodNameCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  final TextEditingController _carbCtrl = TextEditingController();
  final TextEditingController _proteinCtrl = TextEditingController();
  final TextEditingController _fatCtrl = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    _image = widget.userImage;
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

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _showPickSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                await _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                Navigator.pop(context);
                await _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showPickSheet,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: _image != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      )
                          : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_upload, size: 48),
                            SizedBox(height: 8),
                            Text('사진 업로드 (탭하기)'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 음식명
                  TextField(
                    controller: _foodNameCtrl,
                    decoration: const InputDecoration(
                      labelText: '음식명',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 칼로리 / 탄수 / 단백 / 지방 입력 카드
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        _InfoField(label: '칼로리 (kcal)', controller: _kcalCtrl, keyboard: TextInputType.number),
                        const SizedBox(height: 8),
                        _InfoField(label: '탄수화물 (g)', controller: _carbCtrl, keyboard: TextInputType.number),
                        const SizedBox(height: 8),
                        _InfoField(label: '단백질 (g)', controller: _proteinCtrl, keyboard: TextInputType.number),
                        const SizedBox(height: 8),
                        _InfoField(label: '지방 (g)', controller: _fatCtrl, keyboard: TextInputType.number),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 버튼 2개: AI 계산 / 직접 입력
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: AI로 칼로리 계산
                          },
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('AI로 음식&칼로리 알아보기'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: 직접 입력 확정/저장
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('직접 입력'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 업로드 버튼 (원래 있던 버튼 유지)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: 서버 업로드 로직
                        // _image(파일)와 입력값(_foodNameCtrl 등) 사용
                      },
                      child: const Text('업로드'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 라벨 + TextField 한 줄
class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    this.keyboard,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 라벨
        SizedBox(
          width: 110, // 고정폭으로 표처럼 정렬
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        // 입력창
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
