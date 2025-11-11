import 'package:flutter/material.dart';

class RecommendDialog extends StatelessWidget {
  const RecommendDialog({super.key, this.uid});
  final int? uid;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "AI 영양 분석가의 추천 식단",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text( // 받아온 데이터 표시 필요
        "닭가슴갈 구이 150g\n고구마 100g\n샐러드(토마토,양상추,올리브 오일 드레싱)\n\n칼로리: 580kacl\n탄수화물: 75g\n단백질: 38g\n지방: 15g",
        style: TextStyle(fontSize: 16, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
