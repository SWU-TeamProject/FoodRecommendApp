import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class RecommendDialog extends StatelessWidget {
  const RecommendDialog({super.key, this.uid, this.date});
  final int? uid;
  final DateTime? date;

  // 필요 시 수정: 서버 베이스 주소
  static const String _baseUrl = 'http://localhost:8080';

  Future<String> _fetchRecommend() async {
    if (uid == null || date == null) {
      return '추천을 불러올 수 없습니다. (uid 또는 date가 없습니다)';
    }

    final dio = Dio();
    final String ymd = date!.toIso8601String().split('T').first; // YYYY-MM-DD
    final String url = '$_baseUrl/api/diet/${uid!}/recommend';

    try {
      final res = await dio.post(url, queryParameters: {'date': ymd});
      if (res.statusCode == 200) {
        final data = res.data;
        // 백엔드 리턴이 문자열이라고 했으므로 그대로 반환
        if (data is String) return data;
        // 혹시 모를 경우 대비
        return data?.toString() ?? '응답이 비어있습니다.';
      } else {
        return '추천을 불러올 수 없습니다. (HTTP ${res.statusCode})';
      }
    } catch (e) {
      return '추천을 불러오는 중 오류가 발생했습니다.\n$e';
    }
  }

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
      content: FutureBuilder<String>(
        future: _fetchRecommend(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final text = snapshot.data ?? '결과가 없습니다.';
          return SingleChildScrollView(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          );
        },
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
